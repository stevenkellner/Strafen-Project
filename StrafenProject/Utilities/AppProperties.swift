//
//  AppProperties.swift
//  StrafenProject
//
//  Created by Steven on 20.04.23.
//

import SwiftUI

class AppProperties: ObservableObject {
    let signedInPerson: Settings.SignedInPerson
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
    
    func fines(of person: Person) -> IdentifiableList<Fine> {
        return self.fines.filter { fine in
            return person.fineIds.contains(fine.id)
        }
    }
}

extension AppProperties {
    struct SortedPersons {
        var personsWithUnpayedFines: [Person]
        var personsWithAllPayedFines: [Person]
        
        mutating func sort() {
            self.personsWithUnpayedFines.sort { lhsPerson, rhsPerson in
                return lhsPerson.name.formatted() < rhsPerson.name.formatted()
            }
            self.personsWithAllPayedFines.sort { lhsPerson, rhsPerson in
                return lhsPerson.name.formatted() < rhsPerson.name.formatted()
            }
        }
        
        func personsWithUnpayedFines(searchText: String) -> [Person] {
            return self.personsWithUnpayedFines.filter { person in
                guard !searchText.isEmpty else {
                    return true
                }
                return person.name.formatted().contains(searchText)
            }
        }
        
        func personsWithAllPayedFines(searchText: String) -> [Person] {
            return self.personsWithAllPayedFines.filter { person in
                guard !searchText.isEmpty else {
                    return true
                }
                return person.name.formatted().contains(searchText)
            }
        }
    }
    
    var sortedPersons: SortedPersons {
        var sortedPersons = self.persons.reduce(into: SortedPersons(personsWithUnpayedFines: [], personsWithAllPayedFines: [])) { sortedPersons, person in
            let fines = self.fines(of: person)
            if fines.unpayedAmount == .zero {
                sortedPersons.personsWithAllPayedFines.append(person)
            } else {
                sortedPersons.personsWithUnpayedFines.append(person)
            }
        }
        sortedPersons.sort()
        return sortedPersons
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
