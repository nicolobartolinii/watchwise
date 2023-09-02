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
    
    func fetchUserDetails() {
        repository.getUser(by: uid) { user in
            self.user = user
        }
    }
}
