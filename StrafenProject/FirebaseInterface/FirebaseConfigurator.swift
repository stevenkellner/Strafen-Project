//
//  FirebaseConfigurator.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation
import FirebaseCore

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
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        self.alreadyConfigured = true
        return .success
    }
}

