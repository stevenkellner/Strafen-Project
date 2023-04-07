//
//  Clamping.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

@propertyWrapper
struct Clamping<Value> where Value: Comparable {
    
    private var value: Value
    
    private let range: ClosedRange<Value>
    
    init(wrappedValue value: Value, _ range: ClosedRange<Value>) {
        self.value = range.clamp(value)
        self.range = range
    }
    
    public var wrappedValue: Value {
        get {
            return self.value
        }
        set {
            self.value = self.range.clamp(newValue)
        }
    }
}

extension Clamping where Value: Numeric {
    init(_ range: ClosedRange<Value>) {
        self.init(wrappedValue: .zero, range)
    }
}

extension Clamping: Equatable where Value: Equatable {
    static func ==(lhs: Clamping, rhs: Clamping) -> Bool {
        return lhs.value == rhs.value
    }
}

extension Clamping: Hashable where Value: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.value)
    }
}

extension ClosedRange {
    public func clamp(_ value: Bound) -> Bound {
        return Swift.min(Swift.max(self.lowerBound, value), self.upperBound)
    }
}
