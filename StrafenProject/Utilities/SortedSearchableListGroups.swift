//
//  SortedSearchableListGroups.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import Foundation

struct SortedSearchableListGroups<Key, Element> where Key: Hashable {
    
    private let groups: [Key: [Element]]
        
    private let searchInValues: (Element) -> [String]
        
    init(_ list: some Sequence<Element>, groupBy groupElementKey: (Element) -> Key, sortBy areInIncreasingOrder: @escaping (Element, Element) -> Bool, searchIn searchInValues: @escaping (Element) -> [String]) {
        self.groups = list.reduce(into: [Key: [Element]]()) { groups, element in
            let key = groupElementKey(element)
            groups[key, default: []].append(element)
        }.mapValues { group in
            return group.sorted(by: areInIncreasingOrder)
        }
        self.searchInValues = searchInValues
    }
    
    init(_ list: some Sequence<Element>, groupBy groupElementKey: (Element) -> Key, sortBy areInIncreasingOrder: @escaping (Element, Element) -> Bool, searchIn searchInValue: @escaping (Element) -> String) {
        self.init(list, groupBy: groupElementKey, sortBy: areInIncreasingOrder, searchIn: { [searchInValue($0)] })
    }
    
    func group(of key: Key) -> [Element] {
        return self.groups[key, default: []]
    }
    
    func searchableGroup(of key: Key, search searchText: String) -> [Element] {
        guard !searchText.isEmpty else {
            return self.group(of: key)
        }
        let searchText = searchText.lowercased()
        return self.group(of: key).filter { element in
            return self.searchInValues(element).contains { value in
                return value.lowercased().contains(searchText)
            }
        }
    }
}

enum SingleGroupKey {
    case defaultKey
}

extension SortedSearchableListGroups where Key == SingleGroupKey {
    init(_ list: some Sequence<Element>, sortBy areInIncreasingOrder: @escaping (Element, Element) -> Bool, searchIn searchInValues: @escaping (Element) -> [String]) {
        self.init(list, groupBy: { _ in .defaultKey }, sortBy: areInIncreasingOrder, searchIn: searchInValues)
    }
    
    init(_ list: some Sequence<Element>, sortBy areInIncreasingOrder: @escaping (Element, Element) -> Bool, searchIn searchInValue: @escaping (Element) -> String) {
        self.init(list, groupBy: { _ in .defaultKey }, sortBy: areInIncreasingOrder, searchIn: searchInValue)
    }
    
    var group: [Element] {
        return self.group(of: .defaultKey)
    }
    
    func searchableGroup(search searchText: String) -> [Element] {
        return self.searchableGroup(of: .defaultKey, search: searchText)
    }
}

extension SortedSearchableListGroups where Element: Comparable {
    init(_ list: some Sequence<Element>, groupBy groupElementKey: (Element) -> Key, searchIn searchInValues: @escaping (Element) -> [String]) {
        self.init(list, groupBy: groupElementKey, sortBy: <, searchIn: searchInValues)
    }
    
    init(_ list: some Sequence<Element>, groupBy groupElementKey: (Element) -> Key, searchIn searchInValue: @escaping (Element) -> String) {
        self.init(list, groupBy: groupElementKey, sortBy: <, searchIn: searchInValue)
    }
}

extension SortedSearchableListGroups where Element == String {
    init(_ list: some Sequence<Element>, groupBy groupElementKey: (Element) -> Key, sortBy areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.init(list, groupBy: groupElementKey, sortBy: areInIncreasingOrder, searchIn: { [$0] })
    }
    
    init(_ list: some Sequence<Element>, groupBy groupElementKey: (Element) -> Key) {
        self.init(list, groupBy: groupElementKey, sortBy: <, searchIn: { [$0] })
    }
}

extension SortedSearchableListGroups where Key == SingleGroupKey, Element: Comparable {
    init(_ list: some Sequence<Element>, searchIn searchInValues: @escaping (Element) -> [String]) {
        self.init(list, groupBy: { _ in .defaultKey }, sortBy: <, searchIn: searchInValues)
    }
    
    init(_ list: some Sequence<Element>, searchIn searchInValue: @escaping (Element) -> String) {
        self.init(list, groupBy: { _ in .defaultKey }, sortBy: <, searchIn: searchInValue)
    }
    
}

extension SortedSearchableListGroups where Key == SingleGroupKey, Element == String {
    init(_ list: some Sequence<Element>, sortBy areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.init(list, groupBy: { _ in .defaultKey }, sortBy: areInIncreasingOrder, searchIn: { [$0] })
    }
    
    init(_ list: some Sequence<Element>) {
        self.init(list, groupBy: { _ in .defaultKey }, sortBy: <, searchIn: { [$0] })
    }
}
