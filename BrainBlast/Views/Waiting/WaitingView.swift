//
//  WaitingView.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI

struct WaitingView: View {
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
        VStack {

        }
    }
}
