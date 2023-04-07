//
//  FirebaseFunction.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation

protocol FirebaseFunction {
    associatedtype ReturnType: Decodable
    
    static var functionName: String { get }
    
    @FirebaseFunctionParametersBuilder var parameters: FirebaseFunctionParameters { get }
}

extension FirebaseFunction {
    typealias ReturnType = VoidReturnType
}

struct VoidReturnType {}

extension VoidReturnType: Decodable {
    init(from decoder: Decoder) throws {}
}
