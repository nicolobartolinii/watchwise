//
//  FirestoreService.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 31/08/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFunctions
import Alamofire

class FirestoreService {
    let db = Firestore.firestore()
    let functions = Functions.functions()
    
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
    
    // Metodo per aggiungere una serie TV alla collection episodes
    func addShowToEpisodesCollection(userId: String, showId: Int64) async throws {
        let docRef = db.collection("users").document(userId).collection("episodes").document(String(showId))
        
        // Verifica se il documento esiste e ha già il campo "status" impostato su "watching"
        let docSnapshot = try await docRef.getDocument()
        if let data = docSnapshot.data(), let status = data["status"] as? String, status == "watching" {
            // Se il documento esiste già e ha il campo "status" impostato su "watching", non fare nulla
            return
        } else {
            // Altrimenti, imposta il campo "status" su "watching"
            try await docRef.setData(["status": "watching"], mergeFields: ["status"])
        }
    }
    
    func removeShowFromEpisodesCollection(userId: String, showId: Int64) async throws {
        let docRef = db.collection("users").document(userId).collection("episodes").document(String(showId))
        
        // Verifica se il documento esiste e ha già il campo "status" impostato su "stopped"
        let docSnapshot = try await docRef.getDocument()
        if let data = docSnapshot.data(), let status = data["status"] as? String, status == "stopped" {
            // Se il documento esiste già e ha il campo "status" impostato su "stopped", non fare nulla
            return
        } else {
            // Altrimenti, imposta il campo "status" su "stopped"
            try await docRef.setData(["status": "stopped"], mergeFields: ["status"])
        }
    }
    
    func addEpisodeToWatchedList(userId: String, showId: Int64, seasonNumber: Int, episodeNumber: Int) async throws {
        let docRef = db.collection("users").document(userId).collection("episodes").document(String(showId))
        
        // Recupera i dati esistenti
        let docSnapshot = try await docRef.getDocument()
        if let data = docSnapshot.data() {
            var updatedData = data
            if var episodes = updatedData["\(seasonNumber)"] as? [Int] {
                if !episodes.contains(episodeNumber) {
                    episodes.append(episodeNumber)
                }
                updatedData["\(seasonNumber)"] = episodes
            } else {
                updatedData["\(seasonNumber)"] = [episodeNumber]
            }
            try await docRef.updateData(updatedData)
        }
    }
    
    func removeEpisodeFromWatchedList(userId: String, showId: Int64, seasonNumber: Int, episodeNumber: Int) async throws {
        let docRef = db.collection("users").document(userId).collection("episodes").document(String(showId))
        
        // Recupera i dati esistenti
        let docSnapshot = try await docRef.getDocument()
        if let data = docSnapshot.data() {
            var updatedData = data
            if var episodes = updatedData["\(seasonNumber)"] as? [Int], let index = episodes.firstIndex(of: episodeNumber) {
                episodes.remove(at: index)
                updatedData["\(seasonNumber)"] = episodes
                try await docRef.updateData(updatedData)
            }
        }
    }
    
    func updateSeasonInWatchedList(userId: String, showId: Int64, seasonNumber: Int, episodesToAdd: [Int]) async throws {
        let docRef = db.collection("users").document(userId).collection("episodes").document(String(showId))
        
        // Recupera i dati esistenti
        let docSnapshot = try await docRef.getDocument()
        if let data = docSnapshot.data() {
            var updatedData = data
            if var existingEpisodes = updatedData["\(seasonNumber)"] as? [Int] {
                for episode in episodesToAdd {
                    if !existingEpisodes.contains(episode) {
                        existingEpisodes.append(episode)
                    }
                }
                updatedData["\(seasonNumber)"] = existingEpisodes
            } else {
                updatedData["\(seasonNumber)"] = episodesToAdd
            }
            try await docRef.updateData(updatedData)
        }
    }
    
    func removeSeasonFromWatchedList(userId: String, showId: Int64, seasonNumber: Int) async throws {
        let docRef = db.collection("users").document(userId).collection("episodes").document(String(showId))
        
        // Recupera i dati esistenti
        let docSnapshot = try await docRef.getDocument()
        if let data = docSnapshot.data(), data.keys.contains("\(seasonNumber)") {
            try await docRef.updateData(["\(seasonNumber)": []])
        }
    }
    
