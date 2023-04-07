//
//  Tagged.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

@dynamicMemberLookup
struct Tagged<Tag, RawValue> {
    public private(set) var rawValue: RawValue
    
    init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
        
    init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    func map<U>(_ transform: (RawValue) -> U) -> Tagged<Tag, U> {
        return Tagged<Tag, U>(rawValue: transform(self.rawValue))
    }
}

extension Tagged {
    subscript<T>(dynamicMember keyPath: KeyPath<RawValue, T>) -> T {
        return self.rawValue[keyPath: keyPath]
    }
}

extension Tagged: CustomStringConvertible {
    var description: String {
        return String(describing: self.rawValue)
    }
}

extension Tagged: RawRepresentable {}

extension Tagged: CustomPlaygroundDisplayConvertible {
    var playgroundDescription: Any {
        return self.rawValue
    }
}

// MARK: - Conditional Conformances

extension Tagged: Collection where RawValue: Collection {
    typealias Element = RawValue.Element
    typealias Index = RawValue.Index
    
    func index(after i: RawValue.Index) -> RawValue.Index {
        return rawValue.index(after: i)
    }
    
    subscript(position: RawValue.Index) -> RawValue.Element {
        return rawValue[position]
    }
    
    var startIndex: RawValue.Index {
        return rawValue.startIndex
    }
    
    var endIndex: RawValue.Index {
        return rawValue.endIndex
    }
    
    __consuming func makeIterator() -> RawValue.Iterator {
        return rawValue.makeIterator()
    }
}

extension Tagged: Comparable where RawValue: Comparable {
    static func <(lhs: Tagged, rhs: Tagged) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension Tagged: Decodable where RawValue: Decodable {
    init(from decoder: Decoder) throws {
        do {
            self.init(rawValue: try decoder.singleValueContainer().decode(RawValue.self))
        } catch {
            self.init(rawValue: try .init(from: decoder))
        }
    }
}

extension Tagged: Encodable where RawValue: Encodable {
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue)
        } catch {
            try self.rawValue.encode(to: encoder)
        }
    }
}

extension Tagged: CodingKeyRepresentable where RawValue: CodingKeyRepresentable {
    init?<T>(codingKey: T) where T: CodingKey {
        guard let rawValue = RawValue(codingKey: codingKey) else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
    
    var codingKey: CodingKey {
        self.rawValue.codingKey
    }
}

extension Tagged: Equatable where RawValue: Equatable {}

extension Tagged: Error where RawValue: Error {}

extension Tagged: Sendable where RawValue: Sendable {}

extension Tagged: LocalizedError where RawValue: Error {
    var errorDescription: String? {
        return rawValue.localizedDescription
    }
    
    var failureReason: String? {
        return (rawValue as? LocalizedError)?.failureReason
    }
    
    var helpAnchor: String? {
        return (rawValue as? LocalizedError)?.helpAnchor
    }
    
    var recoverySuggestion: String? {
        return (rawValue as? LocalizedError)?.recoverySuggestion
    }
}

extension Tagged: ExpressibleByBooleanLiteral where RawValue: ExpressibleByBooleanLiteral {
    typealias BooleanLiteralType = RawValue.BooleanLiteralType
    
    init(booleanLiteral value: RawValue.BooleanLiteralType) {
        self.init(rawValue: RawValue(booleanLiteral: value))
    }
}

extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral where RawValue: ExpressibleByExtendedGraphemeClusterLiteral {
    typealias ExtendedGraphemeClusterLiteralType = RawValue.ExtendedGraphemeClusterLiteralType
    
    init(extendedGraphemeClusterLiteral: ExtendedGraphemeClusterLiteralType) {
        self.init(rawValue: RawValue(extendedGraphemeClusterLiteral: extendedGraphemeClusterLiteral))
    }
}

extension Tagged: ExpressibleByFloatLiteral where RawValue: ExpressibleByFloatLiteral {
    typealias FloatLiteralType = RawValue.FloatLiteralType
    
    init(floatLiteral: FloatLiteralType) {
        self.init(rawValue: RawValue(floatLiteral: floatLiteral))
    }
}

extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = RawValue.IntegerLiteralType
    
    init(integerLiteral: IntegerLiteralType) {
        self.init(rawValue: RawValue(integerLiteral: integerLiteral))
    }
}

extension Tagged: ExpressibleByStringLiteral where RawValue: ExpressibleByStringLiteral {
    typealias StringLiteralType = RawValue.StringLiteralType
    
    init(stringLiteral: StringLiteralType) {
        self.init(rawValue: RawValue(stringLiteral: stringLiteral))
    }
}

