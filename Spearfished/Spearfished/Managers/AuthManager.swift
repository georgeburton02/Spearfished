//
//  AuthManager.swift
//  Spearfished
//
//  Created by bryce burton on 12/4/24.
//

import Foundation
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var currentUser: User?
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isSignedIn = user != nil
            self?.currentUser = user
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        DispatchQueue.main.async {
            self.currentUser = result.user
            self.isSignedIn = true
        }
    }
    
    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        DispatchQueue.main.async {
            self.currentUser = result.user
            self.isSignedIn = true
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        self.isSignedIn = false
        self.currentUser = nil
    }
}
