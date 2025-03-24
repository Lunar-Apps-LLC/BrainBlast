//
//  GameView.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(gameId: String) {
        _viewModel = StateObject(wrappedValue: GameViewModel(gameId: gameId))
    }
    
    var body: some View {
        Content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColor.primaryBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                }
            }
    }
        
    @ViewBuilder private var Content: some View {
        ZStack {
            if let game = viewModel.game {
                let currentUserId = FirebaseManager.shared.getCurrentUser()?.uid
                
                switch game.state {
                case .waiting:
                    WaitingView()
                case .playing:
                    if game.player1Id == currentUserId {
                        if let question = viewModel.currentQuestion {
                            QuestionView(viewModel: viewModel, question: question)
                        } else {
                            ProgressView()
                        }
                    } else {
                        WaitingView(message: "Waiting for Player 1 to answer...")
                    }
                case .player1Turn:
                    if game.player1Id == currentUserId {
                        if let question = viewModel.currentQuestion {
                            QuestionView(viewModel: viewModel, question: question)
                        } else {
                            ProgressView()
                        }
                    } else {
                        WaitingView(message: "Waiting for Player 1 to answer...")
                    }
                case .player2Turn:
                    if game.player2Id == currentUserId {
                        if let question = viewModel.currentQuestion {
                            QuestionView(viewModel: viewModel, question: question)
                        } else {
                            ProgressView()
                        }
                    } else {
                        WaitingView(message: "Waiting for Player 2 to answer...")
                    }
                case .finished:
                    ResultsView(game: game)
                }
            } else {
                ProgressView()
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
            }
        }
    }
}
