//
//  PersonEditFunction.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

struct PersonEditFunction: FirebaseFunction {
    
    static let functionName = "person-edit"
    
    public private(set) var clubId: ClubProperties.ID
    
    public private(set) var editType: EditType
    
    public private(set) var personId: Person.ID
    
    public private(set) var person: Person?
    
    private init(clubId: ClubProperties.ID, editType: EditType, personId: Person.ID, person: Person?) {
        self.clubId = clubId
        self.editType = editType
        self.personId = personId
        self.person = person
    }
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.editType, for: "editType")
        FirebaseFunctionParameter(self.personId, for: "personId")
        FirebaseFunctionParameter(self.person, for: "person")
    }
}

extension PersonEditFunction {
    static func add(clubId: ClubProperties.ID, person: Person) -> PersonEditFunction {
        return PersonEditFunction(clubId: clubId, editType: .add, personId: person.id, person: person)
    }
    
    static func update(clubId: ClubProperties.ID, person: Person) -> PersonEditFunction {
        return PersonEditFunction(clubId: clubId, editType: .update, personId: person.id, person: person)
    }
    
    static func delete(clubId: ClubProperties.ID, personId: Person.ID) -> PersonEditFunction {
        return PersonEditFunction(clubId: clubId, editType: .delete, personId: personId, person: nil)
    }
}
