//
//  CallSecret.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct CallSecret {
    let expiresAt: Date
    let callSecretKey: String
    
    init(key callSecretKey: String) {
        self.expiresAt = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
        self.callSecretKey = callSecretKey
    }
}

extension CallSecret: Codable {}

extension CallSecret: Sendable {}

extension CallSecret: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        let expiresAtIsoDate = self.expiresAt.ISO8601Format(.iso8601)
        FirebaseFunctionParameter(expiresAtIsoDate, for: "expiresAt")
        let hashedData = Crypter.sha512(expiresAtIsoDate, key: self.callSecretKey)
        FirebaseFunctionParameter(hashedData, for: "hashedData")
    }
}
