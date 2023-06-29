//
//  SettingsTests.swift
//  StrafenProjectTests
//
//  Created by Steven on 09.04.23.
//

import Foundation
import XCTest
@testable import StrafenProject

@MainActor
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
    }
    
    func testInitialSettings() {
        let settingsManager = SettingsManager()
        XCTAssertEqual(settingsManager.appearance, .system)
        XCTAssertNil(settingsManager.signedInPerson)
    }
    
    func testSaveAndInitialRead() throws {
        let settingsManager = SettingsManager()
        try settingsManager.save(.dark, at: \.appearance)
        let signedInPerson = Settings.SignedInPerson(id: Person.ID(), name: PersonName(first: "asdf"), fineIds: [Fine.ID()], isAdmin: true, hashedUserId: "ölkj", club: ClubProperties(id: ClubProperties.ID(), name: "ölkmun"))
        try settingsManager.save(signedInPerson, at: \.signedInPerson)
        XCTAssertEqual(SettingsManager().appearance, .dark)
        XCTAssertEqual(SettingsManager().signedInPerson, signedInPerson)
    }
    
    func testSaveAndRead() throws {
        let settingsManager1 = SettingsManager()
        let settingsManager2 = SettingsManager()
        try settingsManager2.save(.light, at: \.appearance)
        let signedInPerson = Settings.SignedInPerson(id: Person.ID(), name: PersonName(first: "mztu", last: "iuw"), fineIds: [Fine.ID(), Fine.ID()], isAdmin: false, hashedUserId: "xycbvcnb", club: ClubProperties(id: ClubProperties.ID(), name: "mzru"))
        try settingsManager2.save(signedInPerson, at: \.signedInPerson)
        XCTAssertEqual(settingsManager1.appearance, .system)
        XCTAssertEqual(settingsManager1.signedInPerson, nil)
        try settingsManager1.readSettings()
        XCTAssertEqual(settingsManager1.appearance, .light)
        XCTAssertEqual(settingsManager1.signedInPerson, signedInPerson)
        
    }
}
