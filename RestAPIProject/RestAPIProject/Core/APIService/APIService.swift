//
//  APIService.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

protocol APIService: AnyObject {
    func login(userName: String, password: String) async throws -> UserAuthAPIModel
    func getMe() async throws -> UserAPIModel
    func save(session: Session) async throws
}
