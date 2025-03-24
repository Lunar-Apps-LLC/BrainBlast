struct QuizQuestion: Identifiable, Codable {
    let id: String
    let text: String
    let options: [String]
    let correctAnswer: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case options
        case correctAnswer
    }
    
    init(id: String, text: String, options: [String], correctAnswer: Int) {
        self.id = id
        self.text = text
        self.options = options
        self.correctAnswer = correctAnswer
    }
} 