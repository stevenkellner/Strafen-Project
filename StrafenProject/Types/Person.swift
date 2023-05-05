//
//  Person.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct Person: Identifiable {
    typealias ID = Tagged<(Person, id: ()), UUID>
    
    public private(set) var id: ID
    public private(set) var name: PersonName
#if !NOTIFICATION_SERVICE_EXTENSION && !WIDGET_EXTENSION
    public var fineIds: [Fine.ID]
#endif
    public var signInData: SignInData?
    public var isInvited: Bool
}

extension Person: Equatable {}

extension Person: Codable {}

extension Person: Sendable {}

extension Person: Hashable {}

#if !NOTIFICATION_SERVICE_EXTENSION && !WIDGET_EXTENSION
extension Person: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.name, for: "name")
    }
}

extension Person: RandomPlaceholder {
    static var randomPlaceholderFineIds: [Fine.ID] = []
    
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> Person {
        return Person(id: ID(), name: PersonName.randomPlaceholder(using: &generator), fineIds: Person.randomPlaceholderFineIds, signInData: nil, isInvited: Bool.random(using: &generator))
    }
}
#endif
