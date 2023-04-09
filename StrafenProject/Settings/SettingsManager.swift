//
//  SettingsManager.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

@dynamicMemberLookup
struct SettingsManager {
    
    private var databaseType: DatabaseType = .default
    
    private var settings: Settings
    
    static let shared = SettingsManager()
    
    private init() {
        self.settings = Settings(appearance: .system, signedInPerson: nil)
        let _ = self.readSettings()
    }
    
    private var settingsUrl: URL {
        let baseUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "secure-setting-group")!
        return baseUrl.appending(path: self.databaseType.rawValue).appending(path: "settings").appendingPathExtension("json")
    }
    
    mutating func readSettings() -> OperationResult {
        guard FileManager.default.fileExists(atPath: self.settingsUrl.absoluteString),
              let encryptedJsonData = FileManager.default.contents(atPath: self.settingsUrl.absoluteString) else {
            return .failed
        }
        let crypter = Crypter(keys: PrivateKeys.current(self.databaseType).cryptionKeys)
        guard let settings = try? crypter.decryptDecode(type: Settings.self, encryptedJsonData) else {
            return .failed
        }
        return .passed
    }
    
    func saveSettings() {
        let crypter = Crypter(keys: PrivateKeys.current(self.databaseType).cryptionKeys)
        guard let encryptedJsonData = try? crypter.encodeEncryptToData(self.settings) else {
            return
        }
        if !FileManager.default.fileExists(atPath: self.settingsUrl.absoluteString) ||
              (try? encryptedJsonData.write(to: self.settingsUrl, options: .atomic)) == nil {
            FileManager.default.createFile(atPath: self.settingsUrl.absoluteString, contents: encryptedJsonData)
        }
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Settings, T>) -> T {
        get {
            return self.settings[keyPath: keyPath]
        }
        set {
            self.settings[keyPath: keyPath] = newValue
            self.saveSettings()
        }
    }
    
    var forTesting: SettingsManager {
        var manager = self
        manager.databaseType = .testing
        return manager
    }
}
