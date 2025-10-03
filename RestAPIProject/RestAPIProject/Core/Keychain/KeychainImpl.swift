//
//  KeychainImpl.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

final class KeychainImpl: Keychain {
    
    // MARK: - Properties
    
    private let lock = NSLock()
    
    // MARK: - Public
    
    @discardableResult
    func save<D: KeychainRepresentable>(_ data: D, for identifier: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        guard let data = data.data else { return false }
        var query = [
            kSecClass as String: kSecClassInternetPassword as String,
            kSecAttrServer as String: D.attrServer,
            kSecAttrAccount as String: identifier
        ] as [String: Any]
        let newAttributes = [kSecValueData as String: data] as [String: Any]

        let deleteStatus = SecItemDelete(query as CFDictionary)

        if deleteStatus == noErr || deleteStatus == errSecItemNotFound {
            query.merge(newAttributes) { $1 }
            return SecItemAdd(query as CFDictionary, nil) == noErr
        }

        return false
    }
    
    @discardableResult
    func retrieve<D: KeychainRepresentable>(for identifier: String) -> D? {
        lock.lock()
        defer { lock.unlock() }
        
        let query = [
            kSecClass as String: kSecClassInternetPassword as String,
            kSecAttrServer as String: D.attrServer,
            kSecAttrAccount as String: identifier,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ] as [String: Any]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard
            status == noErr,
            let dict = result as? [String: Any],
            let data = dict[String(kSecValueData)] as? Data
        else {
            return nil
        }

        guard let credential = try? JSONDecoder().decode(D.self, from: data) else { return nil }

        return credential
    }
    
    @discardableResult
    func clear<D: KeychainRepresentable>(_ type: D.Type, for identifier: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        let query = [
            kSecClass as String: kSecClassInternetPassword as String,
            kSecAttrServer as String: D.attrServer,
            kSecAttrAccount as String: identifier
        ] as [String: Any]

        let deleteStatus = SecItemDelete(query as CFDictionary)
        guard deleteStatus == errSecSuccess || deleteStatus == errSecItemNotFound else { return false }

        return true
    }
}
