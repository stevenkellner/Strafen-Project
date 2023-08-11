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
    public private(set) var date: UtcDate
    public private(set) var reasonMessage: String
    public private(set) var amount: FineAmount
}

extension Fine: Equatable {}

extension Fine: Codable {}

extension Fine: Sendable {}

extension Fine: Hashable {}

#if !WIDGET_EXTENSION
extension Fine: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.id, for: "id")
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
            date: UtcDate.randomPlaceholder(using: &generator),
            reasonMessage: Fine.randomPlaceholderReasonMessages.randomElement(using: &generator)!,
            amount: FineAmount.randomPlaceholder(using: &generator)
        )
    }
}

#if !NOTIFICATION_SERVICE_EXTENSION && !WIDGET_EXTENSION
extension Fine: ChangeObservable {
    
    typealias GetSingleFunction = FineGetSingleFunction
    
    static let changesKey = "fines"
}

extension Fine: ListCachable {
    static let cacheFilePath = "fines"
}

extension Fine: AppPropertiesList {
    typealias GetFunction = FineGetFunction
    typealias GetChangesFunction = FineGetChangesFunction
}
#endif

extension Fine: Sortable {
    enum SortingKey: String, SortingKeyProtocol {
        case date
        case reasonMessage
        case amount
        
        func areInAscendingOrder(lhs lhsFine: Fine, rhs rhsFine: Fine) -> Bool {
            switch self {
            case .date:
                return lhsFine.date < rhsFine.date
            case .reasonMessage:
                return lhsFine.reasonMessage.lowercased() < rhsFine.reasonMessage.lowercased()
            case .amount:
                switch (lhsFine.amount, rhsFine.amount) {
                case (.amount(let lhsAmount), .amount(let rhsAmount)):
                    return lhsAmount < rhsAmount
                case (.item(let lhsItem, count: let lhsCount), .item(let rhsItem, count: let rhsCount)):
                    guard lhsItem == rhsItem else {
                        return lhsItem < rhsItem
                    }
                    return lhsCount < rhsCount
                case (.amount(_), .item(_, count: _)):
                    return true
                case (.item(_, count: _), .amount(_)):
                    return false
                }
            }
        }
        
        func formatted(order: SortingOrder) -> String {
            switch (self, order) {
            case (.date, .ascending):
                return String(localized: "fine|sorting-key|date-ascending", comment: "Sorting key of fine sorted ascending by date.")
            case (.date, .descending):
                return String(localized: "fine|sorting-key|date-descending", comment: "Sorting key of fine sorted descending by date.")
            case (.reasonMessage, .ascending):
                return String(localized: "fine|sorting-key|reason-message-ascending", comment: "Sorting key of fine sorted ascending by reason message.")
            case (.reasonMessage, .descending):
                return String(localized: "fine|sorting-key|reason-message-descending", comment: "Sorting key of fine sorted descending by reason message.")
            case (.amount, .ascending):
                return String(localized: "fine|sorting-key|amount-ascending", comment: "Sorting key of fine sorted ascending by amount.")
            case (.amount, .descending):
                return String(localized: "fine|sorting-key|amount-descending", comment: "Sorting key of fine sorted descending by amount.")
            }
        }
    }
}

extension Fine.SortingKey: Sendable {}

extension Fine.SortingKey: Equatable {}

extension Fine.SortingKey: Hashable {}

extension Fine.SortingKey: Codable {}

extension Sequence where Element == Fine {
    var totalAmount: TotalFineAmount {
        return self.reduce(into: .zero) { result, fine in
            result += fine.amount
        }
    }
    
    var payedAmount: TotalFineAmount {
        return self.reduce(into: .zero) { result, fine in
            guard fine.payedState == .payed else {
                return
            }
            result += fine.amount
        }
    }
    
    var unpayedAmount: TotalFineAmount {
        return self.reduce(into: .zero) { result, fine in
            guard fine.payedState == .unpayed else {
                return
            }
            result += fine.amount
        }
    }
}
