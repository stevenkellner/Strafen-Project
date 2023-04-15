//
//  InvitationLinkGetPersonFunction.swift
//  StrafenProject
//
//  Created by Steven on 11.04.23.
//

import Foundation

struct InvitationLinkGetPersonFunction: FirebaseFunction {
    struct ReturnType {
        public private(set) var id: Person.ID
        public private(set) var name: Person.PersonName
        public private(set) var fineIds: [Fine.ID]
        public private(set) var club: ClubProperties
    }
    
    static let functionName = "invitationLink-getPerson"
    
    public private(set) var invitationLinkId: String
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.invitationLinkId, for: "invitationLinkId")
    }
}

extension InvitationLinkGetPersonFunction.ReturnType: Equatable {}

extension InvitationLinkGetPersonFunction.ReturnType: Decodable {}

extension InvitationLinkGetPersonFunction.ReturnType: Sendable {}

extension InvitationLinkGetPersonFunction.ReturnType: Hashable {}

extension InvitationLinkGetPersonFunction.ReturnType: Identifiable {}
