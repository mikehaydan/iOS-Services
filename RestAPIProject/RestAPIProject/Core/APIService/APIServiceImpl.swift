//
//  APIService.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

final class APIServiceImpl: APIService {
    
    // MARK: - Properties
    
    let requestExecutor: RequestExecutor
    let sessionHandler: SessionHandler
    
    // MARK: - LifeCycle
    
    init(requestExecutor: RequestExecutor, sessionHandler: SessionHandler) {
        self.requestExecutor = requestExecutor
        self.sessionHandler = sessionHandler
    }
    
    // MARK: - Public
    
    func login(userName: String, password: String) async throws -> UserAuthAPIModel {
        let request = PostLogin(username: userName, password: password)
        return try await requestExecutor.execute(request)
    }
    
    func getMe() async throws -> UserAPIModel {
        let request = GetMe()
        return try await requestExecutor.execute(request)
    }
    
    func save(session: Session) async throws {
         try await sessionHandler.save(session: session)
    }
}
