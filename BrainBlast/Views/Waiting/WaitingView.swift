//
//  WaitingView.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI

struct WaitingView: View {
    var message: String = "Waiting for Player 2 to join..."
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding()
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
