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
    
    func fines(of person: some PersonWithFines) -> IdentifiableList<Fine> {
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
    
    func sortedPersons(by sorting: Settings.Sorting.SortingKeyAndOrder<Person>) -> SortedSearchableListGroups<SingleGroupKey, Person> {
        return SortedSearchableListGroups(self.persons) { lhsPerson, rhsPerson in
            return sorting.areInAscendingOrder(lhs: lhsPerson, rhs: rhsPerson, context: self)
        } searchIn: { person in
            return person.name.formatted()
        }
    }
    
    func sortedPersonsGroups(by sorting: Settings.Sorting.SortingKeyAndOrder<Person>) -> SortedSearchableListGroups<PersonGroupsKey, Person> {
        return SortedSearchableListGroups(self.persons) { person in
            let unpayedAmount = self.fines(of: person).unpayedAmount
            return unpayedAmount == .zero ?.withPayedFines : .withUnpayedFines
        } sortBy: { lhsPerson, rhsPerson in
            return sorting.areInAscendingOrder(lhs: lhsPerson, rhs: rhsPerson, context: self)
        } searchIn: { person in
            return person.name.formatted()
        }
    }
}

extension AppProperties {
    func sortedReasonTemplates(by sorting: Settings.Sorting.SortingKeyAndOrder<ReasonTemplate>) -> SortedSearchableListGroups<SingleGroupKey, ReasonTemplate> {
        return SortedSearchableListGroups(self.reasonTemplates, sortBy: sorting.areInAscendingOrder(lhs:rhs:)) { reasonTemplate in
            return reasonTemplate.formatted
        }
    }
}

extension AppProperties {
    func sortedFinesGroups(of person: some PersonWithFines, by sorting: Settings.Sorting.SortingKeyAndOrder<Fine>) -> SortedSearchableListGroups<PayedState, Fine> {
        return SortedSearchableListGroups(self.fines(of: person), groupBy: { fine in
            return fine.payedState
        }, sortBy: sorting.areInAscendingOrder(lhs:rhs:)) { fine in
            return fine.reasonMessage
        }
    }
}

extension AppProperties {
    func shareText(sorting: Settings.Sorting) -> String {
        let sortedPersons = self.sortedPersonsGroups(by: sorting.personSorting).group(of: .withUnpayedFines)
        return sortedPersons.map { person in
            let sortedFines = self.sortedFinesGroups(of: person, by: sorting.fineSorting)
            let nameText = "\(person.name.formatted()): \(sortedFines.group(of: .unpayed).totalAmount.formatted(.short))"
            let finesText = sortedFines.group(of: .unpayed).map { fine in
                return "\t- \(fine.reasonMessage), \(fine.date.formatted(date: .abbreviated, time: .omitted)): \(fine.amount.formatted(.short))"
            }.joined(separator: "\n")
            return "\(nameText)\n\(finesText)"
        }.joined(separator: "\n\n")
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
