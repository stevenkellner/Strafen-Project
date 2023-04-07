//
//  Array+randomBytes.swift
//  StrafenProject
//
//  Created by Steven on 06.04.23.
//

import Foundation

extension Array where Element == UInt8 {
    enum RandomBytesError: Error {
        case noRandomBytes
    }
    
    static func random(length: Int) throws -> [UInt8] {
        var bytes = Array<UInt8>(repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        guard status == errSecSuccess else {
            throw RandomBytesError.noRandomBytes
        }
        return bytes
    }
    
    func addPadding() -> [UInt8] {
        let missingLength = 16 - UInt8(self.count % 16)
        var padding = Array<UInt8>(repeating: 0, count: Int(missingLength))
        padding[0] = missingLength
        return padding + self
    }
    
    func removePadding() -> [UInt8] {
        let missingLength = self[0]
        return Array<UInt8>(self.dropFirst(Int(missingLength)))
    }
}
