//
//  String+randomNonce.swift
//  StrafenProject
//
//  Created by Steven on 15.04.23.
//

import Foundation
import CryptoKit

extension String {
    static func randomNonce(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = Array<UInt8>(repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charSet = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charSet[Int(byte) % charSet.count]
        }
        return String(nonce)
    }
    
    var sha256: String {
        let data = Data(self.utf8)
        let hashedData = SHA256.hash(data: data)
        return hashedData.compactMap { byte in
            return String(format: "%02x", byte)
        }.joined()
    }
}
