//
//  FirebaseImageCache.swift
//  StrafenProject
//
//  Created by Steven on 21.04.23.
//

import SwiftUI

enum CacheState {
    case image(UIImage)
    case noImage
    case notCached
}

struct FirebaseImageCache<Key> where Key: Hashable, Key: Codable, Key: RawRepresentable, Key.RawValue == UUID {
    
    private var imageStates = [Key: CacheState]()
    
    init() {}
    
    private var baseUrl: URL {
        let baseUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.stevenkellner.StrafenProject.imageCache")!
        let directoryUrl = baseUrl.appending(path: DatabaseType.current.rawValue)
        try? FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true)
        return directoryUrl
    }
    
    private func url(key: Key) -> URL {
        return self.baseUrl
            .appending(path: key.rawValue.uuidString)
            .appendingPathExtension("jpeg")
    }
    
    private var noImageKeysCacheUrl: URL {
        return self.baseUrl
            .appending(path: "noImages")
            .appendingPathExtension("json")
    }
    
    private var noImageKeysCache: Set<Key> {
        get {
            guard let data = try? Data(contentsOf: self.noImageKeysCacheUrl, options: .uncached) else {
                return []
            }
            let decoder = JSONDecoder()
            guard let noImageKeys = try? decoder.decode(Set<Key>.self, from: data) else {
                return []
            }
            return noImageKeys
        }
        set {
            let encoder = JSONEncoder()
            guard let data = try? encoder.encode(newValue) else {
                return
            }
            try? data.write(to: self.noImageKeysCacheUrl, options: .atomic)
        }
    }
    
    subscript(_ key: Key) -> UIImage? {
        get {
            switch self.imageStates[key] {
            case .image(let image):
                return image
            case .noImage, .notCached, .none:
                return nil
            }
        }
    }
    
    mutating func setCache(state: CacheState, key: Key) {
        switch state {
        case .image(let image):
            self.updateImage(image, forKey: key)
        case .noImage:
            self.removeImage(forKey: key)
        case .notCached:
            self.uncacheImage(forKey: key)
        }
    }
    
    mutating func getCache(key: Key) -> CacheState {
        if let state = self.imageStates[key] {
            if case .notCached = state {
                return state
            }
        }
        var state: CacheState = .notCached
        if let imageData = try? Data(contentsOf: self.url(key: key), options: .uncached),
           let image = UIImage(data: imageData) {
            state = .image(image)
        } else if self.noImageKeysCache.contains(key) {
            state = .noImage
        }
        self.imageStates[key] = state
        return state
    }
    
    private mutating func updateImage(_ image: UIImage, forKey key: Key) {
        self.imageStates[key] = .image(image)
        let compressionQuality: CGFloat = 0.85
        if let imageData = image.jpegData(compressionQuality: compressionQuality) {
            try? imageData.write(to: self.url(key: key), options: .atomic)
        }
        self.noImageKeysCache = self.noImageKeysCache.filter { $0 != key }
    }
    
    private mutating func removeImage(forKey key: Key) {
        self.imageStates[key] = .noImage
        try? FileManager.default.removeItem(at: self.url(key: key))
        self.noImageKeysCache.insert(key)
    }
    
    private mutating func uncacheImage(forKey key: Key) {
        self.imageStates.removeValue(forKey: key)
        try? FileManager.default.removeItem(at: self.url(key: key))
        self.noImageKeysCache = self.noImageKeysCache.filter { $0 != key }
    }
    
    mutating func clear() {
        self.imageStates = [:]
    }
}
