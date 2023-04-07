//
//  FineReason.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct FineReason: IFineReason {
    public private(set) var reasonMessage: String
    public private(set) var amount: Amount
    public private(set) var importance: Importance
}

extension FineReason {
    init(_ fineReason: some IFineReason) {
        self.reasonMessage = fineReason.reasonMessage
        self.amount = Amount(fineReason.amount)
        self.importance = Importance(fineReason.importance)
    }
}

extension FineReason: Equatable {}

extension FineReason: Codable {}

extension FineReason: Sendable {}

extension FineReason: Hashable {}

extension FineReason: RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> FineReason {
        return FineReason(
            reasonMessage: ReasonTemplate.randomPlaceholderReasonMessages.randomElement(using: &generator)!,
            amount: Amount.randomPlaceholder(using: &generator),
            importance: Importance.randomPlaceholder(using: &generator)
        )
    }
}
