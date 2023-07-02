//
//  PaypalMeSetFunction.swift
//  StrafenProject
//
//  Created by Steven on 02.07.23.
//

import Foundation

struct PaypalMeSetFunction: FirebaseFunction {
    
    static let functionName = "paypalMe-set"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var paypalMeLink: String?
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.paypalMeLink, for: "paypalMeLink")
    }
}
