//
//  Person.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 02/09/23.
//

import Foundation

struct Person: Codable {
    let id: Int32
    let adult: Bool
    let biography: String?
    let birthday: String?
    let deathday: String?
    let gender: Int?
    let homepage: String?
    let knownForDepartment: String?
    let name: String
    let placeOfBirth: String?
    let profilePath: String?
    var credits: CombinedCredits?
    
    enum CodingKeys: String, CodingKey {
        case id, adult, biography, birthday, deathday, gender, homepage, name
        case knownForDepartment = "known_for_department"
        case placeOfBirth = "place_of_birth"
        case profilePath = "profile_path"
        case credits = "combined_credits"
    }
}

struct CombinedCredits: Codable, Hashable {
    var cast: [Product]?
    var crew: [Product]?
}

struct Product: Codable, Hashable {
    let adult: Bool
    let id: Int64
    let posterPath: String?
    let title: String?
    let name: String?
    let character: String?
    let mediaType: String
    let job: String?
    let popularity: CGFloat
    let voteCount: Int
    let voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case adult, id, character, title, name, job, popularity
        case posterPath = "poster_path"
        case mediaType = "media_type"
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
    }
}
