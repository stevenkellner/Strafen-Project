//
//  FirebaseConfigurator.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation
import FirebaseCore
import FirebaseAuth

struct FirebaseConfigurator {
    enum ConfigurationResult {
        case success
        case failure
        case alreadyConfigured
    }
    
    private var alreadyConfigured = false
    
    static var shared = FirebaseConfigurator()
    
    private init() {}
    
    @MainActor
    @discardableResult
    mutating func configure() -> ConfigurationResult {
        guard !self.alreadyConfigured else {
            return .alreadyConfigured
        }
        FirebaseApp.configure()
        try? Auth.auth().useUserAccessGroup("K7NTJ83ZF8.stevenkellner.StrafenProject")
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        self.alreadyConfigured = true
        return .success
    }
}
