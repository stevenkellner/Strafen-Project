//
//  ReasonTemplateGetChangesFunction.swift
//  StrafenProject
//
//  Created by Steven on 05.08.23.
//

import Foundation

struct ReasonTemplateGetChangesFunction: FirebaseFunction {
    typealias ReturnType = [Deletable<ReasonTemplate>]
    
    static let functionName = "reasonTemplate-getChanges"
    
    public private(set) var clubId: ClubProperties.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
    }
}

extension ReasonTemplateGetChangesFunction: FirebaseGetChangesFunction {
    typealias Element = ReasonTemplate
}
