//
//  PersonRegisterFunction.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

struct PersonRegisterFunction: FirebaseFunction {
    typealias ReturnType = ClubProperties
    
    static let functionName = "person-register"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var personId: Person.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.personId, for: "personId")
    }
}
