//
//  FineAmount.swift
//  StrafenProject
//
//  Created by Steven on 11.08.23.
//

import Foundation

enum FineAmount {
    enum Item: String, CaseIterable {
        case crateOfBeer
        
        var formatted: String {
            switch self {
            case .crateOfBeer:
                return String(localized: "fine-amount-item|crate-of-beer", comment: "Crate of beer description of fine amount item.")
            }
        }
        
        func formatted(count: Int) -> String {
            switch self {
            case .crateOfBeer:
                return String(localized: "fine-amount-item|crate-of-beer?count=\(count)", comment: "Crate of beer description of fine amount item.")
            }
        }
    }
    
    case amount(Amount)
    case item(Item, count: Int)
    
    static func * (lhs: FineAmount, rhs: Int) -> FineAmount {
        switch lhs {
        case .amount(let amount):
            return .amount(amount * rhs)
        case .item(let item, count: let count):
            return .item(item, count: count * rhs)
        }
    }
    
    static func *= (lhs: inout FineAmount, rhs: Int) {
        lhs = lhs * rhs
    }
    
    func formatted(_ style: Amount.FormatStyle = .standard) -> String {
        switch self {
        case .amount(let amount):
            return amount.formatted(style)
        case .item(let item, count: let count):
            return item.formatted(count: count)
        }
    }
    
    var isZero: Bool {
        switch self {
        case .amount(let amount):
            return amount == .zero
        case .item(_, count: let count):
            return count == 0
        }
    }
}

extension FineAmount.Item: Equatable {}

extension FineAmount.Item: Codable {}

extension FineAmount.Item: Sendable {}

extension FineAmount.Item: Hashable {}

extension FineAmount.Item: Comparable {
    static func < (lhs: FineAmount.Item, rhs: FineAmount.Item) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension FineAmount.Item: FirebaseFunctionParameterType {
    var parameter: String {
        return self.rawValue
    }
}

extension FineAmount.Item: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> FineAmount.Item {
        return FineAmount.Item.allCases.randomElement(using: &generator)!
    }
}

extension FineAmount: Equatable {}

extension FineAmount: Codable {
    private enum CodingKeys: String, CodingKey {
        case item
        case count
    }
    
    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let amount = try? container.decode(Amount.self) {
            self = .amount(amount)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let item = try container.decode(FineAmount.Item.self, forKey: .item)
            let count = try container.decode(Int.self, forKey: .count)
            self = .item(item, count: count)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .amount(let amount):
            var container = encoder.singleValueContainer()
            try container.encode(amount)
        case .item(let item, count: let count):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(item, forKey: .item)
            try container.encode(count, forKey: .count)
        }
    }
}

extension FineAmount: Sendable {}

extension FineAmount: Hashable {}

#if !WIDGET_EXTENSION
extension FineAmount: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        switch self {
        case .amount(let amount):
            FirebaseFunctionParameter(amount)
        case .item(let item, count: let count):
            FirebaseFunctionParameter(item, for: "item")
            FirebaseFunctionParameter(count, for: "count")
        }
    }
}
#endif

extension FineAmount: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> FineAmount {
        if Bool.random(using: &generator) {
            return .amount(Amount.randomPlaceholder(using: &generator))
        } else {
            return .item(FineAmount.Item.randomPlaceholder(using: &generator), count: Int.random(in: 1...5, using: &generator))
        }
    }
}

struct TotalFineAmount {
    
    let amount: Amount
    
    let items: [FineAmount.Item: Int]
    
    init(amount: Amount, items: [FineAmount.Item: Int]) {
        self.amount = amount
        self.items = items
    }
    
    static var zero: TotalFineAmount {
        return TotalFineAmount(amount: .zero, items: [:])
    }
    
    static func + (lhs: TotalFineAmount, rhs: FineAmount) -> TotalFineAmount {
        switch rhs {
        case .amount(let amount):
            return TotalFineAmount(amount: lhs.amount + amount, items: lhs.items)
        case .item(let item, count: let count):
            var items = lhs.items
            items[item, default: 0] += count
            return TotalFineAmount(amount: lhs.amount, items: items)
        }
    }
    
    static func += (lhs: inout TotalFineAmount, rhs: FineAmount) {
        lhs = lhs + rhs
    }
    
    func formatted(_ style: Amount.FormatStyle = .standard) -> String {
        if self.items == [:] {
            return self.amount.formatted(style)
        }
        let itemsDescription = self.items.reduce(into: "") { result, item in
            if result != "" {
                result += ", "
            }
            result += item.key.formatted(count: item.value)
        }
        if self.amount == .zero {
            return itemsDescription
        }
        return "\(self.amount.formatted(style)), \(itemsDescription)"
    }
}

extension TotalFineAmount: Equatable {}

extension TotalFineAmount: Comparable {
    static func < (lhs: TotalFineAmount, rhs: TotalFineAmount) -> Bool {
        if lhs.amount != rhs.amount {
            return lhs.amount < rhs.amount
        }
        for item in FineAmount.Item.allCases.sorted() {
            let lhsCount = lhs.items[item]
            let rhsCount = rhs.items[item]
            if let lhsCount, let rhsCount {
                return lhsCount < rhsCount
            }
            if lhsCount != nil {
                return true
            }
            if rhsCount != nil {
                return false
            }
        }
        return false
    }
}

