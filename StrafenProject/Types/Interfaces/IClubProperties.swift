//
//  IClubProperties.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

public protocol IClubProperties {
    associatedtype ID: RawRepresentable where ID.RawValue == UUID
    
    var id: ID { get }
    var identifier: String { get }
    var name: String { get }
    var regionCode: String { get }
    var inAppPaymentActive: Bool { get }
}

extension IClubProperties {
    var concrete: ClubProperties {
        return ClubProperties(self)
    }
}
