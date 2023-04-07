//
//  Fine.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct Fine {
    typealias ID = Tagged<(Fine, id: ()), UUID>
    
    public private(set) var id: ID
    public private(set) var personId: Person.ID
    public private(set) var payedState: PayedState
    public private(set) var number: UInt
    public private(set) var date: Date
    public private(set) var fineReason: FineReason
}

extension Fine: Equatable {
    public static func ==(lhs: Fine, rhs: Fine) -> Bool {
        return lhs.id == rhs.id &&
            lhs.personId == rhs.personId &&
            lhs.payedState == rhs.payedState &&
            lhs.number == rhs.number &&
            Calendar.current.isDate(lhs.date, equalTo: rhs.date, toGranularity: .nanosecond) &&
            lhs.fineReason == rhs.fineReason
    }
}

extension Fine: Codable {}

extension Fine: Sendable {}

extension Fine: Hashable {}

extension Fine: RandomPlaceholder {
    static var randomPlaceholderPersonIds: [Person.ID] = []
    
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> Fine {
        return Fine(
            id: ID(),
            personId: Fine.randomPlaceholderPersonIds.randomElement(using: &generator) ?? Person.ID(),
            payedState: PayedState.randomPlaceholder(using: &generator),
            number: UInt.random(in: 1..<10, using: &generator),
            date: Date(timeIntervalSinceNow: TimeInterval.random(in: -31536000..<0, using: &generator)),
            fineReason: FineReason.randomPlaceholder(using: &generator)
        )
    }
}
