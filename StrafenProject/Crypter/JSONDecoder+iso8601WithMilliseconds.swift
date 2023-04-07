//
//  JSONDecoder+iso8601WithMilliseconds.swift
//  StrafenProject
//
//  Created by Steven on 06.04.23.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static var iso8601WithMilliseconds: JSONDecoder.DateDecodingStrategy {
        return JSONDecoder.DateDecodingStrategy.custom { decoder in
            let container = try decoder.singleValueContainer()
            let isoString = try container.decode(String.self)
            let isoDateFormatter = ISO8601DateFormatter()
            if let date = isoDateFormatter.date(from: isoString) {
                return date
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = dateFormatter.date(from: isoString) {
                return date
            }
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Couldn't decode iso8601 formatted date."))
        }
    }
}
