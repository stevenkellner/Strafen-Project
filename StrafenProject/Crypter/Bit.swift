//
//  Bit.swift
//  StrafenProject
//
//  Created by Steven on 06.04.23.
//

import Foundation

enum Bit {
    case zero
    case one
    
    var value: Int {
        switch self {
        case .zero:
            return 0
        case .one:
            return 1
        }
    }
}

extension Bit {
    static prefix func ~(rhs: Bit) -> Bit {
        switch rhs {
        case .zero:
            return .one
        case .one:
            return .zero
        }
    }
    
    static func &(lhs: Bit, rhs: Bit) -> Bit {
        switch (lhs, rhs) {
        case (.zero, .zero), (.zero, .one), (.one, .zero):
            return .zero
        case (.one, .one):
            return .one
        }
    }
    
    static func |(lhs: Bit, rhs: Bit) -> Bit {
        switch (lhs, rhs) {
        case (.zero, .zero):
            return .zero
        case (.zero, .one), (.one, .zero), (.one, .one):
            return .one
        }
    }
    
    static func ^(lhs: Bit, rhs: Bit) -> Bit {
        switch (lhs, rhs) {
        case (.zero, .zero), (.one, .one):
            return .zero
        case (.zero, .one), (.one, .zero):
            return .one
        }
    }
}

extension FixedWidthInteger where Self: UnsignedInteger {
    var bits: [Bit] {
        let totalBitsCount = MemoryLayout<Self>.size * 8
        var byte = self
        var bitsArray = Array<Bit>(repeating: .zero, count: totalBitsCount)
        for index in 0..<totalBitsCount {
            bitsArray[totalBitsCount - index - 1] = byte & 0b1 == 0b1 ? .one : .zero
            byte >>= 1
        }
        return bitsArray
    }
}
