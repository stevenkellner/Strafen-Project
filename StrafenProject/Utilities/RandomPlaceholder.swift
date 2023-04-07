//
//  RandomPlaceholder.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

protocol RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> Self
}

extension RandomPlaceholder {
    static var randomPlaceholder: Self {
        var generator = SystemRandomNumberGenerator()
        return Self.randomPlaceholder(using: &generator)
    }
}

extension Dictionary: RandomPlaceholder where Key: RawRepresentable, Key.RawValue == UUID, Value: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> Dictionary<Key, Value> {
        let count = UInt.random(in: 5..<15, using: &generator)
        let keysAndValues: [Element] = (0...count).compactMap { _ in
            guard let key = Key(rawValue: UUID()) else {
                return nil
            }
            return (key: key, value: Value.randomPlaceholder(using: &generator))
        }
        return Dictionary(keysAndValues) { value, _ in value }
    }
}
