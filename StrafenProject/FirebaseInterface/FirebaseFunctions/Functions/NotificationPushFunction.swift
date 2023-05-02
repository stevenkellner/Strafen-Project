//
//  NotificationPushFunction.swift
//  StrafenProject
//
//  Created by Steven on 01.05.23.
//

import Foundation

struct NotificationPushFunction: FirebaseFunction {
    
    static let functionName = "notification-push"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var personId: Person.ID
    
    public private(set) var payload: NotificationPayload
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.personId, for: "personId")
        FirebaseFunctionParameter(self.payload, for: "payload")
    }
}
