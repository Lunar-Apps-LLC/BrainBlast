//
//  GameViewModel.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI
import FirebaseFirestore

final class GameViewModel: ObservableObject {
    @Published var game: QuizGame?
    @Published var currentQuestion: QuizQuestion?
    @Published var errorMessage: String?
    private var listener: ListenerRegistration?
    private let gameId: String
    
    init(gameId: String) {
        self.gameId = gameId
        setupGameListener()
    }
    
    private func setupGameListener() {
        listener = API.Game.listen(gameId: gameId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let game):
                Task { @MainActor in
                    let oldState = self.game?.state
                    self.game = game
                    
                    // If the game just transitioned from waiting to playing (Player 2 joined)
                    if oldState == .waiting && game.state == .playing {
                        do {
                            // Fetch the first question
                            let question = try await API.Question.fetchRandomQuestion()
                            try await API.Game.updateQuestion(gameId: self.gameId, questionId: question.id)
                            self.currentQuestion = question
                        } catch {
                            self.errorMessage = error.localizedDescription
                        }
                    }
                    // If there's a question ID in the game and we don't have the question loaded
                    else if let questionId = game.currentQuestionId,
                            self.currentQuestion == nil {
                        do {
                            self.currentQuestion = try await API.Question.getQuestion(id: questionId)
                        } catch {
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }
            case .failure(let error):
                Task { @MainActor in
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func submitAnswer(_ index: Int) async {
        do {
            // Get the current question before clearing it
            guard let question = currentQuestion else { return }
            
            // Submit the answer and update game state
            try await API.Game.submitAnswer(gameId: gameId, answerIndex: index)
            
            // Clear the current question
            await MainActor.run {
                self.currentQuestion = nil
            }
            
            // If it's player 2's turn, fetch a new question
            if let game = game,
               let currentUserId = FirebaseManager.shared.getCurrentUser()?.uid,
               currentUserId == game.player2Id {
                let newQuestion = try await API.Question.fetchRandomQuestion()
                try await API.Game.updateQuestion(gameId: gameId, questionId: newQuestion.id)
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}
