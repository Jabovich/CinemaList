//
//  KeychainManager.swift
//  Test
//
//  Created by Андрей Сметанин on 20.03.2025.
//

import Foundation

enum KeychainError: Error {
    case duplicateItem
    case unknown(status: OSStatus)
    case notFound
}

final class KeychainManager {
    static func save(token: Data, account: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecValueData: token
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateItem
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status: status)
        }
        
//        -> String
//        return "Saved"
    }
    
    static func update(token: Data, account: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account
        ]
        
        let attributes: [CFString: Any] = [
            kSecValueData: token
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status != errSecSuccess {
            throw KeychainError.unknown(status: status)
        }
        
//        -> String
//        return "Updated"
    }
    
    static func get(account: String) throws -> Data {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecReturnData: kCFBooleanTrue as Any
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.notFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status: status)
        }
        
        return result as? Data ?? Data()
    }
    
    static func delete(account: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unknown(status: status)
        }
        //-> String
        //return "Deleted"
    }
}


//    static func get(account: String) throws -> Data? {
//        let query: [CFString: Any] = [
//            kSecClass: kSecClassGenericPassword,
//            kSecAttrAccount: account,
//            kSecReturnData: kCFBooleanTrue as Any
//        ]
//
//        var result : AnyObject?
//
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//
//        guard status == errSecSuccess else {
//            throw KeychainError.unknown(status: status)
//        }
//
//        return result as? Data
//    }

func getAccessToken(account: String) -> String? {
//    print("Call stack:")
//    Thread.callStackSymbols.forEach { print($0) }
    
    do {
        let tokenData = try KeychainManager.get(account: account)
        guard let accessToken = String(data: tokenData, encoding: .utf8) else {
            print("Failed to decode token data for account: \(account)")
            return nil
        }
        print("Retrieved Access Token for account \(account): \(tokenData)")
        return accessToken
    } catch KeychainError.notFound {
        print("Token not found in Keychain for account: \(account)")
        return nil
    } catch {
        print("Error retrieving token for account \(account): \(error)")
        return nil  
    }
}

//func getAccessToken(account: String) -> String? {
//    struct RecursionGuard {
//        static var isRunning = false
//    }
//    
//    guard !RecursionGuard.isRunning else {
//        print("⚠️ Рекурсивный вызов getAccessToken предотвращен")
//        return nil
//    }
//    
//    RecursionGuard.isRunning = true
//    defer { RecursionGuard.isRunning = false }
//    
//    do {
//        let tokenData = try KeychainManager.get(account: account)
//        guard let accessToken = String(data: tokenData, encoding: .utf8) else {
//            print("Failed to decode token data")
//            return nil
//        }
//        return accessToken
//    } catch {
//        print("Error getting token: \(error)")
//        return nil
//    }
//}
