//
//  ChangeBackdropViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 11/09/23.
//

import Foundation

@MainActor
class ChangeBackdropViewModel: ObservableObject {
    @Published var backdropImages: [String] = []
    @Published var selectedImage: String?
    @Published var currentPage: Int = 0
    private let moviesRepository: MoviesRepository
    private let tvShowsRepository: TVShowsRepository
    private let firestoreService: FirestoreService
    
    private var currentUserUid: String
    
    init(currentUserUid: String) {
        self.moviesRepository = MoviesRepository()
        self.tvShowsRepository = TVShowsRepository()
        self.firestoreService = FirestoreService()
        self.currentUserUid = currentUserUid
        Task {
            await fetchBackdrops()
        }
    }
    
    func fetchBackdrops() async {
        var favorites: (movies: [Int64], shows: [Int64], type: String, name: String)
        do {
            favorites = try await firestoreService.getUserList(userId: currentUserUid, listId: "favorite") ?? ([], [], "", "")
        } catch {
            print("Errore nell'ottenimento della lista: \(error)")
            return
        }
        print(favorites)
        
        let dispatchGroup = DispatchGroup()
        var movieImages: [String] = []
        var tvShowImages: [String] = []
        
        for movieId in favorites.movies {
            dispatchGroup.enter()
            moviesRepository.getMovieImages(for: movieId) { (backdrops) in
                movieImages.append(contentsOf: backdrops.map { "https://image.tmdb.org/t/p/w1280\($0.imagePath)" })
                dispatchGroup.leave()
            }
        }
        
        for showId in favorites.shows {
            dispatchGroup.enter()
            tvShowsRepository.getTVShowImages(for: showId) { (backdrops) in
                tvShowImages.append(contentsOf: backdrops.map { "https://image.tmdb.org/t/p/w1280\($0.imagePath)" })
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.backdropImages = (movieImages + tvShowImages).shuffled()
        }
    }


    
    func selectImage(_ url: String) {
        if selectedImage == url {
            selectedImage = nil
        } else {
            selectedImage = url
        }
    }
}
