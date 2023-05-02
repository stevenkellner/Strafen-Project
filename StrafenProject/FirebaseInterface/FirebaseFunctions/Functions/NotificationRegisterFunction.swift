//
//  NotificationRegisterFunction.swift
//  StrafenProject
//
//  Created by Steven on 01.05.23.
//

import Foundation

struct NotificationRegisterFunction: FirebaseFunction {
        
    static let functionName = "notification-register"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var personId: Person.ID
    
    public private(set) var token: String
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.personId, for: "personId")
        FirebaseFunctionParameter(self.token, for: "token")
    }
}
