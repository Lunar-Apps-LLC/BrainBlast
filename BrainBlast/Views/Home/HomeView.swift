//
//  HomeView.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var navigateToGame = false
    @State private var showGameCode = false
    
    var body: some View {
        NavigationStack {
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
                .navigationDestination(isPresented: $navigateToGame) {
                    if let gameId = viewModel.gameId {
                        GameView(gameId: gameId)
                    }
                }
                .onChange(of: viewModel.gameId) { newValue in
                    if newValue != nil {
                        if viewModel.gameCode != nil {
                            // Player 1 created the game
                            showGameCode = true
                        } else {
                            // Player 2 joined the game
                            navigateToGame = true
                        }
                    }
                }
                .sheet(isPresented: $showGameCode) {
                    if let gameCode = viewModel.gameCode {
                        GameCodeView(gameCode: gameCode) {
                            showGameCode = false
                            navigateToGame = true
                        }
                    }
                }
        }
    }
        
    @ViewBuilder private var Content: some View {
        VStack(spacing: 20) {
            PrimaryButtonView(title: "Create Game", is3D: true) {
                Task {
                    await viewModel.createGame()
                }
            }
            .disabled(viewModel.isLoading)
            
            TextField("Enter Game Code", text: $viewModel.gameCodeTextField)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .disabled(viewModel.isLoading)
            
            PrimaryButtonView(title: "Join Game", is3D: true) {
                Task {
                    await viewModel.joinGame()
                }
            }
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}

struct GameCodeView: View {
    let gameCode: String
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Share this code with Player 2")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text(gameCode)
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(AppColor.primaryText)
            
            Text("Waiting for Player 2 to join...")
                .font(.headline)
                .foregroundColor(.gray)
            
            Button {
                onStart()
            } label: {
                Text("Start Game")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.primaryText)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
        .presentationDetents([.medium])
    }
}
