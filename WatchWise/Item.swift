//
//  Item.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 15/08/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
