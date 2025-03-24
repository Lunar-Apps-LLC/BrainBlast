//
//  HomeView.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
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
        VStack {
            PrimaryButtonView(title: "Create Game", is3D: true) {
                print("Test")
            }
            
            TextField("", text: $viewModel.gameCodeTextField)
            PrimaryButtonView(title: "Join Game", is3D: true) {
                print("Test")
            }
        }
    }
}
