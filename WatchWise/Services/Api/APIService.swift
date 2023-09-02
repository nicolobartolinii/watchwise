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
        let request = AF.request(route)
        
        return request
//            .responseData { (dataResponse) in
//                // Stampa il JSON come stringa, se disponibile (opzionale)
//                if let data = dataResponse.data {
//                    if let jsonString = String(data: data, encoding: .utf8) {
//                        print("JSON Response: \(jsonString)")
//                    }
//                }
//            }
            .responseDecodable(decoder: decoder) { (response: AFDataResponse<T>) in
                completion(response.result)
            }
    }
    
    static func getMovieDetails(movieId: Int64, completion: @escaping (AFResult<Movie>) -> Void) {
        performRequest(route: APIRouter.getMovieDetails(movieId: movieId), completion: completion)
    }
    
    static func getNowPlayingMovies(completion: @escaping (AFResult<DiscoverMoviesResponse>) -> Void) {
        performRequest(route: APIRouter.getNowPlayingMovies, completion: completion)
    }
    
    static func getPopularMovies(completion: @escaping (AFResult<DiscoverMoviesResponse>) -> Void) {
        performRequest(route: APIRouter.getPopularMovies, completion: completion)
    }
    
    static func getPopularTVShows(completion: @escaping (AFResult<DiscoverTVShowsResponse>) -> Void) {
        performRequest(route: APIRouter.getPopularTVShows, completion: completion)
    }
    
    static func getTrendingMovies(completion: @escaping (AFResult<DiscoverMoviesResponse>) -> Void) {
        performRequest(route: APIRouter.getTrendingMovies, completion: completion)
    }
    
    static func getTrendingTVShows(completion: @escaping (AFResult<DiscoverTVShowsResponse>) -> Void) {
        performRequest(route: APIRouter.getTrendingTVShows, completion: completion)
    }
    
    static func searchMovies(query: String, page: Int32, completion: @escaping (AFResult<DiscoverMoviesResponse>) -> Void) {
        performRequest(route: APIRouter.searchMovies(query: query, page: page), completion: completion)
    }
    
    static func searchShows(query: String, page: Int32, completion: @escaping (AFResult<DiscoverTVShowsResponse>) -> Void) {
        performRequest(route: APIRouter.searchShows(query: query, page: page), completion: completion)
    }
    
    static func searchPeople(query: String, page: Int32, completion: @escaping (AFResult<DiscoverPeopleResponse>) -> Void) {
        performRequest(route: APIRouter.searchPeople(query: query, page: page), completion: completion)
    }
    
    static func getTVShowDetails(showId: Int64, completion: @escaping (AFResult<TVShow>) -> Void) {
        performRequest(route: APIRouter.getTVShowDetails(showId: showId), completion: completion)
    }
    
    static func getSeasonDetails(showId: Int64, seasonNumber: Int32, completion: @escaping (AFResult<Season>) -> Void) {
        performRequest(route: APIRouter.getSeasonDetails(showId: showId, seasonNumber: seasonNumber), completion: completion)
    }
    
    static func getPersonDetails(personId: Int32, completion: @escaping (AFResult<Person>) -> Void) {
        performRequest(route: APIRouter.getPersonDetails(personId: personId), completion: completion)
    }
}
