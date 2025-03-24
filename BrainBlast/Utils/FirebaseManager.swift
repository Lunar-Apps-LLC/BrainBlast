import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    let firestore: Firestore
    
    private init() {
        FirebaseApp.configure()
        self.firestore = Firestore.firestore()
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