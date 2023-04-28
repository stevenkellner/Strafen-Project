//
//  Settings+Appearance.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation
import UIKit

extension Settings {
    enum Appearance: String, CaseIterable {
        case system
        case light
        case dark
        
        var uiStyle: UIUserInterfaceStyle {
            switch self {
            case .system:
                return .unspecified
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }
        
        var formatted: String {
            switch self {
            case .system:
                return String(localized: "appearance|system", comment: "Description of the system appearance.")
            case .light:
                return String(localized: "appearance|light", comment: "Description of the light appearance.")
            case .dark:
                return String(localized: "appearance|dark", comment: "Description of the dark appearance.")
            }
        }
    }
}

extension Settings.Appearance: Sendable {}

extension Settings.Appearance: Equatable {}

extension Settings.Appearance: Hashable {}

extension Settings.Appearance: Codable {}
