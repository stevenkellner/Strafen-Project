//
//  ReasonTemplate.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct ReasonTemplate: Identifiable {
    struct Counts {
        enum Item: String, CaseIterable {
            case minute
            case day
            case item
            
            var formatted: String {
                switch self {
                case .minute:
                    return String(localized: "reason-template-counts-item|minute", comment: "Minute description of reason template counts item.")
                case .day:
                    return String(localized: "reason-template-counts-item|day", comment: "Day description of reason template counts item.")
                case .item:
                    return String(localized: "reason-template-counts-item|item", comment: "Item description of reason template counts item.")
                }
            }
            
            func formatted(count: Int) -> String {
                switch self {
                case .minute:
                    return String(localized: "reason-template-counts-item|minutes?count=\(count)", comment: "Minute description of reason template counts item.")
                case .day:
                    return String(localized: "reason-template-counts-item|days?count=\(count)", comment: "Day description of reason template counts item.")
                case .item:
                    return String(localized: "reason-template-counts-item|items?count=\(count)", comment: "Item description of reason template counts item.")
                }
            }
        }
        
        public private(set) var item: Item
        public private(set) var maxCount: Int?
    }
    
    typealias ID = Tagged<(ReasonTemplate, id: ()), UUID>
    
    public private(set) var id: ID
    public private(set) var reasonMessage: String
    public private(set) var amount: Amount
    public private(set) var counts: Counts?
    
    var formatted: String {
        if let counts = self.counts {
            if let maxCount = counts.maxCount {
                return String(localized: "reason-template|formatted?reason-message=\(reasonMessage)&item=\(counts.item.formatted)&max-count?\(maxCount)", comment: "Formatted reason template with message, counts item and max count. 'reason-message' parameter is the message of the reason template. 'item' parameter is the item to repeat. 'max-count' parameter is the max count to repeat.")
            }
            return String(localized: "reason-template|formatted?reason-message=\(reasonMessage)&item=\(counts.item.formatted)", comment: "Formatted reason template with message, counts item and max count. 'reason-message' parameter is the message of the reason template. 'item' parameter is the item to repeat.")
        }
        return reasonMessage
    }
}

extension ReasonTemplate.Counts.Item: Equatable {}

extension ReasonTemplate.Counts.Item: Codable {}

extension ReasonTemplate.Counts.Item: Sendable {}

extension ReasonTemplate.Counts.Item: Hashable {}

extension ReasonTemplate.Counts.Item: FirebaseFunctionParameterType {
    var parameter: String {
        return self.rawValue
    }
}

extension ReasonTemplate.Counts.Item: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> ReasonTemplate.Counts.Item {
        return ReasonTemplate.Counts.Item.allCases.randomElement(using: &generator)!
    }
}

extension ReasonTemplate.Counts: Equatable {}

extension ReasonTemplate.Counts: Codable {}

extension ReasonTemplate.Counts: Sendable {}

extension ReasonTemplate.Counts: Hashable {}

extension ReasonTemplate.Counts: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.item, for: "item")
        FirebaseFunctionParameter(self.maxCount, for: "maxCount")
    }
}

extension ReasonTemplate.Counts: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> ReasonTemplate.Counts {
        return ReasonTemplate.Counts(
            item: ReasonTemplate.Counts.Item.randomPlaceholder(using: &generator),
            maxCount: Bool.random(using: &generator) ? nil : Int.random(in: 3...6, using: &generator)
        )
    }
}

extension ReasonTemplate: Equatable {}

extension ReasonTemplate: Codable {}

extension ReasonTemplate: Sendable {}

extension ReasonTemplate: Hashable {}

extension ReasonTemplate: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.id, for: "id")
        FirebaseFunctionParameter(self.reasonMessage, for: "reasonMessage")
        FirebaseFunctionParameter(self.amount, for: "amount")
        FirebaseFunctionParameter(self.counts, for: "counts")
    }
}

extension ReasonTemplate: RandomPlaceholder {
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
    
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> ReasonTemplate {
        return ReasonTemplate(
            id: ID(),
            reasonMessage: ReasonTemplate.randomPlaceholderReasonMessages.randomElement(using: &generator)!,
            amount: Amount.randomPlaceholder(using: &generator),
            counts: Bool.random(using: &generator) ? nil : ReasonTemplate.Counts.randomPlaceholder(using: &generator)
        )
    }
}

extension ReasonTemplate: Sortable {
    enum SortingKey: String, SortingKeyProtocol {
        case reasonMessage
        case amount
        
        func areInAscendingOrder(lhs lhsReasonTemplate: ReasonTemplate, rhs rhsReasonTemplate: ReasonTemplate) -> Bool {
            switch self {
            case .reasonMessage:
                return lhsReasonTemplate.formatted.lowercased() < rhsReasonTemplate.formatted.lowercased()
            case .amount:
                return lhsReasonTemplate.amount < rhsReasonTemplate.amount
            }
        }
        
        func formatted(order: SortingOrder) -> String {
            switch (self, order) {
            case (.reasonMessage, .ascending):
                return String(localized: "reason-template|sorting-key|reason-message-ascending", comment: "Sorting key of reason template sorted ascending by reason message.")
            case (.reasonMessage, .descending):
                return String(localized: "reason-template|sorting-key|reason-message-descending", comment: "Sorting key of reason template sorted descending by reason message.")
            case (.amount, .ascending):
                return String(localized: "reason-template|sorting-key|amount-ascending", comment: "Sorting key of reason template sorted ascending by amount.")
            case (.amount, .descending):
                return String(localized: "reason-template|sorting-key|amount-descending", comment: "Sorting key of reason template sorted descending by amount.")
            }
        }
    }
}

extension ReasonTemplate.SortingKey: Sendable {}

extension ReasonTemplate.SortingKey: Equatable {}

extension ReasonTemplate.SortingKey: Hashable {}

extension ReasonTemplate.SortingKey: Codable {}
