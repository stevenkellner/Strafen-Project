//
//  SettingsManager.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

@dynamicMemberLookup
class SettingsManager: ObservableObject {
        
    @Published private var settings: Settings
    
    init() {
        self.settings = .default
        try? self.readSettings()
    }
    
    private var settingsUrl: URL {
        let baseUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.stevenkellner.StrafenProject.settings")!
        return baseUrl.appending(path: "settings-\(DatabaseType.current.rawValue)").appendingPathExtension("json")
    }
    
    func readSettings() throws {
        let encryptedJsonData = try Data(contentsOf: self.settingsUrl, options: .uncached)
        let crypter = Crypter(keys: PrivateKeys.current.cryptionKeys)
        self.settings = try crypter.decryptDecode(type: Settings.self, encryptedJsonData)
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<Settings, T>) -> T {
        get {
            return self.settings[keyPath: keyPath]
        }
    }
    
    #if !NOTIFICATION_SERVICE_EXTENSION && !WIDGET_EXTENSION
    func saveSettings() throws {
        let crypter = Crypter(keys: PrivateKeys.current.cryptionKeys)
        let encryptedJsonData = try crypter.encodeEncryptToData(self.settings)
        try encryptedJsonData.write(to: self.settingsUrl, options: .atomic)
    }
        
    func save<T>(_ value: T, at keyPath: WritableKeyPath<Settings, T>) throws {
        self.settings[keyPath: keyPath] = value
        try self.saveSettings()
        
    }
    #endif
}
