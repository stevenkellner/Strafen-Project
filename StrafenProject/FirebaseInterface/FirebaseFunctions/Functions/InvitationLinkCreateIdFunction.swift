//
//  InvitationLinkCreateIdFunction.swift
//  StrafenProject
//
//  Created by Steven on 11.04.23.
//

import Foundation

struct InvitationLinkCreateIdFunction: FirebaseFunction {
    typealias ReturnType = String
    
    static let functionName = "invitationLink-createId"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var personId: Person.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.personId, for: "personId")
    }
}
