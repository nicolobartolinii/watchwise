//
//  TVShow.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 27/08/23.
//

import Foundation

struct TVShow: Codable {
    let adult: Bool
    let backdropPath: String?
    let posterPath: String?
    let createdBy: [Creator]?
    let firstAirDate: String?
    let genres: [Genre]
    let homepage: String?
    let id: Int
    let inProduction: Bool?
    let languages: [String]?
    let lastAirDate: String?
    let name: String
    let numberOfEpisodes: Int?
    let numberOfSeasons: Int?
    let originCountry: [String]?
    let originalLanguage: String?
    let originalName: String
    let overview: String?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    var seasons: [Season]?
    let status: String?
    let tagline: String?
    let type: String?
    let watchProviders: WatchProvidersResponse?
    let videos: VideosResponse?
    let credits: Credits?
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"
        case createdBy = "created_by"
        case firstAirDate = "first_air_date"
        case genres
        case homepage
        case id
        case inProduction = "in_production"
        case languages
        case lastAirDate = "last_air_date"
        case name
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case overview
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case seasons
        case status
        case tagline
        case type
        case watchProviders = "watch/providers"
        case videos
        case credits
    }
}

struct Creator: Codable {
    let id: Int
    let creditId: String
    let name: String
    let gender: Int
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case creditId = "credit_id"
        case name
        case gender
        case profilePath = "profile_path"
    }
}

struct Network: Codable {
    let id: Int
    let logoPath: String?
    let name: String
    let originCountry: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}

struct Season: Hashable, Codable {
    let airDate: String?
    let id: Int
    let name: String?
    let overview: String?
    let posterPath: String?
    let seasonNumber: Int
    let episodes: [Episode]?
    
    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case id
        case name
        case overview
        case posterPath = "poster_path"
        case seasonNumber = "season_number"
        case episodes
    }
}

struct Episode: Hashable, Codable, Identifiable {
    let id = UUID()
    let name: String?
    let overview: String?
    let runtime: Int?
    let seasonNumber: Int?
    let episodeNumber: Int
    let type: String?
    let showId: Int?
    let imagePath: String?
    let airDate: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case overview
        case runtime
        case seasonNumber = "season_number"
        case episodeNumber = "episode_number"
        case type = "episode_type"
        case showId = "show_id"
        case imagePath = "still_path"
        case airDate = "air_date"
    }
}
