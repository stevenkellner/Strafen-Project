//
//  AppProperties.swift
//  StrafenProject
//
//  Created by Steven on 20.04.23.
//

import SwiftUI
import OSLog

protocol FirebaseGetFunction: FirebaseFunction {
    
    associatedtype Element: Identifiable where Element: Identifiable, Element.ID: Hashable
    
    associatedtype ReturnType = IdentifiableList<Element>
    
    init(clubId: ClubProperties.ID)
}

protocol FirebaseGetChangesFunction: FirebaseFunction {
    
    associatedtype Element: Identifiable
    
    associatedtype ReturnType = [Deletable<Element>]
        
    init(clubId: ClubProperties.ID)
}

protocol AppPropertiesList: Identifiable, ListCachable {
    
    associatedtype GetFunction: FirebaseGetFunction where GetFunction.Element == Self
    
    associatedtype GetChangesFunction: FirebaseGetChangesFunction where GetChangesFunction.Element == Self
}

@MainActor
class AppProperties: ObservableObject {
    @Published var signedInPerson: Settings.SignedInPerson
    @Published var persons: IdentifiableList<Person>
    @Published var reasonTemplates: IdentifiableList<ReasonTemplate>
    @Published var fines: IdentifiableList<Fine>
    
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "StrafenProject", category: String(describing: AppProperties.self))
    
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
    
    static func fetchList<Element>(clubId: ClubProperties.ID, getCache: Bool) async throws -> IdentifiableList<Element> where Element: AppPropertiesList {
        let cachedList: IdentifiableList<Element>? = try? AppPropertiesCache.shared.getList()
        if var cachedList {
            if getCache {
                let getChangesFunction = Element.GetChangesFunction(clubId: clubId)
                let changes = try await FirebaseFunctionCaller.shared.call(getChangesFunction) as! [Deletable<Element>]
                cachedList.update(changes)
                try? AppPropertiesCache.shared.saveList(list: cachedList)
            }
            return cachedList
        } else {
            let getFunction = Element.GetFunction(clubId: clubId)
            let list = try await FirebaseFunctionCaller.shared.call(getFunction) as! IdentifiableList<Element>
            try? AppPropertiesCache.shared.saveList(list: list)
            return list
        }
    }

    static func fetch(with signedInPerson: Settings.SignedInPerson, getCache: Bool = false) async throws -> AppProperties {
        AppProperties.logger.log("Fetch app properties for \(signedInPerson.club.name, privacy: .public) (\(signedInPerson.club.id, privacy: .public)).")
        let clubId = signedInPerson.club.id
        async let persons: IdentifiableList<Person> = AppProperties.fetchList(clubId: clubId, getCache: getCache)
        async let reasonTemplates: IdentifiableList<ReasonTemplate> = AppProperties.fetchList(clubId: clubId, getCache: getCache)
        async let fines: IdentifiableList<Fine> = AppProperties.fetchList(clubId: clubId, getCache: getCache)
        do {
            let appProperties = try await AppProperties(signedInPerson: signedInPerson, persons: persons, reasonTemplates: reasonTemplates, fines: fines)
            AppProperties.logger.log("Fetch app properties succeeded.")
            return appProperties
        } catch {
            AppProperties.logger.log(level: .error, "Fetch app properties failed: \(error.localizedDescription, privacy: .public).")
            throw error
        }
    }
    
    func observe() {
        FirebaseObserver.shared.observeChanges(clubId: self.club.id, type: Person.self) { deletablePerson in
            Task {
                await MainActor.run {
                    self.persons.update(deletablePerson)
                    try? AppPropertiesCache.shared.saveList(list: self.persons)
                }
                await FirebaseImageStorage.shared.fetch(.person(clubId: self.club.id, personId: deletablePerson.id), useCachedImage: false)
            }
        }
        FirebaseObserver.shared.observeChanges(clubId: self.club.id, type: ReasonTemplate.self) { deletableReasonTemplate in
            Task {
                await MainActor.run {
                    self.reasonTemplates.update(deletableReasonTemplate)
                    try? AppPropertiesCache.shared.saveList(list: self.reasonTemplates)
                }
            }
        }
        FirebaseObserver.shared.observeChanges(clubId: self.club.id, type: Fine.self) { deletableFine in
            Task {
                await MainActor.run {
                    self.fines.update(deletableFine)
                    try? AppPropertiesCache.shared.saveList(list: self.fines)
                }
            }
        }
    }
    
    func refresh() async {
        AppProperties.logger.log("Refresh app properties for \(self.signedInPerson.club.name, privacy: .public) (\(self.signedInPerson.club.id, privacy: .public)).")
        do {
            let personGetCurrentFunction = PersonGetCurrentFunction()
            let currentPerson = try await FirebaseFunctionCaller.shared.call(personGetCurrentFunction)
            self.signedInPerson = currentPerson.settingsPerson
            let settingsManager = SettingsManager()
            try settingsManager.save(self.signedInPerson, at: \.signedInPerson)
            let appProperties = try await AppProperties.fetch(with: self.signedInPerson, getCache: true)
            self.persons = appProperties.persons
            self.reasonTemplates = appProperties.reasonTemplates
            self.fines = appProperties.fines
        } catch {
            AppProperties.logger.log(level: .error, "Refresh app properties failed: \(error.localizedDescription, privacy: .public).")
        }
    }
    
    var club: ClubProperties {
        return self.signedInPerson.club
    }
    
    func fines(of person: some PersonWithFines) -> IdentifiableList<Fine> {
        if let person = self.persons[person.id] {
            return self.fines(ofFinesList: person)
        }
        return self.fines(ofFinesList: person)
    }
    
    private func fines(ofFinesList person: some PersonWithFines) -> IdentifiableList<Fine> {
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
        return AppProperties(signedInPerson: signedInPerson, persons: persons, reasonTemplates: reasonTemplates, fines: fines)
    }
    
    static func randomPlaceholder(signedInPerson: Settings.SignedInPerson) -> AppProperties {
        var generator = SystemRandomNumberGenerator()
        return AppProperties.randomPlaceholder(signedInPerson: signedInPerson, using: &generator)
    }
}
