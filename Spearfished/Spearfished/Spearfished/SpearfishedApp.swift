//
//  SpearfishedApp.swift
//  Spearfished
//
//  Created by bryce burton on 12/4/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@main
struct SpearfishedApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isSignedIn {
                FeedView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
