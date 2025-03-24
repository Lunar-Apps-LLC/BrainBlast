//
//  HomeView.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
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
                .navigationDestination(isPresented: $viewModel.shouldNavigateToGame) {
                    if let gameId = viewModel.gameId {
                        GameView(gameId: gameId)
                    }
                }
                .onChange(of: viewModel.gameId) { newValue in
                    if newValue != nil {
                        if viewModel.gameCode != nil {
                            // Player 1 created the game
                            showGameCode = true
                        }
                    }
                }
                .onChange(of: viewModel.shouldNavigateToGame) { newValue in
                    if newValue {
                        showGameCode = false
                    }
                }
                .sheet(isPresented: $showGameCode) {
                    if let gameCode = viewModel.gameCode {
                        GameCodeView(gameCode: gameCode)
                    }
                }
        }
    }
        
    @ViewBuilder private var Content: some View {
        VStack(spacing: 20) {
            PrimaryButtonView(title: "Create Game", is3D: true, isRainbow: true) {
                Task {
                    await viewModel.createGame()
                }
            }
            .disabled(viewModel.isLoading)
            
            TextField("Enter Game Code", text: $viewModel.gameCodeTextField)
                .keyboardType(.numberPad)
                .disabled(viewModel.isLoading)
                .font(.custom("ClassicComic-Bold", size: 18))
                .frame(height: 50)
                .foregroundColor(AppColor.primaryText)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColor.primaryText, lineWidth: 2)
                )
            
            PrimaryButtonView(title: "Join Game", is3D: true, backgroundColor: Color(hex: "2674E5")) {
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
    @State private var isCopied = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColor.secondaryBackground)
    }
    
    @ViewBuilder private var Content: some View {
        VStack(spacing: 30) {
            Text("Share this code with Player 2")
                .appFont(size: 20)
            
            HStack(spacing: 15) {
                Text(gameCode)
                    .appFont(size: 40)
                
                Button {
                    UIPasteboard.general.string = gameCode
                    withAnimation {
                        isCopied = true
                    }
                    // Reset the copied state after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isCopied = false
                        }
                    }
                } label: {
                    Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                        .font(.system(size: 24))
                        .foregroundColor(isCopied ? .green : AppColor.primaryText)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isCopied ? Color.green : AppColor.primaryText, lineWidth: 2)
                        )
                }
            }
            
            Text("Waiting for Player 2 to join...")
                .appFont(size: 20)
        }
        .padding()
        .presentationDetents([.medium])
    }
}
