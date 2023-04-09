//
//  PersonGetFunction.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

struct PersonGetFunction: FirebaseFunction {
    typealias ReturnType = IdentifiableList<Person>
    
    static let functionName = "person-get"
    
    public private(set) var clubId: ClubProperties.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
    }
}
