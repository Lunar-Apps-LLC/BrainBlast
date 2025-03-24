//
//  GameView.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    
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
        }
    }
        
    @ViewBuilder private var Content: some View {
        ZStack {
            switch viewModel.state {
                case .waiting:
                    WaitingView()
            }
        }
    }
}
