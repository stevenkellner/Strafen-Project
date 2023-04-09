//
//  ValidationResult.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

enum ValidationResult<Failure> {
    case valid
    case invalid(Failure)
    
    static func &&<Failure>(lhs: ValidationResult<Failure>, rhs: @autoclosure () throws -> ValidationResult<Failure>) rethrows -> ValidationResult<Failure> {
        if case .invalid(let failure) = lhs {
            return .invalid(failure)
        }
        return try rhs()
    }
    
    static func ||<Failure>(lhs: ValidationResult<Failure>, rhs: @autoclosure () throws -> ValidationResult<Failure>) rethrows -> ValidationResult<Failure> {
        if case .valid = lhs {
            return .valid
        }
        return try rhs()
    }
    
    func mapFailure<NewFailure>(_ transform: (Failure) throws -> NewFailure) rethrows -> ValidationResult<NewFailure> {
        switch self {
        case .valid:
            return .valid
        case .invalid(let failure):
            return .invalid(try transform(failure))
        }
    }
    
    static func evaluate(@ValidationResultEvaluator<Failure> _ evaluator: () -> ValidationResult<Failure>) -> ValidationResult<Failure> {
        return evaluator()
    }
}

extension Collection {
    
    func evaluateAll<Failure>(valid evaluate: (Element) throws -> ValidationResult<Failure>) rethrows -> ValidationResult<Failure> {
        for result in try self.map(evaluate) {
            if case .invalid(let failure) = result {
                return .invalid(failure)
            }
        }
        return .valid
    }
}

@resultBuilder
struct ValidationResultEvaluator<Failure> {
    
    static func buildBlock(_ results: ValidationResult<Failure>...) -> ValidationResult<Failure> {
        return results.evaluateAll { $0 }
    }
    
    static func buildArray(_ results: [ValidationResult<Failure>]) -> ValidationResult<Failure> {
        return results.evaluateAll { $0 }
    }
    
    static func buildOptional(_ result: ValidationResult<Failure>?) -> ValidationResult<Failure> {
        return result ?? .valid
    }
    
    static func buildEither(first result: ValidationResult<Failure>) -> ValidationResult<Failure> {
        return result
    }
    
    static func buildEither(second result: ValidationResult<Failure>) -> ValidationResult<Failure> {
        return result
    }
}
