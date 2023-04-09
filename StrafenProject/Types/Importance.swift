//
//  Importance.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

enum Importance: String {
    case high
    case medium
    case low
}

extension Importance: Equatable {}

extension Importance: Comparable {
    static func < (lhs: Importance, rhs: Importance) -> Bool {
        switch (lhs, rhs) {
        case (.low, .medium), (.low, .high), (.medium, .high):
            return true
        case (.high, .low), (.high, .medium), (.medium, .low):
            return false
        case (.low, .low), (.medium, .medium), (.high, .high):
            return false
        }
    }
}

extension Importance: Codable {}

extension Importance: Sendable {}

extension Importance: Hashable {}

extension Importance: FirebaseFunctionParameterType {
    var parameter: String {
        return self.rawValue
    }
}

extension Importance: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> Importance {
        return [.high, .medium, .low].randomElement(using: &generator)!
    }
}
