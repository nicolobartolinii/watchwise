//
//  ChatsListViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 13/09/23.
//

import Foundation

class ChatsListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    private var firestoreService = FirestoreService()
    private var currentUserUid: String

    init(currentUserUid: String) {
        self.currentUserUid = currentUserUid
        loadChats()
    }

    func loadChats() {
        Task {
            do {
                self.chats = try await firestoreService.fetchUserChats(for: currentUserUid)
            } catch {
                print("Error fetching chats: \(error)")
            }
        }
    }
}
