//
//  Utilities.swift
//  StrafenProjectTests
//
//  Created by Steven on 07.04.23.
//

import Foundation
import XCTest
import FirebaseDatabase
@testable import StrafenProject

func XCTAssertEqualIterator<T>(_ iterator1: some IteratorProtocol<T>, _ iterator2: some IteratorProtocol<T>, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) where T : Equatable {
    var iterator1 = iterator1
    var iterator2 = iterator2
    while let element1 = iterator1.next() {
        guard let element2 = iterator2.next() else {
            return XCTFail("Iterator 1 has more elements than iterator 2.", file: file, line: line)
        }
        XCTAssertEqual(element1, element2, message(), file: file, line: line)
    }
    if iterator2.next() != nil {
        XCTFail("Iterator 2 has more elements than iterator 1.", file: file, line: line)
    }
}

func XCTAssertThrowsErrorAsync<T>(_ expression: @autoclosure () async throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line, _ errorHandler: (_ error: Error) -> Void = { _ in }) async {
    do {
        let _ = try await expression()
        XCTFail(message(), file: file, line: line)
    } catch {
        errorHandler(error)
    }
}

extension FirebaseAuthenticator {
    func authenticateTestUser(clubId: ClubProperties.ID) async throws {
        try await self.signIn(email: "functions-tests-user@mail.com", password: "ghQshXA7rnDdGWj8GffSQN7VGrm9Qf3Z")
        await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for authenticationType in ["clubMember", "clubManager"] {
                taskGroup.addTask {
                    try await self.authenticateTestUser(type: authenticationType, clubId: clubId)
                }
            }
        }
    }
    
    private func authenticateTestUser(type authenticationType: String, clubId: ClubProperties.ID) async throws {
        XCTAssertNotNil(self.user)
        let hashedUserId = Crypter.sha512(self.user!.uid)
        try await Database.database(url: PrivateKeys.current(.testing).databaseUrl).reference(withPath: "clubs/\(clubId.uuidString)/authentication/\(authenticationType)/\(hashedUserId)").setValue("authenticated")
    }
}

extension FirebaseConfigurator {
    func createTestClub(id clubId: ClubProperties.ID, type testClubType: ClubNewTestFunction.TestClubType = .default) async throws {
        let clubNewTestFunction = ClubNewTestFunction(clubId: clubId, testClubType: testClubType)
        try await FirebaseFunctionCaller.shared.forTesting.call(clubNewTestFunction)
    }
    
    func cleanUp() async throws {
        let deleteAllDataFunction = DeleteAllDataFunction()
        try await FirebaseFunctionCaller.shared.forTesting.call(deleteAllDataFunction)
    }
}
