//
//  Chat.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 13/09/23.
//

import Foundation

struct Chat: Codable, Hashable {
    var user: User
    var lastMessage: Message?
}
