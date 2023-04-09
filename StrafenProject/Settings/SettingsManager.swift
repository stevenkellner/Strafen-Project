//
//  SettingsManager.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

@dynamicMemberLookup
struct SettingsManager {
        
    private var settings: Settings
    
    static var shared = SettingsManager()
    
    init() {
        self.settings = Settings(appearance: .system, signedInPerson: nil)
        do {
            try self.readSettings()
        } catch {
            print(error)
        }
    }
    
    private var settingsUrl: URL {
        let baseUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.stevenkellner.StrafenProject.settings")!
        return baseUrl.appending(path: "settings-\(DatabaseType.current.rawValue)").appendingPathExtension("json")
    }
    
    mutating func readSettings() throws {
        let encryptedJsonData = try Data(contentsOf: self.settingsUrl, options: .uncached)
        let crypter = Crypter(keys: PrivateKeys.current.cryptionKeys)
        self.settings = try crypter.decryptDecode(type: Settings.self, encryptedJsonData)
    }
    
    func saveSettings() throws {
        let crypter = Crypter(keys: PrivateKeys.current.cryptionKeys)
        let encryptedJsonData = try crypter.encodeEncryptToData(self.settings)
        try encryptedJsonData.write(to: self.settingsUrl, options: .atomic)
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<Settings, T>) -> T {
        get {
            return self.settings[keyPath: keyPath]
        }
    }
    
    mutating func save<T>(_ value: T, at keyPath: WritableKeyPath<Settings, T>) throws {
        self.settings[keyPath: keyPath] = value
        try self.saveSettings()
        
    }
}
