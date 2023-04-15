//
//  FirebaseFunctionResult.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

enum FirebaseFunctionResult<T> {
    case success(value: T)
    case failure(error: FirebaseFunctionError)
    
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

extension FirebaseFunctionResult: Equatable where T: Equatable {}

extension FirebaseFunctionResult: Hashable where T: Hashable {}

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
            let error = try container.decode(FirebaseFunctionError.self, forKey: .error)
            self = .failure(error: error)
        }
    }
}

extension FirebaseFunctionResult: Sendable where T: Sendable {}
