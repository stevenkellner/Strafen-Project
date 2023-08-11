//
//  FirebaseFunctionParameter.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

enum FirebaseFunctionParameter {
    case single(FirebaseFunctionInternalParameterType)
    case keyed(FirebaseFunctionInternalParameterType, key: String)
            
    init(_ parameter: some FirebaseFunctionParameterType) {
        self = .single(parameter.internalParameter)
    }
    
    init(_ parameter: some FirebaseFunctionParameterType, for key: String) {
        self = .keyed(parameter.internalParameter, key: key)
    }
}
