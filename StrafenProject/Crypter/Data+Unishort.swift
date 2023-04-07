//
//  Data+Unishort.swift
//  StrafenProject
//
//  Created by Steven on 06.04.23.
//

import Foundation

extension Data {
    enum UnishortEncodingError: Error {
        case invalidUnicodeScalarData
    }
    
    init(unishortString: String) throws {
        self.init()
        for char in unishortString {
            guard let byte = char.unicodeScalars.first?.value,
                  byte <= UInt8.max else {
                throw UnishortEncodingError.invalidUnicodeScalarData
            }
            self.append(UInt8(byte))
        }
    }
    
    var unishortString: String {
        var value = ""
        for byte in self {
            value.append(Character(UnicodeScalar(byte)))
        }
        return value
    }
}
