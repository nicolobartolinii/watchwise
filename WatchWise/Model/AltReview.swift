//
//  AltReview.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 09/09/23.
//

import Foundation
import FirebaseFirestore

struct AltReview {
    let productId: Int64
    let type: String
    let text: String
    let timestamp: Timestamp
    let posterPath: String?
}
