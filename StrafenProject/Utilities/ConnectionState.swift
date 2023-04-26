//
//  ConnectionState.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

enum ConnectionState<Content, Failure> {
    case notStarted
    case loading
    case failed(reason: Failure)
    case passed(value: Content)
    
    mutating func reset() {
        self = .notStarted
    }
    
    @discardableResult
    mutating func start() -> OperationResult {
        guard case .notStarted = self else {
            return .failed
        }
        self = .loading
        return .passed
    }
    
    @discardableResult
    mutating func restart() -> OperationResult {
        if case .loading = self {
            return .failed
        }
        self = .loading
        return .passed
    }
    
    mutating func failed(reason: Failure) {
        self = .failed(reason: reason)
    }
    
    mutating func passed(value: Content) {
        self = .passed(value: value)
    }
}

extension ConnectionState where Failure == Void {
    mutating func failed() {
        self = .failed(reason: ())
    }
}

extension ConnectionState: Sendable where Content: Sendable, Failure: Sendable {}

extension ConnectionState: Hashable where Content: Hashable, Failure: Hashable {}

extension ConnectionState: Equatable where Content: Equatable, Failure: Equatable {}
