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
    
    func getUserDetails(by uid: String) async throws -> User? {
        let documentReference = db.collection("users").document(uid)
        let documentSnapshot = try await documentReference.getDocument()
        
        if let data = documentSnapshot.data() {
            let user = User(dictionary: data)
            return user
        } else {
            return nil
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
    
    // Metodo per aggiungere o aggiornare una valutazione
    func addOrUpdateRating(productId: Int64, userId: String, ratingValue: CGFloat, type: String) async throws {
        let productRatingsRef = db.collection("ratings").document(type).collection(String(productId))
        let userRatingRef = productRatingsRef.document(userId)
        let ratingData: [String: Any] = [
            "value": ratingValue,
            "timestamp": Timestamp(date: Date())
        ]
        
        try await userRatingRef.setData(ratingData, merge: true)
        try await calculateTotalRating(productRatingsRef: productRatingsRef)
    }
    
    // Metodo per calcolare e settare il rating totale del prodotto
    func calculateTotalRating(productRatingsRef: CollectionReference) async throws {
        let snapshot = try await productRatingsRef.getDocuments()
        
        let documents = snapshot.documents
        
        let ratingsCount = documents.count
        let totalRating = documents.compactMap { $0.data()["value"] as? CGFloat }.reduce(0, +)
        let infoData: [String: Any] = [
            "count": ratingsCount,
            "total": totalRating
        ]
        
        let infoDocumentRef = productRatingsRef.document("info")
        try await infoDocumentRef.setData(infoData, merge: true)
    }
    
    // Metodo per ottenere la valutazione dell'utente corrente
    func getCurrentUserRating(productId: Int64, userId: String, type: String) async throws -> CGFloat? {
        let snapshot = try await db.collection("ratings").document(type).collection(String(productId)).document(userId).getDocument()
        
        return snapshot.data()?["value"] as? CGFloat
    }
    
    // Metodo per ottenere tutte le valutazioni per un film
    func getAllRatings(productId: Int64, type: String) async throws -> [CGFloat] {
        let snapshot = try await db.collection("ratings").document(type).collection(String(productId)).getDocuments()
        
        return snapshot.documents.compactMap { $0.data()["value"] as? CGFloat }
    }
    
    // Metodo per aggiungere o aggiornare una recensione
    func addOrUpdateReview(productId: Int64, userId: String, reviewText: String, type: String) async throws {
        let productReviewsRef = db.collection("reviews").document(type).collection(String(productId))
        let userReviewRef = productReviewsRef.document(userId)
        let reviewData: [String: Any] = [
            "text": reviewText,
            "timestamp": Timestamp(date: Date())
        ]
        
        try await userReviewRef.setData(reviewData, merge: true)
        try await calculateTotalReviews(productReviewsRef: productReviewsRef)
    }
    
    // Metodo per calcolare e settare il numero totale di recensioni
    func calculateTotalReviews(productReviewsRef: CollectionReference) async throws {
        let snapshot = try await productReviewsRef.getDocuments()
        
        let documents = snapshot.documents
        
        let reviewsCount = documents.count < 2 ? 1 : documents.count - 1
        let infoData: [String: Any] = [
            "count": reviewsCount
        ]
        
        let infoDocumentRef = productReviewsRef.document("info")
        try await infoDocumentRef.setData(infoData, merge: true)
    }
    
    // Metodo per ottenere la recensione dell'utente corrente
    func getCurrentUserReview(productId: Int64, userId: String, type: String) async throws -> Review? {
        let snapshot = try await db.collection("reviews").document(type).collection(String(productId)).document(userId).getDocument()
        
        guard let reviewData = snapshot.data(),
              let user = try await getUserDetails(by: userId),
              let text = reviewData["text"] as? String,
              let timestamp = reviewData["timestamp"] as? Timestamp else {
            return nil
        }
        
        let review = Review(user: user, text: text, timestamp: timestamp)
        return review
    }
    
    // Metodo per ottenere tutte le recensioni per un dato prodotto
    func getAllReviews(productId: Int64, type: String) async throws -> [Review] {
        let snapshot = try await db.collection("reviews").document(type).collection(String(productId)).getDocuments()
        var reviews: [Review] = []

        for document in snapshot.documents {
            let reviewData = document.data()
            
            guard let user = try await getUserDetails(by: document.documentID),
                  let text = reviewData["text"] as? String,
                  let timestamp = reviewData["timestamp"] as? Timestamp else {
                continue
            }

            let review = Review(user: user, text: text, timestamp: timestamp)
            reviews.append(review)
        }

        return reviews
    }

    // Metodo per ottenere il numero totale di recensioni per un dato prodotto
    func getReviewsCount(productId: Int64, type: String) async throws -> Int {
        let snapshot = try await db.collection("reviews").document(type).collection(String(productId)).document("info").getDocument()
        
        return snapshot.data()?["count"] as? Int ?? 0
    }
}
