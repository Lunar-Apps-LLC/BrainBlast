import SwiftUI
import ConfettiSwiftUI
import SDWebImageSwiftUI

struct ResultsView: View {
    let game: QuizGame
    @Environment(\.dismiss) private var dismiss
    @State private var confettiTrigger = 0
    
    private var winner: String {
        if game.player1Score > game.player2Score {
            return "Player 1"
        } else if game.player2Score > game.player1Score {
            return "Player 2"
        } else {
            return "It's a tie!"
        }
    }
    
    private var hasWinner: Bool {
        game.player1Score != game.player2Score
    }
    
    private var isCurrentUserWinner: Bool {
        guard let currentUserId = FirebaseManager.shared.getCurrentUser()?.uid else { return false }
        
        if game.player1Score > game.player2Score {
            return currentUserId == game.player1Id
        } else if game.player2Score > game.player1Score {
            return currentUserId == game.player2Id
        }
        return false
    }
    
    private let winnerGifURL = URL(string: "https://files.tryflowdrive.com/org-2f3e4c92-20d9-49d2-be8f-0f3b4d5e98d1/file-6a2adc81-414a-4c90-a01a-3df307648e54_GIF_DerdFan-(1).gif")!
    private let loserGifURL = URL(string: "https://files.tryflowdrive.com/org-2f3e4c92-20d9-49d2-be8f-0f3b4d5e98d1/file-ab613818-5ca2-4cf0-ba87-e4795465e9a3_GIF_DerdHammer-(1)-(1).gif")!
    
    var body: some View {
        VStack(spacing: 30) {
            if hasWinner {
                AnimatedImage(url: isCurrentUserWinner ? winnerGifURL : loserGifURL)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
            }
            
            Text("Game Over!")
                .appFont(size: 40, weight: .bold, color: AppColor.primaryText, type: .classicComic)
            
            Text("\(winner) wins")
                .appFont(size: 32, weight: .bold, color: .green, type: .classicComic)
            
            VStack(spacing: 20) {
                Text("Final Score")
                    .appFont(size: 20, weight: .semibold)
                
                HStack(spacing: 40) {
                    VStack {
                        Text("Player 1")
                            .appFont(size: 16, weight: .medium)
                        Text("\(game.player1Score)")
                            .appFont(size: 32, weight: .bold)
                    }
                    
                    VStack {
                        Text("Player 2")
                            .appFont(size: 16, weight: .medium)
                        Text("\(game.player2Score)")
                            .appFont(size: 32, weight: .bold)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
        }
        .padding()
        .confettiCannon(
            trigger: $confettiTrigger,
            num: 50,
            confettis: [
                .shape(.circle),
                .shape(.triangle),
                .shape(.square),
                .shape(.slimRectangle),
                .shape(.roundedCross)
            ],
            colors: [.blue, .red, .green, .yellow, .pink, .purple, .orange],
            confettiSize: 10,
            rainHeight: 600,
            openingAngle: Angle(degrees: 0),
            closingAngle: Angle(degrees: 360),
            radius: 200
        )
        .onAppear {
            if hasWinner && isCurrentUserWinner {
                confettiTrigger += 1
            }
        }
    }
}

#Preview {
    ResultsView(game: QuizGame(
        id: "preview-game",
        code: "ABC123",
        player1Id: "player1",
        player2Id: "player2",
        currentQuestionId: "1",
        player1Score: 8,
        player2Score: 5,
        currentPlayerTurn: 0,
        state: .finished
    ))
}
