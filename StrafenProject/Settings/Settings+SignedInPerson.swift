//
//  Settings+SignedInPerson.swift
//  StrafenProject
//
//  Created by Steven on 09.04.23.
//

import Foundation

extension Settings {
    struct SignedInPerson {
        public private(set) var id: Person.ID
        public private(set) var name: Person.PersonName
        public private(set) var signInDate: Date
        public private(set) var isAdmin: Bool
        public private(set) var hashedUserId: String
        public private(set) var club: ClubProperties
    }
}

extension Settings.SignedInPerson: Sendable {}

extension Settings.SignedInPerson: Equatable {}

extension Settings.SignedInPerson: Hashable {}

extension Settings.SignedInPerson: Codable {}

