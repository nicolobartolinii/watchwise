//
//  Review.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 06/09/23.
//

import Foundation
import FirebaseFirestore

struct Review {
    var user: User
    var text: String
    var timestamp: Timestamp
}
