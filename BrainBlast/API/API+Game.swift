import FirebaseFirestore
import Firebase

extension API {
    struct Game {
        private static func shouldAwardPoint(player1Answer: Int?, player2Answer: Int?, correctAnswer: Int, player1Time: Date?, player2Time: Date?) -> Bool {
            guard let player1Answer = player1Answer, let player2Answer = player2Answer,
                  let player1Time = player1Time, let player2Time = player2Time else {
                return false
            }
            
            let player1Correct = player1Answer == correctAnswer
            let player2Correct = player2Answer == correctAnswer
            
            // If one player is correct and the other is wrong, award point to correct player
            if player1Correct && !player2Correct {
                return true
            } else if !player1Correct && player2Correct {
                return false
            }
            
            // If both players are correct, award point to faster player
            if player1Correct && player2Correct {
                return player1Time < player2Time
            }
            
            // If both players are wrong, no point awarded
            return false
        }
        
        static func createGame() async throws -> QuizGame {
            let gameCode = UUID().uuidString.prefix(6).uppercased()
            let currentUserId = FirebaseManager.shared.getCurrentUser()?.uid
            
            guard let currentUserId = currentUserId else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            }
            
            let game = QuizGame(
                id: UUID().uuidString,
                code: String(gameCode),
                player1Id: currentUserId,
                player2Id: nil,
                currentQuestionId: nil,
                player1Score: 0,
                player2Score: 0,
                currentPlayerTurn: 1,
                state: .waiting,
                player1Answer: nil,
                player2Answer: nil,
                player1AnswerTime: nil,
                player2AnswerTime: nil
            )
            
            try await FirebaseManager.shared.firestore
                .collection("games")
                .document(game.id)
                .setData(game.dictionary)
            
            return game
        }
        
        static func joinGame(code: String) async throws -> QuizGame {
            let currentUserId = FirebaseManager.shared.getCurrentUser()?.uid
            
            guard let currentUserId = currentUserId else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            }
            
            // First get all games with matching code
            let snapshot = try await FirebaseManager.shared.firestore
                .collection("games")
                .whereField("code", isEqualTo: code)
                .getDocuments()
            
