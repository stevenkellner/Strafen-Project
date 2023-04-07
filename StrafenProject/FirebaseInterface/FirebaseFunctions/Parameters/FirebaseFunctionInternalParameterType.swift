//
//  FirebaseFunctionInternalParameterType.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

indirect enum FirebaseFunctionInternalParameterType {
    case bool(Bool)
    case int(Int)
    case uint(UInt)
    case double(Double)
    case float(Float)
    case string(String)
    case optional(FirebaseFunctionInternalParameterType?)
    case array([FirebaseFunctionInternalParameterType])
    case dictionary([String: FirebaseFunctionInternalParameterType])
}

extension FirebaseFunctionInternalParameterType {
    var firebaseFunctionParameter: Any {
        switch self {
        case .bool(let value):
            return value
        case .int(let value):
            return value
        case .uint(let value):
            return value
        case .double(let value):
            return value
        case .float(let value):
            return value
        case .string(let value):
            return value
        case .optional(let value):
            return value.map(\.firebaseFunctionParameter) as Any
        case .array(let value):
            return value.map(\.firebaseFunctionParameter)
        case .dictionary(let value):
            return value.mapValues(\.firebaseFunctionParameter)
        }
    }
}

extension FirebaseFunctionInternalParameterType: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .uint(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .float(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .optional(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        }
    }
}
