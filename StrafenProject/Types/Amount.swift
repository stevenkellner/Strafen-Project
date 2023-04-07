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
    
    public init(value: UInt, subUnitValue: UInt) {
        self.value = value
        self.subUnitValue = subUnitValue
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
        self.value = UInt(rawAmount)
        self.subUnitValue = UInt(rawAmount * 100) - self.value * 100
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Double(self.value) + Double(self.subUnitValue) / 100)
    }
}

extension Amount: CustomDebugStringConvertible {
    var debugDescription: String {
        return (self.value + self.subUnitValue / 100).formatted(.currency(code: "EUR"))
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
        guard value >= 0 else { return .zero }
        return Amount(value: UInt(value), subUnitValue: UInt(subUnitValue))
    }
}

extension Amount: Sendable {}

extension Amount: Hashable {}

extension Amount: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> Amount {
        let value = UInt.random(in: 0..<100, using: &generator)
        let subUnitValue = UInt.random(in: 0..<100, using: &generator)
        return Amount(value: value, subUnitValue: subUnitValue)
    }
}
