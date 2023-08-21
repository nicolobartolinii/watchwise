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
    
    static let baseURL = URL(string: "https://api.themoviedb.org/3")
    
    var path: String {
        switch self {
        case .getMovieDetails(let movieId):
            return "/movie/\(movieId)"
        case .getNowPlayingMovies:
            return "/movie/now_playing"
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
