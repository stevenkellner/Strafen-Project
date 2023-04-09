//
//  SettingsTests.swift
//  StrafenProjectTests
//
//  Created by Steven on 09.04.23.
//

import Foundation
import XCTest
@testable import StrafenProject

final class SettingsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        DatabaseType.current = .testing
        self.tearDown()
    }
    
    override func tearDown() {
        let baseUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.stevenkellner.StrafenProject.settings")!
        let settingsUrl = baseUrl.appending(path: "settings-\(DatabaseType.current.rawValue)").appendingPathExtension("json")
        try? FileManager.default.removeItem(at: settingsUrl)
        SettingsManager.shared = SettingsManager()
    }
    
    func testInitialSettings() {
        XCTAssertEqual(SettingsManager.shared.appearance, .system)
        XCTAssertNil(SettingsManager.shared.signedInPerson)
    }
    
    func testSaveAndInitialRead() throws {
        try SettingsManager.shared.save(.dark, at: \.appearance)
        let signedInPerson = Settings.SignedInPerson(id: Person.ID(), name: Person.PersonName(first: "asdf"), signInDate: Date(), isAdmin: true, hashedUserId: "ölkj", club: ClubProperties(id: ClubProperties.ID(), identifier: "idadsf", name: "ölkmun", regionCode: "DE", inAppPaymentActive: false))
        try SettingsManager.shared.save(signedInPerson, at: \.signedInPerson)
        XCTAssertEqual(SettingsManager().appearance, .dark)
        XCTAssertEqual(SettingsManager().signedInPerson, signedInPerson)
    }
    
    func testSaveAndRead() throws {
        var settingsManager = SettingsManager()
        try settingsManager.save(.light, at: \.appearance)
        let signedInPerson = Settings.SignedInPerson(id: Person.ID(), name: Person.PersonName(first: "mztu", last: "iuw"), signInDate: Date(), isAdmin: false, hashedUserId: "xycbvcnb", club: ClubProperties(id: ClubProperties.ID(), identifier: "wert", name: "mzru", regionCode: "ES", inAppPaymentActive: true))
        try settingsManager.save(signedInPerson, at: \.signedInPerson)
        XCTAssertEqual(SettingsManager.shared.appearance, .system)
        XCTAssertEqual(SettingsManager.shared.signedInPerson, nil)
        try SettingsManager.shared.readSettings()
        XCTAssertEqual(SettingsManager.shared.appearance, .light)
        XCTAssertEqual(SettingsManager.shared.signedInPerson, signedInPerson)
        
    }
}
