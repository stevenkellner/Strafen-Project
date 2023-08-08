//
//  UtcDateTests.swift
//  StrafenProjectTests
//
//  Created by Steven on 05.08.23.
//

import XCTest
@testable import StrafenProject

final class UtcDateTests: XCTestCase {
    func testFromDate() {
        let date = UtcDate(ISO8601DateFormatter().date(from: "2023-02-07T12:34:56+01:00") ?? Date())
        XCTAssertEqual(date, UtcDate(year: 2023, month: 2, day: 7, hour: 11, minute: 34))
    }
    
    struct T1: Codable {
        let asd: UtcDate
    }
    
    func testEncodeDecode() throws {
        let date = UtcDate(ISO8601DateFormatter().date(from: "2023-02-07T12:34:56+01:00") ?? Date())
        let encoded = try JSONEncoder().encode(date)
        XCTAssertEqual(String(data: encoded, encoding: .utf8), "\"2023-02-07-11-34\"")
        let decoded = try JSONDecoder().decode(UtcDate.self, from: encoded)
        XCTAssertEqual(decoded, date)
    }
    
    func testSetted() {
        let date = UtcDate(ISO8601DateFormatter().date(from: "2023-02-07T12:34:56+01:00") ?? Date())
        var newDate = date.setted(year: 2022, month: 5, day: 1)
        XCTAssertEqual(newDate, UtcDate(year: 2022, month: 5, day: 1, hour: 11, minute: 34))
        newDate = date.setted(hour: 0, minute: 0)
        XCTAssertEqual(newDate, UtcDate(year: 2023, month: 2, day: 7, hour: 0, minute: 0))
        newDate = date.setted(month: 1, day: 40, minute: 65)
        XCTAssertEqual(newDate, UtcDate(year: 2023, month: 2, day: 9, hour: 12, minute: 5))
    }
    
    func testAdvanced() {
        let date = UtcDate(ISO8601DateFormatter().date(from: "2023-02-07T12:34:56+01:00") ?? Date())
        var newDate = date.advanced(year: 1, month: 1, day: 1)
        XCTAssertEqual(newDate, UtcDate(year: 2024, month: 3, day: 8, hour: 11, minute: 34))
        newDate = date.advanced(hour: 4, minute: 2)
        XCTAssertEqual(newDate, UtcDate(year: 2023, month: 2, day: 7, hour: 15, minute: 36))
        newDate = date.advanced(month: 1, day: 30, minute: 30);
        XCTAssertEqual(newDate, UtcDate(year: 2023, month: 4, day: 6, hour: 12, minute: 4))
    }
    
    func testCompare() {
        let date1 = UtcDate(ISO8601DateFormatter().date(from: "2024-02-07T12:34:56+01:00") ?? Date())
        let date2 = UtcDate(ISO8601DateFormatter().date(from: "2023-02-08T12:34:56+01:00") ?? Date())
        let date3 = UtcDate(ISO8601DateFormatter().date(from: "2023-02-07T12:35:56+01:00") ?? Date())
        let date4 = UtcDate(ISO8601DateFormatter().date(from: "2023-02-07T12:34:56+01:00") ?? Date())
        XCTAssertGreaterThan(date1, date2)
        XCTAssertGreaterThan(date1, date3)
        XCTAssertGreaterThan(date1, date4)
        XCTAssertGreaterThan(date2, date3)
        XCTAssertGreaterThan(date2, date4)
        XCTAssertGreaterThan(date3, date4)
        XCTAssertEqual(date1, date1)
        XCTAssertLessThan(date2, date1)
        XCTAssertLessThan(date3, date1)
        XCTAssertLessThan(date4, date1)
        XCTAssertLessThan(date3, date2)
        XCTAssertLessThan(date4, date2)
        XCTAssertLessThan(date4, date3)
    }
}
