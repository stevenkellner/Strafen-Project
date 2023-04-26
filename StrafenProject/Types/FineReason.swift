//
//  FineReason.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct FineReason {
    public private(set) var reasonMessage: String
    public private(set) var amount: Amount
}

extension FineReason: Equatable {}

extension FineReason: Codable {}

extension FineReason: Sendable {}

extension FineReason: Hashable {}

extension FineReason: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.reasonMessage, for: "reasonMessage")
        FirebaseFunctionParameter(self.amount, for: "amount")
    }
}

extension FineReason: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> FineReason {
        return FineReason(
            reasonMessage: ReasonTemplate.randomPlaceholderReasonMessages.randomElement(using: &generator)!,
            amount: Amount.randomPlaceholder(using: &generator)
        )
    }
}
