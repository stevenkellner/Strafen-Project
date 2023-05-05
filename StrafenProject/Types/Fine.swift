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
    public var payedState: PayedState
    public private(set) var date: Date
    public private(set) var reasonMessage: String
    public private(set) var amount: Amount
}

extension Fine: Equatable {
    public static func ==(lhs: Fine, rhs: Fine) -> Bool {
        return lhs.id == rhs.id &&
            lhs.personId == rhs.personId &&
            lhs.payedState == rhs.payedState &&
            Calendar.current.isDate(lhs.date, equalTo: rhs.date, toGranularity: .nanosecond) &&
            lhs.reasonMessage == rhs.reasonMessage &&
            lhs.amount == rhs.amount
    }
}

extension Fine: Codable {}

extension Fine: Sendable {}

extension Fine: Hashable {}

#if !WIDGET_EXTENSION
extension Fine: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.personId, for: "personId")
        FirebaseFunctionParameter(self.payedState, for: "payedState")
        FirebaseFunctionParameter(self.date, for: "date")
        FirebaseFunctionParameter(self.reasonMessage, for: "reasonMessage")
        FirebaseFunctionParameter(self.amount, for: "amount")
    }
}
#endif

extension Fine: RandomPlaceholder {
    static var randomPlaceholderPersonIds: [Person.ID] = []
    
    static let randomPlaceholderReasonMessages = [
        "Lorem ipsum dolor",
        "sit amet",
        "consetetur sadipscing elitr",
        "sed diam nonumy",
        "eirmod tempor",
        "invidunt ut labore et dolore magna",
        "aliquyam erat, sed diam voluptua",
        "At vero eos et accusam",
        "et justo duo dolores",
        "et ea rebum",
        "Stet clita kasd gubergren",
        "no sea takimata sanctus est"
    ]
    
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> Fine {
        return Fine(
            id: ID(),
            personId: Fine.randomPlaceholderPersonIds.randomElement(using: &generator) ?? Person.ID(),
            payedState: PayedState.randomPlaceholder(using: &generator),
            date: Date(timeIntervalSinceNow: TimeInterval.random(in: -31536000..<0, using: &generator)),
            reasonMessage: Fine.randomPlaceholderReasonMessages.randomElement(using: &generator)!,
            amount: Amount.randomPlaceholder(using: &generator)
        )
    }
}

extension Sequence where Element == Fine {
    var totalAmount: Amount {
        return self.reduce(into: .zero) { result, fine in
            result += fine.amount
        }
    }
    
    var payedAmount: Amount {
        return self.reduce(into: .zero) { result, fine in
            guard fine.payedState == .payed else {
                return
            }
            result += fine.amount
        }
    }
    
    var unpayedAmount: Amount {
        return self.reduce(into: .zero) { result, fine in
            guard fine.payedState == .unpayed else {
                return
            }
            result += fine.amount
        }
    }
}
