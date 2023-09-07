//
//  UserDetailsViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 31/08/23.
//

import Combine
import SwiftUI

class UserDetailsViewModel: ObservableObject {
    @Published var user: User?
    private var uid: String
    private var repository: UsersRepository
    
    init(uid: String) {
        self.uid = uid
        self.repository = UsersRepository()
    }
    
    func fetchUserDetails() async {
        do {
            if let user = try await repository.getUser(by: self.uid) {
                self.user = user
            } else {
                self.user = nil
            }
        } catch {
            print("Errore nell'ottenimento dei dettagli dell'utente: \(error)")
            self.user = nil
        }
    }
}
