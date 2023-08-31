//
//  DiscoverTVShowsResponse.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 27/08/23.
//

import Foundation

struct DiscoverTVShowsResponse: Codable {
    let results: [DiscoveredTVShow]
    let total_pages: Int32
}

struct DiscoveredTVShow: Codable, Hashable {
    let id: Int64
    let name: String
    let poster_path: String?
}
