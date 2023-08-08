//
//  CallSecret.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct CallSecret {
    let expiresAt: UtcDate
    let callSecretKey: String
    
    init(key callSecretKey: String) {
        self.expiresAt = UtcDate().advanced(minute: 1)
        self.callSecretKey = callSecretKey
    }
}

extension CallSecret: Codable {}

extension CallSecret: Sendable {}

extension CallSecret: FirebaseFunctionParameterType {
    @FirebaseFunctionParametersBuilder var parameter: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.expiresAt, for: "expiresAt")
        let hashedData = Crypter.sha512(self.expiresAt.encoded, key: self.callSecretKey)
        FirebaseFunctionParameter(hashedData, for: "hashedData")
    }
}
