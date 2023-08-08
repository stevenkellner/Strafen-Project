//
//  WidgetProperties.swift
//  StrafenProject
//
//  Created by Steven on 02.05.23.
//

import Foundation
import UIKit.UIImage

protocol FirebaseGetFunction: FirebaseFunction {
    
    associatedtype Element: Identifiable where Element: Identifiable, Element.ID: Hashable
    
    associatedtype ReturnType = IdentifiableList<Element>
    
    init(clubId: ClubProperties.ID)
}

struct WidgetProperties {
    let signedInPerson: Settings.SignedInPerson
    let sorting: Settings.Sorting
    let personImage: UIImage?
    private let allFines: IdentifiableList<Fine>
    
    private init(
        signedInPerson: Settings.SignedInPerson,
        sorting: Settings.Sorting,
        personImage: UIImage?,
        allFines: IdentifiableList<Fine>
    ) {
        self.signedInPerson = signedInPerson
        self.sorting = sorting
        self.personImage = personImage
        self.allFines = allFines
    }
    
    static func fetch(with signedInPerson: Settings.SignedInPerson, sorting: Settings.Sorting) async throws -> WidgetProperties {
        let clubId = signedInPerson.club.id
        let fineGetFunction = FineGetFunction(clubId: clubId)
        async let image = ImageFetcher.shared.fetch(clubId: clubId, personId: signedInPerson.id)
        async let allFines = FirebaseFunctionCaller.shared.call(fineGetFunction)
        return try await WidgetProperties(
            signedInPerson: signedInPerson,
            sorting: sorting,
            personImage: image,
            allFines: allFines
        )
    }
    
    var club: ClubProperties {
        return self.signedInPerson.club
    }
    
    var fines: IdentifiableList<Fine> {
        return self.signedInPerson.fineIds.reduce(into: IdentifiableList<Fine>()) { fines, fineId in
            guard let fine = self.allFines[fineId] else {
                return
            }
            fines[fineId] = fine
        }
    }
}

extension WidgetProperties {
    
    @MainActor
    var sortedFinesGroups: SortedSearchableListGroups<PayedState, Fine> {
        return SortedSearchableListGroups(self.fines, groupBy: { fine in
            return fine.payedState
        }, sortBy: self.sorting.fineSorting.areInAscendingOrder(lhs:rhs:)) { fine in
            return fine.reasonMessage
        }
    }
}

extension WidgetProperties {
    static func randomPlaceholder(signedInPerson: inout Settings.SignedInPerson, using generator: inout some RandomNumberGenerator) -> WidgetProperties {
        Fine.randomPlaceholderPersonIds = [signedInPerson.id]
        let allFines = IdentifiableList<Fine>.randomPlaceholder(using: &generator)
        signedInPerson.fineIds = allFines.map(\.id)
        return WidgetProperties(
            signedInPerson: signedInPerson,
            sorting: Settings.Sorting.default,
            personImage: UIImage(named: "profile_placeholder"),
            allFines: allFines
        )
    }
    
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> WidgetProperties {
        let clubProperties = ClubProperties(id: ClubProperties.ID(), name: "")
        var signedInPerson = Settings.SignedInPerson(id: Person.ID(), name: PersonName.randomPlaceholder, fineIds: [], isAdmin: false, hashedUserId: "", club: clubProperties)
        return WidgetProperties.randomPlaceholder(signedInPerson: &signedInPerson, using: &generator)
    }
    
    static func randomPlaceholder(signedInPerson: inout Settings.SignedInPerson) -> WidgetProperties {
        var generator = SystemRandomNumberGenerator()
        return WidgetProperties.randomPlaceholder(signedInPerson: &signedInPerson, using: &generator)
    }
    
    static var randomPlaceholder: WidgetProperties {
        var generator = SystemRandomNumberGenerator()
        return WidgetProperties.randomPlaceholder(using: &generator)
    }
}
