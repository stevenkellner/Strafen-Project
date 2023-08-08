//
//  FineGetChangesFunction.swift
//  StrafenProject
//
//  Created by Steven on 05.08.23.
//

import Foundation

struct FineGetChangesFunction: FirebaseFunction {
    typealias ReturnType = [Deletable<Fine>]
    
    static let functionName = "fine-getChanges"
    
    public private(set) var clubId: ClubProperties.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
    }
}

extension FineGetChangesFunction: FirebaseGetChangesFunction {
    typealias Element = Fine
}
