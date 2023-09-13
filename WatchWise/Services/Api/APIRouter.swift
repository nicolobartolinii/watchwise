//
//  APIRouter.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    case getMovieDetails(movieId: Int64)
    case getNowPlayingMovies
    case getPopularMovies
    case getPopularTVShows
    case getTrendingMovies
    case getTrendingTVShows
    case searchMovies(query: String, page: Int32)
    case searchShows(query: String, page: Int32)
    case searchPeople(query: String, page: Int32)
    case getTVShowDetails(showId: Int64)
    case getSeasonDetails(showId: Int64, seasonNumber: Int32)
    case getPersonDetails(personId: Int32)
    case getSimilarMovies(movieId: Int64)
    case getSimilarTVShows(showId: Int64)
    case getMovieImages(movieId: Int64, language: String)
    case getTVShowImages(showId: Int64, language: String)
    
    static let baseURL = URL(string: "https://api.themoviedb.org/3")
    
    var path: String {
        switch self {
        case .getMovieDetails(let movieId):
            return "/movie/\(movieId)"
        case .getNowPlayingMovies:
            return "/movie/now_playing"
        case .getPopularMovies:
            return "/movie/top_rated"
        case .getPopularTVShows:
            return "/tv/top_rated"
        case .getTrendingMovies:
            return "/trending/movie/week"
        case .getTrendingTVShows:
            return "/trending/tv/week"
        case .searchMovies:
            return "/search/movie"
        case .searchShows:
            return "/search/tv"
        case .searchPeople:
            return "/search/person"
        case .getTVShowDetails(let showId):
            return "/tv/\(showId)"
        case .getSeasonDetails(let showId, let seasonNumber):
            return "/tv/\(showId)/season/\(seasonNumber)"
        case .getPersonDetails(let personId):
            return "/person/\(personId)"
        case .getSimilarMovies(let movieId):
            return "/movie/\(movieId)/similar"
        case .getSimilarTVShows(let showId):
            return "/tv/\(showId)/similar"
        case .getMovieImages(let movieId, _):
            return "/movie/\(movieId)/images"
        case .getTVShowImages(let showId, _):
            return "/movie/\(showId)/images"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String: Any] {
        switch self {
        case .getMovieDetails:
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "append_to_response": "credits,videos,watch/providers"]
        case .getNowPlayingMovies:
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "page": 1]
        case .getPopularMovies:
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "page": 1]
        case .getPopularTVShows:
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "page": 1]
        case .getTrendingMovies:
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "page": 1]
        case .getTrendingTVShows:
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "page": 1]
        case .searchMovies(let query, let page):
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "include_adult": "false",
                    "query": query,
                    "page": page]
        case .searchShows(let query, let page):
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "include_adult": "false",
                    "query": query,
                    "page": page]
        case .searchPeople(let query, let page):
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "include_adult": "false",
                    "query": query,
                    "page": page]
        case .getTVShowDetails:
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "append_to_response": "credits,videos,watch/providers"]
        case .getSeasonDetails:
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT"]
        case .getPersonDetails:
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "append_to_response": "combined_credits"]
        case .getSimilarMovies:
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "page": 1]
        case .getSimilarTVShows:
            return ["api_key": APIConstants.apiKey,
                    "language": "it-IT",
                    "region": "IT",
                    "page": 1]
        case .getMovieImages(_, let language):
            return ["api_key": APIConstants.apiKey,
                    "include_image_language": language]
        case .getTVShowImages(_, let language):
            return ["api_key": APIConstants.apiKey,
                    "include_image_language": language]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = APIRouter.baseURL!.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request = try URLEncoding.default.encode(request, with: parameters as Parameters)
        return request
    }
}
