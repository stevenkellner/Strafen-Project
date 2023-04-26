//
//  Fine.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct Fine: Identifiable {
    typealias ID = Tagged<(Fine, id: ()), UUID>
    
    public private(set) var id: ID
    public private(set) var personId: Person.ID
    public private(set) var payedState: PayedState
    public private(set) var number: UInt
    public private(set) var date: Date
    public private(set) var fineReason: FineReason
    
    var totalAmount: Amount {
        return self.fineReason.amount * self.number
    }
    
    var formatted: String {
        return self.fineReason.reasonMessage
    }
    
    var isPayed: Bool {
        switch self.payedState {
        case .payed(payDate: _):
            return true
        case .unpayed:
            return false
        }
    }
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

extension Fine: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.personId, for: "personId")
        FirebaseFunctionParameter(self.payedState, for: "payedState")
        FirebaseFunctionParameter(self.number, for: "number")
        FirebaseFunctionParameter(self.date, for: "date")
        FirebaseFunctionParameter(self.fineReason, for: "fineReason")
    }
}

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

extension Sequence where Element == Fine {
    var totalAmount: Amount {
        return self.reduce(into: .zero) { result, fine in
            result += fine.totalAmount
        }
    }
    
    var payedAmount: Amount {
        return self.reduce(into: .zero) { result, fine in
            guard case .payed(payDate: _) = fine.payedState else {
                return
            }
            result += fine.totalAmount
        }
    }
    
    var unpayedAmount: Amount {
        return self.reduce(into: .zero) { result, fine in
            guard case .unpayed = fine.payedState else {
                return
            }
            result += fine.totalAmount
        }
    }
}
