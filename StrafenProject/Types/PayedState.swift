//
//  PayedState.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

enum PayedState: String {
    case payed
    case unpayed
}

extension PayedState: Equatable {}

extension PayedState: Codable {}

extension PayedState: Sendable {}

extension PayedState: Hashable {}

extension PayedState: FirebaseFunctionParameterType {
    var parameter: String {
        return self.rawValue
    }
}

extension PayedState: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> PayedState {
        return Bool.random(using: &generator) ? .payed : .unpayed
    }
}
