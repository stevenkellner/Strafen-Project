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
        DatabaseType.current = .testing
        let result = await FirebaseConfigurator.shared.configure()
        XCTAssertNotEqual(result, .failure)
        try await FirebaseConfigurator.shared.createTestClub(id: self.clubId)
        try await FirebaseAuthenticator.shared.authenticateTestUser(clubId: self.clubId)
    }
    
    override func tearDown() async throws {
        try await FirebaseConfigurator.shared.cleanUp()
    }
    
    func testThrowsHttpsError() async {
        let fineEditPayedFunction = FineEditPayedFunction(clubId: self.clubId, fineId: Fine.ID(), payedState: .payed)
        await XCTAssertThrowsErrorAsync(try await FirebaseFunctionCaller.shared.verbose.call(fineEditPayedFunction)) { error in
            XCTAssertTrue(error is FirebaseFunctionError)
            XCTAssertEqual((error as? FirebaseFunctionError)?.code, .notFound)
        }
    }
        
    func testNewClub() async throws {
        let clubNewFunction = ClubNewFunction(clubProperties: ClubProperties(id: ClubProperties.ID(), name: "Test Club"), personId: Person.ID(), personName: PersonName(first: "asdf"))
        try await FirebaseFunctionCaller.shared.verbose.call(clubNewFunction)
    }
    
    func testFineEditAdd() async throws {
        let fineEditFunction = FineEditFunction.add(clubId: self.clubId, fine: Fine(id: Fine.ID(), personId: Person.ID(), payedState: .unpayed, date: Date(), reasonMessage: "asdf", amount: Amount(value: 10, subUnitValue: 50)))
        try await FirebaseFunctionCaller.shared.verbose.call(fineEditFunction)
    }
    
    func testFineEditUpdate() async throws {
        let fineEditFunction = FineEditFunction.update(clubId: self.clubId, fine: Fine(id: Fine.ID(uuidString: "02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, personId: Person.ID(), payedState: .unpayed, date: Date(), reasonMessage: "asdf", amount: Amount(value: 10, subUnitValue: 50)))
        try await FirebaseFunctionCaller.shared.verbose.call(fineEditFunction)
    }
    
    func testFineEditDelete() async throws {
        let fineEditFunction = FineEditFunction.delete(clubId: self.clubId, fineId: Fine.ID(uuidString: "02462A8B-107F-4BAE-A85B-EFF1F727C00F")!)
        try await FirebaseFunctionCaller.shared.verbose.call(fineEditFunction)
    }
    
    func testFineEditPayed() async throws {
        let fineEditPayedFunction = FineEditPayedFunction(clubId: self.clubId, fineId: Fine.ID(uuidString: "0B5F958E-9D7D-46E1-8AEE-F52F4370A95A")!, payedState: .payed)
        try await FirebaseFunctionCaller.shared.verbose.call(fineEditPayedFunction)
    }
    
    func testFineGet() async throws {
        let fineGetFunction = FineGetFunction(clubId: self.clubId)
        let fineList = try await FirebaseFunctionCaller.shared.verbose.call(fineGetFunction)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        XCTAssertEqual(fineList, IdentifiableList(values:[
            Fine(id: Fine.ID(uuidString: "02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, personId: Person.ID(uuidString: "76025DDE-6893-46D2-BC34-9864BB5B8DAD")!, payedState: .unpayed, date: dateFormatter.date(from: "2023-01-24T17:23:45.678Z")!, reasonMessage: "test_fine_reason_1", amount: Amount(value: 1, subUnitValue: 0)),
            Fine(id: Fine.ID(uuidString: "0B5F958E-9D7D-46E1-8AEE-F52F4370A95A")!, personId: Person.ID(uuidString: "76025DDE-6893-46D2-BC34-9864BB5B8DAD")!, payedState: .unpayed, date: dateFormatter.date(from: "2023-01-02T17:23:45.678Z")!, reasonMessage: "test_fine_reason_2", amount: Amount(value: 2, subUnitValue: 50)),
            Fine(id: Fine.ID(uuidString: "1B5F958E-9D7D-46E1-8AEE-F52F4370A95A")!, personId: Person.ID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!, payedState: .payed, date: dateFormatter.date(from: "2023-01-20T17:23:45.678Z")!, reasonMessage: "test_fine_reason_3", amount: Amount(value: 2, subUnitValue: 0))
        ]))
    }
    
    func testPersonEditAdd() async throws {
        let personEditFunction = PersonEditFunction.add(clubId: self.clubId, person: Person(id: Person.ID(), name: PersonName(first: "ölkm", last: "poikm"), fineIds: [], signInData: nil, isInvited: false))
        try await FirebaseFunctionCaller.shared.verbose.call(personEditFunction)
    }
    
    func testPersonEditUpdate() async throws {
        let personEditFunction = PersonEditFunction.update(clubId: self.clubId, person: Person(id: Person.ID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!, name: PersonName(first: "poiunzg"), fineIds: [], signInData: nil, isInvited: true))
        try await FirebaseFunctionCaller.shared.verbose.call(personEditFunction)
    }
    
    func testPersonEditDelete() async throws {
        let personEditFunction = PersonEditFunction.delete(clubId: self.clubId, personId: Person.ID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!)
        try await FirebaseFunctionCaller.shared.verbose.call(personEditFunction)
    }
    
    func testPersonGetCurrent() async throws {
        let user = await FirebaseAuthenticator.shared.user
        XCTAssertNotNil(user)
        let hashedUserId = Crypter.sha512(user!.uid)
        let personId = Person.ID()
        let crypter = Crypter(keys: PrivateKeys.current.cryptionKeys)
        try await Database.database(url: PrivateKeys.current.databaseUrl).reference(withPath: "users/\(hashedUserId)").setValue(crypter.encodeEncrypt(["clubId": self.clubId.uuidString, "personId": personId.uuidString]))
        let signInDate = Date()
        try await Database.database(url: PrivateKeys.current.databaseUrl).reference(withPath: "clubs/\(self.clubId.uuidString)/persons/\(personId.uuidString)").setValue(crypter.encodeEncrypt(Person(id: personId, name: PersonName(first: "lkj", last: "asef"), fineIds: [], signInData: SignInData(hashedUserId: hashedUserId, signInDate: signInDate, authentication: [.clubMember]), isInvited: false)))
        let personGetCurrentFunction = PersonGetCurrentFunction()
        let person = try await FirebaseFunctionCaller.shared.verbose.call(personGetCurrentFunction)
        XCTAssertEqual(person, PersonGetCurrentFunction.ReturnType(id: personId, name: PersonName(first: "lkj", last: "asef"), fineIds: [], signInData: SignInData(hashedUserId: hashedUserId, signInDate: signInDate, authentication: [.clubMember]), club: ClubProperties(id: self.clubId, name: "Neuer Verein")))
    }
    
    func testPersonGet() async throws {
        let personGetFunction = PersonGetFunction(clubId: self.clubId)
        let personList = try await FirebaseFunctionCaller.shared.verbose.call(personGetFunction)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        XCTAssertEqual(personList, IdentifiableList(values: [
            Person(id: Person.ID(uuidString: "76025DDE-6893-46D2-BC34-9864BB5B8DAD")!, name: PersonName(first: "John"), fineIds: [Fine.ID(uuidString: "02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, Fine.ID(uuidString: "0B5F958E-9D7D-46E1-8AEE-F52F4370A95A")!], signInData: SignInData(hashedUserId: "sha_abc", signInDate: dateFormatter.date(from: "2022-01-24T17:23:45.678Z")!, authentication: [.clubMember, .clubManager]), isInvited: false),
            Person(id: Person.ID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!, name: PersonName(first: "Jane", last: "Doe"), fineIds: [], signInData: nil, isInvited: true),
            Person(id: Person.ID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!, name: PersonName(first: "Max", last: "Mustermann"), fineIds: [Fine.ID(uuidString: "1B5F958E-9D7D-46E1-8AEE-F52F4370A95A")!], signInData: SignInData(hashedUserId: "sha_xyz", signInDate: dateFormatter.date(from: "2022-01-26T17:23:45.678Z")!, authentication: [.clubMember]), isInvited: false)
        ]))
    }
    
    func testPersonRegister() async throws {
        let user = await FirebaseAuthenticator.shared.user
        XCTAssertNotNil(user)
        let hashedUserId = Crypter.sha512(user!.uid)
        try await Database.database(url: PrivateKeys.current.databaseUrl).reference(withPath: "clubs/\(self.clubId.uuidString)/authentication/clubMember/\(hashedUserId)").removeValue()
        try await Database.database(url: PrivateKeys.current.databaseUrl).reference(withPath: "clubs/\(self.clubId.uuidString)/authentication/clubManager/\(hashedUserId)").removeValue()
        let personRegisterPerson = PersonRegisterFunction(clubId: self.clubId, personId: Person.ID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!)
        let club = try await FirebaseFunctionCaller.shared.verbose.call(personRegisterPerson)
        XCTAssertEqual(club, ClubProperties(id: self.clubId, name: "Neuer Verein"))
    }
    
    func testPersonMakeManager() async throws {
        let personId = Person.ID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!
        let personMakeManagerFunction = PersonMakeManagerFunction(clubId: self.clubId, personId: personId)
        try await FirebaseFunctionCaller.shared.verbose.call(personMakeManagerFunction)
    }
    
    func testReasonTemplateEditAdd() async throws {
        let reasonTemplateEditFunction = ReasonTemplateEditFunction.add(clubId: self.clubId, reasonTemplate: ReasonTemplate(id: ReasonTemplate.ID(), reasonMessage: "asdf", amount: Amount(value: 10, subUnitValue: 50)))
        try await FirebaseFunctionCaller.shared.verbose.call(reasonTemplateEditFunction)
    }
    
    func testReasonTemplateEditUpdate() async throws {
        let reasonTemplateEditFunction = ReasonTemplateEditFunction.update(clubId: self.clubId, reasonTemplate: ReasonTemplate(id: ReasonTemplate.ID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!, reasonMessage: "asdf", amount: Amount(value: 10, subUnitValue: 50)))
        try await FirebaseFunctionCaller.shared.verbose.call(reasonTemplateEditFunction)
    }
    
    func testReasonTemplateEditDelete() async throws {
        let reasonTemplateEditFunction = ReasonTemplateEditFunction.delete(clubId: self.clubId, reasonTemplateId: ReasonTemplate.ID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!)
        try await FirebaseFunctionCaller.shared.verbose.call(reasonTemplateEditFunction)
    }
    
    func testReasonTemplateGet() async throws {
        let personGetFunction = ReasonTemplateGetFunction(clubId: self.clubId)
        let reasonTemplateList = try await FirebaseFunctionCaller.shared.verbose.call(personGetFunction)
        XCTAssertEqual(reasonTemplateList, IdentifiableList(values: [
            ReasonTemplate(id: ReasonTemplate.ID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!, reasonMessage: "test_reason_1", amount: Amount(value: 1, subUnitValue: 0)),
            ReasonTemplate(id: ReasonTemplate.ID(uuidString: "16805D21-5E8D-43E9-BB5C-7B4A790F0CE7")!, reasonMessage: "test_reason_2", amount: Amount(value: 2, subUnitValue: 50)),
            ReasonTemplate(id: ReasonTemplate.ID(uuidString: "23A3412E-87DE-4A23-A08F-67214B8A8541")!, reasonMessage: "test_reason_3", amount: Amount(value: 2, subUnitValue: 0))
        ]))
    }
    
    func testInvitationLinkCreateId() async throws {
        let invitationLinkCreateIdFunction = InvitationLinkCreateIdFunction(clubId: self.clubId, personId: Person.ID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!)
        _ = try await FirebaseFunctionCaller.shared.verbose.call(invitationLinkCreateIdFunction)
    }
    
    func testInvitationLinkWithdraw() async throws {
        let invitationLinkWithdrawFunction = InvitationLinkWithdrawFunction(clubId: self.clubId, personId: Person.ID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!)
        try await FirebaseFunctionCaller.shared.verbose.call(invitationLinkWithdrawFunction)
    }
    
    func testInvitationLinkGetPerson() async throws {
        let personId = Person.ID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!
        let invitationLinkCreateIdFunction = InvitationLinkCreateIdFunction(clubId: self.clubId, personId: personId)
        let invitationLinkId = try await FirebaseFunctionCaller.shared.verbose.call(invitationLinkCreateIdFunction)
        let invitationLinkGetPersonFunction = InvitationLinkGetPersonFunction(invitationLinkId: invitationLinkId)
        let person = try await FirebaseFunctionCaller.shared.verbose.call(invitationLinkGetPersonFunction)
        XCTAssertEqual(person, InvitationLinkGetPersonFunction.ReturnType(id: personId, name: PersonName(first: "Jane", last: "Doe"), fineIds: [], club: ClubProperties(id: self.clubId, name: "Neuer Verein")))
    }
}
