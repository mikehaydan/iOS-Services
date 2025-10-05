//
//  KeychainSpy.swift
//  
//
//  Created by Mykhailo Haidan on 05/10/2025.
//

import Foundation
@testable import RestAPIProject

final class KeychainSpy: Keychain {
    
    var saveToBeReturned = true
    var saveCallCount = 0
    @discardableResult
    func save<D: KeychainRepresentable>(_ data: D, for identifier: String) -> Bool {
        saveCallCount += 1
        return saveToBeReturned
    }
    
    var retrieveToBeReturned: KeychainRepresentable!
    var retrieveCallCount = 0
    @discardableResult
    func retrieve<D: KeychainRepresentable>(for identifier: String) -> D? {
        retrieveCallCount += 1
        return retrieveToBeReturned as? D
    }
    
    var clearToBeReturned = true
    var clearCallCount = 0
    @discardableResult
    func clear<D: KeychainRepresentable>(_ type: D.Type, for identifier: String) -> Bool {
        clearCallCount += 1
        return clearToBeReturned
    }
}
