//
//  GameViewModel.swift
//  BrainBlast
//
//  Created by Andrew Garcia on 3/24/25.
//

import SwiftUI

final class GameViewModel: ObservableObject {
    @Published var state: GameState = .waiting
}
