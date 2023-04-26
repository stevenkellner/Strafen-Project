//
//  FirebaseStorageImageType.swift
//  StrafenProject
//
//  Created by Steven on 21.04.23.
//

import Foundation

enum FirebaseStorageImageType {
    case club(clubId: ClubProperties.ID)
    case person(clubId: ClubProperties.ID, personId: Person.ID)
    
    var imageUrl: URL {
        switch self {
        case .club(let clubId):
            return URL(string: DatabaseType.current.rawValue)!
                .appending(component: clubId.uuidString.uppercased())
                .appending(path: "clubImage")
                .appendingPathExtension("jpeg")
        case .person(let clubId, let personId):
            return URL(string: DatabaseType.current.rawValue)!
                .appending(component: clubId.uuidString.uppercased())
                .appending(path: personId.uuidString.uppercased())
                .appendingPathExtension("jpeg")
        }
    }
}
