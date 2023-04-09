//
//  FirebaseFunctionCaller.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation
import FirebaseFunctions

struct FirebaseFunctionCaller {
    enum Error: Swift.Error {
        case invalidReturnType
    }
        
    private var isVerbose = false
    
    static let shared = FirebaseFunctionCaller()
    
    private init() {}
    
    private func createParameters(of function: some FirebaseFunction) throws -> FirebaseFunctionParameters {
        let crypter = Crypter(keys: PrivateKeys.current.cryptionKeys)
        let encryptedParameters = try crypter.encodeEncrypt(function.parameters)
        @FirebaseFunctionParametersBuilder var parameters: FirebaseFunctionParameters {
            FirebaseFunctionParameter(self.isVerbose ? "verbose" : "none", for: "verbose")
            FirebaseFunctionParameter(DatabaseType.current, for: "databaseType")
            FirebaseFunctionParameter(CallSecret(key: PrivateKeys.current.callSecretKey), for: "callSecret")
            FirebaseFunctionParameter(encryptedParameters, for: "parameters")
        }
        return parameters
    }
    
    func call<Function>(_ function: Function) async throws -> Function.ReturnType where Function: FirebaseFunction {
        let parameters = try self.createParameters(of: function).firebaseFunctionParameters
        let httpsResult = try await Functions
            .functions(region: "europe-west1")
            .httpsCallable(Function.functionName)
            .call(parameters)
        guard let encryptedResult = httpsResult.data as? String else {
            throw Error.invalidReturnType
        }
        let crypter = Crypter(keys: PrivateKeys.current.cryptionKeys)
        let result = try crypter.decryptDecode(type: FirebaseFunctionResult<Function.ReturnType>.self, encryptedResult)
        return try result.value
    }
    
    func call<Function>(_ function: Function) async throws where Function: FirebaseFunction, Function.ReturnType == VoidReturnType {
        let _: Function.ReturnType = try await self.call(function)
    }
        
    var verbose: FirebaseFunctionCaller {
        var caller = self
        caller.isVerbose = true
        return caller
    }
}
