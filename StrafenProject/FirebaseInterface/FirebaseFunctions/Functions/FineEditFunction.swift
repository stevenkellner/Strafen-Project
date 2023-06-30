//
//  FineEditFunction.swift
//  StrafenProject
//
//  Created by Steven on 08.04.23.
//

import Foundation

struct FineAddFunction: FirebaseFunction {
    
    static let functionName = "fine-add"
    
    public private(set) var clubId: ClubProperties.ID
        
    public private(set) var fine: Fine
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.fine, for: "fine")
    }
}

struct FineUpdateFunction: FirebaseFunction {
    
    static let functionName = "fine-update"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var fine: Fine
        
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.fine, for: "fine")
    }
}

struct FineDeleteFunction: FirebaseFunction {
    
    static let functionName = "fine-delete"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var fineId: Fine.ID

    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.fineId, for: "fineId")
    }
}