            // Then find the first game that has no player2Id
            guard let document = snapshot.documents.first(where: { doc in
                      let data = doc.data()
                      return data["player2Id"] as? String == nil
                  }),
                  var game = try? document.data(as: QuizGame.self) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Game not found or already in progress"])
            }
            
            // Fetch the first question
            let question = try await Question.fetchRandomQuestion()
            
            // Update game with player 2, change state to playing, and set the first question
            game = QuizGame(
                id: game.id,
                code: game.code,
                player1Id: game.player1Id,
                player2Id: currentUserId,
                currentQuestionId: question.id,
                player1Score: game.player1Score,
                player2Score: game.player2Score,
                currentPlayerTurn: 1,
                state: .playing,
                player1Answer: nil,
                player2Answer: nil,
                player1AnswerTime: nil,
                player2AnswerTime: nil
            )
            
            try await FirebaseManager.shared.firestore
                .collection("games")
                .document(game.id)
                .setData(game.dictionary)
            
            return game
        }
        
        static func listen(gameId: String, completion: @escaping (Result<QuizGame, Error>) -> Void) -> ListenerRegistration {
            return FirebaseManager.shared.firestore
                .collection("games")
                .document(gameId)
                .addSnapshotListener { documentSnapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let document = documentSnapshot else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                        return
                    }
                    
                    do {
                        let game = try document.data(as: QuizGame.self)
                        completion(.success(game))
                    } catch {
                        completion(.failure(error))
                    }
                }
        }
        
        static func getQuestion(gameId: String) async throws -> QuizQuestion {
            // Fetch current question from the game document
            let gameDoc = try await FirebaseManager.shared.firestore
                .collection("games")
                .document(gameId)
                .getDocument()
            
            guard let game = try? gameDoc.data(as: QuizGame.self) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Game not found"])
            }
            
            // If there's already a question in the game, return it
            if let currentQuestionId = game.currentQuestionId,
               let currentQuestion = try? await Question.getQuestion(id: currentQuestionId) {
                return currentQuestion
            }
            
            // Only fetch a new question if it's Player 1's turn and there's no current question
            if game.currentPlayerTurn == 1 {
                // Fetch a new random question
                let question = try await Question.fetchRandomQuestion()
                
                // Update the game with the new question
                try await FirebaseManager.shared.firestore
                    .collection("games")
                    .document(gameId)
                    .updateData([
                        "currentQuestionId": question.id
                    ])
                
                return question
            }
            
            // If it's Player 2's turn and there's no question, something went wrong
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No question available for Player 2"])
        }
        
        static func submitAnswer(gameId: String, answerIndex: Int) async throws {
            let currentUserId = FirebaseManager.shared.getCurrentUser()?.uid
            
            guard let currentUserId = currentUserId else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            }
            
            // Get the current game state
            let gameDoc = try await FirebaseManager.shared.firestore
                .collection("games")
                .document(gameId)
                .getDocument()
            
            guard var game = try? gameDoc.data(as: QuizGame.self) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Game not found"])
            }
            
            // Get the current question to check the correct answer
            let question = try await Question.getQuestion(id: game.currentQuestionId ?? "")
            
            // Update game state based on the current player
            if currentUserId == game.player1Id {
                // Player 1 is answering
                game = QuizGame(
                    id: game.id,
                    code: game.code,
                    player1Id: game.player1Id,
                    player2Id: game.player2Id,
                    currentQuestionId: game.currentQuestionId,
                    player1Score: game.player1Score,
                    player2Score: game.player2Score,
                    currentPlayerTurn: 2,
                    state: .player2Turn,
                    player1Answer: answerIndex,
                    player2Answer: game.player2Answer,
                    player1AnswerTime: Date(),
                    player2AnswerTime: game.player2AnswerTime
                )
            } else if currentUserId == game.player2Id {
                // Player 2 is answering
                let newPlayer1Score = game.player1Score + (shouldAwardPoint(player1Answer: game.player1Answer, player2Answer: answerIndex, correctAnswer: question.correctAnswer, player1Time: game.player1AnswerTime, player2Time: Date()) ? 1 : 0)
                let newPlayer2Score = game.player2Score + (shouldAwardPoint(player1Answer: game.player1Answer, player2Answer: answerIndex, correctAnswer: question.correctAnswer, player1Time: game.player1AnswerTime, player2Time: Date()) ? 0 : 1)
                
                // Check if game is over (someone reached 3 points)
                let isGameOver = newPlayer1Score >= 3 || newPlayer2Score >= 3
                
                game = QuizGame(
                    id: game.id,
                    code: game.code,
                    player1Id: game.player1Id,
                    player2Id: game.player2Id,
                    currentQuestionId: nil, // Clear the question after both players have answered
                    player1Score: newPlayer1Score,
                    player2Score: newPlayer2Score,
                    currentPlayerTurn: 1,
                    state: isGameOver ? .finished : .player1Turn,
                    player1Answer: nil,
                    player2Answer: nil,
                    player1AnswerTime: nil,
                    player2AnswerTime: nil
                )
            }
            
            // Update the game in Firestore
            try await FirebaseManager.shared.firestore
                .collection("games")
                .document(gameId)
                .setData(game.dictionary)
        }
        
        static func updateQuestion(gameId: String, questionId: String) async throws {
            try await FirebaseManager.shared.firestore
                .collection("games")
                .document(gameId)
                .updateData([
                    "currentQuestionId": questionId
                ])
        }
    }
}

