//
//  EpisodesViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 08/09/23.
//

import Foundation

@MainActor
class EpisodesViewModel: ObservableObject {
    @Published var nextEpisodes: [NextEpisode]?
    
    private var currentUserUid: String
    private var repository: TVShowsRepository
    private var firestoreService: FirestoreService
    
    init(currentUserUid: String) {
        self.currentUserUid = currentUserUid
        self.repository = TVShowsRepository()
        self.firestoreService = FirestoreService()
    }
    
    func loadNextEpisodes() async throws {
        let watchingShows = try await firestoreService.getWatchingShows(userId: currentUserUid)
        var nextEpisodesList: [NextEpisode] = []
        
        for var show in watchingShows {
            var seasonNumber: Int32 = -1
            var nextEpisodeNumber: Int32 = -1
            let showId = Int64(show.key) ?? -1
            var showDetails = try await repository.getTVShowDetails(showId: showId)
            for (index, season) in showDetails.seasons!.enumerated() {
                do {
                    let detailedSeason = try await repository.getSeasonDetails(showId: showId, seasonNumber: Int32(season.seasonNumber))
                    showDetails.seasons?[index] = detailedSeason
                } catch {
                    print("Error fetching details for season \(season.seasonNumber): \(error)")
                }
            }
            showDetails.seasons?.removeAll(where: { $0.seasonNumber == 0 })
            show.value?.removeValue(forKey: "0")
            
            if let showValue = show.value, !showValue.isEmpty {
                for season in showValue {
                    seasonNumber = Int32(season.key) ?? -1
                    let seasonDetails = try await repository.getSeasonDetails(showId: showId, seasonNumber: seasonNumber)
                    
                    if season.value.count == seasonDetails.episodes?.count {
                        if showValue.count != showDetails.seasons?.count && !showValue.contains(where: { $0.key == String(seasonNumber + 1) }) {
                            try await firestoreService.addSeasonToWatchingShow(userId: currentUserUid, showId: showId, seasonNumber: seasonNumber + 1)
                            seasonNumber += 1
                            nextEpisodeNumber = 1
                            break
                        } else {
                            continue
                        }
                    } else {
                        if (Int32(season.key) ?? -1) != 1 && !showValue.contains(where: { $0.key == "1" }) {
                            seasonNumber = 1
                            while showValue.contains(where: { $0.key == String(seasonNumber) }) {
                                seasonNumber += 1
                            }
                            try await firestoreService.addSeasonToWatchingShow(userId: currentUserUid, showId: showId, seasonNumber: seasonNumber)
                            nextEpisodeNumber = 1
                            break
                        } else {
                            nextEpisodeNumber = !season.value.isEmpty ? Int32(season.value.max() ?? -2) + 1 : 1
                            if nextEpisodeNumber == (seasonDetails.episodes?.count ?? -2) + 1 {
                                nextEpisodeNumber = 1
                                while season.value.contains(Int(nextEpisodeNumber)) {
                                    nextEpisodeNumber += 1
                                }
                            }
                        }
                    }
                    if nextEpisodeNumber != -1 && season.value.count == showDetails.seasons?[Int(seasonNumber) - 1].episodes?.count {
                        continue
                    } else if (nextEpisodeNumber != -1) && (showValue.count == showDetails.seasons?.count) {
                        break
                    } else {
                        break
                    }
                }
            } else {
                seasonNumber = 1
                nextEpisodeNumber = 1
            }
            
            
            if nextEpisodeNumber != -1 {
                let nextEpisode = NextEpisode(
                    showId: showId,
                    showName: showDetails.name.isEmpty ? showDetails.originalName : showDetails.name,
                    seasonNumber: Int(seasonNumber),
                    episodeNumber: Int(nextEpisodeNumber),
                    episodeName: showDetails.seasons?[Int(seasonNumber) - 1].episodes?[Int(nextEpisodeNumber) - 1].name ?? "Episodio \(nextEpisodeNumber)",
                    posterPath: showDetails.posterPath,
                    duration: showDetails.seasons?[Int(seasonNumber) - 1].episodes?[Int(nextEpisodeNumber) - 1].runtime
                )
                nextEpisodesList.append(nextEpisode)
            } else {
                continue
            }
        }
        
        self.nextEpisodes = nextEpisodesList.sorted(by: { $0.showName < $1.showName })
    }
    
    func watchEpisode(showId: Int64, seasonNumber: Int, episodeNumber: Int, episodeRuntime: Int) async {
        do {
            try await firestoreService.addEpisodeToWatchedList(userId: currentUserUid, showId: showId, seasonNumber: seasonNumber, episodeNumber: episodeNumber)
            try await firestoreService.incrementUserField(userId: currentUserUid, type: "tvMinutes", number: episodeRuntime)
            try await firestoreService.incrementUserField(userId: currentUserUid, type: "tvNumber", number: 1)
            self.nextEpisodes = nil
            try await self.loadNextEpisodes()
        } catch {
            print("Errore durante l'aggiunta dell'episodio alla lista dei visti: \(error)")
        }
    }
}
