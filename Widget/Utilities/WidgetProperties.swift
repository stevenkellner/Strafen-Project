//
//  WidgetProperties.swift
//  StrafenProject
//
//  Created by Steven on 02.05.23.
//

import Foundation
import UIKit.UIImage

struct WidgetProperties {
    let signedInPerson: Settings.SignedInPerson
    let personImage: UIImage?
    private let allFines: IdentifiableList<Fine>
    
    private init(
        signedInPerson: Settings.SignedInPerson,
        personImage: UIImage?,
        allFines: IdentifiableList<Fine>
    ) {
        self.signedInPerson = signedInPerson
        self.personImage = personImage
        self.allFines = allFines
    }
    
    static func fetch(with signedInPerson: Settings.SignedInPerson) async throws -> WidgetProperties {
        let clubId = signedInPerson.club.id
        let fineGetFunction = FineGetFunction(clubId: clubId)
        async let image = ImageFetcher.shared.fetch(clubId: clubId, personId: signedInPerson.id)
        async let allFines = FirebaseFunctionCaller.shared.call(fineGetFunction)
        return try await WidgetProperties(
            signedInPerson: signedInPerson,
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
    var sortedFinesGroups: SortedSearchableListGroups<PayedState, Fine> {
        return SortedSearchableListGroups(self.fines) { fine in
            return fine.payedState
        } sortBy: { fine in
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
