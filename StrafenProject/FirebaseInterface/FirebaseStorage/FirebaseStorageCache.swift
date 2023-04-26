//
//  FirebaseStorageCache.swift
//  StrafenProject
//
//  Created by Steven on 21.04.23.
//

import Foundation

struct FirebaseStorageCache<Key, T> where Key: Hashable {
    
    private let maxItemsCount: Int?
    
    private var data = [Key: (value: T, createdAt: TimeInterval)]()
    
    init() {
        self.maxItemsCount = nil
    }
    
    init(max maxItemsCount: Int) {
        self.maxItemsCount = Swift.max(maxItemsCount, 1)
    }
    
    subscript(_ key: Key) -> T? {
        get {
            return self.data[key]?.value
        }
        set {
            guard let newValue else {
                return self.removeValue(forKey: key)
            }
            self.updateValue(newValue, forKey: key)
        }
    }
    
    mutating func clear() {
        self.data = [:]
    }
    
    private mutating func updateValue(_ value: T, forKey key: Key) {
        if let maxItemsCount = self.maxItemsCount {
            while self.data.count >= maxItemsCount {
                self.removeEarlist()
            }
        }
        let createdAtTimeInterval = self.data[key]?.createdAt ?? Date().timeIntervalSinceReferenceDate
        self.data.updateValue((value: value, createdAt: createdAtTimeInterval), forKey: key)
    }
    
    private mutating func removeValue(forKey key: Key) {
        self.data.removeValue(forKey: key)
    }
    
    private mutating func removeEarlist() {
        let minEntry = self.data.min { entry1, entry2 in
            return entry1.value.createdAt < entry2.value.createdAt
        }
        guard let minEntry else {
            return
        }
        self.removeValue(forKey: minEntry.key)
    }
}
