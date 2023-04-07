//
//  FirebaseFunctionResult.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

enum FirebaseFunctionResult<T> {
    struct Error: Swift.Error {
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
    
    case success(value: T)
    case failure(error: Error)
    
    var value: T {
        get throws {
            switch self {
            case .success(let value):
                return value
            case .failure(let error):
                throw error
            }
        }
    }
}

extension FirebaseFunctionResult.Error.Code: Decodable {}

extension FirebaseFunctionResult.Error.Code: Sendable {}

extension FirebaseFunctionResult.Error: Decodable {}

extension FirebaseFunctionResult.Error: Sendable {}

extension FirebaseFunctionResult: Decodable where T: Decodable {
    private enum CodingKeys: String, CodingKey {
        case state
        case value
        case error
    }
    
    private enum State: String, Decodable {
        case success
        case failure
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let state = try container.decode(State.self, forKey: .state)
        switch state {
        case .success:
            let value = try container.decode(T.self, forKey: .value)
            self = .success(value: value)
        case .failure:
            let error = try container.decode(Error.self, forKey: .error)
            self = .failure(error: error)
        }
    }
}

extension FirebaseFunctionResult: Sendable where T: Sendable {}
