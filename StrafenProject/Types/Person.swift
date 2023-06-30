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
        FirebaseFunctionParameter(self.id, for: "id")
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

#if !NOTIFICATION_SERVICE_EXTENSION && !WIDGET_EXTENSION
extension Person: Sortable {
    enum SortingKey: String, CaseIterable, SortingKeyProtocolWithContext {
        case name
        case amount
        
        func areInAscendingOrder(lhs lhsPerson: Person, rhs rhsPerson: Person, context appProperties: AppProperties) -> Bool {
            switch self {
            case .name:
                return lhsPerson.name.formatted().lowercased() < rhsPerson.name.formatted().lowercased()
            case .amount:
                let lhsAmount = appProperties.fines(of: lhsPerson).unpayedAmount
                let rhsAmount = appProperties.fines(of: rhsPerson).unpayedAmount
                guard lhsAmount != .zero && rhsAmount != .zero else {
                    return SortingKey.name.areInAscendingOrder(lhs: lhsPerson, rhs: rhsPerson, context: appProperties)
                }
                guard lhsAmount != .zero else {
                    return false
                }
                guard rhsAmount != .zero else {
                    return true
                }
                return lhsAmount < rhsAmount
            }
        }
        
        func formatted(order: SortingOrder) -> String {
            switch (self, order) {
            case (.name, .ascending):
                return String(localized: "person|sorting-key|name-ascending", comment: "Sorting key of person sorted ascending by name.")
            case (.name, .descending):
                return String(localized: "person|sorting-key|name-descending", comment: "Sorting key of person sorted descending by name.")
            case (.amount, .ascending):
                return String(localized: "person|sorting-key|amount-ascending", comment: "Sorting key of person sorted ascending by amount.")
            case (.amount, .descending):
                return String(localized: "person|sorting-key|amount-descending", comment: "Sorting key of person sorted descending by amount.")
            }
        }
    }
}
#else
extension Person: Sortable {
    enum SortingKey: String, SortingKeyProtocol {
        case name
        
        func areInAscendingOrder(lhs lhsPerson: Person, rhs rhsPerson: Person) -> Bool {
            switch self {
            case .name:
                return lhsPerson.name.formatted().lowercased() < rhsPerson.name.formatted().lowercased()
            }
        }
        
        func formatted(order: SortingOrder) -> String {
            switch (self, order) {
            case (.name, .ascending):
                return String(localized: "person|sorting-key|name-ascending", comment: "Sorting key of person sorted ascending by name.")
            case (.name, .descending):
                return String(localized: "person|sorting-key|name-descending", comment: "Sorting key of person sorted descending by name.")
            }
        }
    }
}
#endif

extension Person.SortingKey: Sendable {}

extension Person.SortingKey: Equatable {}

extension Person.SortingKey: Hashable {}

extension Person.SortingKey: Codable {}

#if !NOTIFICATION_SERVICE_EXTENSION && !WIDGET_EXTENSION
protocol PersonWithFines {
    var id: Person.ID { get }
    var name: PersonName { get }
    var fineIds: [Fine.ID] { get }
    
}

extension Person: PersonWithFines {}
#endif
