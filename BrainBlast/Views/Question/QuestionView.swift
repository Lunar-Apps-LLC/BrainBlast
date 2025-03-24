//
//  QuestionView.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI

struct QuestionView: View {
    @ObservedObject var viewModel: GameViewModel
    let question: QuizQuestion
    @State private var selectedAnswerIndex: Int?
    @State private var isAnswerCorrect: Bool?
    @State private var isSubmitting = false
    
    private var isCurrentPlayerTurn: Bool {
        guard let game = viewModel.game,
              let currentUserId = FirebaseManager.shared.getCurrentUser()?.uid else {
            return false
        }
        
        if currentUserId == game.player1Id {
            return game.currentPlayerTurn == 1
        } else if currentUserId == game.player2Id {
            return game.currentPlayerTurn == 2
        }
        
        return false
    }
    
    private func scoreDotsView(score: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(index < score ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
            }
        }
    }
    
    private func getAnswerBackgroundColor(for index: Int) -> Color {
        if let selectedIndex = selectedAnswerIndex {
            if index == selectedIndex {
                if let isCorrect = isAnswerCorrect {
                    return isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3)
                }
            }
        }
        return Color.white
    }
    
    private func handleAnswerSelection(_ index: Int) {
        guard !isSubmitting else { return }
        
        selectedAnswerIndex = index
        isAnswerCorrect = index == question.correctAnswer
        isSubmitting = true
        
        // Delay the submission by 1 second to show the feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Task {
                await viewModel.submitAnswer(index)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Top bar with scores
            HStack {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                    scoreDotsView(score: viewModel.game?.player1Score ?? 0)
                }
                
                Spacer()
                
                HStack {
                    scoreDotsView(score: viewModel.game?.player2Score ?? 0)
                    Image(systemName: "person.fill")
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Question number
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 60, height: 30)
                
                Text("14")
                    .font(.system(size: 18, weight: .bold))
            }
            .padding(.top)
            
            // Question text
            Text(question.text)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top)
            
            if isCurrentPlayerTurn {
                VStack(spacing: 12) {
                    ForEach(question.options.indices, id: \.self) { index in
                        Button {
                            handleAnswerSelection(index)
                        } label: {
                            HStack {
                                Text(["A", "B", "C", "D"][index])
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                    .frame(width: 30, height: 30)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                                
                                Text(question.options[index])
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(getAnswerBackgroundColor(for: index))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .disabled(isSubmitting)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            } else {
                Text("Waiting for other player...")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.top, 40)
            }
            
            Spacer()
        }
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - Preview
struct QuestionView_Previews: PreviewProvider {
    static let mockQuestion = QuizQuestion(
        id: "mock",
        text: "What is 10% of 100?",
        options: ["1", "5", "10", "15"],
        correctAnswer: 2
    )
    
    static let mockGame = QuizGame(
        id: "mockGameId",
        code: "ABC123",
        player1Id: "player1",
        player2Id: "player2",
        currentQuestionId: "mock",
        player1Score: 2,
        player2Score: 1,
        currentPlayerTurn: 1,
        state: .playing
    )
    
    static var mockViewModel: GameViewModel = {
        let vm = GameViewModel(gameId: "mockGameId")
        vm.game = mockGame
        return vm
    }()
    
    static var previews: some View {
        QuestionView(viewModel: mockViewModel, question: mockQuestion)
    }
}
