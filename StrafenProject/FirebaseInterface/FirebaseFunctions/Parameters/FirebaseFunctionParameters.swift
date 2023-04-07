//
//  FirebaseFunctionParameters.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct FirebaseFunctionParameters {
    
    private var parameters: [String: FirebaseFunctionInternalParameterType]
    
    init() {
        self.parameters = [:]
    }
    
    init(_ parameters: [String: FirebaseFunctionInternalParameterType]) {
        self.parameters = parameters
    }
    
    init(_ parameters: [String: any FirebaseFunctionParameterType]) {
        self.parameters = parameters.mapValues(\.internalParameter)
    }
        
    var firebaseFunctionParameters: [String: Any] {
        return self.parameters.mapValues(\.firebaseFunctionParameter)
    }
    
    mutating func append(_ parameter: some FirebaseFunctionParameterType, for key: String) {
        self.parameters[key] = parameter.internalParameter
    }
    
    mutating func append(contentsOf parameters: some Sequence<(key: String, value: any FirebaseFunctionParameterType)>) {
        for (key, parameter) in parameters {
            self.append(parameter, for: key)
        }
    }
    
    mutating func remove(with key: String) {
        self.parameters.removeValue(forKey: key)
    }
}

extension FirebaseFunctionParameters: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.parameters)
    }
}

extension FirebaseFunctionParameters: FirebaseFunctionParameterType {
    var internalParameter: FirebaseFunctionInternalParameterType {
        return .dictionary(self.parameters)
    }
    
    var parameter: FirebaseFunctionParameters {
        return self
    }
}
