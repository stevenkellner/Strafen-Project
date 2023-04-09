//
//  FineGetFunction.swift
//  StrafenProject
//
//  Created by Steven on 08.04.23.
//

import Foundation

struct FineGetFunction: FirebaseFunction {
    typealias ReturnType = IdentifiableList<Fine>
    
    static let functionName = "fine-get"
    
    public private(set) var clubId: ClubProperties.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
    }
}
