//
//  MovieDetailsViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 05/09/23.
//

import Foundation
import Combine

class MovieDetailsViewModel: ObservableObject {
    @Published var movie: Movie?
    @Published var isInList: [String: Bool] = [
        "watched_m": false,
        "watchlist": false,
        "favorite": false
    ]
    
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
    }
    
    func getMovieDetails() {
        repository.getMovieDetails(by: movieId) { movie in
            self.movie = movie
        }
    }
    
    func toggleMovieToList(listName: String) {
        if let isInList = isInList[listName] {
            if isInList {
                firestoreService.removeProductFromList(self.movieId, listName: listName, userId: self.currentUserUid, type: "movies") { error in
                    if let error = error {
                        print("Errore nella rimozione del film \(self.movieId) dalla lista \(listName): \(error)")
                        return
                    }
                    self.isInList[listName] = false
                }
            } else {
                firestoreService.addProductToList(self.movieId, listName: listName, userId: self.currentUserUid, type: "movies") { error in
                    if let error = error {
                        print("Errore nell'aggiunta del film \(self.movieId) alla lista \(listName): \(error)")
                        return
                    }
                    self.isInList[listName] = true
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
}
