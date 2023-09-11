//
//  UserDetailsViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 31/08/23.
//

import Combine
import SwiftUI

@MainActor
class UserDetailsViewModel: ObservableObject {
    @Published var user: User? {
        didSet {
            updateTotalTime()
        }
    }
    
    private var uid: String
    private var repository: UsersRepository
    private var firestoreService: FirestoreService
    private var currentUserUid: String
    
    @Published var isFollowing: Bool = false
    @Published var ratings: [CGFloat] = []
    @Published var reviews: [AltReview] = []
    @Published var rawLists: [(type: String, name: String, totalCount: Int, listId: String)] = []
    @Published var movieMonths: Int = 0
    @Published var movieDays: Int = 0
    @Published var movieHours: Int = 0
    @Published var tvMonths: Int = 0
    @Published var tvDays: Int = 0
    @Published var tvHours: Int = 0
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    
    init(uid: String, currentUserUid: String) {
        self.uid = uid
        self.repository = UsersRepository()
        self.firestoreService = FirestoreService()
        self.currentUserUid = currentUserUid
        
        if uid != currentUserUid {
            loadFollowingStatus()
        }
    }
    
    func fetchUserDetails() async {
        do {
            if let user = try await repository.getUser(by: self.uid) {
                self.user = user
            } else {
                self.user = nil
            }
            await loadUserInfos()
        } catch {
            print("Errore nell'ottenimento dei dettagli dell'utente: \(error)")
            self.user = nil
        }
    }
    
    private func loadFollowingStatus() {
        Task {
            do {
                self.isFollowing = try await firestoreService.isUserFollowing(currentUserUid: self.currentUserUid, targetUserUid: self.uid)
            } catch {
                print("Errore nel caricamento dello stato di follow: \(error)")
            }
        }
    }
    
    func followUser() {
        Task {
            do {
                try await firestoreService.followUser(currentUserUid: self.currentUserUid, targetUserUid: self.uid)
                self.isFollowing = true
                self.followersCount += 1
            } catch {
                print("Errore nel seguire l'utente: \(error)")
            }
        }
    }
    
    func unfollowUser() {
        Task {
            do {
                try await firestoreService.unfollowUser(currentUserUid: self.currentUserUid, targetUserUid: self.uid)
                self.isFollowing = false
                self.followersCount -= 1
            } catch {
                print("Errore nello smettere di seguire l'utente: \(error)")
            }
        }
    }
    
    func loadUserInfos() async {
        do {
            self.ratings = try await firestoreService.getUserRatings(userId: self.uid)
            self.reviews = try await firestoreService.getUserReviews(userId: self.uid)
            await self.getUserRawLists()
            self.followersCount = try await firestoreService.getUserFollowCount(for: self.uid, type: "followers")
            self.followingCount = try await firestoreService.getUserFollowCount(for: self.uid, type: "following")
        } catch {
            print("Error loading user details: \(error)")
        }
    }
    
    func getUserRawLists() async {
        do {
            self.rawLists = []
            self.rawLists = try await firestoreService.getUserRawLists(userId: self.uid)
        } catch {
            print("Errore durante l'ottenimento delle liste: \(error)")
        }
    }
    
    private func updateTotalTime() {
        guard let user = user else { return }
        let movieMinutes = user.movieMinutes
        let tvMinutes = user.tvMinutes
        let movieComponents = Utils.convertMinutesToTimeComponents(minutes: movieMinutes)
        let tvComponents = Utils.convertMinutesToTimeComponents(minutes: tvMinutes)
        self.movieMonths = movieComponents.months
        self.movieDays = movieComponents.days
        self.movieHours = movieComponents.hours
        self.tvMonths = tvComponents.months
        self.tvDays = tvComponents.days
        self.tvHours = tvComponents.hours
    }
}
