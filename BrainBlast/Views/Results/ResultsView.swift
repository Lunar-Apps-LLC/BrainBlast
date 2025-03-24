import SwiftUI

struct ResultsView: View {
    let game: QuizGame
    @Environment(\.dismiss) private var dismiss
    
    private var winner: String {
        if game.player1Score > game.player2Score {
            return "Player 1"
        } else if game.player2Score > game.player1Score {
            return "Player 2"
        } else {
            return "It's a tie!"
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Game Over!")
                .font(.largeTitle)
                .bold()
            
            Text(winner)
                .font(.title)
                .foregroundColor(.green)
            
            VStack(spacing: 20) {
                Text("Final Score")
                    .font(.headline)
                
                HStack(spacing: 40) {
                    VStack {
                        Text("Player 1")
                            .font(.subheadline)
                        Text("\(game.player1Score)")
                            .font(.title)
                            .bold()
                    }
                    
                    VStack {
                        Text("Player 2")
                            .font(.subheadline)
                        Text("\(game.player2Score)")
                            .font(.title)
                            .bold()
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            
            Button {
                dismiss()
            } label: {
                Text("Play Again")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.primaryText)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
    }
} 
