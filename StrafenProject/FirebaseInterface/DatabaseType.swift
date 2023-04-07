//
//  DatabaseType.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

enum DatabaseType: String {
    case release
    case debug
    case testing
    
    static var `default`: DatabaseType {
#if DEBUG
        return .debug
#else
        return .release
#endif
    }
}

extension DatabaseType: Codable {}

extension DatabaseType: Sendable {}

extension DatabaseType: FirebaseFunctionParameterType {
    var parameter: String {
        return self.rawValue
    }
}
