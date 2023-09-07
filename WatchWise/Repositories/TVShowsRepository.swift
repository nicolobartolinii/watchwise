//
//  TVShowsRepository.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 07/09/23.
//

import Foundation
import Alamofire

class TVShowsRepository {
    
    func getTVShowDetails(showId: Int64) async throws -> TVShow {
        return try await withCheckedThrowingContinuation { continuation in
            APIManager.getTVShowDetails(showId: showId) { (result: AFResult<TVShow>) in
                switch result {
                case .success(let show):
                    continuation.resume(returning: show)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getSeasonDetails(showId: Int64, seasonNumber: Int32) async throws -> Season {
        return try await withCheckedThrowingContinuation { continuation in
            APIManager.getSeasonDetails(showId: showId, seasonNumber: seasonNumber) { (result: AFResult<Season>) in
                switch result {
                case .success(let season):
                    continuation.resume(returning: season)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getSimilarTVShows(by showId: Int64, completion: @escaping (DiscoverTVShowsResponse?) -> Void) {
        APIManager.getSimilarTVShows(showId: showId) { (result: AFResult<DiscoverTVShowsResponse>) in
            switch result {
            case .success(let discoveredTVShows):
                completion(discoveredTVShows)
            case .failure(let error):
                print("Error getting similar shows: \(error)")
            }
        }
    }
}
