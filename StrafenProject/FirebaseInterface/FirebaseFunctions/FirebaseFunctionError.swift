//
//  FirebaseFunctionError.swift
//  StrafenProject
//
//  Created by Steven on 14.04.23.
//

import Foundation

struct FirebaseFunctionError: Error {
    enum Code: String {
        case ok = "ok"
        case cancelled = "cancelled"
        case unknown = "unknown"
        case invalidArgument = "invalid-argument"
        case deadlineExceeded = "deadline-exceeded"
        case notFound = "not-found"
        case alreadyExists = "already-exists"
        case permissionDenied = "permission-denied"
        case resourceExhausted = "resource-exhausted"
        case failedPrecondition = "failed-precondition"
        case aborted = "aborted"
        case outOfRange = "out-of-range"
        case unimplemented = "unimplemented"
        case `internal` = "`internal`"
        case unavailable = "unavailable"
        case dataLoss = "data-loss"
        case unauthenticated = "unauthenticated"
    }
    
    let code: Code
    let message: String
    let stack: String
}

extension FirebaseFunctionError.Code: Equatable {}

extension FirebaseFunctionError.Code: Hashable {}

extension FirebaseFunctionError.Code: Decodable {}

extension FirebaseFunctionError.Code: Sendable {}

extension FirebaseFunctionError: Equatable {}

extension FirebaseFunctionError: Hashable {}

extension FirebaseFunctionError: Decodable {}

extension FirebaseFunctionError: Sendable {}
