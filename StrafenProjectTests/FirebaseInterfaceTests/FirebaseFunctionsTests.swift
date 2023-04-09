//
//  FirebaseFunctions.swift
//  StrafenProjectTests
//
//  Created by Steven on 07.04.23.
//

import XCTest
import FirebaseDatabase
@testable import StrafenProject

final class FirebaseFunctionsTests: XCTestCase {
    private let clubId = ClubProperties.ID()

    override func setUp() async throws {
        try await super.setUp()
        let result = await FirebaseConfigurator.shared.configure()
        XCTAssertNotEqual(result, .failure)
        try await FirebaseConfigurator.shared.createTestClub(id: self.clubId)
        try await FirebaseAuthenticator.shared.authenticateTestUser(clubId: self.clubId)
    }
    
    override func tearDown() async throws {
        try await FirebaseConfigurator.shared.cleanUp()
    }
    
    func testThrowsHttpsError() async {
        let clubGetIdFunction = ClubGetIdFunction(identifier: "invalid")
        await XCTAssertThrowsErrorAsync(try await FirebaseFunctionCaller.shared.forTesting.call(clubGetIdFunction)) { error in
            XCTAssertTrue(error is FirebaseFunctionResult<ClubGetIdFunction.ReturnType>.Error)
            XCTAssertEqual((error as? FirebaseFunctionResult<ClubGetIdFunction.ReturnType>.Error)?.code, .notFound)
        }
    }
    
    func testGetId() async throws {
        let clubGetIdFunction = ClubGetIdFunction(identifier: "demo-team")
        let id = try await FirebaseFunctionCaller.shared.forTesting.call(clubGetIdFunction)
        XCTAssertEqual(id, clubId)
    }
    
    func testNewClub() async throws {
        let clubNewFunction = ClubNewFunction(clubProperties: ClubProperties(id: ClubProperties.ID(), identifier: "test-club", name: "Test Club", regionCode: "DE", inAppPaymentActive: false), personId: Person.ID(), personName: Person.PersonName(first: "asdf"))
        try await FirebaseFunctionCaller.shared.forTesting.call(clubNewFunction)
    }
    
    func testFineEditAdd() async throws {
        let fineEditFunction = FineEditFunction.add(clubId: self.clubId, fine: Fine(id: Fine.ID(), personId: Person.ID(), payedState: .unpayed, number: 2, date: Date(), fineReason: FineReason(reasonMessage: "asdf", amount: Amount(value: 10, subUnitValue: 50), importance: .low)))
        try await FirebaseFunctionCaller.shared.forTesting.call(fineEditFunction)
    }
    
