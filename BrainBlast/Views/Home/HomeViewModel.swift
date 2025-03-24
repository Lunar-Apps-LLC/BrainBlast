//
//  HomeViewModel.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI
import FirebaseFirestore

final class HomeViewModel: ObservableObject {
    @Published var gameCodeTextField: String = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var gameId: String?
    @Published var gameCode: String?
    @Published var shouldNavigateToGame = false
    private var listener: ListenerRegistration?
    
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
            setupGameListener(gameId: game.id)
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
                self.shouldNavigateToGame = true
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Game not found or already in progress"
                self.isLoading = false
            }
        }
    }
    
    private func setupGameListener(gameId: String) {
        listener?.remove()
        listener = API.Game.listen(gameId: gameId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let game):
                if game.state == .playing {
                    Task { @MainActor in
                        self.shouldNavigateToGame = true
                    }
                }
            case .failure(let error):
                Task { @MainActor in
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}
