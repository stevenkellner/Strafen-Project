//
//  FirebaseFunctionCaller.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation
import FirebaseFunctions
import OSLog

struct FirebaseFunctionCaller {
    enum Error: Swift.Error {
        case invalidReturnType
    }
        
    private var isVerbose = false
    
    static let shared = FirebaseFunctionCaller()
    
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "StrafenProject", category: String(describing: FirebaseFunctionCaller.self))
    
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
    
    private func functionName<Function>(of function: Function) -> String where Function: FirebaseFunction {
        switch DatabaseType.current {
        case .release:
            return Function.functionName
        case .debug, .testing:
            return "debug-\(Function.functionName)"
        }
    }
    
    func call<Function>(_ function: Function) async throws -> Function.ReturnType where Function: FirebaseFunction {
        FirebaseFunctionCaller.logger.log("Call firebase function \(Function.functionName, privacy: .public).")
        do {
            let parameters = try self.createParameters(of: function).firebaseFunctionParameters
            let httpsResult = try await Functions
                .functions(region: "europe-west1")
                .httpsCallable(self.functionName(of: function))
                .call(parameters)
            guard let response = httpsResult.data as? [String: Any],
                  let encryptedResult = response["result"] as? String else {
                throw Error.invalidReturnType
            }
            let crypter = Crypter(keys: PrivateKeys.current.cryptionKeys)
            let result = try crypter.decryptDecode(type: FirebaseFunctionResult<Function.ReturnType>.self, encryptedResult).value
            FirebaseFunctionCaller.logger.log("Call firebase function \(Function.functionName, privacy: .public) succeeded.")
            return result
        } catch {
            FirebaseFunctionCaller.logger.log(level: .error, "Call firebase function \(Function.functionName, privacy: .public) failed: \(error.localizedDescription, privacy: .public).")
            throw error
        }
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
