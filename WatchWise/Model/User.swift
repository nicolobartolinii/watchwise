//
//  User.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 31/08/23.
//

import Foundation

struct User {
    let uid: String
    let username: String
    let displayName: String
    let email: String
    let profilePath: String
    let backdropPath: String
    let movieMinutes: Int
    let movieNumber: Int
    let tvMinutes: Int
    let tvNumber: Int
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.displayName = dictionary["displayName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.profilePath = dictionary["profilePath"] as? String ?? ""
        self.backdropPath = dictionary["backdropPath"] as? String ?? ""
        self.movieMinutes = dictionary["movieMinutes"] as? Int ?? 0
        self.movieNumber = dictionary["movieNumber"] as? Int ?? 0
        self.tvMinutes = dictionary["tvMinutes"] as? Int ?? 0
        self.tvNumber = dictionary["tvNumber"] as? Int ?? 0
    }
}
