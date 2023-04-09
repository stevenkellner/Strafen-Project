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
}

extension IdentifiableList: Sequence {
    func makeIterator() -> Dictionary<Element.ID, Element>.Iterator {
        return self.keyedValues.makeIterator()
    }
}

extension IdentifiableList: Equatable where Element: Equatable, Element.ID: Equatable {}

extension IdentifiableList: Sendable where Element: Sendable, Element.ID: Sendable {}

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
