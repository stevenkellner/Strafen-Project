//
//  PersonGetChangesFunction.swift
//  StrafenProject
//
//  Created by Steven on 05.08.23.
//

import Foundation

struct PersonGetChangesFunction: FirebaseFunction {
    typealias ReturnType = [Deletable<Person>]
    
    static let functionName = "person-getChanges"
    
    public private(set) var clubId: ClubProperties.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
    }
}

extension PersonGetChangesFunction: FirebaseGetChangesFunction {
    typealias Element = Person
}