    func testFineEditUpdate() async throws {
        let fineEditFunction = FineEditFunction.update(clubId: self.clubId, fine: Fine(id: Fine.ID(uuidString: "02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, personId: Person.ID(), payedState: .unpayed, number: 2, date: Date(), fineReason: FineReason(reasonMessage: "asdf", amount: Amount(value: 10, subUnitValue: 50), importance: .low)))
        try await FirebaseFunctionCaller.shared.forTesting.call(fineEditFunction)
    }
    
    func testFineEditDelete() async throws {
        let fineEditFunction = FineEditFunction.delete(clubId: self.clubId, fineId: Fine.ID(uuidString: "02462A8B-107F-4BAE-A85B-EFF1F727C00F")!)
        try await FirebaseFunctionCaller.shared.forTesting.call(fineEditFunction)
    }
    
    func testFineEditPayed() async throws {
        let fineEditPayedFunction = FineEditPayedFunction(clubId: self.clubId, fineId: Fine.ID(uuidString: "0B5F958E-9D7D-46E1-8AEE-F52F4370A95A")!, payedState: .payed(inApp: false, payDate: Date()))
        try await FirebaseFunctionCaller.shared.forTesting.call(fineEditPayedFunction)
    }
    
    func testFineGet() async throws {
        let fineGetFunction = FineGetFunction(clubId: self.clubId)
        let fineList = try await FirebaseFunctionCaller.shared.forTesting.call(fineGetFunction)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        XCTAssertEqual(fineList, IdentifiableList(values:[
            Fine(id: Fine.ID(uuidString: "02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, personId: Person.ID(uuidString: "76025DDE-6893-46D2-BC34-9864BB5B8DAD")!, payedState: .settled, number: 1, date: dateFormatter.date(from: "2023-01-24T17:23:45.678Z")!, fineReason: FineReason(reasonMessage: "test_fine_reason_1", amount: Amount(value: 1, subUnitValue: 0), importance: .low)),
            Fine(id: Fine.ID(uuidString: "0B5F958E-9D7D-46E1-8AEE-F52F4370A95A")!, personId: Person.ID(uuidString: "76025DDE-6893-46D2-BC34-9864BB5B8DAD")!, payedState: .unpayed, number: 2, date: dateFormatter.date(from: "2023-01-02T17:23:45.678Z")!, fineReason: FineReason(reasonMessage: "test_fine_reason_2", amount: Amount(value: 2, subUnitValue: 50), importance: .high)),
            Fine(id: Fine.ID(uuidString: "1B5F958E-9D7D-46E1-8AEE-F52F4370A95A")!, personId: Person.ID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!, payedState: .payed(inApp: false, payDate: dateFormatter.date(from: "2023-01-22T17:23:45.678Z")!), number: 1, date: dateFormatter.date(from: "2023-01-20T17:23:45.678Z")!, fineReason: FineReason(reasonMessage: "test_fine_reason_3", amount: Amount(value: 2, subUnitValue: 0), importance: .medium))
        ]))
    }
    
    func testPersonEditAdd() async throws {
        let personEditFunction = PersonEditFunction.add(clubId: self.clubId, person: Person(id: Person.ID(), name: Person.PersonName(first: "ölkm", last: "poikm"), fineIds: [], signInData: nil))
        try await FirebaseFunctionCaller.shared.forTesting.call(personEditFunction)
    }
    
    func testPersonEditUpdate() async throws {
        let personEditFunction = PersonEditFunction.update(clubId: self.clubId, person: Person(id: Person.ID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!, name: Person.PersonName(first: "poiunzg"), fineIds: [], signInData: nil))
        try await FirebaseFunctionCaller.shared.forTesting.call(personEditFunction)
    }
    
    func testPersonEditDelete() async throws {
        let personEditFunction = PersonEditFunction.delete(clubId: self.clubId, personId: Person.ID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!)
        try await FirebaseFunctionCaller.shared.forTesting.call(personEditFunction)
    }
    
    func testPersonGetCurrent() async throws {
        XCTAssertNotNil(FirebaseAuthenticator.shared.user)
        let hashedUserId = Crypter.sha512(FirebaseAuthenticator.shared.user!.uid)
        let personId = Person.ID()
        try await Database.database(url: PrivateKeys.current(.testing).databaseUrl).reference(withPath: "users/\(hashedUserId)").setValue(["clubId": self.clubId.uuidString, "personId": personId.uuidString])
        let signInDate = Date()
        let crypter = Crypter(keys: PrivateKeys.current(.testing).cryptionKeys)
        try await Database.database(url: PrivateKeys.current(.testing).databaseUrl).reference(withPath: "clubs/\(self.clubId.uuidString)/persons/\(personId.uuidString)").setValue(crypter.encodeEncrypt(Person(id: personId, name: Person.PersonName(first: "lkj", last: "asef"), fineIds: [], signInData: Person.SignInData(hashedUserId: hashedUserId, signInDate: signInDate))))
        let personGetCurrentFunction = PersonGetCurrentFunction()
        let person = try await FirebaseFunctionCaller.shared.forTesting.call(personGetCurrentFunction)
        XCTAssertEqual(person, PersonGetCurrentFunction.ReturnType(id: personId, name: Person.PersonName(first: "lkj", last: "asef"), fineIds: [], signInData: Person.SignInData(hashedUserId: hashedUserId, signInDate: signInDate), isAdmin: true, club: ClubProperties(id: self.clubId, identifier: "demo-team", name: "Neuer Verein", regionCode: "DE", inAppPaymentActive: true)))
    }
    
    func testPersonGet() async throws {
        let personGetFunction = PersonGetFunction(clubId: self.clubId)
        let personList = try await FirebaseFunctionCaller.shared.forTesting.call(personGetFunction)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        XCTAssertEqual(personList, IdentifiableList(values: [
            Person(id: Person.ID(uuidString: "76025DDE-6893-46D2-BC34-9864BB5B8DAD")!, name: Person.PersonName(first: "John"), fineIds: [Fine.ID(uuidString: "02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, Fine.ID(uuidString: "0B5F958E-9D7D-46E1-8AEE-F52F4370A95A")!], signInData: Person.SignInData(hashedUserId: "sha_abc", signInDate: dateFormatter.date(from: "2022-01-24T17:23:45.678Z")!)),
            Person(id: Person.ID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!, name: Person.PersonName(first: "Jane", last: "Doe"), fineIds: [], signInData: nil),
            Person(id: Person.ID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!, name: Person.PersonName(first: "Max", last: "Mustermann"), fineIds: [Fine.ID(uuidString: "1B5F958E-9D7D-46E1-8AEE-F52F4370A95A")!], signInData: Person.SignInData(hashedUserId: "sha_xyz", signInDate: dateFormatter.date(from: "2022-01-26T17:23:45.678Z")!))
        ]))
    }
    
    func testPersonRegister() async throws {
        XCTAssertNotNil(FirebaseAuthenticator.shared.user)
        let hashedUserId = Crypter.sha512(FirebaseAuthenticator.shared.user!.uid)
        try await Database.database(url: PrivateKeys.current(.testing).databaseUrl).reference(withPath: "clubs/\(self.clubId.uuidString)/authentication/clubMember/\(hashedUserId)").removeValue()
        try await Database.database(url: PrivateKeys.current(.testing).databaseUrl).reference(withPath: "clubs/\(self.clubId.uuidString)/authentication/clubManager/\(hashedUserId)").removeValue()
        let personRegisterPerson = PersonRegisterFunction(clubId: self.clubId, personId: Person.ID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!)
        let club = try await FirebaseFunctionCaller.shared.forTesting.call(personRegisterPerson)
        XCTAssertEqual(club, ClubProperties(id: self.clubId, identifier: "demo-team", name: "Neuer Verein", regionCode: "DE", inAppPaymentActive: true))
    }
    
    func testReasonTemplateEditAdd() async throws {
        let reasonTemplateEditFunction = ReasonTemplateEditFunction.add(clubId: self.clubId, reasonTemplate: ReasonTemplate(id: ReasonTemplate.ID(), reasonMessage: "asdf", amount: Amount(value: 10, subUnitValue: 50), importance: .low))
        try await FirebaseFunctionCaller.shared.forTesting.call(reasonTemplateEditFunction)
    }
    
    func testReasonTemplateEditUpdate() async throws {
        let reasonTemplateEditFunction = ReasonTemplateEditFunction.update(clubId: self.clubId, reasonTemplate: ReasonTemplate(id: ReasonTemplate.ID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!, reasonMessage: "asdf", amount: Amount(value: 10, subUnitValue: 50), importance: .low))
        try await FirebaseFunctionCaller.shared.forTesting.call(reasonTemplateEditFunction)
    }
    
    func testReasonTemplateEditDelete() async throws {
        let reasonTemplateEditFunction = ReasonTemplateEditFunction.delete(clubId: self.clubId, reasonTemplateId: ReasonTemplate.ID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!)
        try await FirebaseFunctionCaller.shared.forTesting.call(reasonTemplateEditFunction)
    }
    
    func testReasonTemplateGet() async throws {
        let personGetFunction = ReasonTemplateGetFunction(clubId: self.clubId)
        let reasonTemplateList = try await FirebaseFunctionCaller.shared.forTesting.call(personGetFunction)
        XCTAssertEqual(reasonTemplateList, IdentifiableList(values: [
            ReasonTemplate(id: ReasonTemplate.ID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!, reasonMessage: "test_reason_1", amount: Amount(value: 1, subUnitValue: 0), importance: .low),
            ReasonTemplate(id: ReasonTemplate.ID(uuidString: "16805D21-5E8D-43E9-BB5C-7B4A790F0CE7")!, reasonMessage: "test_reason_2", amount: Amount(value: 2, subUnitValue: 50), importance: .high),
            ReasonTemplate(id: ReasonTemplate.ID(uuidString: "23A3412E-87DE-4A23-A08F-67214B8A8541")!, reasonMessage: "test_reason_3", amount: Amount(value: 2, subUnitValue: 0), importance: .medium)
        ]))
    }
}
