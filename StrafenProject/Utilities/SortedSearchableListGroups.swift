//
//  SortedSearchableListGroups.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import Foundation

struct SortedSearchableListGroups<Key, Element> where Key: Hashable {
    
    private let groups: [Key: [Element]]
    
    private let elementToCompare: (Element) -> String
        
    init(_ list: some Sequence<Element>, groupBy groupElementKey: (Element) -> Key, sortBy elementToCompare: @escaping (Element) -> String) {
        self.groups = list.reduce(into: [Key: [Element]]()) { groups, element in
            let key = groupElementKey(element)
            groups[key, default: []].append(element)
        }
        self.elementToCompare = elementToCompare
    }
    
    init(_ list: some Sequence<Element>, groupBy groupElementKey: (Element) -> Key, sortBy elementToCompare: KeyPath<Element, String>) {
        self.init(list, groupBy: groupElementKey) { element in
            return element[keyPath: elementToCompare]
        }
    }
    
    func sortedList(of key: Key) -> [Element] {
        return self.groups[key, default: []].sorted { lhsElement, rhsElement in
            return self.elementToCompare(lhsElement).lowercased() < self.elementToCompare(rhsElement).lowercased()
        }
    }
    
    func sortedSearchableList(of key: Key, search searchText: String) -> [Element] {
        guard !searchText.isEmpty else {
            return self.sortedList(of: key)
        }
        let searchText = searchText.lowercased()
        return self.sortedList(of: key).filter { element in
            return self.elementToCompare(element).lowercased().contains(searchText)
        }
    }
}

enum SingleGroupKey {
    case defaultKey
}

extension SortedSearchableListGroups where Key == SingleGroupKey {
    init(_ list: some Sequence<Element>, sortBy elementToCompare: @escaping (Element) -> String) {
        self.groups = [.defaultKey: Array(list)]
        self.elementToCompare = elementToCompare
    }
    
    init(_ list: some Sequence<Element>, sortBy elementToCompare: KeyPath<Element, String>) {
        self.init(list) { element in
            return element[keyPath: elementToCompare]
        }
    }
    
    var sortedList: [Element] {
        return self.sortedList(of: .defaultKey)
    }
    
    func sortedSearchableList(search searchText: String) -> [Element] {
        return self.sortedSearchableList(of: .defaultKey, search: searchText)
    }
}

extension SortedSearchableListGroups where Element == String {
    init(_ list: some Sequence<Element>, groupBy groupElementKey: (Element) -> Key) {
        self.init(list, groupBy: groupElementKey, sortBy: \.self)
    }
}

extension SortedSearchableListGroups where Key == SingleGroupKey, Element == String {
    init(_ list: some Sequence<Element>) {
        self.init(list, sortBy: \.self)
    }
}
