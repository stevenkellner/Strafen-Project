//
//  IPerson.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

protocol IPersonName {
    var first: String { get }
    var last: String? { get }
}

extension IPersonName {
    var concrete: Person.PersonName {
        return Person.PersonName(self)
    }
}

protocol ISignInData {
    var hashedUserId: String { get }
    var signInDate: Date { get }
}

extension ISignInData {
    var concrete: Person.SignInData {
        return Person.SignInData(self)
    }
}

protocol IPerson {
    associatedtype ID: RawRepresentable where ID.RawValue == UUID
    associatedtype FineID: RawRepresentable where FineID.RawValue == UUID
    associatedtype PersonName: IPersonName
    associatedtype SignInData: ISignInData
    
    var id: ID { get }
    var name: PersonName { get }
    var fineIds: [FineID] { get }
    var signInData: SignInData? { get }
}

extension IPerson {
    var concrete: Person {
        return Person(self)
    }
}
