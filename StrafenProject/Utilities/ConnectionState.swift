//
//  ConnectionState.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

enum ConnectionState {
    case notStarted
    case loading
    case failed
    case passed
    
    mutating func reset() {
        self = .notStarted
    }
    
    @discardableResult
    mutating func start() -> OperationResult {
        guard self == .notStarted else {
            return .failed
        }
        self = .loading
        return .passed
    }
    
    @discardableResult
    mutating func restart() -> OperationResult {
        guard self != .loading else {
            return .failed
        }
        self = .loading
        return .passed
    }
    
    mutating func failed() {
        self = .failed
    }
    
    mutating func passed() {
        self = .passed
    }
}
