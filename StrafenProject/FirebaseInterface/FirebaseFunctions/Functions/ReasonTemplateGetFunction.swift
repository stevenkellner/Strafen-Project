//
//  ReasonTemplateGetFunction.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

struct ReasonTemplateGetFunction: FirebaseFunction {
    typealias ReturnType = IdentifiableList<ReasonTemplate>
    
    static let functionName = "reasonTemplate-get"
    
    public private(set) var clubId: ClubProperties.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
    }
}

extension ReasonTemplateGetFunction: FirebaseGetFunction {
    typealias Element = ReasonTemplate
}
