//
//  BrainBlastApp.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI

@main
struct BrainBlastApp: App {
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    
    init() {
        Task {
            await signInAnonymously()
        }
    }
    
    private func signInAnonymously() async {
        do {
            _ = try await FirebaseManager.shared.signInAnonymously()
            await MainActor.run {
                self.isAuthenticated = true
            }
        } catch {
            print("Failed to sign in anonymously: \(error)")
        }
    }
}
