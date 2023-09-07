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
    
    static func getPopularMovies(completion: @escaping (AFResult<DiscoverMoviesResponse>) -> Void) {
        APIService.getPopularMovies(completion: completion)
    }
    
    static func getPopularTVShows(completion: @escaping (AFResult<DiscoverTVShowsResponse>) -> Void) {
        APIService.getPopularTVShows(completion: completion)
    }
    
    static func getTrendingMovies(completion: @escaping (AFResult<DiscoverMoviesResponse>) -> Void) {
        APIService.getTrendingMovies(completion: completion)
    }
    
    static func getTrendingTVShows(completion: @escaping (AFResult<DiscoverTVShowsResponse>) -> Void) {
        APIService.getTrendingTVShows(completion: completion)
    }

    static func searchMovies(query: String, page: Int32, completion: @escaping (AFResult<DiscoverMoviesResponse>) -> Void) {
        APIService.searchMovies(query: query, page: page, completion: completion)
    }
    
    static func searchShows(query: String, page: Int32, completion: @escaping (AFResult<DiscoverTVShowsResponse>) -> Void) {
        APIService.searchShows(query: query, page: page, completion: completion)
    }
    
    static func searchPeople(query: String, page: Int32, completion: @escaping (AFResult<DiscoverPeopleResponse>) -> Void) {
        APIService.searchPeople(query: query, page: page, completion: completion)
    }
    
    static func getTVShowDetails(showId: Int64, completion: @escaping (AFResult<TVShow>) -> Void) {
        APIService.getTVShowDetails(showId: showId, completion: completion)
    }
    
    static func getSeasonDetails(showId: Int64, seasonNumber: Int32, completion: @escaping (AFResult<Season>) -> Void) {
        APIService.getSeasonDetails(showId: showId, seasonNumber: seasonNumber, completion: completion)
    }
    
    static func getPersonDetails(personId: Int32, completion: @escaping (AFResult<Person>) -> Void) {
        APIService.getPersonDetails(personId: personId, completion: completion)
    }
    
    static func getSimilarMovies(movieId: Int64, completion: @escaping (AFResult<DiscoverMoviesResponse>) -> Void) {
        APIService.getSimilarMovies(movieId: movieId, completion: completion)
    }
    
    static func getSimilarTVShows(showId: Int64, completion: @escaping (AFResult<DiscoverTVShowsResponse>) -> Void) {
        APIService.getSimilarTVShows(showId: showId, completion: completion)
    }
}
