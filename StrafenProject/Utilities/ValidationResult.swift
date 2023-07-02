//
//  ValidationResult.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

enum ValidationResult {
    case valid
    case invalid
    static func &&(lhs: ValidationResult, rhs: @autoclosure () throws -> ValidationResult) rethrows -> ValidationResult {
        if lhs == .invalid {
            return .invalid
        }
        return try rhs()
    }
    
    static func ||(lhs: ValidationResult, rhs: @autoclosure () throws -> ValidationResult) rethrows -> ValidationResult {
        if lhs == .valid {
            return .valid
        }
        return try rhs()
    }
        
    static func evaluate(@ValidationResultEvaluator _ evaluator: () -> ValidationResult) -> ValidationResult {
        return evaluator()
    }
}

extension ValidationResult: Equatable {}

extension ValidationResult: Hashable {}

extension ValidationResult: Sendable {}

extension Collection {
    
    func evaluateAll(valid evaluate: (Element) throws -> ValidationResult) rethrows -> ValidationResult {
        for result in try self.map(evaluate) {
            if result == .invalid {
                return .invalid
            }
        }
        return .valid
    }
}

@resultBuilder
struct ValidationResultEvaluator {
    
    static func buildBlock(_ results: ValidationResult...) -> ValidationResult {
        return results.evaluateAll { $0 }
    }
    
    static func buildArray(_ results: [ValidationResult]) -> ValidationResult {
        return results.evaluateAll { $0 }
    }
    
    static func buildOptional(_ result: ValidationResult?) -> ValidationResult {
        return result ?? .valid
    }
    
    static func buildEither(first result: ValidationResult) -> ValidationResult {
        return result
    }
    
    static func buildEither(second result: ValidationResult) -> ValidationResult {
        return result
    }
}
