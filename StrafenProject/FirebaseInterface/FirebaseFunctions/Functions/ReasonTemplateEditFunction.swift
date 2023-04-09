//
//  ReasonTemplateEditFunction.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

struct ReasonTemplateEditFunction: FirebaseFunction {
    
    static let functionName = "reasonTemplate-edit"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var editType: EditType
    
    public private(set) var reasonTemplateId: ReasonTemplate.ID
    
    public private(set) var reasonTemplate: ReasonTemplate?
    
    private init(clubId: ClubProperties.ID, editType: EditType, reasonTemplateId: ReasonTemplate.ID, reasonTemplate: ReasonTemplate?) {
        self.clubId = clubId
        self.editType = editType
        self.reasonTemplateId = reasonTemplateId
        self.reasonTemplate = reasonTemplate
    }
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.editType, for: "editType")
        FirebaseFunctionParameter(self.reasonTemplateId, for: "reasonTemplateId")
        FirebaseFunctionParameter(self.reasonTemplate, for: "reasonTemplate")
    }
}

extension ReasonTemplateEditFunction {
    static func add(clubId: ClubProperties.ID, reasonTemplate: ReasonTemplate) -> ReasonTemplateEditFunction {
        return ReasonTemplateEditFunction(clubId: clubId, editType: .add, reasonTemplateId: reasonTemplate.id, reasonTemplate: reasonTemplate)
    }
    
    static func update(clubId: ClubProperties.ID, reasonTemplate: ReasonTemplate) -> ReasonTemplateEditFunction {
        return ReasonTemplateEditFunction(clubId: clubId, editType: .update, reasonTemplateId: reasonTemplate.id, reasonTemplate: reasonTemplate)
    }
    
    static func delete(clubId: ClubProperties.ID, reasonTemplateId: ReasonTemplate.ID) -> ReasonTemplateEditFunction {
        return ReasonTemplateEditFunction(clubId: clubId, editType: .delete, reasonTemplateId: reasonTemplateId, reasonTemplate: nil)
    }
}
