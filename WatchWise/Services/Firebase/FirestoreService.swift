//
//  FirestoreService.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 31/08/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService {
    let db = Firestore.firestore()
    
    func getUserDetails(by uid: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(uid).getDocument { document, error in
            if let user = document.flatMap({
                $0.data().flatMap({ data in
                    return User(dictionary: data)
                })
            }) {
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    func searchUsers(by query: String, currentUserUid: String, completion: @escaping ([User]) -> Void) {
        var users = [User]()
        
        db.collection("users")
            .order(by: "username")
            .start(at: [query])
            .end(at: [query + "\u{f8ff}"])
            .getDocuments { snapshot, error in
                
                guard let documents = snapshot?.documents else {
                    print("Nessun documento trovato")
                    completion([])
                    return
                }
                
                for document in documents {
                    let user = User(dictionary: document.data())
                    if user.uid != currentUserUid {
                        users.append(user)
                    }
                }
                
                completion(users)
            }
    }
    
    func addProductToList(_ productId: Int64, listName: String, userId: String, type: String, completion: @escaping (Error?) -> Void) {
        let usersRef = db.collection("users").document(userId)
        let listsCollectionRef = usersRef.collection("lists")
        let listToAddRef = listsCollectionRef.document(listName)
        
        listToAddRef.updateData([
            type: FieldValue.arrayUnion([productId])
        ]) { error in
            completion(error)
        }
    }
    
    func removeProductFromList(_ productId: Int64, listName: String, userId: String, type: String, completion: @escaping (Error?) -> Void) {
        let usersRef = db.collection("users").document(userId)
        let listsCollectionRef = usersRef.collection("lists")
        let listToRemoveRef = listsCollectionRef.document(listName)
        
        listToRemoveRef.updateData([
            type: FieldValue.arrayRemove([productId])
        ]) { error in
            completion(error)
        }
    }
    
    func isProductInList(_ productId: Int64, listName: String, userId: String, type: String, completion: @escaping (Bool, Error?) -> Void) {
        let usersRef = db.collection("users").document(userId)
        let listsCollectionRef = usersRef.collection("lists")
        let listToCheckRef = listsCollectionRef.document(listName)
        
        listToCheckRef.getDocument { (document, error) in
            if let error = error {
                completion(false, error)
                return
            }
            
            if let data = document?.data(), let productsArray = data[type] as? [Int64], productsArray.contains(productId) {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
}
