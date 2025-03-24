import FirebaseFirestore

extension API {
    struct Question {
        static func fetchRandomQuestion() async throws -> Question {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("questions").getDocuments()
            let questions = snapshot.documents.compactMap { document -> Question? in
                let data = document.data()
                return Question(
                    id: document.documentID,
                    text: data["text"] as? String ?? "",
                    options: data["options"] as? [String] ?? [],
                    correctAnswer: data["correctAnswer"] as? Int ?? 0
                )
            }
            
            return questions.randomElement() ?? Question(
                id: "default",
                text: "What is the capital of France?",
                options: ["London", "Berlin", "Paris", "Madrid"],
                correctAnswer: 2
            )
        }
    }
}

struct Question: Identifiable {
    let id: String
    let text: String
    let options: [String]
    let correctAnswer: Int
} 