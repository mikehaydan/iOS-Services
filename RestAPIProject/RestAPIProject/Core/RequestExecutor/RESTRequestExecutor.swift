//
//  RESTRequestExecutor.swift
//
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

final class RESTRequestExecutor: RequestExecutor {
    
    // MARK: - Properties
    
    let apiClient: APIClient
    let requestBuilder: URLRequestBuilder
    let sessionAdapter: SessionAdapter
    
    // MARK: - LifeCycle
    
    init(
        apiClient: APIClient,
        requestBuilder: URLRequestBuilder,
        sessionAdapter: SessionAdapter
    ) {
        self.apiClient = apiClient
        self.requestBuilder = requestBuilder
        self.sessionAdapter = sessionAdapter
    }
    
    // MARK: - Public
    
    func execute<R: APIRequest>(_ request: R) async throws -> R.Response {
        guard var urlRequest = requestBuilder.makeURLRequest(from: request) else {
            throw APIError.invalidRequest
        }
                
        if request.authorizationRequired {
            return try await performAuthenticatedRequest(request, urlRequest: &urlRequest)
        } else {
            return try await apiClient.send(request: urlRequest)
        }
    }
    
    // MARK: - Private
    
    func performAuthenticatedRequest<R: APIRequest>(
        _ request: R,
        urlRequest: inout URLRequest,
    ) async throws -> R.Response {
        try await sessionAdapter.adapt(&urlRequest, apiRequest: request)
        do {
            return try await apiClient.send(request: urlRequest)
        } catch let error as APIError where error == .unAuthorized {
            try await sessionAdapter.adapt(&urlRequest, apiRequest: request)
            return try await apiClient.send(request: urlRequest)
        }
    }
}
