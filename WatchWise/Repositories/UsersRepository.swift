//
//  UsersRepository.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 31/08/23.
//

class UsersRepository {
    private var firestoreService: FirestoreService
    
    init() {
        self.firestoreService = FirestoreService()
    }
    
    func getUser(by uid: String) async throws -> User? {
        return try await firestoreService.getUserDetails(by: uid)
    }
}
