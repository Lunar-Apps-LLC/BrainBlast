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
    @Published var gameId: String?
    @Published var gameCode: String?
    
    func createGame() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let game = try await API.Game.createGame()
            await MainActor.run {
                self.gameId = game.id
                self.gameCode = game.code
                self.isLoading = false
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
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let game = try await API.Game.joinGame(code: gameCodeTextField)
            await MainActor.run {
                self.gameId = game.id
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Game not found or already in progress"
                self.isLoading = false
            }
        }
    }
}
