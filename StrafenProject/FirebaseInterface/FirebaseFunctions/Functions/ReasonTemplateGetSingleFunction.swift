//
//  ReasonTemplateGetSingleFunction.swift
//  StrafenProject
//
//  Created by Steven on 05.08.23.
//

import Foundation

struct ReasonTemplateGetSingleFunction: FirebaseFunction {
    typealias ReturnType = ReasonTemplate?
    
    static let functionName = "reasonTemplate-getSingle"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var reasonTemplateId: ReasonTemplate.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.reasonTemplateId, for: "reasonTemplateId")
    }
}

extension ReasonTemplateGetSingleFunction: FirebaseGetSingleFunction {
    typealias Element = ReasonTemplate
    
    init(clubId: ClubProperties.ID, id reasonTemplateId: ReasonTemplate.ID) {
        self.init(clubId: clubId, reasonTemplateId: reasonTemplateId)
    }
}
