//
//  ChatViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 13/09/23.
//

import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [(Message, Any)] = []
    @Published var user: User
    private var firestoreService = FirestoreService()
    private var moviesRepository = MoviesRepository()
    private var tvShowsRepository = TVShowsRepository()
    var currentUserUid: String

    init(user: User, currentUserUid: String) {
        self.user = user
        self.currentUserUid = currentUserUid
        loadMessages()
    }

    func loadMessages() {
        Task {
            do {
                let rawMessages = try await firestoreService.fetchUserChatMessages(for: currentUserUid, by: user.uid).sorted(by: { $0.timestamp.dateValue() < $1.timestamp.dateValue() })
                for message in rawMessages {
                    moviesRepository.getMovieDetails(by: message.productId) { movie in
                        self.messages.append((message, movie ?? ""))
                    }
                }
            } catch {
                print("Error fetching messages: \(error)")
            }
        }
    }

    func send(content: String) {
        return
//        Task {
//            do {
//                try firestoreService.sendMessage(to: chatId, content: content, currentUserUid: currentUserUid)
//                loadMessages()  // Ricarica i messaggi dopo l'invio
//            } catch {
//                print("Error sending message: \(error)")
//            }
//        }
    }
}
