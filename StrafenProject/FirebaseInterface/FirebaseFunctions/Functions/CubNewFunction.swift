//
//  CubNewFunction.swift
//  StrafenProject
//
//  Created by Steven on 08.04.23.
//

import Foundation

struct ClubNewFunction: FirebaseFunction {
    
    static let functionName = "club-new"
    
    public private(set) var clubProperties: ClubProperties
    
    public private(set) var personId: Person.ID
    
    public private(set) var personName: Person.PersonName
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubProperties.id, for: "clubId")
        FirebaseFunctionParameter(self.clubProperties, for: "clubProperties")
        FirebaseFunctionParameter(self.personId, for: "personId")
        FirebaseFunctionParameter(self.personName, for: "personName")
    }
}