    func getWatchedEpisodes(userId: String, showId: Int64) async throws -> [Int: [Int]] {
        let docRef = db.collection("users").document(userId).collection("episodes").document(String(showId))
        let docSnapshot = try await docRef.getDocument()
        
        if let data = docSnapshot.data() {
            var watchedEpisodes: [Int: [Int]] = [:]
            for (key, value) in data {
                if let seasonNumber = Int(key), let episodes = value as? [Int], key != "status" {
                    watchedEpisodes[seasonNumber] = episodes
                }
            }
            return watchedEpisodes
        } else {
            return [:]
        }
    }
    
    func getWatchingShows(userId: String) async throws -> [String: [String: [Int]]?] {
        let docRef = db.collection("users").document(userId).collection("episodes")
        let docSnapshot = try await docRef.getDocuments()
        
        var watchingSeries: [String: [String: [Int]]] = [:]
        
        for document in docSnapshot.documents {
            let seriesId = document.documentID
            let seriesData = document.data() as [String: Any]
            if let status = seriesData["status"] as? String, status == "watching" {
                var seasonData: [String: [Int]] = [:]
                for (key, value) in seriesData {
                    if let seasonEpisodes = value as? [Int], let seasonNumber = Int(key) {
                        seasonData["\(seasonNumber)"] = seasonEpisodes
                    }
                }
                watchingSeries[seriesId] = seasonData
            }
        }
        return watchingSeries
    }
    
    func addSeasonToWatchingShow(userId: String, showId: Int64, seasonNumber: Int32) async throws {
        let docRef = db.collection("users").document(userId).collection("episodes").document(String(showId))
        
        let initialSeasonData: [Int32] = []
        try await docRef.updateData([String(seasonNumber): initialSeasonData])
    }
    
    func updateUserData(userId: String, field: String, value: Any) async throws {
        let docRef = db.collection("users").document(userId)
        try await docRef.updateData([field: value])
    }
    
    func incrementUserField(userId: String, type: String, number: Int) async throws {
        let docRef = db.collection("users").document(userId)
        let increment = FieldValue.increment(Int64(number))
        try await docRef.updateData([type: increment])
    }
    
    func followUser(currentUserUid: String, targetUserUid: String) async throws {
        let timestamp = Timestamp(date: Date())
        
        // Aggiungi targetUserId alla lista "following" dell'utente corrente
        let followingDocRef = db.collection("users").document(currentUserUid).collection("following").document(targetUserUid)
        try await followingDocRef.setData(["timestamp": timestamp])
        
        // Aggiungi currentUserId alla lista "followers" dell'utente target
        let followersDocRef = db.collection("users").document(targetUserUid).collection("followers").document(currentUserUid)
        try await followersDocRef.setData(["timestamp": timestamp])
    }
    
    func unfollowUser(currentUserUid: String, targetUserUid: String) async throws {
        // Rimuovi targetUserId dalla lista "following" dell'utente corrente
        let followingDocRef = db.collection("users").document(currentUserUid).collection("following").document(targetUserUid)
        try await followingDocRef.delete()
        
        // Rimuovi currentUserId dalla lista "followers" dell'utente target
        let followersDocRef = db.collection("users").document(targetUserUid).collection("followers").document(currentUserUid)
        try await followersDocRef.delete()
    }
    
    func isUserFollowing(currentUserUid: String, targetUserUid: String) async throws -> Bool {
        let followingDocRef = db.collection("users").document(currentUserUid).collection("following").document(targetUserUid)
        let docSnapshot = try await followingDocRef.getDocument()
        return docSnapshot.exists
    }
    
    func getUserRatings(userId: String) async throws -> [CGFloat] {
        var ratings: [CGFloat] = []
        
        let ratingsIndexDoc = try await db.collection("metadata").document("ratingsIndex").getDocument()
        let movieIds = ratingsIndexDoc.get("movies") as? [String] ?? []
        let tvIds = ratingsIndexDoc.get("tv") as? [String] ?? []
        
        for movieId in movieIds {
            let ratingDoc = try await db.collection("ratings").document("movies").collection(movieId).document(userId).getDocument()
            if let value = ratingDoc.get("value") as? CGFloat {
                ratings.append(value)
            }
        }
        
        for tvId in tvIds {
            let ratingDoc = try await db.collection("ratings").document("tv").collection(tvId).document(userId).getDocument()
            if let value = ratingDoc.get("value") as? CGFloat {
                ratings.append(value)
            }
        }
        
        return ratings
    }
    
