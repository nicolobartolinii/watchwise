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
}
