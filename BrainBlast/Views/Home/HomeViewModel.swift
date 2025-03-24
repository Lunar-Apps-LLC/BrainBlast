//
//  HomeViewModel.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var gameCodeTextField: String = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func createGame() async {
        isLoading = true
        do {
            let game = try await API.Game.createGame()
            await MainActor.run {
                self.isLoading = false
                // Navigate to game view
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func joinGame() async {
        guard !gameCodeTextField.isEmpty else {
            errorMessage = "Please enter a game code"
            return
        }
        
        isLoading = true
        do {
            let game = try await API.Game.joinGame(code: gameCodeTextField)
            await MainActor.run {
                self.isLoading = false
                // Navigate to game view
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Game not found or already in progress"
                self.isLoading = false
            }
        }
    }
}