struct QuizGame: Identifiable, Codable {
    let id: String
    let code: String
    let player1Id: String
    let player2Id: String?
    let currentQuestionId: String?
    let player1Score: Int
    let player2Score: Int
    let currentPlayerTurn: Int
    let state: GameState
    let player1Answer: Int?
    let player2Answer: Int?
    let player1AnswerTime: Date?
    let player2AnswerTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case player1Id
        case player2Id
        case currentQuestionId
        case player1Score
        case player2Score
        case currentPlayerTurn
        case state
        case player1Answer
        case player2Answer
        case player1AnswerTime
        case player2AnswerTime
    }
    
    init(id: String, code: String, player1Id: String, player2Id: String?, currentQuestionId: String?, player1Score: Int, player2Score: Int, currentPlayerTurn: Int, state: GameState, player1Answer: Int? = nil, player2Answer: Int? = nil, player1AnswerTime: Date? = nil, player2AnswerTime: Date? = nil) {
        self.id = id
        self.code = code
        self.player1Id = player1Id
        self.player2Id = player2Id
        self.currentQuestionId = currentQuestionId
        self.player1Score = player1Score
        self.player2Score = player2Score
        self.currentPlayerTurn = currentPlayerTurn
        self.state = state
        self.player1Answer = player1Answer
        self.player2Answer = player2Answer
        self.player1AnswerTime = player1AnswerTime
        self.player2AnswerTime = player2AnswerTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        code = try container.decode(String.self, forKey: .code)
        player1Id = try container.decode(String.self, forKey: .player1Id)
        player2Id = try container.decodeIfPresent(String.self, forKey: .player2Id)
        currentQuestionId = try container.decodeIfPresent(String.self, forKey: .currentQuestionId)
        player1Score = try container.decode(Int.self, forKey: .player1Score)
        player2Score = try container.decode(Int.self, forKey: .player2Score)
        currentPlayerTurn = try container.decode(Int.self, forKey: .currentPlayerTurn)
        let stateString = try container.decode(String.self, forKey: .state)
        guard let decodedState = GameState(rawValue: stateString) else {
            throw DecodingError.dataCorruptedError(forKey: .state, in: container, debugDescription: "Invalid game state")
        }
        state = decodedState
        player1Answer = try container.decodeIfPresent(Int.self, forKey: .player1Answer)
        player2Answer = try container.decodeIfPresent(Int.self, forKey: .player2Answer)
        player1AnswerTime = try container.decodeIfPresent(Date.self, forKey: .player1AnswerTime)
        player2AnswerTime = try container.decodeIfPresent(Date.self, forKey: .player2AnswerTime)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(code, forKey: .code)
        try container.encode(player1Id, forKey: .player1Id)
        try container.encodeIfPresent(player2Id, forKey: .player2Id)
        try container.encodeIfPresent(currentQuestionId, forKey: .currentQuestionId)
        try container.encode(player1Score, forKey: .player1Score)
        try container.encode(player2Score, forKey: .player2Score)
        try container.encode(currentPlayerTurn, forKey: .currentPlayerTurn)
        try container.encode(state.rawValue, forKey: .state)
        try container.encodeIfPresent(player1Answer, forKey: .player1Answer)
        try container.encodeIfPresent(player2Answer, forKey: .player2Answer)
        try container.encodeIfPresent(player1AnswerTime, forKey: .player1AnswerTime)
        try container.encodeIfPresent(player2AnswerTime, forKey: .player2AnswerTime)
    }
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "code": code,
            "player1Id": player1Id,
            "player2Id": player2Id as Any,
            "currentQuestionId": currentQuestionId as Any,
            "player1Score": player1Score,
            "player2Score": player2Score,
            "currentPlayerTurn": currentPlayerTurn,
            "state": state.rawValue,
            "player1Answer": player1Answer as Any,
            "player2Answer": player2Answer as Any,
            "player1AnswerTime": player1AnswerTime as Any,
            "player2AnswerTime": player2AnswerTime as Any
        ]
    }
}

enum GameError: Error {
    case gameNotFound
} 
