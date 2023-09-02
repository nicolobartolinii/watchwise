//
//  Movie.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import Foundation

struct Movie: Codable {
    let adult: Bool?
    let backdrop_path: String?
    let belongs_to_collection: Collection?
    let budget: Int?
    let genres: [Genre]
    let homepage: String?
    let id: Int64
    let original_language: String?
    let original_title: String?
    let overview: String?
    let poster_path: String?
    let release_date: String?
    let revenue: Int?
    let runtime: Int
    let status: String?
    let tagline: String?
    let title: String
    let watchProviders: WatchProvidersResponse?
    let videos: VideosResponse?
    let credits: Credits?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let spokenLanguages: [SpokenLanguage]?
    
    enum CodingKeys: String, CodingKey {
        case adult, backdrop_path, belongs_to_collection, budget, genres, homepage, id, original_language, original_title, overview, poster_path, release_date, revenue, runtime, status, tagline, title, videos, credits
        case watchProviders = "watch/providers"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case spokenLanguages = "spoken_languages"
    }
}

struct Collection: Codable {
    let id: Int
    let name: String
    let poster_path: String?
    let backdrop_path: String?
}

struct Genre: Codable {
    let id: Int
    let name: String
}

struct WatchProvidersResponse: Codable {
    let results: [String: WatchProvider]
}

struct WatchProvider: Codable {
    let flatrate: [Provider]?
    let buy: [Provider]?
    let rent: [Provider]?
}

struct Provider: Codable, Hashable {
    let logo_path: String
    let provider_id: Int
    let provider_name: String
    let display_priority: Int
}

struct VideosResponse: Codable {
    let results: [Video]
}

struct Video: Codable, Hashable {
    let id: String
    let iso_639_1: String
    let iso_3166_1: String
    let key: String
    let name: String
    let site: String
    let type: String
    let official: Bool
}

struct Credits: Codable {
    let cast: [Cast]
    let crew: [Crew]
}

struct Cast: Codable, Hashable {
    let adult: Bool
    let gender: Int
    let id: Int32
    let known_for_department: String?
    let name: String
    let original_name: String
    let profile_path: String?
    let character: String
}

struct Crew: Codable, Hashable {
    let adult: Bool
    let gender: Int
    let id: Int32
    let known_for_department: String?
    let name: String
    let original_name: String
    let profile_path: String?
    let department: String
    let job: String
}

struct ProductionCompany: Codable, Hashable {
    let id: Int64
    let logo_path: String?
    let name: String
}

struct ProductionCountry: Codable, Hashable {
    let iso_3166_1: String
    let name: String
}

struct SpokenLanguage: Codable, Hashable {
    let english_name: String
    let iso_639_1: String
    let name: String
}
