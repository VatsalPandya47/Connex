import Foundation
import Security

class TokenManager {
    static let shared = TokenManager()
    
    private let accessTokenKey = "com.connex.accessToken"
    private let refreshTokenKey = "com.connex.refreshToken"
    private let keychain = KeychainWrapper.standard
    
    private init() {}
    
    var accessToken: String? {
        keychain.string(forKey: accessTokenKey)
    }
    
    var refreshToken: String? {
        keychain.string(forKey: refreshTokenKey)
    }
    
    func saveTokens(accessToken: String, refreshToken: String) {
        keychain.set(accessToken, forKey: accessTokenKey)
        keychain.set(refreshToken, forKey: refreshTokenKey)
    }
    
    func clearTokens() {
        keychain.removeObject(forKey: accessTokenKey)
        keychain.removeObject(forKey: refreshTokenKey)
    }
}

// MARK: - KeychainWrapper

class KeychainWrapper {
    static let standard = KeychainWrapper()
    
    private init() {}
    
    func string(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    func set(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
        }
    }
    
    func removeObject(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
} 