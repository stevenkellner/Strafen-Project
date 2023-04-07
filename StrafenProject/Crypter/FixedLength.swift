//
//  FixedLength.swift
//  StrafenProject
//
//  Created by Steven on 06.04.23.
//

import Foundation

protocol Length {
    static var length: Int { get }
}

struct Length16: Length {
    static let length = 16
}

struct Length32: Length {
    static let length = 32
}

struct Length64: Length {
    static let length = 64
}

struct FixedLength<T, L> where T: Collection, L: Length {
    enum Error: Swift.Error {
        case notExpectedLength
    }
    
    let value: T
    
    init(value: T) throws {
        guard (value.count == L.length) else {
            throw Error.notExpectedLength
        }
        self.value = value
    }
}
