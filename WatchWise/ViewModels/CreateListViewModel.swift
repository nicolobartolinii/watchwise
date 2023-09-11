//
//  CreateListViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 10/09/23.
//

import Foundation

class CreateListViewModel: ObservableObject {
    @Published var listId: String = ""
    @Published var listIdError: Bool = false
    @Published var listName: String = ""
    @Published var listNameError: Bool = false
    @Published var listType: String = "both"
    @Published var showLoadingToast: Bool = false
    @Published var showCompletedToast: Bool = false
    
    private var currentUserUid: String
    private var firestoreService: FirestoreService
    
    init(currentUserUid: String) {
        self.currentUserUid = currentUserUid
        self.firestoreService = FirestoreService()
    }
    
    func validateListId() -> Bool {
        // Controlla se l'ID della lista contiene caratteri non validi
        let invalidCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789_.").inverted
        if listId.rangeOfCharacter(from: invalidCharacters) != nil {
            listIdError = true
            return false
        }
        
        // Controlla la lunghezza dell'ID della lista
        if listId.count < 3 || listId.count > 25 {
            listIdError = true
            return false
        }
        
        listIdError = false
        return true
    }
    
    func validateListName() -> Bool {
        // Controlla la lunghezza del nome della lista
        if listName.count < 3 || listName.count > 20 {
            listNameError = true
            return false
        }
        
        listNameError = false
        return true
    }
    
    func createNewList() async {
        let isListIdValid = validateListId()
        let isListNameValid = validateListName()
        
        if !isListIdValid || !isListNameValid {
            return
        }
        
        showLoadingToast = true
        
        do {
            try await firestoreService.createNewList(for: currentUserUid, listId: listId, listName: listName, listType: listType)
            showLoadingToast = false
            showCompletedToast = true
        } catch {
            print("Errore nella creazione della lista: \(error)")
        }
        showLoadingToast = false
    }
}
