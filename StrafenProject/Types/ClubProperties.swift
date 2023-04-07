//
//  ClubProperties.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct ClubProperties: IClubProperties {
    typealias ID = Tagged<(ClubProperties, id: ()), UUID>
    
    public private(set) var id: ClubProperties.ID
    public private(set) var identifier: String
    public private(set) var name: String
    public private(set) var regionCode: String
    public private(set) var inAppPaymentActive: Bool
}

extension ClubProperties {
    public init(_ clubProperties: some IClubProperties) {
        self.id = ID(clubProperties.id.rawValue)
        self.identifier = clubProperties.identifier
        self.name = clubProperties.name
        self.regionCode = clubProperties.regionCode
        self.inAppPaymentActive = clubProperties.inAppPaymentActive
    }
}

extension ClubProperties: Equatable {}

extension ClubProperties: Codable {}

extension ClubProperties: Sendable {}

extension ClubProperties: Hashable {}
