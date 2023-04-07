//
//  Person.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct Person {
    typealias ID = Tagged<(Person, id: ()), UUID>
    
    struct PersonName {
        public private(set) var first: String
        public private(set) var last: String?
    }
    
    struct SignInData {
        public private(set) var hashedUserId: String
        public private(set) var signInDate: Date
    }
    
    public private(set) var id: ID
    public private(set) var name: PersonName
    public private(set) var fineIds: [Fine.ID]
    public private(set) var signInData: SignInData?
}

extension Person.PersonName: Equatable {}

extension Person.PersonName: Codable {}

extension Person.PersonName: Sendable {}

extension Person.PersonName: Hashable {}

extension Person.PersonName: RandomPlaceholder {
    private static let randomPlaceholderNames = [
        Person.PersonName(first: "Longin", last: "D'Agostino"),
        Person.PersonName(first: "Suresh", last: "Thorburn"),
        Person.PersonName(first: "Meltem", last: "Ferrara"),
        Person.PersonName(first: "Muthoni", last: "Kovačevič"),
        Person.PersonName(first: "Pier", last: "Sharma"),
        Person.PersonName(first: "Deimne", last: "Alfero"),
        Person.PersonName(first: "Yeong-Gi", last: "Vargas"),
        Person.PersonName(first: "Dejan", last: "Alfero"),
        Person.PersonName(first: "Rian", last: "Keane"),
        Person.PersonName(first: "Jahel", last: "Spiros"),
        Person.PersonName(first: "Bronisław", last: "MacLeòid"),
        Person.PersonName(first: "Elon", last: "Field"),
        Person.PersonName(first: "Stipan", last: "Haig"),
        Person.PersonName(first: "Aminah", last: "Henriksen"),
        Person.PersonName(first: "Helve", last: "Lyne"),
        Person.PersonName(first: "Hammurabi"),
        Person.PersonName(first: "Veaceslav"),
        Person.PersonName(first: "Dagný"),
        Person.PersonName(first: "Gerlof"),
        Person.PersonName(first: "Everett"),
        Person.PersonName(first: "Dalimil"),
        Person.PersonName(first: "Eadwald"),
        Person.PersonName(first: "Artyom"),
        Person.PersonName(first: "Cerys"),
        Person.PersonName(first: "Maunu")
    ]
    
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> Person.PersonName {
        return Person.PersonName.randomPlaceholderNames.randomElement(using: &generator)!
    }
}

extension Person.SignInData: Equatable {}

extension Person.SignInData: Codable {}

extension Person.SignInData: Sendable {}

extension Person.SignInData: Hashable {}

extension Person: Equatable {}

extension Person: Codable {}

extension Person: Sendable {}

extension Person: Hashable {}

extension Person: RandomPlaceholder {
    static var randomPlaceholderFineIds: [Fine.ID] = []
    
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> Person {
        return Person(id: ID(), name: PersonName.randomPlaceholder(using: &generator), fineIds: Person.randomPlaceholderFineIds, signInData: nil)
    }
}
