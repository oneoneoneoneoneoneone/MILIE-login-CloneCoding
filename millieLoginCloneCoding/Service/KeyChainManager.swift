//
//  KeyChainManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/05/06.
//

import Foundation

class KeyChainManager{
    let bundleId = Bundle.main.bundleIdentifier!
    
    func isEmpty() throws -> Bool{
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: bundleId,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
                                        
        //검색
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return true}  //정보 없음
        
        return false
    }
    
    func add(account: String, password: String) throws{
        let account = account
        guard let password = password.data(using: String.Encoding.utf8) else {return}
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: bundleId,             //앱 고유 값
                                    kSecAttrAccount as String: account,           //식별 값
                                    kSecValueData as String: password]
        
        //추가
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw LoginError.unknown(key: SecCopyErrorMessageString(status, nil)! as String)
        }
    }
    
    func read() async throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: bundleId,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
                                        
        //검색
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return }  //정보 없음
        guard status == errSecSuccess else {
            throw LoginError.unknown(key: SecCopyErrorMessageString(status, nil)! as String)
        }
        
        //추출
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
        else {
            return
        }
        
        try await FirebaseLogin().login(phone: account, password: password)
    }
    
    func update(account: String, password: String) throws{
        let account = account
        guard let password = password.data(using: String.Encoding.utf8) else {return}
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: bundleId]
        let attributes: [String: Any] = [kSecAttrAccount as String: account,
                                         kSecValueData as String: password]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else {return}
        guard status == errSecSuccess else {
            throw LoginError.unknown(key: SecCopyErrorMessageString(status, nil)! as String)
        }
    }
    
    func delete() throws{
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: bundleId]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status != errSecItemNotFound else {return}
        guard status == errSecSuccess else {
            throw LoginError.unknown(key: SecCopyErrorMessageString(status, nil)! as String)
        }
    }
}
