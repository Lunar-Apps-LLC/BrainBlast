//
//  CreateGameView.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI

struct CreateGameView: View {
    @StateObject private var viewModel = CreateGameViewModel()
    
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

        }
    }
}
