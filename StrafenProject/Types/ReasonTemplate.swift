//
//  ReasonTemplate.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct ReasonTemplate {
    typealias ID = Tagged<(ReasonTemplate, id: ()), UUID>
    
    public private(set) var id: ID
    public private(set) var reasonMessage: String
    public private(set) var amount: Amount
    public private(set) var importance: Importance
}

extension ReasonTemplate: Equatable {}

extension ReasonTemplate: Codable {}

extension ReasonTemplate: Sendable {}

extension ReasonTemplate: Hashable {}

extension ReasonTemplate: RandomPlaceholder {
    static let randomPlaceholderReasonMessages = [
        "Lorem ipsum dolor",
        "sit amet",
        "consetetur sadipscing elitr",
        "sed diam nonumy",
        "eirmod tempor",
        "invidunt ut labore et dolore magna",
        "aliquyam erat, sed diam voluptua",
        "At vero eos et accusam",
        "et justo duo dolores",
        "et ea rebum",
        "Stet clita kasd gubergren",
        "no sea takimata sanctus est"
    ]
    
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> ReasonTemplate {
        return ReasonTemplate(
            id: ID(),
            reasonMessage: ReasonTemplate.randomPlaceholderReasonMessages.randomElement(using: &generator)!,
            amount: Amount.randomPlaceholder(using: &generator),
            importance: Importance.randomPlaceholder(using: &generator)
        )
    }
}
