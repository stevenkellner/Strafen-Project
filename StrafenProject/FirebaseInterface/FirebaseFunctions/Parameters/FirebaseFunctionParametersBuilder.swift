//
//  FirebaseFunctionParametersBuilder.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

@resultBuilder
struct FirebaseFunctionParametersBuilder {    
    static func buildExpression(_ parameter: FirebaseFunctionParameter) -> FirebaseFunctionParameters {
        switch parameter {
        case .single(let parameter):
            return .single(parameter)
        case .keyed(let parameter, key: let key):
            return .keyed([key: parameter])
        }
    }
    
    static func buildBlock(_ parameters: FirebaseFunctionParameters...) -> FirebaseFunctionParameters {
        let parameters = parameters.filter { parameters in
            if case .unknown = parameters {
                return false
            }
            return true
        }
        guard !parameters.isEmpty else {
            return .unknown
        }
        if parameters.count == 1, case .single(let parameter) = parameters.first {
            return .single(parameter)
        }
        return FirebaseFunctionParametersBuilder.buildArray(parameters)
    }
    
    static func buildArray(_ parameters: [FirebaseFunctionParameters]) -> FirebaseFunctionParameters {
        return .keyed(parameters.reduce(into: [:]) { result, parameters in
            guard case .keyed(let parameters) = parameters else {
                return
            }
            result.merge(parameters) { value, _ in value }
        })
    }
    
    static func buildOptional(_ parameters: FirebaseFunctionParameters?) -> FirebaseFunctionParameters {
        return parameters ?? .unknown
    }
    
    static func buildEither(first parameters: FirebaseFunctionParameters) -> FirebaseFunctionParameters {
        return parameters
    }
    
    static func buildEither(second parameters: FirebaseFunctionParameters) -> FirebaseFunctionParameters {
        return parameters
    }
}
