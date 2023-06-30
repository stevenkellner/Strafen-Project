//
//  ReasonTemplateEditFunction.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

struct ReasonTemplateAddFunction: FirebaseFunction {
    
    static let functionName = "reasonTemplate-add"
    
    public private(set) var clubId: ClubProperties.ID
        
    public private(set) var reasonTemplate: ReasonTemplate
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.reasonTemplate, for: "reasonTemplate")
    }
}

struct ReasonTemplateUpdateFunction: FirebaseFunction {
    
    static let functionName = "reasonTemplate-update"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var reasonTemplate: ReasonTemplate
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.reasonTemplate, for: "reasonTemplate")
    }
}

struct ReasonTemplateDeleteFunction: FirebaseFunction {
    
    static let functionName = "reasonTemplate-delete"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var reasonTemplateId: ReasonTemplate.ID
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.reasonTemplateId, for: "reasonTemplateId")
    }
}
