//
//  DiscoverMoviesResponse.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import Foundation

struct DiscoverMoviesResponse: Codable {
    let results: [DiscoveredMovie]
    let total_pages: Int32
}

struct DiscoveredMovie: Codable, Hashable {
    let id: Int64
    let title: String
    let poster_path: String?
}
