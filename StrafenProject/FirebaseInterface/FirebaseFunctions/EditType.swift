//
//  EditType.swift
//  StrafenProject
//
//  Created by Steven on 08.04.23.
//

import Foundation

enum EditType: String {
    case add
    case update
    case delete
}

extension EditType: Equatable {}

extension EditType: Codable {}

extension EditType: Sendable {}

extension EditType: Hashable {}

extension EditType: FirebaseFunctionParameterType {
    var parameter: String {
        return self.rawValue
    }
}
