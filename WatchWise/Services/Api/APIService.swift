//
//  APIService.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import Foundation
import Alamofire

class APIService {
    @discardableResult
    private static func performRequest<T: Decodable>(route: APIRouter, decoder: JSONDecoder = JSONDecoder(), completion: @escaping (AFResult<T>) -> Void) -> DataRequest {
        return AF.request(route).responseDecodable(decoder: decoder) { (response: AFDataResponse<T>) in
            completion(response.result)
        }
    }
    
    static func getMovieDetails(movieId: Int64, completion: @escaping (AFResult<Movie>) -> Void) {
        performRequest(route: APIRouter.getMovieDetails(movieId: movieId), completion: completion)
    }
    
    static func getNowPlayingMovies(completion: @escaping (AFResult<DiscoverMoviesResponse>) -> Void) {
        performRequest(route: APIRouter.getNowPlayingMovies, completion: completion)
    }
    
}
