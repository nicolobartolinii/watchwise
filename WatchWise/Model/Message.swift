//
//  Message.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 13/09/23.
//

import Foundation
import FirebaseFirestore

struct Message: Codable, Hashable {
    var id: String
    var productId: Int64
    var senderId: String
    var timestamp: Timestamp
}
