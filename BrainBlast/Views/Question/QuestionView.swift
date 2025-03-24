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
    
    var body: some View {
        VStack(spacing: 20) {
            if let game = viewModel.game {
                HStack {
                    Text("Player 1: \(game.player1Score)")
                    Spacer()
                    Text("Player 2: \(game.player2Score)")
                }
                .font(.headline)
                .padding()
            }
            
            Text(question.text)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            
            if isCurrentPlayerTurn {
                ForEach(question.options.indices, id: \.self) { index in
                    Button {
                        Task {
                            await viewModel.submitAnswer(index)
                        }
                    } label: {
                        Text(question.options[index])
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColor.primaryText)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                Text("Waiting for other player...")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}
