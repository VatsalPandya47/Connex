import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let firestore: Firestore
    let storage: Storage
    
    private init() {
        FirebaseApp.configure()
        auth = Auth.auth()
        firestore = Firestore.firestore()
        storage = Storage.storage()
    }
    
    func getCurrentUserID() -> String? {
        return auth.currentUser?.uid
    }
} 