//
//  ClubGetIdFunction.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct ClubGetIdFunction: FirebaseFunction {
    typealias ReturnType = ClubProperties.ID
    
    static let functionName = "club-getId"
    
    public private(set) var identifier: String
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.identifier, for: "identifier")
    }
}

extension ClubGetIdFunction: Sendable {}
