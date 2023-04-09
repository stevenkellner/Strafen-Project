//
//  FirebaseAuthenticator.swift
//  StrafenProject
//
//  Created by Steven on 07.04.23.
//

import Foundation
import FirebaseAuth

struct FirebaseAuthenticator {
    
    static let shared = FirebaseAuthenticator()
    
    private init() {}
    
    @discardableResult
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    var user: User? {
        return Auth.auth().currentUser
    }
}
