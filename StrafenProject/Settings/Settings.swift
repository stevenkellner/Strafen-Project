//
//  Settings.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

struct Settings: Codable {    
    private struct OptionalSettings: Decodable {
        let appearance: Settings.Appearance?
        let sorting: Settings.Sorting?
        let signedInPerson: Settings.SignedInPerson?
    }
    
    static let `default` = Settings(appearance: .system, sorting: Settings.Sorting.default, signedInPerson: nil)
    
    public var appearance: Settings.Appearance
    public var sorting: Settings.Sorting
    public var signedInPerson: Settings.SignedInPerson?
    
    init(appearance: Settings.Appearance, sorting: Settings.Sorting, signedInPerson: Settings.SignedInPerson?) {
        self.appearance = appearance
        self.sorting = sorting
        self.signedInPerson = signedInPerson
    }
    
    init(from decoder: Decoder) throws {
        let optionalSettings = try? OptionalSettings(from: decoder)
        self.appearance = optionalSettings?.appearance ?? Settings.default.appearance
        self.sorting = optionalSettings?.sorting ?? Settings.default.sorting
        self.signedInPerson = optionalSettings?.signedInPerson ?? Settings.default.signedInPerson
    }
}
