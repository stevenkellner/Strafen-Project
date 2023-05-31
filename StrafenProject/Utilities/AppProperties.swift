//
//  AppProperties.swift
//  StrafenProject
//
//  Created by Steven on 20.04.23.
//

import SwiftUI

class AppProperties: ObservableObject {
    var signedInPerson: Settings.SignedInPerson
    @Published var persons: IdentifiableList<Person>
    @Published var reasonTemplates: IdentifiableList<ReasonTemplate>
    @Published var fines: IdentifiableList<Fine>
    
    private init(
        signedInPerson: Settings.SignedInPerson,
        persons: IdentifiableList<Person>,
        reasonTemplates: IdentifiableList<ReasonTemplate>,
        fines: IdentifiableList<Fine>
    ) {
        self.signedInPerson = signedInPerson
        self.persons = persons
        self.reasonTemplates = reasonTemplates
        self.fines = fines
    }
    
    static func fetch(with signedInPerson: Settings.SignedInPerson) async throws -> AppProperties {
        let clubId = signedInPerson.club.id
        let personGetFunction = PersonGetFunction(clubId: clubId)
        let reasonTemplateGetFunction = ReasonTemplateGetFunction(clubId: clubId)
        let fineGetFunction = FineGetFunction(clubId: clubId)
        async let persons = FirebaseFunctionCaller.shared.call(personGetFunction)
        async let reasonTemplates = FirebaseFunctionCaller.shared.call(reasonTemplateGetFunction)
        async let fines = FirebaseFunctionCaller.shared.call(fineGetFunction)
        return try await AppProperties(
            signedInPerson: signedInPerson,
            persons: persons,
            reasonTemplates: reasonTemplates,
            fines: fines
        )
    }
    
    func refresh() async {
        do {
            let personGetCurrentFunction = PersonGetCurrentFunction()
            let currentPerson = try await FirebaseFunctionCaller.shared.call(personGetCurrentFunction)
            self.signedInPerson = currentPerson.settingsPerson
            let settingsManager = SettingsManager()
            try settingsManager.save(self.signedInPerson, at: \.signedInPerson)
            let appProperties = try await AppProperties.fetch(with: self.signedInPerson)
            await MainActor.run {
                self.persons = appProperties.persons
                self.reasonTemplates = appProperties.reasonTemplates
                self.fines = appProperties.fines
            }
        } catch {}
    }
    
    var club: ClubProperties {
        return self.signedInPerson.club
    }
    
    func fines(of person: Person) -> IdentifiableList<Fine> {
        return person.fineIds.reduce(into: IdentifiableList<Fine>()) { fines, fineId in
            guard let fine = self.fines[fineId] else {
                return
            }
            fines[fineId] = fine
        }
    }
    
    func fines(of person: Settings.SignedInPerson) -> IdentifiableList<Fine> {
        if let person = self.persons[person.id] {
            return self.fines(of: person)
        }
        return person.fineIds.reduce(into: IdentifiableList<Fine>()) { fines, fineId in
            guard let fine = self.fines[fineId] else {
                return
            }
            fines[fineId] = fine
        }
    }
}

extension AppProperties {
    enum PersonGroupsKey {
        case withUnpayedFines
        case withPayedFines
    }
    
    var sortedPersons: SortedSearchableListGroups<SingleGroupKey, Person> {
        return SortedSearchableListGroups(self.persons) { lhsPerson, rhsPerson in
            return lhsPerson.name.formatted().lowercased() < rhsPerson.name.formatted().lowercased()
        } searchIn: { person in
            return person.name.formatted()
        }
    }
    
    var sortedPersonsGroups: SortedSearchableListGroups<PersonGroupsKey, Person> {
        return SortedSearchableListGroups(self.persons) { person in
            let unpayedAmount = self.fines(of: person).unpayedAmount
            return unpayedAmount == .zero ?.withPayedFines : .withUnpayedFines
        } sortBy: { lhsPerson, rhsPerson in
            return lhsPerson.name.formatted().lowercased() < rhsPerson.name.formatted().lowercased()
        } searchIn: { person in
            return person.name.formatted()
        }
    }
}

extension AppProperties {
    var sortedReasonTemplates: SortedSearchableListGroups<SingleGroupKey, ReasonTemplate> {
        return SortedSearchableListGroups(self.reasonTemplates) { lhsReasonTemplate, rhsReasonTemplate in
            return lhsReasonTemplate.formatted.lowercased() < rhsReasonTemplate.formatted.lowercased()
        } searchIn: { reasonTemplate in
            return reasonTemplate.formatted
        }
    }
}

extension AppProperties {
    func sortedFinesGroups(of person: Person) -> SortedSearchableListGroups<PayedState, Fine> {
        return SortedSearchableListGroups(self.fines(of: person)) { fine in
            return fine.payedState
        } sortBy: { lhsFine, rhsFine in
            return lhsFine.date > rhsFine.date
        } searchIn: { fine in
            return fine.reasonMessage
        }
    }
    
    func sortedFinesGroups(of person: Settings.SignedInPerson) -> SortedSearchableListGroups<PayedState, Fine> {
        return SortedSearchableListGroups(self.fines(of: person)) { fine in
            return fine.payedState
        } sortBy: { lhsFine, rhsFine in
            return lhsFine.date > rhsFine.date
        } searchIn: { fine in
            return fine.reasonMessage
        }
    }
}

extension AppProperties {
    var shareText: String {
        let titleText = String(localized: "app-properties|share-text-title", comment: "Title of the share text where sharing persons.")
        let sortedPersonsWithUnpayedFines = self.sortedPersonsGroups.sortedList(of: .withUnpayedFines)
        let personsText = sortedPersonsWithUnpayedFines.map { person in
            let fines = self.fines(of: person)
            let nameText = "\(person.name.formatted()): \(fines.unpayedAmount.formatted(.short))"
            let finesText = fines.compactMap { fine in
                guard fine.payedState == .unpayed else {
                    return nil
                }
                return "\t- \(fine.reasonMessage), \(fine.date.formatted(date: .abbreviated, time: .omitted)): \(fine.amount.formatted(.short))"
            }.joined(separator: "\n")
            return "\(nameText)\n\(finesText)"
        }.joined(separator: "\n\n")
        return "\(titleText)\n\n\(personsText)"
    }
}

extension AppProperties {
    static func randomPlaceholder(signedInPerson: Settings.SignedInPerson, using generator: inout some RandomNumberGenerator) -> AppProperties {
        let persons = IdentifiableList<Person>.randomPlaceholder(using: &generator)
        let reasonTemplates = IdentifiableList<ReasonTemplate>.randomPlaceholder(using: &generator)
        let fines = IdentifiableList<Fine>.randomPlaceholder(using: &generator)
        return AppProperties(
            signedInPerson: signedInPerson,
            persons: persons,
            reasonTemplates: reasonTemplates,
            fines: fines
        )
    }
    
    static func randomPlaceholder(signedInPerson: Settings.SignedInPerson) -> AppProperties {
        var generator = SystemRandomNumberGenerator()
        return AppProperties.randomPlaceholder(signedInPerson: signedInPerson, using: &generator)
    }
}
