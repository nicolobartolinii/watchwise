//
//  CompleteRegistrationView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 20/08/23.
//

import SwiftUI
import CoreHaptics
import PhotosUI
import FirebaseFirestore

private enum FocusableField: Hashable {
    case username
    case displayName
}

struct CompleteRegistrationView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focus: FocusableField?
    
    @State private var profileImage: PhotosPickerItem? = nil
    @State private var data: Data?
    @State private var usernameError: Bool = false
    @State private var usernameExistsError: Bool = false
    @State private var displayNameError: Bool = false
    @State private var defaultPropicColor: Color = .accentColor
    var subtitle1: Text = Text(NSLocalizedString("Inserisci un ", comment: "Inserisci un "))
    var subtitle2: Text = Text(NSLocalizedString("nome utente", comment: "nome utente"))
        .foregroundColor(.accentColor)
    var subtitle3: Text = Text(NSLocalizedString(", un ", comment: ", un "))
    var subtitle4: Text = Text(NSLocalizedString("nome visualizzato ", comment: "nome visualizzato "))
        .foregroundColor(.accentColor)
    var subtitle5: Text = Text(NSLocalizedString("e, se vuoi, scegli un'", comment: "e, se vuoi, scegli un'"))
    var subtitle6: Text = Text(NSLocalizedString("immagine di profilo", comment: "immagine di profilo"))
        .foregroundColor(.accentColor)
    var subtitle7: Text = Text(NSLocalizedString(" (cambia il colore dell'immagine di default cliccando sul pulsante al suo fianco, altrimenti clicca sull'immagine stessa per scegliere una foto dalla galleria)", comment: " (cambia il colore dell'immagine di default cliccando sul pulsante al suo fianco, altrimenti clicca sull'immagine stessa per scegliere una foto dalla galleria)"))
    private var systemColors: [Color] = [.blue, .green, .yellow, .purple, .cyan, .brown, .gray, .orange, .pink, .indigo, .mint, .teal]
    
    private func signUp() {
        Task {
            if await authManager.signUp() == true {
                dismiss()
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image("logo_title")
                .resizable()
                .scaledToFit()
                .padding(.top)
                .frame(width: UIScreen.main.bounds.width / 2.5)
            
            Text(NSLocalizedString("Registrazione", comment: "Registrazione"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.largeTitle)
                .bold()
            
            Group {
                subtitle1 + subtitle2 + subtitle3 + subtitle4 + subtitle5 + subtitle6 + subtitle7
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            ClearableTextField(hint: "Nome utente", text: $authManager.username, startIcon: "person.text.rectangle", endIcon: "xmark.circle.fill", error: $usernameError, keyboardType: .default, lowercaseText: true)
                .focused($focus, equals: .username)
                .submitLabel(.next)
                .onSubmit {
                    self.focus = .displayName
                }
                
            
            if usernameError {
                Text(NSLocalizedString("Il nome utente deve essere lungo tra 3 e 30 caratteri e può contenere solo lettere minuscole, numeri e i caratteri speciali \".\" e \"_\"", comment: "Inserisci un nome utente valido"))
                    .foregroundColor(.red)
                    .padding(.vertical, -12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.footnote)
            }
            
            if usernameExistsError {
                Text(NSLocalizedString("Nome utente non disponibile", comment: "Nome utente non disponibile"))
                    .foregroundColor(.red)
                    .padding(.vertical, -12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.footnote)
            }
            
            ClearableTextField(hint: "Nome visualizzato", text: $authManager.displayName, startIcon: "person", endIcon: "xmark.circle.fill", error: $displayNameError, keyboardType: .default, autocorrectionDisabled: false)
                .focused($focus, equals: .displayName)
                .submitLabel(.go)
                .onSubmit {
                    focus = nil
                }
            
            
            if displayNameError {
                Text(NSLocalizedString("Il nome visualizzato deve essere lungo tra 3 e 30 caratteri", comment: "Inserisci un nome visualizzato valido"))
                    .foregroundColor(.red)
                    .padding(.vertical, -12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.footnote)
            }
            
            if let data = data, let uiimage = UIImage(data: data) {
                ZStack {
                    PhotosPicker(selection: $profileImage, matching: .images) {
                        Image(uiImage: uiimage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    }.onChange(of: profileImage) { newValue in
                        guard let item = profileImage else {
                            return
                        }
                        item.loadTransferable(type: Data.self) { result in
                            switch result {
                            case .success(let data):
                                if let data = data {
                                    self.data = data
                                    authManager.profileImage = UIImage(data: data)
                                } else {
                                    print ("Data is nil")
                                }
                            case .failure(let failure):
                                fatalError("\(failure)")
                            }
                        }
                    }
                    Button {
                        self.data = nil
                        authManager.profileImage = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .tint(.red)
                    }
                    .offset(x: 125, y: 0)
                }
            } else {
                ZStack {
                    PhotosPicker(selection: $profileImage, matching: .images) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .foregroundStyle(defaultPropicColor)
                    }.onChange(of: profileImage) { newValue in
                        guard let item = profileImage else {
                            return
                        }
                        item.loadTransferable(type: Data.self) { result in
                            switch result {
                            case .success(let data):
                                if let data = data {
                                    self.data = data
                                    authManager.profileImage = UIImage(data: data)
                                } else {
                                    print ("Data is nil")
                                }
                            case .failure(let failure):
                                fatalError("\(failure)")
                            }
                        }
                    }
                    Button {
                        defaultPropicColor = systemColors.randomElement()!
                    } label: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .tint(defaultPropicColor)
                    }
                    .offset(x: 125, y: 0)
                }
            }
            
            Button(action: {
                Task {
                    await completeRegistration()
                }
            }) {
                if authManager.authenticationState != .authenticating {
                    Text(NSLocalizedString("Completa registrazione", comment: "Completa registrazione"))
                        .font(.title3)
                        .bold()
                        .frame(width: UIScreen.main.bounds.width - 100, height: 40)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(authManager.email == "")
    }
    
    func completeRegistration() async {
        usernameError = false
        displayNameError = false
        checkUsername()
            do {
                let usernameExists = try await checkUsernameExists()
                if usernameExists {
                    usernameExistsError = true
                }
            } catch {
                print(error)
                usernameExistsError = true
            }
        checkDisplayName()
        if usernameError || usernameExistsError || displayNameError {
            triggerHapticFeedback()
        } else {
            setupUIImage()
            signUp()
        }
    }
    
    func checkUsername() {
        guard !authManager.username.isEmpty,
              authManager.username.count >= 3,
              authManager.username.count <= 30,
              authManager.username.range(of: "^[a-z0-9._]+$", options: .regularExpression) != nil else {
            usernameError = true
            return
        }
    }
    
    func checkDisplayName() {
        guard !authManager.displayName.isEmpty,
              authManager.displayName.count >= 3,
              authManager.displayName.count <= 30 else {
            displayNameError = true
            return
        }
    }
    
    func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    func setupUIImage() {
        if self.data == nil {
            let currentImage = UIImage(systemName: "person.circle.fill")!.withTintColor(UIColor(defaultPropicColor))
            let newSize = CGSize(width: 300, height: 300)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            currentImage.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            authManager.profileImage = resizedImage
        }
    }
    
    func checkUsernameExists() async throws -> Bool {
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        let querySnapshot = try await usersRef.whereField("username", isEqualTo: authManager.username).getDocuments()
        return !querySnapshot.documents.isEmpty
    }
}

#Preview {
    CompleteRegistrationView()
        .accentColor(.cyan)
}
