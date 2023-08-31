//
//  DiscoverPeopleResponse.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 28/08/23.
//

import Foundation

struct DiscoverPeopleResponse: Codable {
    let results: [DiscoveredPerson]
    let total_pages: Int32
}

struct DiscoveredPerson: Codable, Hashable {
    let id: Int64
    let name: String
    let profile_path: String?
}
