//
//  FirebaseFunctionParameters.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

enum FirebaseFunctionParameters {
    case unknown
    case single(FirebaseFunctionInternalParameterType)
    case keyed([String: FirebaseFunctionInternalParameterType])
}

extension FirebaseFunctionParameters: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .unknown:
            try container.encode([:] as [String: FirebaseFunctionInternalParameterType])
        case .single(let parameter):
            try container.encode(parameter)
        case .keyed(let parameters):
            try container.encode(parameters)
        }
    }
}

extension FirebaseFunctionParameters: FirebaseFunctionParameterType {
    var internalParameter: FirebaseFunctionInternalParameterType {
        switch self {
        case .unknown:
            return .optional(nil)
        case .single(let parameter):
            return parameter
        case .keyed(let parameters):
            return .dictionary(parameters)
        }
    }
    
    var parameter: FirebaseFunctionParameters {
        return self
    }
}
