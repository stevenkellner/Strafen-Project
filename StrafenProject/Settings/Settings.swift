//
//  Settings.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation
import StrafenProjectMacros

@DefaultDecodable
struct Settings: Encodable {
    static let `default` = Settings(appearance: .system, sorting: Settings.Sorting.default, signedInPerson: nil)
    
    public var appearance: Settings.Appearance
    public var sorting: Settings.Sorting
    public var signedInPerson: Settings.SignedInPerson?
    
    init(appearance: Settings.Appearance, sorting: Settings.Sorting, signedInPerson: Settings.SignedInPerson?) {
        self.appearance = appearance
        self.sorting = sorting
        self.signedInPerson = signedInPerson
    }
}
