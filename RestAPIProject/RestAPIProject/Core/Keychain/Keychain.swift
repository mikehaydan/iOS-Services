//
//  Keychain.swift
//
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

protocol KeychainRepresentable: Codable {
    var data: Data? { get }
    static var attrServer: String { get }
    static var identifier: String { get }
}

protocol Keychain {
    @discardableResult
    func save<D: KeychainRepresentable>(_ data: D, for identifier: String) -> Bool
    @discardableResult
    func retrieve<D: KeychainRepresentable>(for identifier: String) -> D?
    @discardableResult
    func clear<D: KeychainRepresentable>(_ type: D.Type, for identifier: String) -> Bool
}
