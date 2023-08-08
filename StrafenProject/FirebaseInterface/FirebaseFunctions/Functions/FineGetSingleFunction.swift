//
//  FineGetSingleFunction.swift
//  StrafenProject
//
//  Created by Steven on 05.08.23.
//

import Foundation

struct FineGetSingleFunction: FirebaseFunction {
    typealias ReturnType = Fine?
    
    static let functionName = "fine-getSingle"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var fineId: Fine.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.fineId, for: "fineId")
    }
}

extension FineGetSingleFunction: FirebaseGetSingleFunction {
    typealias Element = Fine
    
    init(clubId: ClubProperties.ID, id fineId: Fine.ID) {
        self.init(clubId: clubId, fineId: fineId)
    }
}
