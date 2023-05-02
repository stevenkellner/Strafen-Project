//
//  ClubProperties.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct ClubProperties {
    typealias ID = Tagged<(ClubProperties, id: ()), UUID>
    
    public private(set) var id: ClubProperties.ID
    public private(set) var name: String
}

extension ClubProperties: Equatable {}

extension ClubProperties: Codable {}

extension ClubProperties: Sendable {}

extension ClubProperties: Hashable {}

#if !NOTIFICATION_SERVICE_EXTENSION
extension ClubProperties: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.name, for: "name")
    }
}
#endif
