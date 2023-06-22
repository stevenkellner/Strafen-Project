//
//  Settings+Sorting.swift
//  StrafenProject
//
//  Created by Steven on 01.06.23.
//

import Foundation

extension Settings {
    struct Sorting {
        struct SortingKeyAndOrder<T> where T: Sortable {
            let sortingKey: T.SortingKey
            let order: SortingOrder
        }
        
        #if !NOTIFICATION_SERVICE_EXTENSION && !WIDGET_EXTENSION
        static let `default` = Sorting(personSorting: SortingKeyAndOrder(sortingKey: .name, order: .ascending), reasonTemplateSorting: SortingKeyAndOrder(sortingKey: .reasonMessage, order: .ascending), fineSorting: SortingKeyAndOrder(sortingKey: .date, order: .descending))
        #elseif !NOTIFICATION_SERVICE_EXTENSION
        static let `default` = Sorting(personSorting: SortingKeyAndOrder(sortingKey: .name, order: .ascending), fineSorting: SortingKeyAndOrder(sortingKey: .date, order: .descending))
        #else
        static let `default` = Sorting(personSorting: SortingKeyAndOrder(sortingKey: .name, order: .ascending))
        #endif
        
        var personSorting: SortingKeyAndOrder<Person>
        #if !NOTIFICATION_SERVICE_EXTENSION && !WIDGET_EXTENSION
        var reasonTemplateSorting: SortingKeyAndOrder<ReasonTemplate>
        #endif
        #if !NOTIFICATION_SERVICE_EXTENSION
        var fineSorting: SortingKeyAndOrder<Fine>
        #endif
    }
}

extension Settings.Sorting.SortingKeyAndOrder {
    
    @MainActor
    func areInAscendingOrder(lhs lhsValue: T, rhs rhsValue: T, context: T.SortingKey.Context) -> Bool {
        switch self.order {
        case .ascending:
            return self.sortingKey.areInAscendingOrder(lhs: lhsValue, rhs: rhsValue, context: context)
        case .descending:
            return !self.sortingKey.areInAscendingOrder(lhs: lhsValue, rhs: rhsValue, context: context)
        }
    }
}

extension Settings.Sorting.SortingKeyAndOrder where T.SortingKey: SortingKeyProtocol {
    
    @MainActor
    func areInAscendingOrder(lhs lhsValue: T, rhs rhsValue: T) -> Bool {
        switch self.order {
        case .ascending:
            return self.sortingKey.areInAscendingOrder(lhs: lhsValue, rhs: rhsValue)
        case .descending:
            return !self.sortingKey.areInAscendingOrder(lhs: lhsValue, rhs: rhsValue)
        }
    }
}

extension Settings.Sorting.SortingKeyAndOrder: Sendable where T.SortingKey: Sendable {}

extension Settings.Sorting.SortingKeyAndOrder: Equatable where T.SortingKey: Equatable {}

extension Settings.Sorting.SortingKeyAndOrder: Hashable where T.SortingKey: Hashable {}

extension Settings.Sorting.SortingKeyAndOrder: Codable where T.SortingKey: Codable {}

extension Settings.Sorting: Sendable {}

extension Settings.Sorting: Equatable {}

extension Settings.Sorting: Hashable {}

extension Settings.Sorting: Codable {}
