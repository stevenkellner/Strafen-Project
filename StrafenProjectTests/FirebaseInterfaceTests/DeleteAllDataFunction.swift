//
//  DeleteAllDataFunction.swift
//  StrafenProjectTests
//
//  Created by Steven on 07.04.23.
//

import Foundation
@testable import StrafenProject

struct DeleteAllDataFunction: FirebaseFunction {
    
    static let functionName = "deleteAllData"
    
    var parameters: FirebaseFunctionParameters {
        return FirebaseFunctionParameters()
    }
}
