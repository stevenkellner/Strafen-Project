//
//  PersonEditFunction.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

struct PersonAddFunction: FirebaseFunction {
    
    static let functionName = "person-add"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var person: Person
        
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.person, for: "person")
    }
}

struct PersonUpdateFunction: FirebaseFunction {
    
    static let functionName = "person-update"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var person: Person
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.person, for: "person")
    }
}

struct PersonDeleteFunction: FirebaseFunction {
    
    static let functionName = "person-delete"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var personId: Person.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.personId, for: "personId")
    }
}
