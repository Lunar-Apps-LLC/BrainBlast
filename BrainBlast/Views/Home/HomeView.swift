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
    @State private var gameId: String?
    
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
                    if let gameId = gameId {
                        GameView(gameId: gameId)
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
