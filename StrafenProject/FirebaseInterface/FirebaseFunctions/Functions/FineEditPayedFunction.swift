//
//  FineEditPayedFunction.swift
//  StrafenProject
//
//  Created by Steven on 08.04.23.
//

import Foundation

struct FineEditPayedFunction: FirebaseFunction {
    
    static let functionName = "fine-editPayed"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var fineId: Fine.ID
    
    public private(set) var payedState: PayedState
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.fineId, for: "fineId")
        FirebaseFunctionParameter(self.payedState, for: "payedState")
    }
}
