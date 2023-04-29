//
//  PersonMakeManagerFunction.swift
//  StrafenProject
//
//  Created by Steven on 29.04.23.
//

import Foundation

struct PersonMakeManagerFunction: FirebaseFunction {
    
    static let functionName = "person-makeManager"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var personId: Person.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.personId, for: "personId")
    }
}
