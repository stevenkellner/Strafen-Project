//
//  Deletable.swift
//  StrafenProject
//
//  Created by Steven on 05.08.23.
//

import Foundation

enum Deletable<T> where T: Identifiable {
    case deleted(id: T.ID)
    case value(T)
    
    var id: T.ID {
        switch self {
        case .deleted(id: let id):
            return id
        case .value(let value):
            return value.id
        }
    }
}

extension Deletable: Decodable where T: Decodable, T.ID: Decodable {
    private enum CodingKeys: String, CodingKey {
        case deleted
    }
    
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let deletedId = try container.decodeIfPresent(T.ID.self, forKey: .deleted) {
            self = .deleted(id: deletedId)
        } else {
            self = .value(try T(from: decoder))
        }
    }
}

extension Deletable: Sendable where T: Sendable, T.ID: Sendable {}

extension Deletable: Equatable where T: Equatable, T.ID: Equatable {}

extension Deletable: Hashable where T: Hashable, T.ID: Hashable {}
