//
//  PersonGetCurrentFunction.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

struct PersonGetCurrentFunction: FirebaseFunction {
    struct ReturnType {
        public private(set) var id: Person.ID
        public private(set) var name: Person.PersonName
        public private(set) var fineIds: [Fine.ID]
        public private(set) var signInData: Person.SignInData
        public private(set) var isAdmin: Bool
        public private(set) var club: ClubProperties
    }
    
    static let functionName = "person-getCurrent"
    
    var parameters: FirebaseFunctionParameters {
        return FirebaseFunctionParameters()
    }
}

extension PersonGetCurrentFunction.ReturnType: Equatable {}

extension PersonGetCurrentFunction.ReturnType: Decodable {}

extension PersonGetCurrentFunction.ReturnType: Sendable {}

extension PersonGetCurrentFunction.ReturnType: Hashable {}

extension PersonGetCurrentFunction.ReturnType {
    var settingsPerson: Settings.SignedInPerson {
        return Settings.SignedInPerson(id: self.id, name: self.name, isAdmin: self.isAdmin, hashedUserId: self.signInData.hashedUserId, club: self.club)
    }
}