extension Tagged: ExpressibleByStringInterpolation where RawValue: ExpressibleByStringInterpolation {
    typealias StringInterpolation = RawValue.StringInterpolation
    
    init(stringInterpolation: Self.StringInterpolation) {
        self.init(rawValue: RawValue(stringInterpolation: stringInterpolation))
    }
}

extension Tagged: ExpressibleByUnicodeScalarLiteral where RawValue: ExpressibleByUnicodeScalarLiteral {
    typealias UnicodeScalarLiteralType = RawValue.UnicodeScalarLiteralType
    
    init(unicodeScalarLiteral: UnicodeScalarLiteralType) {
        self.init(rawValue: RawValue(unicodeScalarLiteral: unicodeScalarLiteral))
    }
}

extension Tagged: Identifiable where RawValue: Identifiable {
    typealias ID = RawValue.ID
    
    var id: ID {
        return rawValue.id
    }
}

extension Tagged: LosslessStringConvertible where RawValue: LosslessStringConvertible {
    init?(_ description: String) {
        guard let rawValue = RawValue(description) else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
}

extension Tagged: AdditiveArithmetic where RawValue: AdditiveArithmetic {
    static var zero: Tagged {
        return self.init(rawValue: .zero)
    }
    
    static func +(lhs: Tagged, rhs: Tagged) -> Tagged {
        return self.init(rawValue: lhs.rawValue + rhs.rawValue)
    }
    
    static func +=(lhs: inout Tagged, rhs: Tagged) {
        lhs.rawValue += rhs.rawValue
    }
    
    static func -(lhs: Tagged, rhs: Tagged) -> Tagged {
        return self.init(rawValue: lhs.rawValue - rhs.rawValue)
    }
    
    static func -=(lhs: inout Tagged, rhs: Tagged) {
        lhs.rawValue -= rhs.rawValue
    }
}

extension Tagged: Numeric where RawValue: Numeric {
    init?<T>(exactly source: T) where T: BinaryInteger {
        guard let rawValue = RawValue(exactly: source) else { return nil }
        self.init(rawValue: rawValue)
    }
    
    var magnitude: RawValue.Magnitude {
        return self.rawValue.magnitude
    }
    
    static func *(lhs: Tagged, rhs: Tagged) -> Tagged {
        return self.init(rawValue: lhs.rawValue * rhs.rawValue)
    }
    
    static func *=(lhs: inout Tagged, rhs: Tagged) {
        lhs.rawValue *= rhs.rawValue
    }
}

extension Tagged: Hashable where RawValue: Hashable {}

extension Tagged: SignedNumeric where RawValue: SignedNumeric {}

extension Tagged: Sequence where RawValue: Sequence {
    typealias Iterator = RawValue.Iterator
    
    __consuming func makeIterator() -> RawValue.Iterator {
        return rawValue.makeIterator()
    }
}

extension Tagged: Strideable where RawValue: Strideable {
    typealias Stride = RawValue.Stride
    
    func distance(to other: Tagged<Tag, RawValue>) -> RawValue.Stride {
        self.rawValue.distance(to: other.rawValue)
    }
    
    func advanced(by n: RawValue.Stride) -> Tagged<Tag, RawValue> {
        Tagged(rawValue: self.rawValue.advanced(by: n))
    }
}

extension Tagged: ExpressibleByArrayLiteral where RawValue: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = RawValue.ArrayLiteralElement
    
    init(arrayLiteral elements: ArrayLiteralElement...) {
        let f = unsafeBitCast(
            RawValue.init(arrayLiteral:) as (ArrayLiteralElement...) -> RawValue,
            to: (([ArrayLiteralElement]) -> RawValue).self
        )
        self.init(rawValue: f(elements))
    }
}

extension Tagged: ExpressibleByDictionaryLiteral where RawValue: ExpressibleByDictionaryLiteral {
    typealias Key = RawValue.Key
    typealias Value = RawValue.Value
    
    init(dictionaryLiteral elements: (Key, Value)...) {
        let f = unsafeBitCast(
            RawValue.init(dictionaryLiteral:) as ((Key, Value)...) -> RawValue,
            to: (([(Key, Value)]) -> RawValue).self
        )
        self.init(rawValue: f(elements))
    }
}

extension Tagged where RawValue == UUID {
    
    /// Generates a tagged UUID.
    ///
    /// Equivalent to `Tagged<Tag, _>(UUID(())`.
    init() {
        self.init(UUID())
    }
    
    /// Creates a tagged UUID from a string representation.
    ///
    /// - Parameter string: The string representation of a UUID, such as
    ///   `DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF`.
    init?(uuidString string: String) {
        guard let uuid = UUID(uuidString: string) else {
            return nil
        }
        self.init(uuid)
    }
}
