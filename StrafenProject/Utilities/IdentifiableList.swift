//
//  IdentifiableList.swift
//  StrafenProject
//
//  Created by Steven on 08.04.23.
//

import Foundation

struct IdentifiableList<Element> where Element: Identifiable, Element.ID: Hashable {
    
    private var keyedValues: [Element.ID: Element]
    
    init() {
        self.keyedValues = [:]
    }
    
    init(values: some Sequence<Element>) {
        self.keyedValues = Dictionary(values.map({ value in
            return (key: value.id, value: value)
        })) { value, _ in value }
    }
    
    subscript(key: Element.ID) -> Element? {
        get {
            return self.keyedValues[key]
        }
        set {
            self.keyedValues[key] = newValue
        }
    }
    
    @discardableResult
    mutating func removeValue(forKey key: Element.ID) -> Element? {
        return self.keyedValues.removeValue(forKey: key)
    }
    
    @discardableResult
    mutating func update(value: Element) -> Element? {
        return self.keyedValues.updateValue(value, forKey: value.id)
    }
    
    @discardableResult
    mutating func update(_ value: Deletable<Element>) -> Element? {
        switch value {
        case .deleted(id: let id):
            return self.removeValue(forKey: id)
        case .value(let element):
            return self.update(value: element)
        }
    }
    
    mutating func update(_ values: [Deletable<Element>]) {
        for value in values {
            self.update(value)
        }
    }
}

extension IdentifiableList: Sequence {
    func makeIterator() -> Dictionary<Element.ID, Element>.Values.Iterator {
        return self.keyedValues.values.makeIterator()
    }
    
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> IdentifiableList<Element> {
        return IdentifiableList(values: try self.keyedValues.values.filter(isIncluded))
    }
    
    func map<T>(_ transform: (Element) throws -> T) rethrows -> IdentifiableList<T> where T: Identifiable, T.ID: Hashable {
        return IdentifiableList<T>(values: try self.keyedValues.values.map(transform))
    }
    
    func flatMap<SegmentOfResult>(_ transform: (Element) throws -> SegmentOfResult) rethrows -> IdentifiableList<SegmentOfResult.Element> where SegmentOfResult: Sequence, SegmentOfResult.Element: Identifiable, SegmentOfResult.Element.ID: Hashable {
        return IdentifiableList<SegmentOfResult.Element>(values: try self.keyedValues.values.flatMap(transform))
    }
    
    func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> IdentifiableList<ElementOfResult> where ElementOfResult: Identifiable, ElementOfResult.ID: Hashable {
        return IdentifiableList<ElementOfResult>(values: try self.keyedValues.values.compactMap(transform))
    }
}

extension IdentifiableList: Equatable where Element: Equatable, Element.ID: Equatable {}

extension IdentifiableList: Sendable where Element: Sendable, Element.ID: Sendable {}

extension IdentifiableList: Encodable where Element: Encodable, Element.ID: RawRepresentable, Element.ID.RawValue == UUID {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let mappedKeyedValues = Dictionary(uniqueKeysWithValues: self.keyedValues.map({ (key: $0.rawValue.uuidString, value: $1) }))
        try container.encode(mappedKeyedValues)
    }
}

extension IdentifiableList: Decodable where Element: Decodable, Element.ID: RawRepresentable, Element.ID.RawValue == UUID {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringDictionary = try container.decode([String: Element].self)
        self.keyedValues = Dictionary(try stringDictionary.map({ keyValuePair in
            guard let uuid = UUID(uuidString: keyValuePair.key), let id = Element.ID(rawValue: uuid) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Couldn't decode id: \"\(keyValuePair.key)\".")
            }
            return (key: id, value: keyValuePair.value)
        })) { value, _ in value }
    }
}

fileprivate var identifiableListRandomPlaceholderLength: Range<UInt> = 10..<11

extension IdentifiableList: RandomPlaceholder where Element: RandomPlaceholder {
    static var randomPlaceholderLength: Range<UInt> {
        get {
            return identifiableListRandomPlaceholderLength
        }
        set {
            identifiableListRandomPlaceholderLength = newValue
        }
    }
    
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> IdentifiableList<Element> {
        let length = UInt.random(in: IdentifiableList.randomPlaceholderLength, using: &generator)
        return IdentifiableList(values: (0..<length).map({ _ in
            return Element.randomPlaceholder(using: &generator)
        }))
    }
}