    func getUserReviews(userId: String) async throws -> [AltReview] {
        var reviews: [AltReview] = []
        
        let reviewsIndexDoc = try await db.collection("metadata").document("reviewsIndex").getDocument()
        let movieIds = reviewsIndexDoc.get("movies") as? [String] ?? []
        let showIds = reviewsIndexDoc.get("tv") as? [String] ?? []
        
        for movieId in movieIds {
            let reviewDoc = try await db.collection("reviews").document("movies").collection(movieId).document(userId).getDocument()
            if let text = reviewDoc.get("text") as? String, let timestamp = reviewDoc.get("timestamp") as? Timestamp {
                let posterPath = try await fetchPosterPath(productId: Int64(movieId)!, type: "movie")
                reviews.append(AltReview(productId: Int64(movieId)!, type: "movie", text: text, timestamp: timestamp, posterPath: posterPath))
            }
        }
        
        for showId in showIds {
            let reviewDoc = try await db.collection("reviews").document("tv").collection(showId).document(userId).getDocument()
            if let text = reviewDoc.get("text") as? String, let timestamp = reviewDoc.get("timestamp") as? Timestamp {
                let posterPath = try await fetchPosterPath(productId: Int64(showId)!, type: "tv")
                reviews.append(AltReview(productId: Int64(showId)!, type: "tv", text: text, timestamp: timestamp, posterPath: posterPath))
            }
        }
        
        // Ordina le recensioni in base al timestamp
        reviews.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
        
        return reviews
    }
    
    func getUserRawLists(userId: String) async throws -> [(type: String, name: String, totalCount: Int, listId: String)] {
        var lists: [(type: String, name: String, totalCount: Int, listId: String)] = []
        
        let listsCollection = try await db.collection("users").document(userId).collection("lists").getDocuments()
        for listDoc in listsCollection.documents {
            let type = listDoc.get("type") as? String ?? ""
            let name = listDoc.get("name") as? String ?? ""
            let movies = listDoc.get("movies") as? [Int] ?? []
            let tv = listDoc.get("tv") as? [Int] ?? []
            let totalCount = movies.count + tv.count
            let listId = listDoc.documentID
            lists.append((type: type, name: name, totalCount: totalCount, listId: listId))
        }
        
        return lists
    }
    
    func getUserList(userId: String, listId: String) async throws -> (movies: [Int64], shows: [Int64], type: String, name: String)? {
        let listRef = try await db.collection("users").document(userId).collection("lists").document(listId).getDocument()
        if listRef.exists {
            let name = listRef.get("name") as? String ?? ""
            let type = listRef.get("type") as? String ?? ""
            let moviesList = listRef.get("movies") as? [Int64] ?? []
            let showsList = listRef.get("tv") as? [Int64] ?? []
            return (movies: moviesList, shows: showsList, type: type, name: name)
        }
        return nil
    }
    
    struct PosterResponse: Decodable {
        let posterPath: String?
    }
    
    struct PosterRequestParameters: Encodable {
        let id: Int64
        let type: String
    }
    
    func fetchPosterPath(productId: Int64, type: String) async throws -> String? {
        let functionURL = "https://us-central1-watchwise-tesi.cloudfunctions.net/getPosterUrl"
        let parameters = PosterRequestParameters(id: productId, type: type)
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(functionURL, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
                .responseDecodable(of: PosterResponse.self) { response in
                    switch response.result {
                    case .success(let posterResponse):
                        continuation.resume(returning: posterResponse.posterPath)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    func getUserFollowCount(for userId: String, type: String) async throws -> Int {
        guard type == "followers" || type == "following" else {
            throw NSError(domain: "FirestoreService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Tipo non valido"])
        }
        let collection = db.collection("users").document(userId).collection(type)
        let snapshot = try await collection.getDocuments()
        return snapshot.documents.count
    }
    
    func createNewList(for userId: String, listId: String, listName: String, listType: String) async throws {
        let listsRef = db.collection("users").document(userId).collection("lists")
        let newListRef = listsRef.document(listId)
        
        let listData: [String: Any] = [
            "name": listName,
            "type": listType,
        ]
        
        try await newListRef.setData(listData)
    }
}
