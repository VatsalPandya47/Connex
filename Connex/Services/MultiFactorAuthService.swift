import Foundation
import Firebase

class MultiFactorAuthService {
    static let shared = MultiFactorAuthService()
    
    private init() {}
    
    func enrollPhoneMultiFactor(phoneNumber: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])))
            return
        }
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let verificationID = verificationID else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Verification failed"])))
                return
            }
            
            // Store verification ID securely
            UserDefaults.standard.set(verificationID, forKey: "AuthVerificationID")
            
            completion(.success(()))
        }
    }
    
    func completePhoneVerification(verificationCode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let verificationID = UserDefaults.standard.string(forKey: "AuthVerificationID") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No verification in progress"])))
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])))
            return
        }
        
        currentUser.multiFactor.enroll(with: PhoneMultiFactorGenerator.assertion(with: credential)) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
} 