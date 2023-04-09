//
//  FineEditFunction.swift
//  StrafenProject
//
//  Created by Steven on 08.04.23.
//

import Foundation

struct FineEditFunction: FirebaseFunction {
    
    static let functionName = "fine-edit"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var editType: EditType
    
    public private(set) var fineId: Fine.ID
    
    public private(set) var fine: Fine?
    
    private init(clubId: ClubProperties.ID, editType: EditType, fineId: Fine.ID, fine: Fine?) {
        self.clubId = clubId
        self.editType = editType
        self.fineId = fineId
        self.fine = fine
    }
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.editType, for: "editType")
        FirebaseFunctionParameter(self.fineId, for: "fineId")
        FirebaseFunctionParameter(self.fine, for: "fine")
    }
}

extension FineEditFunction {
    static func add(clubId: ClubProperties.ID, fine: Fine) -> FineEditFunction {
        return FineEditFunction(clubId: clubId, editType: .add, fineId: fine.id, fine: fine)
    }
    
    static func update(clubId: ClubProperties.ID, fine: Fine) -> FineEditFunction {
        return FineEditFunction(clubId: clubId, editType: .update, fineId: fine.id, fine: fine)
    }
    
    static func delete(clubId: ClubProperties.ID, fineId: Fine.ID) -> FineEditFunction {
        return FineEditFunction(clubId: clubId, editType: .delete, fineId: fineId, fine: nil)        
    }
}
