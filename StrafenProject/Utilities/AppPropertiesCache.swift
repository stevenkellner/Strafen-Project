//
//  AppPropertiesCache.swift
//  StrafenProject
//
//  Created by Steven on 05.08.23.
//

import Foundation
import WidgetKit
import OSLog

protocol ListCachable: Identifiable, Codable where ID: Hashable, ID: RawRepresentable, ID.RawValue == UUID {
    static var cacheFilePath: String { get }
}

struct AppPropertiesCache {
    private struct CachedData<Element>: Codable where Element: ListCachable {
        let savedAt: UtcDate
        let list: IdentifiableList<Element>
    }
    
    static let shared = AppPropertiesCache()
    
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "StrafenProject", category: String(describing: AppPropertiesCache.self))
    
    private init() {}
    
    private func url(path: String) -> URL {
        let baseUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.stevenkellner.StrafenProject.appPropertiesCache")!
        return baseUrl.appending(path: "\(path)-\(DatabaseType.current.rawValue)").appendingPathExtension("json")
    }
    
    func removeList<Element>(type: Element.Type) throws where Element: ListCachable {
        AppPropertiesCache.logger.log("Remove cached list for \(Element.self)")
        try FileManager.default.removeItem(at: self.url(path: Element.cacheFilePath))
    }
    
    func saveList<Element>(list: IdentifiableList<Element>) throws where Element: ListCachable {
        AppPropertiesCache.logger.log("Cache list for \(Element.self)")
        let crypter = Crypter(keys: PrivateKeys.current.cryptionKeys)
        let encryptedJsonData = try crypter.encodeEncryptToData(CachedData(savedAt: UtcDate(), list: list))
        try encryptedJsonData.write(to: self.url(path: Element.cacheFilePath), options: .atomic)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func getList<Element>() throws -> IdentifiableList<Element>? where Element: ListCachable {
        AppPropertiesCache.logger.log("Get cached list for \(Element.self)")
        guard let encryptedJsonData = try? Data(contentsOf: self.url(path: Element.cacheFilePath), options: .uncached) else {
            return nil
        }
        let crypter = Crypter(keys: PrivateKeys.current.cryptionKeys)
        let cachedData = try crypter.decryptDecode(type: CachedData<Element>.self, encryptedJsonData)
        guard cachedData.savedAt >= UtcDate().advanced(day: -5).setted(hour: 0, minute: 0) else {
            return nil
        }
        return cachedData.list
    }
}
