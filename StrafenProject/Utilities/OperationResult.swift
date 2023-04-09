//
//  OperationResult.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

enum OperationResult {
    case failed
    case passed
    
    mutating func toggle() {
        if self == .passed {
            return self = .failed
        }
        self = .passed
    }
    
    static func &&(lhs: OperationResult, rhs: @autoclosure () throws -> OperationResult) rethrows -> OperationResult {
        if lhs == .failed {
            return .failed
        }
        return try rhs()
    }
    
    static func ||(lhs: OperationResult, rhs: @autoclosure () throws -> OperationResult) rethrows -> OperationResult {
        if lhs == .passed {
            return .passed
        }
        return try rhs()
    }
    
    static prefix func !(rhs: OperationResult) -> OperationResult {
        var result = rhs
        result.toggle()
        return result
    }
    
    static func evaluate(@OperationResultEvaluator _ evaluator: () -> OperationResult) -> OperationResult {
        return evaluator()
    }
}

extension Collection<OperationResult> {
    
    var allPassed: OperationResult {
        return self.allSatisfy { $0 == .passed } ? .passed : .failed
    }
}

extension Collection {
    
    func evaluateAll(passed evaluate: (Element) throws -> OperationResult) rethrows -> OperationResult {
        return try self.map(evaluate).allPassed
    }
}

@resultBuilder
struct OperationResultEvaluator {
    
    static func buildBlock(_ results: OperationResult...) -> OperationResult {
        return results.allPassed
    }
    
    static func buildArray(_ results: [OperationResult]) -> OperationResult {
        return results.allPassed
    }
    
    static func buildOptional(_ result: OperationResult?) -> OperationResult {
        return result ?? .passed
    }
    
    static func buildEither(first result: OperationResult) -> OperationResult {
        return result
    }
    
    static func buildEither(second result: OperationResult) -> OperationResult {
        return result
    }
}
