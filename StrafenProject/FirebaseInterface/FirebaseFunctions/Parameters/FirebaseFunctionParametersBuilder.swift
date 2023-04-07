//
//  FirebaseFunctionParametersBuilder.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

@resultBuilder
struct FirebaseFunctionParametersBuilder {
    typealias Parameters = [String: FirebaseFunctionInternalParameterType]
    
    static func buildExpression(_ parameter: FirebaseFunctionParameter) -> Parameters {
        return [parameter.key: parameter.parameter]
    }
    
    static func buildBlock(_ parameters: Parameters...) -> Parameters {
        return parameters.reduce(into: [:]) { result, parameters in
            result.merge(parameters) { value, _ in value }
        }
    }
    
    static func buildArray(_ parameters: [Parameters]) -> Parameters {
        return parameters.reduce(into: [:]) { result, parameters in
            result.merge(parameters) { value, _ in value }
        }
    }
    
    static func buildOptional(_ parameters: Parameters?) -> Parameters {
        return parameters ?? [:]
    }
    
    static func buildEither(first parameters: Parameters) -> Parameters {
        return parameters
    }
    
    static func buildEither(second parameters: Parameters) -> Parameters {
        return parameters
    }
    
    static func buildFinalResult(_ parameters: Parameters) -> FirebaseFunctionParameters {
        return FirebaseFunctionParameters(parameters)
    }
}
