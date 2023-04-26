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
    
    var club: ClubProperties {
        return self.signedInPerson.club
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
            guard !searchText.isEmpty else {
                return self.personsWithUnpayedFines
            }
            let searchText = searchText.lowercased()
            return self.personsWithUnpayedFines.filter { person in
                return person.name.formatted().lowercased().contains(searchText)
            }
        }
        
        func personsWithAllPayedFines(searchText: String) -> [Person] {
            guard !searchText.isEmpty else {
                return self.personsWithAllPayedFines
            }
            let searchText = searchText.lowercased()
            return self.personsWithAllPayedFines.filter { person in
                return person.name.formatted().lowercased().contains(searchText)
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
    struct SortedFines {
        var unpayedFines: [Fine]
        var payedFines: [Fine]
        
        mutating func sort() {
            self.unpayedFines.sort { lhsFine, rhsFine in
                return lhsFine.formatted < rhsFine.formatted
            }
            self.payedFines.sort { lhsFine, rhsFine in
                return lhsFine.formatted < rhsFine.formatted
            }
        }
        
        func unpayedFines(searchText: String) -> [Fine] {
            guard !searchText.isEmpty else {
                return self.unpayedFines
            }
            let searchText = searchText.lowercased()
            return self.unpayedFines.filter { fine in
                return fine.formatted.lowercased().contains(searchText)
            }
        }
        
        func payedFines(searchText: String) -> [Fine] {
            guard !searchText.isEmpty else {
                return self.payedFines
            }
            let searchText = searchText.lowercased()
            return self.payedFines.filter { fine in
                return fine.formatted.lowercased().contains(searchText)
            }
        }
    }
    
    func sortedFines(of person: Person) -> SortedFines {
        var sortedFines = self.fines(of: person).reduce(into: SortedFines(unpayedFines: [], payedFines: [])) { sortedFines, fine in
            switch fine.payedState {
            case .unpayed:
                sortedFines.unpayedFines.append(fine)
            case .payed(payDate: _):
                sortedFines.payedFines.append(fine)
            }
        }
        sortedFines.sort()
        return sortedFines
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
