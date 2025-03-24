import FirebaseFirestore

extension API {
    struct Question {
        static func fetchRandomQuestion() async throws -> QuizQuestion {
            // First check if we have any questions
            let snapshot = try await FirebaseManager.shared.firestore
                .collection("questions")
                .limit(to: 1)
                .getDocuments()
            
            // If no questions exist, seed initial questions
            if snapshot.documents.isEmpty {
                try await seedInitialQuestions()
            }
            
            // Now fetch a random question
            let questionSnapshot = try await FirebaseManager.shared.firestore
                .collection("questions")
                .getDocuments()
            
            guard let document = questionSnapshot.documents.randomElement() else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No questions available"])
            }
            
            let data = document.data()
            return QuizQuestion(
                id: document.documentID,
                text: data["text"] as? String ?? "",
                options: data["options"] as? [String] ?? [],
                correctAnswer: data["correctAnswer"] as? Int ?? 0
            )
        }
        
        static func getQuestion(id: String) async throws -> QuizQuestion {
            let document = try await FirebaseManager.shared.firestore
                .collection("questions")
                .document(id)
                .getDocument()
            
            guard let data = document.data() else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Question not found"])
            }
            
            return QuizQuestion(
                id: document.documentID,
                text: data["text"] as? String ?? "",
                options: data["options"] as? [String] ?? [],
                correctAnswer: data["correctAnswer"] as? Int ?? 0
            )
        }
        
        private static func seedInitialQuestions() async throws {
            let questions = [
                [
                    "text": "What is the capital of France?",
                    "options": ["London", "Berlin", "Paris", "Madrid"],
                    "correctAnswer": 2
                ],
                [
                    "text": "Which planet is known as the Red Planet?",
                    "options": ["Venus", "Mars", "Jupiter", "Saturn"],
                    "correctAnswer": 1
                ],
                [
                    "text": "What is 2 + 2?",
                    "options": ["3", "4", "5", "6"],
                    "correctAnswer": 1
                ],
                [
                    "text": "Who painted the Mona Lisa?",
                    "options": ["Van Gogh", "Da Vinci", "Picasso", "Rembrandt"],
                    "correctAnswer": 1
                ],
                [
                    "text": "What is the largest mammal?",
                    "options": ["African Elephant", "Blue Whale", "Giraffe", "Hippopotamus"],
                    "correctAnswer": 1
                ]
            ]
            
            let batch = FirebaseManager.shared.firestore.batch()
            
            for question in questions {
                let docRef = FirebaseManager.shared.firestore
                    .collection("questions")
                    .document()
                batch.setData(question, forDocument: docRef)
            }
            
            try await batch.commit()
        }
    }
}

extension QuizQuestion {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "text": text,
            "options": options,
            "correctAnswer": correctAnswer
        ]
    }
} 
