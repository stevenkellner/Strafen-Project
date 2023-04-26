//
//  RandomPlaceholder.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

protocol RandomPlaceholder {
    static func randomPlaceholder(using generator: inout some RandomNumberGenerator) -> Self
}

extension RandomPlaceholder {
    static var randomPlaceholder: Self {
        var generator = SystemRandomNumberGenerator()
        return Self.randomPlaceholder(using: &generator)
    }
}
