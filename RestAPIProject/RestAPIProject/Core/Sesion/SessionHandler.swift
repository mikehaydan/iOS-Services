//
//  SessionAdapter.swift
//
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

protocol SessionHandler {
    func save(session: Session) async throws
    func clear() async throws
}

protocol SessionAdapter: APIRequestAdapter {
    func clear() async throws
}
