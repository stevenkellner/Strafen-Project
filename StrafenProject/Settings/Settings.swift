//
//  Settings.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

struct Settings {
    static let `default` = Settings(appearance: .system, sorting: Settings.Sorting.default, signedInPerson: nil)
    
    public var appearance: Settings.Appearance
    public var sorting: Settings.Sorting
    public var signedInPerson: Settings.SignedInPerson?
}

extension Settings: Codable { // TODO macro
    private struct OptionalSettings: Decodable {
        let appearance: Settings.Appearance?
        public var sorting: Settings.Sorting?
        let signedInPerson: Settings.SignedInPerson?
    }
    
    init(from decoder: Decoder) throws {
        let optionalSettings = try? OptionalSettings(from: decoder)
        self.appearance = optionalSettings?.appearance ?? Settings.default.appearance
        self.sorting = optionalSettings?.sorting ?? Settings.default.sorting
        self.signedInPerson = optionalSettings?.signedInPerson ?? Settings.default.signedInPerson
    }
}
