//
//  EditProfileViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 11/09/23.
//

import Foundation
import PhotosUI
import FirebaseStorage
import FirebaseAuth

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var displayName: String = ""
    @Published var displayNameError: Bool = false
    @Published var profileImage: UIImage?
    @Published var backdropImage: String
    @Published var showDisplayNameLoadingAlert: Bool = false
    @Published var showDisplayNameCompletedAlert: Bool = false
    @Published var showProfileImageLoadingAlert: Bool = false
    @Published var showProfileImageCompletedAlert: Bool = false
    @Published var showBackdropImageLoadingAlert: Bool = false
    @Published var showBackdropImageCompletedAlert: Bool = false
    
    private var firestoreService: FirestoreService
    var oldDisplayName: String
    
    init(user: User) {
        self.user = user
        self.firestoreService = FirestoreService()
        self.oldDisplayName = user.displayName
        self.displayName = self.oldDisplayName
        self.backdropImage = user.backdropPath
    }
    
    func changeUserField(field: String, value: String) async {
        do {
            try await firestoreService.updateUserData(userId: user.uid, field: field, value: value)
        } catch {
            print("Errore durante l'aggiornamento del campo \(field)")
        }
    }
    
    func changeDisplayName() async {
        if displayName.count < 3 || displayName.count > 30 {
            self.displayNameError = true
            return
        }
        
        showDisplayNameLoadingAlert = true
        await changeUserField(field: "displayName", value: self.displayName)
        self.oldDisplayName = self.displayName
        showDisplayNameLoadingAlert = false
        showDisplayNameCompletedAlert = true
    }
    
    func changeProfileImage() async {
        showProfileImageLoadingAlert = true
        let storageRef = Storage.storage().reference()
        let uid = Auth.auth().currentUser!.uid
        let profileImageStorageRef = storageRef.child("users/propics/\(uid).jpg")
        
        guard let resizedImage = resizeImage(targetSize: 50 * 1024, targetWidth: 500) else {
            print("Error resizing image")
            return
        }
        
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            print("Error converting image to data")
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            _ = try await profileImageStorageRef.putDataAsync(imageData, metadata: metadata)
            try await changeUserField(field: "profilePath", value: profileImageStorageRef.downloadURL().absoluteString)
        } catch {
            print(error)
            return
        }
        showProfileImageLoadingAlert = false
        showProfileImageCompletedAlert = true
    }
    
    func resizeImage(targetSize: Int, targetWidth: CGFloat) -> UIImage? {
        let scale = targetWidth / self.profileImage!.size.width
        let newHeight = self.profileImage!.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: targetWidth, height: newHeight))
        self.profileImage!.draw(in: CGRect(x: 0, y: 0, width: targetWidth, height: newHeight))
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
    
    func changeBackdropImage() async {
        showBackdropImageLoadingAlert = true
        await changeUserField(field: "backdropPath", value: self.backdropImage)
        showBackdropImageLoadingAlert = false
        showBackdropImageCompletedAlert = true
    }
}
