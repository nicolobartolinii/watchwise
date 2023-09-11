//
//  MovieDetailsViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 05/09/23.
//

import Foundation
import Combine

@MainActor
class MovieDetailsViewModel: ObservableObject {
    @Published var movie: Movie?
    @Published var similarMovies: [DiscoveredMovie]?
    @Published var isInList: [String: Bool] = [
        "watched_m": false,
        "watchlist": false,
        "favorite": false
    ]
    @Published var currentUserRating: CGFloat = 0.0
    @Published var oldRating: CGFloat = 0.0
    @Published var allRatings: [CGFloat] = []
    @Published var reviewText: String = ""
    @Published var currentUserReview: Review?
    @Published var oldReviewText: String = ""
    @Published var reviewsCount: Int = 0
    @Published var allReviews: [Review] = []
    @Published var rawLists: [(type: String, name: String, totalCount: Int, listId: String)] = []
    
    private var movieId: Int64
    private var currentUserUid: String
    private var repository: MoviesRepository
    private var firestoreService: FirestoreService
    
    init(movieId: Int64, currentUserUid: String) {
        self.movieId = movieId
        self.currentUserUid = currentUserUid
        self.repository = MoviesRepository()
        self.firestoreService = FirestoreService()
        
        checkIfMovieInLists()
        
        Task {
            await fetchCurrentUserRating()
            await fetchAllRatings()
            await fetchCurrentUserReview()
            await fetchReviewsCount()
        }
    }
    
    func getMovieDetails() {
        repository.getMovieDetails(by: movieId) { movie in
            self.movie = movie
        }
    }
    
    func getSimilarMovies() {
        repository.getSimilarMovies(by: movieId) { discoveredMovies in
            self.similarMovies = discoveredMovies?.results as? [DiscoveredMovie]
        }
    }
    
    func toggleMovieToList(listName: String, movieRuntime: Int?) async throws {
        if let isInList = isInList[listName] {
            if isInList {
                firestoreService.removeProductFromList(self.movieId, listName: listName, userId: self.currentUserUid, type: "movies") { error in
                    if let error = error {
                        print("Errore nella rimozione del film \(self.movieId) dalla lista \(listName): \(error)")
                        return
                    }
                    self.isInList[listName] = false
                }
                if listName == "watched_m" {
                    try await firestoreService.incrementUserField(userId: currentUserUid, type: "movieMinutes", number: -(movieRuntime ?? 120))
                    try await firestoreService.incrementUserField(userId: currentUserUid, type: "movieNumber", number: -1)
                }
            } else {
                firestoreService.addProductToList(self.movieId, listName: listName, userId: self.currentUserUid, type: "movies") { error in
                    if let error = error {
                        print("Errore nell'aggiunta del film \(self.movieId) alla lista \(listName): \(error)")
                        return
                    }
                    self.isInList[listName] = true
                }
                if listName == "watched_m" {
                    try await firestoreService.incrementUserField(userId: currentUserUid, type: "movieMinutes", number: movieRuntime ?? 120)
                    try await firestoreService.incrementUserField(userId: currentUserUid, type: "movieNumber", number: 1)
                }
            }
        }
    }
    
    private func checkIfMovieInLists() {
        for (listName, _) in isInList {
            firestoreService.isProductInList(self.movieId, listName: listName, userId: self.currentUserUid, type: "movies") { isInThisList, error in
                if let error = error {
                    print("Errore nel controllo del film \(self.movieId) nella lista \(listName): \(error)")
                    return
                }
                self.isInList[listName] = isInThisList
            }
        }
    }
    
    func fetchCurrentUserRating() async {
        do {
            let rating = try await firestoreService.getCurrentUserRating(productId: movieId, userId: currentUserUid, type: "movies")
            self.currentUserRating = (rating ?? 0.0) / 5
            self.oldRating = self.currentUserRating
        } catch {
            print("Error fetching current user rating: \(error)")
        }
    }
    
    func fetchAllRatings() async {
        do {
            let ratings = try await firestoreService.getAllRatings(productId: movieId, type: "movies")
            self.allRatings = ratings
        } catch {
            print("Error fetching all ratings: \(error)")
        }
    }
    
    func addOrUpdateRating(value: CGFloat) async {
        do {
            try await firestoreService.addOrUpdateRating(productId: movieId, userId: currentUserUid, ratingValue: value, type: "movies")
            self.oldRating = value / 5
            await fetchAllRatings()
        } catch {
            print("Error updating rating: \(error)")
        }
    }
    
    func fetchCurrentUserReview() async {
        do {
            let review = try await firestoreService.getCurrentUserReview(productId: movieId, userId: currentUserUid, type: "movies")
            self.currentUserReview = review
            self.reviewText = review?.text ?? ""
            self.oldReviewText = self.reviewText
        } catch {
            print("Errore nel recupero della recensione: \(error)")
        }
    }
    
    func fetchReviewsCount() async {
        do {
            let reviewCount = try await firestoreService.getReviewsCount(productId: movieId, type: "movies")
            self.reviewsCount = reviewCount
        } catch {
            print("Errore nel recupero del numero delle recensioni: \(error)")
        }
    }
    
    func fetchAllReviews() async {
        do {
            let reviews = try await firestoreService.getAllReviews(productId: movieId, type: "movies")
            self.allReviews = reviews
        } catch {
            print("Errore nel recupero di tutte le recensioni: \(error)")
        }
    }
    
    func addOrUpdateReview(reviewText: String) async {
        do {
            try await firestoreService.addOrUpdateReview(productId: movieId, userId: currentUserUid, reviewText: reviewText, type: "movies")
            self.oldReviewText = reviewText
            await fetchCurrentUserReview()
            await fetchReviewsCount()
        } catch {
            print("Errore durante l'aggiornamento della recensione: \(error)")
        }
    }
    
    func loadUserRawLists() async {
        do {
            self.rawLists = try await firestoreService.getUserRawLists(userId: currentUserUid)
            for rawList in filterRawLists() {
                isInList[rawList.listId] = false
            }
            checkIfMovieInLists()
        } catch {
            print("Errore durante l'ottenimento delle liste: \(error)")
        }
    }
    
    func filterRawLists() -> [(type: String, name: String, totalCount: Int, listId: String)] {
        return Array(rawLists.filter { rawList in
            return rawList.listId != "favorite" && rawList.listId != "watchlist" && rawList.listId != "watched_m" && rawList.listId != "watching_t" && rawList.listId != "finished_t" && rawList.type != "tv"
        })
    }
}
