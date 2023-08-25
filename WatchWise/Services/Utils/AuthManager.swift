//
//  UserUtils.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 20/08/23.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import PhotosUI
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import GoogleSignInSwift

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
    case openingApp
}

enum AuthenticationFlow {
    case login
    case signUp
}

@MainActor
class AuthManager: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var passwordConfirmation = ""
    @Published var username = ""
    @Published var displayName = ""
    @Published var profileImage: UIImage?
    
    @Published var flow: AuthenticationFlow = .login
    
    @Published var isValid  = false
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorLogin = false
    @Published var errorSignup = false
    @Published var errorSignout = false
    @Published var errorDelete = false
    @Published var shouldNavigate = false
    @Published var user: FirebaseAuth.User?
    
    private var loggingWithGoogle: Bool = false
    
    init() {
        self.authenticationState = .openingApp
        registerAuthStateHandler()
        
        $flow
            .combineLatest($email, $password, $passwordConfirmation)
            .map { flow, email, password, passwordConfirmation in
                flow == .login
                ? !(email.isEmpty || password.isEmpty)
                : !(email.isEmpty || password.isEmpty || passwordConfirmation.isEmpty)
            }
            .assign(to: &$isValid)
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.authenticationState = user == nil || self.loggingWithGoogle ? .unauthenticated : .authenticated
            }
        }
    }
    
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorLogin = false
        errorSignup = false
        errorSignout = false
    }
    
    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("Done")
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func reset() {
        if (flow == .login) {
            email = ""
            password = ""
        } else if (flow == .signUp) {
            if (username != "" || displayName != "") {
                username = ""
                displayName = ""
            } else {
                email = ""
                password = ""
                passwordConfirmation = ""
            }
        }
    }
}

enum AuthenticationError: Error {
  case tokenError(message: String)
}

extension AuthManager {
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            return true
        }
        catch  {
            print(error)
            errorLogin = true
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func signUp() async -> Bool {
        authenticationState = .authenticating
        if (email != "" && password != "") {
            do  {
                try await Auth.auth().createUser(withEmail: email, password: password)
            }
            catch {
                print(error)
                errorSignup = true
                authenticationState = .unauthenticated
                return false
            }
        } else {
            email = Auth.auth().currentUser!.email!
        }
        let storageRef = Storage.storage().reference()
        let uid = Auth.auth().currentUser!.uid
        let profileImageStorageRef = storageRef.child("users/propics/\(uid).jpg")
        
        guard let resizedImage = resizeImage(targetSize: 50 * 1024, targetWidth: 500) else {
            print("Error resizing image")
            return false
        }
        
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            print("Error converting image to data")
            return false
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            let storageMetadata = try await profileImageStorageRef.putDataAsync(imageData, metadata: metadata)
        } catch {
            print(error)
            authenticationState = .unauthenticated
            return false
        }
        
        let db = Firestore.firestore()
        
        let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        do {
            try await userRef.setData([
                "uid": uid,
                "email": email,
                "username": username,
                "displayName": displayName,
                "profilePath": profileImageStorageRef.downloadURL().absoluteString,
                "backdropPath": "",
                "movieMinutes": 0,
                "tvMinutes": 0,
                "movieNumber": 0,
                "tvNumber": 0
            ])
        } catch {
            print(error)
            authenticationState = .unauthenticated
            return false
        }
        
        let listsRef = userRef.collection("lists")
        let episodesRef = userRef.collection("episodes")
        let followRef = userRef.collection("follow")
        let reviewsRef = userRef.collection("reviews")
        let recommendationsRef = userRef.collection("recommendations")
        
        do {
            try await listsRef.document("watched_m").setData([
                "name": NSLocalizedString("Film visti", comment: "Film visti"),
                "type": "movie",
                "movies": []
            ])
            try await listsRef.document("watching_t").setData([
                "name": NSLocalizedString("Serie TV in visione", comment: "Serie TV in visione"),
                "type": "tv",
                "tvShows": []
            ])
            try await listsRef.document("watchlist").setData([
                "name": NSLocalizedString("Watchlist", comment: "Watchlist"),
                "type": "both",
                "movies": [],
                "tvShows": []
            ])
            try await listsRef.document("favorite").setData([
                "name": NSLocalizedString("Preferiti", comment: "Preferiti"),
                "type": "both",
                "movies": [],
                "tvShows": []
            ])
            try await listsRef.document("finished_t").setData([
                "name": NSLocalizedString("Serie TV completate", comment: "Serie TV completate"),
                "type": "tv",
                "tvShows": []
            ])
            try await followRef.document("following").setData([
                "users": [],
                "count": 0
            ])
            try await followRef.document("followers").setData([
                "users": [],
                "count": 0
            ])
            try await reviewsRef.document("movies").setData([
                "count": 0
            ])
            try await reviewsRef.document("tv").setData([
                "count": 0
            ])
        } catch {
            print(error)
            authenticationState = .unauthenticated
            return false
        }
        authenticationState = .authenticated
        email = ""
        password = ""
        username = ""
        displayName = ""
        profileImage = nil
        switchFlow()
        return true
    }
    
    func signInWithGoogle() async -> Bool {
        loggingWithGoogle = true
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID fount in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller!")
            return false
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            let user = userAuthentication.user
            guard let idToken = user.idToken else { throw AuthenticationError.tokenError(message: "ID token missing") }
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)
            
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
            loggingWithGoogle = false
            return true
        }
        catch {
            print(error.localizedDescription)
            loggingWithGoogle = false
            return false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error)
            errorSignout = true
        }
    }
    
    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            return true
        }
        catch {
            errorDelete = true
            return false
        }
    }
    
    func resizeImage(targetSize: Int, targetWidth: CGFloat) -> UIImage? {
        let scale = targetWidth / profileImage!.size.width
        let newHeight = profileImage!.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: targetWidth, height: newHeight))
        profileImage!.draw(in: CGRect(x: 0, y: 0, width: targetWidth, height: newHeight))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let resized = resizedImage else { return nil }
        
        var compression: CGFloat = 0.9
        let maxCompression: CGFloat = 0.1
        var imageData = resized.jpegData(compressionQuality: compression)
        
        while (imageData?.count ?? 0) > targetSize && compression > maxCompression {
            compression -= 0.1
            imageData = resized.jpegData(compressionQuality: compression)
        }
        
        guard let compressedImageData = imageData else { return nil }
        
        return UIImage(data: compressedImageData)
    }
}
