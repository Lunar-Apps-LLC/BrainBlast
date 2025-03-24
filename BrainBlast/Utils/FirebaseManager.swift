import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {
        FirebaseApp.configure()
    }
    
    func signInAnonymously() async throws -> User {
        let result = try await Auth.auth().signInAnonymously()
        return result.user
    }
    
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
} 