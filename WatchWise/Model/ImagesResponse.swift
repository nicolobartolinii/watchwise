//
//  ImagesResponse.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 11/09/23.
//

import Foundation

struct ImagesResponse: Codable {
    let backdrops: [Backdrop]
    
    enum CodingKeys: String, CodingKey {
        case backdrops = "backdrops"
    }
}

struct Backdrop: Codable {
    let aspectRatio: CGFloat
    let iso_639_1: String?
    let imagePath: String
    
    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case iso_639_1
        case imagePath = "file_path"
    }
}
