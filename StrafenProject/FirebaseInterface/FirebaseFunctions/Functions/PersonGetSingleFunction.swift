//
//  PersonGetSingleFunction.swift
//  StrafenProject
//
//  Created by Steven on 05.08.23.
//

import Foundation

struct PersonGetSingleFunction: FirebaseFunction {
    typealias ReturnType = Person?
    
    static let functionName = "person-getSingle"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var personId: Person.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.personId, for: "personId")
    }
}

extension PersonGetSingleFunction: FirebaseGetSingleFunction {
    typealias Element = Person
    
    init(clubId: ClubProperties.ID, id personId: Person.ID) {
        self.init(clubId: clubId, personId: personId)
    }
}
