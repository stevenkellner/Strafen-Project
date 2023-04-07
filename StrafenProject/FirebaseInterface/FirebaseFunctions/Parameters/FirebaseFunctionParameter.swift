//
//  FirebaseFunctionParameter.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

struct FirebaseFunctionParameter {
    
    let key: String
    
    let parameter: FirebaseFunctionInternalParameterType
        
    init(_ parameter: some FirebaseFunctionParameterType, for key: String) {
        self.parameter = parameter.internalParameter
        self.key = key
    }
}
