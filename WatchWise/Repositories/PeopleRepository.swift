//
//  PeopleRepository.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 02/09/23.
//

import Foundation
import Alamofire

class PeopleRepository {
    
    func getPersonDetails(by personId: Int32, completion: @escaping (Person?) -> Void) {
        APIManager.getPersonDetails(personId: personId) { (result: AFResult<Person>) in
            switch result {
            case .success(let person):
                completion(person)
            case .failure(let error):
                print("Error getting person details: \(error)")
            }
        }
    }
}
