//
//  Sortable.swift
//  StrafenProject
//
//  Created by Steven on 01.06.23.
//

import Foundation

protocol SortingKeyProtocolWithContext: CaseIterable, Hashable where AllCases: RandomAccessCollection {
    associatedtype Value
    associatedtype Context
    
    @MainActor
    func areInAscendingOrder(lhs lhsValue: Value, rhs rhsValue: Value, context: Context) -> Bool
    
    func formatted(order: SortingOrder) -> String
}

protocol SortingKeyProtocol: SortingKeyProtocolWithContext {
    associatedtype Value
    
    @MainActor
    func areInAscendingOrder(lhs lhsValue: Value, rhs rhsValue: Value) -> Bool
}

extension SortingKeyProtocol {
    
    @MainActor
    func areInAscendingOrder(lhs lhsValue: Value, rhs rhsValue: Value, context: Void) -> Bool {
        return self.areInAscendingOrder(lhs: lhsValue, rhs: rhsValue)
    }
}

protocol Sortable {
    associatedtype SortingKey: SortingKeyProtocolWithContext where SortingKey.Value == Self
}

enum SortingOrder: String {
    case ascending
    case descending
}

extension SortingOrder: Sendable {}

extension SortingOrder: Equatable {}

extension SortingOrder: Hashable {}

extension SortingOrder: Codable {}
