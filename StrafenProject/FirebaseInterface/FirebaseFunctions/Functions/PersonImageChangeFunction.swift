//
//  PersonImageChangeFunction.swift
//  StrafenProject
//
//  Created by Steven on 12.08.23.
//

import Foundation

struct PersonImageChangeFunction: FirebaseFunction {
    
    static let functionName = "person-imageChange"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var personId: Person.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.personId, for: "personId")
    }
}
