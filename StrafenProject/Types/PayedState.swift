//
//  PayedState.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

enum PayedState {
    case payed(inApp: Bool, payDate: Date)
    case unpayed
    case settled
}

extension PayedState: Equatable {
    static func ==(lhs: PayedState, rhs: PayedState) -> Bool {
        switch (lhs, rhs) {
        case let (.payed(inApp: lhsInApp, payDate: lhsPayDate), .payed(inApp: rhsInApp, payDate: rhsPayDate)):
            return lhsInApp == rhsInApp && Calendar.current.isDate(lhsPayDate, equalTo: rhsPayDate, toGranularity: .nanosecond)
        case (.unpayed, .unpayed):
            return true
        case (.settled, .settled):
            return true
        default:
            return false
        }
    }
}

extension PayedState: Codable {
    private enum CodingKeys: String, CodingKey {
        case state
        case inApp
        case payDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let state = try container.decode(String.self, forKey: .state)
        switch state {
        case "payed":
            let inApp = try container.decode(Bool.self, forKey: .inApp)
            let payDate = try container.decode(Date.self, forKey: .payDate)
            self = .payed(inApp: inApp, payDate: payDate)
        case "unpayed":
            self = .unpayed
        case "settled":
            self = .settled
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.state], debugDescription: "Invalid state: \(state)."))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .payed(inApp: inApp, payDate: payDate):
            try container.encode("payed", forKey: .state)
            try container.encode(inApp, forKey: .inApp)
            try container.encode(payDate, forKey: .payDate)
        case .unpayed:
            try container.encode("unpayed", forKey: .state)
        case .settled:
            try container.encode("settled", forKey: .state)
        }
    }
}

extension PayedState: Sendable {}

extension PayedState: Hashable {}

extension PayedState: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        switch self {
        case .payed(let inApp, let payDate):
            FirebaseFunctionParameter("payed", for: "state")
            FirebaseFunctionParameter(inApp, for: "inApp")
            FirebaseFunctionParameter(payDate, for: "payDate")
        case .unpayed:
            FirebaseFunctionParameter("unpayed", for: "state")
        case .settled:
            FirebaseFunctionParameter("settled", for: "state")
        }
    }
}

extension PayedState: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> PayedState {
        switch UInt.random(in: 0...2, using: &generator) {
        case 0:
            return .payed(inApp: Bool.random(using: &generator), payDate: Date())
        case 1:
            return .unpayed
        case 2:
            return .settled
        default:
            return .unpayed
        }
    }
}
