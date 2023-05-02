//
//  PersonName.swift
//  StrafenProject
//
//  Created by Steven on 29.04.23.
//

import Foundation

struct PersonName {
    public private(set) var first: String
    public private(set) var last: String?
}

extension PersonName: Equatable {}

extension PersonName: Codable {}

extension PersonName: Sendable {}

extension PersonName: Hashable {}

extension PersonName {
    func formatted(_ style: PersonNameComponents.FormatStyle.Style = .medium) -> String {
        let personNameComponents = PersonNameComponents(givenName: self.first, familyName: self.last)
        return personNameComponents.formatted(.name(style: style))
    }
}

#if !NOTIFICATION_SERVICE_EXTENSION
extension PersonName: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.first, for: "first")
        FirebaseFunctionParameter(self.last, for: "last")
    }
}

extension PersonName: RandomPlaceholder {
    private static let randomPlaceholderNames = [
        PersonName(first: "Longin", last: "D'Agostino"),
        PersonName(first: "Suresh", last: "Thorburn"),
        PersonName(first: "Meltem", last: "Ferrara"),
        PersonName(first: "Muthoni", last: "Kovačevič"),
        PersonName(first: "Pier", last: "Sharma"),
        PersonName(first: "Deimne", last: "Alfero"),
        PersonName(first: "Yeong-Gi", last: "Vargas"),
        PersonName(first: "Dejan", last: "Alfero"),
        PersonName(first: "Rian", last: "Keane"),
        PersonName(first: "Jahel", last: "Spiros"),
        PersonName(first: "Bronisław", last: "MacLeòid"),
        PersonName(first: "Elon", last: "Field"),
        PersonName(first: "Stipan", last: "Haig"),
        PersonName(first: "Aminah", last: "Henriksen"),
        PersonName(first: "Helve", last: "Lyne"),
        PersonName(first: "Hammurabi"),
        PersonName(first: "Veaceslav"),
        PersonName(first: "Dagný"),
        PersonName(first: "Gerlof"),
        PersonName(first: "Everett"),
        PersonName(first: "Dalimil"),
        PersonName(first: "Eadwald"),
        PersonName(first: "Artyom"),
        PersonName(first: "Cerys"),
        PersonName(first: "Maunu")
    ]
    
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> PersonName {
        return PersonName.randomPlaceholderNames.randomElement(using: &generator)!
    }
}
#endif
