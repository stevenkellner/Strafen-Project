//
//  Data+base64UrlEscaped.swift
//  StrafenProject
//
//  Created by Steven on 29.06.23.
//

import Foundation

extension Data {
    func base64UrlEscaped(options: Data.Base64EncodingOptions) -> String {
        return self.base64EncodedString(options: options)
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    var base64UrlEscaped: String {
        return self.base64UrlEscaped(options: [])
    }
}

extension String {
    func base64UrlUnescaped(options: Data.Base64DecodingOptions) -> Data? {
        var value = self.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = value.count % 4
        if padding > 0 {
            value += String(repeating: "=", count: 4 - padding)
        }
        return Data(base64Encoded: value, options: options)
    }
    
    var base64UrlUnescaped: Data? {
        return self.base64UrlUnescaped(options: [])
    }
}
