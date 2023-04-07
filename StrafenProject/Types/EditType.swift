//
//  EditType.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

enum EditType {
    case add
    case update
    case delete
}

extension EditType: Equatable {}

extension EditType: Codable {}

extension EditType: Sendable {}

extension EditType: Hashable {}
