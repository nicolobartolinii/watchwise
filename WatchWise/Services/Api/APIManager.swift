//
//  APIManager.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import Foundation
import Alamofire

class APIManager {
    static func getMovieDetails(movieId: Int64, completion: @escaping (AFResult<Movie>) -> Void) {
        APIService.getMovieDetails(movieId: movieId, completion: completion)
    }
    
    static func getNowPlayingMovies(completion: @escaping (AFResult<DiscoverMoviesResponse>) -> Void) {
        APIService.getNowPlayingMovies(completion: completion)
    }

}
