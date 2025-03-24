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
    private var questionStartTime: Date?
    
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
                    let oldQuestionId = self.game?.currentQuestionId
                    self.game = game
                    
                    // If the game just transitioned from waiting to playing (Player 2 joined)
                    if oldState == .waiting && game.state == .playing {
                        do {
                            // Fetch the first question
                            let question = try await API.Question.fetchRandomQuestion()
                            try await API.Game.updateQuestion(gameId: self.gameId, questionId: question.id)
                            self.currentQuestion = question
                            self.questionStartTime = Date()
                        } catch {
                            self.errorMessage = error.localizedDescription
                        }
                    }
                    // If it's Player 1's turn and there's no current question
                    else if game.currentPlayerTurn == 1 && game.currentQuestionId == nil {
                        do {
                            // Fetch a new random question
                            let question = try await API.Question.fetchRandomQuestion()
                            try await API.Game.updateQuestion(gameId: self.gameId, questionId: question.id)
                            self.currentQuestion = question
                            self.questionStartTime = Date()
                        } catch {
                            self.errorMessage = error.localizedDescription
                        }
                    }
                    // If the question ID has changed and we don't have the new question loaded
                    else if let newQuestionId = game.currentQuestionId,
                            newQuestionId != oldQuestionId {
                        do {
                            self.currentQuestion = try await API.Question.getQuestion(id: newQuestionId)
                            self.questionStartTime = Date()
                        } catch {
                            self.errorMessage = error.localizedDescription
                        }
                    }
                    // If the question ID is nil, clear the current question
                    else if game.currentQuestionId == nil {
                        self.currentQuestion = nil
                        self.questionStartTime = nil
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
            guard let startTime = questionStartTime else { return }
            let timeToAnswer = Date().timeIntervalSince(startTime)
            
            // Submit the answer and update game state
            try await API.Game.submitAnswer(gameId: gameId, answerIndex: index, timeToAnswer: timeToAnswer)
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
