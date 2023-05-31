//
//  Amount.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct Amount {
    
    public private(set) var value: UInt
    
    @Clamping(0...99) public private(set) var subUnitValue: UInt
    
    init(value: UInt, subUnitValue: UInt) {
        self.value = value
        self.subUnitValue = subUnitValue
    }
    
    init(doubleValue: Double) {
        self.value = UInt(doubleValue.rounded(.towardZero))
        self.subUnitValue = UInt((doubleValue * 100).rounded(.towardZero)) - self.value * 100
    }
        
    var doubleValue: Double {
        return Double(self.value) + Double(self.subUnitValue) / 100
    }
}

extension Amount: Equatable {}

extension Amount: Comparable {
    static func <(lhs: Amount, rhs: Amount) -> Bool {
        if lhs.value == rhs.value {
            return lhs.subUnitValue < rhs.subUnitValue
        }
        return lhs.value < rhs.value
    }
}

extension Amount: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawAmount = try container.decode(Double.self)
        guard rawAmount >= 0 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Amount is negative.")
        }
        self.init(doubleValue: rawAmount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.doubleValue)
    }
}

extension Amount: CustomDebugStringConvertible {
    var debugDescription: String {
        return self.formatted()
    }
    
    static var currencySymbol: String {
        Locale.availableIdentifiers.compactMap { identifier in
            let locale = Locale(identifier: identifier)
            guard let code = locale.currency?.identifier else {
                return nil
            }
            guard code == "EUR" else {
                return nil
            }
            return locale.currencySymbol
        }.sorted {
            return $0.count < $1.count
        }.first ?? ""
    }
}

extension Amount: AdditiveArithmetic {
    static var zero: Amount {
        return Amount(value: 0, subUnitValue: 0)
    }
    
    static func +(lhs: Amount, rhs: Amount) -> Amount {
        let newSubUnitValue = lhs.subUnitValue + rhs.subUnitValue
        let value = lhs.value + rhs.value + newSubUnitValue / 100
        let subUnitValue = newSubUnitValue % 100
        return Amount(value: value, subUnitValue: subUnitValue)
    }
    
    static func -(lhs: Amount, rhs: Amount) -> Amount {
        let newSubUnitValue = Int(lhs.subUnitValue) - Int(rhs.subUnitValue)
        let value = Int(lhs.value) - Int(rhs.value) - (newSubUnitValue >= 0 ? 0 : 1)
        let subUnitValue = (newSubUnitValue + 100) % 100
        guard value >= 0 else {
            return .zero
        }
        return Amount(value: UInt(value), subUnitValue: UInt(subUnitValue))
    }
    
    static func *(lhs: Amount, rhs: Int) -> Amount {
        let rhs = rhs < 0 ? .zero : UInt(rhs)
        let newSubUnitValue = lhs.subUnitValue * rhs
        let value = lhs.value * rhs + newSubUnitValue / 100
        let subUnitValue = newSubUnitValue % 100
        return Amount(value: value, subUnitValue: subUnitValue)
    }
    
    static func *=(lhs: inout Amount, rhs: Int) {
        lhs = lhs * rhs
    }
}

extension Amount: Sendable {}

extension Amount: Hashable {}

extension Amount {
    func formatted(_ style: Amount.FormatStyle = .standard) -> String {
        return style.format(self)
    }
}

extension Amount {
    struct Strategy: ParseStrategy {
        enum FormattingError: Error {
            case invalidAmount
        }
        
        public func parse(_ value: String) throws -> Amount {
            let value = value.replacingOccurrences(of: Amount.currencySymbol, with: "")
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = .current
            guard let doubleValue = formatter.number(from: value)?.doubleValue else {
                throw FormattingError.invalidAmount
            }
            return Amount(doubleValue: doubleValue)
        }
    }
    
    enum FormatStyle: ParseableFormatStyle {
        case standard
        case short
        
        var parseStrategy: Amount.Strategy {
            return Amount.Strategy()
        }
        
        func format(_ amount: Amount) -> String {
                let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = .current
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            formatter.currencyCode = "EUR"
            if self == .short && amount.subUnitValue == .zero {
                formatter.maximumFractionDigits = 0
                formatter.minimumFractionDigits = 0
            }
            return formatter.string(from: amount.doubleValue as NSNumber) ?? amount.doubleValue.formatted(.currency(code: "EUR"))
        }
    }
}

extension ParseableFormatStyle where Self == Amount.FormatStyle {
    static func amount(_ style: Amount.FormatStyle) -> Amount.FormatStyle {
        return style
    }
}

#if !WIDGET_EXTENSION
extension Amount: FirebaseFunctionParameterType {
    var parameter: Double {
        return Double(self.value) + Double(self.subUnitValue) / 100
    }
}
#endif

extension Amount: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> Amount {
        let value = UInt.random(in: 0..<100, using: &generator)
        let subUnitValue = UInt.random(in: 0..<100, using: &generator)
        return Amount(value: value, subUnitValue: subUnitValue)
    }
}
