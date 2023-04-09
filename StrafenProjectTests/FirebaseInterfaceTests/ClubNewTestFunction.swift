//
//  ClubNewTestFunction.swift
//  StrafenProjectTests
//
//  Created by Steven on 07.04.23.
//

import Foundation
@testable import StrafenProject

struct ClubNewTestFunction: FirebaseFunction {
    enum TestClubType: String {
        case `default`
    }
    
    static let functionName = "club-newTest"
    
    public private(set) var clubId: ClubProperties.ID
    public private(set) var testClubType: TestClubType
    
    var parameters: FirebaseFunctionParameters {
        FirebaseFunctionParameter(self.clubId, for: "clubId")
        FirebaseFunctionParameter(self.testClubType, for: "testClubType")
    }
}

extension ClubNewTestFunction.TestClubType: Decodable {}

extension ClubNewTestFunction.TestClubType: FirebaseFunctionParameterType {
    var parameter: String {
        return self.rawValue
    }
}
