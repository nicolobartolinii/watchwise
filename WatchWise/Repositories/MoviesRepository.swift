//
//  MoviesRepository.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 05/09/23.
//

import Foundation
import Alamofire

class MoviesRepository {
    
    func getMovieDetails(by movieId: Int64, completion: @escaping (Movie?) -> Void) {
        APIManager.getMovieDetails(movieId: movieId) { (result: AFResult<Movie>) in
            switch result {
            case .success(let movie):
                completion(movie)
            case .failure(let error):
                print("Error getting movie details: \(error)")
            }
        }
    }
    
    func getSimilarMovies(by movieId: Int64, completion: @escaping (DiscoverMoviesResponse?) -> Void) {
        APIManager.getSimilarMovies(movieId: movieId) { (result: AFResult<DiscoverMoviesResponse>) in
            switch result {
            case .success(let discoveredMovies):
                completion(discoveredMovies)
            case .failure(let error):
                print("Error getting similar movies: \(error)")
            }
        }
    }
    
    func getMovieImages(for movieId: Int64, completion: @escaping ([Backdrop]) -> Void) {
        var backdrops: [Backdrop] = []
        let dispatchGroup = DispatchGroup()
        
        // Chiamata per la lingua "it"
        dispatchGroup.enter()
        APIManager.getMovieImages(movieId: movieId, language: "it") { (result: AFResult<ImagesResponse>) in
            switch result {
            case .success(let imagesResponse):
                backdrops.append(contentsOf: imagesResponse.backdrops)
            case .failure(let error):
                print("Error getting IT movie images: \(error)")
            }
            dispatchGroup.leave()
        }
        
        // Chiamata per la lingua "en"
        dispatchGroup.enter()
        APIManager.getMovieImages(movieId: movieId, language: "en") { (result: AFResult<ImagesResponse>) in
            switch result {
            case .success(let imagesResponse):
                backdrops.append(contentsOf: imagesResponse.backdrops)
            case .failure(let error):
                print("Error getting EN movie images: \(error)")
            }
            dispatchGroup.leave()
        }
        
        // Chiamata senza specifica lingua
        dispatchGroup.enter()
        APIManager.getMovieImages(movieId: movieId, language: "null") { (result: AFResult<ImagesResponse>) in
            switch result {
            case .success(let imagesResponse):
                backdrops.append(contentsOf: imagesResponse.backdrops)
            case .failure(let error):
                print("Error getting NULL movie images: \(error)")
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(backdrops)
        }
    }

//    func getMovieImages(for movieId: Int64, completion: @escaping) -> [Backdrop] {
//        var backdrops: [Backdrop] = []
//
//        // Chiamata per la lingua "it"
//        APIManager.getMovieImages(movieId: movieId, language: "it") { response in
//            // Stampa la risposta effettiva
////            debugPrint(response)
//
//            switch response {
//            case .success(let imagesResponse):
//                backdrops.append(contentsOf: imagesResponse.backdrops)
//            case .failure(let error):
//                print("Error getting IT movie images: \(error)")
//            }
//        }
//
//        // Chiamata per la lingua "en"
//        APIManager.getMovieImages(movieId: movieId, language: "en") { response in
//            // Stampa la risposta effettiva
////            debugPrint(response)
//
//            switch response {
//            case .success(let imagesResponse):
//                backdrops.append(contentsOf: imagesResponse.backdrops)
//            case .failure(let error):
//                print("Error getting EN movie images: \(error)")
//            }
//        }
//
//        // Chiamata per la lingua "null"
//        APIManager.getMovieImages(movieId: movieId, language: "null") { response in
//            // Stampa la risposta effettiva
////            debugPrint(response)
//
//            switch response {
//            case .success(let imagesResponse):
//                backdrops.append(contentsOf: imagesResponse.backdrops)
//            case .failure(let error):
//                print("Error getting NULL movie images: \(error)")
//            }
//        }
//
//        return backdrops
//    }


}
