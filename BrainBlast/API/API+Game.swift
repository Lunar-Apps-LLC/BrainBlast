import FirebaseFirestore

extension API {
    struct Game {
        static func createGame() async throws -> Game {
            let db = Firestore.firestore()
            let gameRef = db.collection("games").document()
            
            let game = Game(
                id: gameRef.documentID,
                code: String(Int.random(in: 100000...999999)),
                player1Id: FirebaseManager.shared.getCurrentUser()?.uid ?? "",
                player2Id: nil,
                currentQuestion: nil,
                player1Score: 0,
                player2Score: 0,
                currentPlayerTurn: 1,
                state: .waiting
            )
            
            try await gameRef.setData(game.dictionary)
            return game
        }
        
        static func joinGame(code: String) async throws -> Game {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("games")
                .whereField("code", isEqualTo: code)
                .whereField("player2Id", isNull: true)
                .getDocuments()
            
            guard let document = snapshot.documents.first else {
                throw GameError.gameNotFound
            }
            
            let game = Game(
                id: document.documentID,
                code: document.data()["code"] as? String ?? "",
                player1Id: document.data()["player1Id"] as? String ?? "",
                player2Id: FirebaseManager.shared.getCurrentUser()?.uid,
                currentQuestion: nil,
                player1Score: document.data()["player1Score"] as? Int ?? 0,
                player2Score: document.data()["player2Score"] as? Int ?? 0,
                currentPlayerTurn: document.data()["currentPlayerTurn"] as? Int ?? 1,
                state: .waiting
            )
            
            try await document.reference.updateData([
                "player2Id": game.player2Id ?? "",
                "state": GameState.playing.rawValue
            ])
            
            return game
        }
        
        static func updateGame(_ game: Game) async throws {
            let db = Firestore.firestore()
            try await db.collection("games").document(game.id).setData(game.dictionary)
        }
        
        static func listenToGame(id: String, completion: @escaping (Game?) -> Void) -> ListenerRegistration {
            let db = Firestore.firestore()
            return db.collection("games").document(id).addSnapshotListener { snapshot, error in
                guard let document = snapshot, let data = document.data() else {
                    completion(nil)
                    return
                }
                
                let game = Game(
                    id: document.documentID,
                    code: data["code"] as? String ?? "",
                    player1Id: data["player1Id"] as? String ?? "",
                    player2Id: data["player2Id"] as? String,
                    currentQuestion: data["currentQuestion"] as? [String: Any],
                    player1Score: data["player1Score"] as? Int ?? 0,
                    player2Score: data["player2Score"] as? Int ?? 0,
                    currentPlayerTurn: data["currentPlayerTurn"] as? Int ?? 1,
                    state: GameState(rawValue: data["state"] as? String ?? "") ?? .waiting
                )
                
                completion(game)
            }
        }
    }
}

struct Game: Identifiable {
    let id: String
    let code: String
    let player1Id: String
    let player2Id: String?
    let currentQuestion: [String: Any]?
    let player1Score: Int
    let player2Score: Int
    let currentPlayerTurn: Int
    let state: GameState
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "code": code,
            "player1Id": player1Id,
            "player2Id": player2Id as Any,
            "currentQuestion": currentQuestion as Any,
            "player1Score": player1Score,
            "player2Score": player2Score,
            "currentPlayerTurn": currentPlayerTurn,
            "state": state.rawValue
        ]
    }
}

enum GameError: Error {
    case gameNotFound
} 