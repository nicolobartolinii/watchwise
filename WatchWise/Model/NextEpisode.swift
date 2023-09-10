//
//  NextEpisode.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 08/09/23.
//

import Foundation

struct NextEpisode: Hashable {
    let showId: Int64
    let showName: String
    let seasonNumber: Int
    let episodeNumber: Int
    let episodeName: String
    let posterPath: String?
    let duration: Int?
}
