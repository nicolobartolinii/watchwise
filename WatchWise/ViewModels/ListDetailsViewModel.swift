//
//  ListDetailsViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 09/09/23.
//

import Foundation

@MainActor
class ListDetailsViewModel: ObservableObject {
    @Published var moviesList: [Movie] = []
    @Published var tvShowsList: [TVShow] = []
    @Published var listName: String = ""
    @Published var listType: String = ""
    @Published var isLoaded: Bool = false
    
    private var listId: String
    private var currentUserUid: String
    private var moviesRepository: MoviesRepository
    private var tvShowsRepository: TVShowsRepository
    private var firestoreService: FirestoreService
    
    init(listId: String, currentUserUid: String) {
        self.listId = listId
        self.currentUserUid = currentUserUid
        self.moviesRepository = MoviesRepository()
        self.tvShowsRepository = TVShowsRepository()
        self.firestoreService = FirestoreService()
    }
    
    func fetchProducts() async throws {
        let listDetails = try await getListDetails()
        
        if let listDetails = listDetails {
            if listDetails.type == "movie" || listDetails.type == "both" {
                for movieId in listDetails.movies {
                    moviesRepository.getMovieDetails(by: movieId) { movie in
                        self.moviesList.append(movie!)
                    }
                }
            }
            if listDetails.type == "tv" || listDetails.type == "both" {
                for showId in listDetails.shows {
                    self.tvShowsList.append(try await tvShowsRepository.getTVShowDetails(showId: showId))
                }
            }
        }
        self.isLoaded = true
    }
    
    func getListDetails() async throws -> (movies: [Int64], shows: [Int64], type: String, name: String)? {
        let listDetails = try await firestoreService.getUserList(userId: currentUserUid, listId: listId)
        self.listName = listDetails?.name ?? ""
        self.listType = listDetails?.type ?? ""
        return listDetails
    }
}
