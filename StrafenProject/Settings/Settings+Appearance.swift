//
//  Settings+Appearance.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation
import UIKit

extension Settings {
    enum Appearance {
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
    }
}

extension Settings.Appearance: Sendable {}

extension Settings.Appearance: Equatable {}

extension Settings.Appearance: Hashable {}

extension Settings.Appearance: Codable {}
