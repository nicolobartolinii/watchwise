//
//  TVShowDetailsViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 07/09/23.
//

import Foundation
import Combine

@MainActor
class TVShowDetailsViewModel: ObservableObject {
    @Published var show: TVShow?
    @Published var similarShows: [DiscoveredTVShow]?
    @Published var isInList: [String: Bool] = [
        "watching_t": false,
        "watchlist": false,
        "favorite": false
    ]
    @Published var episodes: [Episode] = []
    @Published var isSeasonDetailsPresented: [Int: Bool] = [:]
    @Published var isEpisodeWatched: [Int: [Int: Bool]] = [:]
    @Published var currentUserRating: CGFloat = 0.0
    @Published var oldRating: CGFloat = 0.0
    @Published var allRatings: [CGFloat] = []
    @Published var reviewText: String = ""
    @Published var currentUserReview: Review?
    @Published var oldReviewText: String = ""
    @Published var reviewsCount: Int = 0
    @Published var allReviews: [Review] = []
    
    private var showId: Int64
    private var currentUserUid: String
    private var repository: TVShowsRepository
    private var firestoreService: FirestoreService
    
    init(showId: Int64, currentUserUid: String) {
        self.showId = showId
        self.currentUserUid = currentUserUid
        self.repository = TVShowsRepository()
        self.firestoreService = FirestoreService()
        
        checkIfTVShowInList()
        
        Task {
            await fetchCurrentUserRating()
            await fetchAllRatings()
            await fetchCurrentUserReview()
            await fetchReviewsCount()
        }
    }
    
    func getTVShowDetails() async {
            do {
                var show = try await repository.getTVShowDetails(showId: showId)
                
                for (index, season) in show.seasons!.enumerated() {
                    do {
                        let detailedSeason = try await repository.getSeasonDetails(showId: showId, seasonNumber: Int32(season.seasonNumber))
                        isSeasonDetailsPresented[season.seasonNumber] = false
                        if season.seasonNumber != 0 {
                            self.episodes.append(contentsOf: detailedSeason.episodes ?? [])
                        }
                        show.seasons?[index] = detailedSeason
                    } catch {
                        print("Error fetching details for season \(season.seasonNumber): \(error)")
                    }
                }
                
                self.show = show
                
            } catch {
                print("Error fetching show details: \(error)")
            }
        }
    
    func getSimilarTVShows() {
        repository.getSimilarTVShows(by: showId) { discoveredTVShows in
            self.similarShows = discoveredTVShows?.results as? [DiscoveredTVShow]
        }
    }
    
    func toggleTVShowToList(listName: String) {
        if let isInList = isInList[listName] {
            if isInList {
                firestoreService.removeProductFromList(self.showId, listName: listName, userId: self.currentUserUid, type: "tv") { error in
                    if let error = error {
                        print("Errore nella rimozione della serie \(self.showId) dalla lista \(listName): \(error)")
                        return
                    }
                    self.isInList[listName] = false
                    
                    if listName == "watching_t" {
                        Task {
                            await self.removeShowFromEpisodesCollection()
                        }
                    }
                }
            } else {
                firestoreService.addProductToList(self.showId, listName: listName, userId: self.currentUserUid, type: "tv") { error in
                    if let error = error {
                        print("Errore nell'aggiunta della serie \(self.showId) alla lista \(listName): \(error)")
                        return
                    }
                    self.isInList[listName] = true
                    
                    if listName == "watching_t" {
                        Task {
                            await self.addShowToEpisodesCollection()
                        }
                    }
                }
            }
        }
    }
    
    private func checkIfTVShowInList() {
        for (listName, _) in isInList {
            firestoreService.isProductInList(self.showId, listName: listName, userId: self.currentUserUid, type: "tv") { isInThisList, error in
                if let error = error {
                    print("Errore nel controllo della serie \(self.showId) nella lista \(listName): \(error)")
                    return
                }
                self.isInList[listName] = isInThisList
            }
        }
    }
    
    func fetchCurrentUserRating() async {
        do {
            let rating = try await firestoreService.getCurrentUserRating(productId: showId, userId: currentUserUid, type: "tv")
            self.currentUserRating = (rating ?? 0.0) / 5
            self.oldRating = self.currentUserRating
        } catch {
            print("Error fetching current user rating: \(error)")
        }
    }
    
    func fetchAllRatings() async {
        do {
            let ratings = try await firestoreService.getAllRatings(productId: showId, type: "tv")
            self.allRatings = ratings
        } catch {
            print("Error fetching all ratings: \(error)")
        }
    }
    
    func addOrUpdateRating(value: CGFloat) async {
        do {
            try await firestoreService.addOrUpdateRating(productId: showId, userId: currentUserUid, ratingValue: value, type: "tv")
            self.oldRating = value / 5
            await fetchAllRatings()
        } catch {
            print("Error updating rating: \(error)")
        }
    }
    
    func fetchCurrentUserReview() async {
        do {
            let review = try await firestoreService.getCurrentUserReview(productId: showId, userId: currentUserUid, type: "tv")
            self.currentUserReview = review
            self.reviewText = review?.text ?? ""
            self.oldReviewText = self.reviewText
        } catch {
            print("Errore nel recupero della recensione: \(error)")
        }
    }
    
    func fetchReviewsCount() async {
        do {
            let reviewCount = try await firestoreService.getReviewsCount(productId: showId, type: "tv")
            self.reviewsCount = reviewCount
        } catch {
            print("Errore nel recupero del numero delle recensioni: \(error)")
        }
    }
    
    func fetchAllReviews() async {
        do {
            let reviews = try await firestoreService.getAllReviews(productId: showId, type: "tv")
            self.allReviews = reviews
        } catch {
            print("Errore nel recupero di tutte le recensioni: \(error)")
        }
    }
    
    func addOrUpdateReview(reviewText: String) async {
        do {
            try await firestoreService.addOrUpdateReview(productId: showId, userId: currentUserUid, reviewText: reviewText, type: "tv")
            self.oldReviewText = reviewText
            await fetchCurrentUserReview()
            await fetchReviewsCount()
        } catch {
            print("Errore durante l'aggiornamento della recensione: \(error)")
        }
    }
    
    private func addShowToEpisodesCollection() async {
        do {
            try await firestoreService.addShowToEpisodesCollection(userId: currentUserUid, showId: showId)
        } catch {
            print("Errore durante l'aggiunta della serie TV alla collection episodes: \(error)")
        }
    }
    
    private func removeShowFromEpisodesCollection() async {
        do {
            try await firestoreService.removeShowFromEpisodesCollection(userId: currentUserUid, showId: showId)
        } catch {
            print("Errore durante la rimozione della serie TV dalle serie in visione: \(error)")
        }
    }
    
    func toggleWatchedEpisode(seasonNumber: Int, episodeNumber: Int) async {
        do {
            try await firestoreService.addEpisodeToWatchedList(userId: currentUserUid, showId: showId, seasonNumber: seasonNumber, episodeNumber: episodeNumber)
        } catch {
            print("Errore durante l'aggiunta dell'episodio alla lista dei visti: \(error)")
        }
    }
}
