//
//  PeopleDetailsViewModel.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 02/09/23.
//

import Combine
import SwiftUI

class PersonDetailsViewModel: ObservableObject {
    @Published var person: Person?
    private var personId: Int32
    private var repository: PeopleRepository
    
    init(personId: Int32) {
        self.personId = personId
        self.repository = PeopleRepository()
    }
    
    func getPersonDetails() {
        repository.getPersonDetails(by: personId) { person in
            var sortedPerson = person
            
            if let cast = person?.credits?.cast {
                sortedPerson?.credits?.cast = cast.sorted(by: { (Double($0.voteCount) * $0.voteAverage) > (Double($1.voteCount) * $1.voteAverage) })
            }
            
            if let crew = person?.credits?.crew {
                sortedPerson?.credits?.crew = crew.sorted(by: { (Double($0.voteCount) * $0.voteAverage) > (Double($1.voteCount) * $1.voteAverage) })
            }
            
            self.person = sortedPerson
        }
    }
}
