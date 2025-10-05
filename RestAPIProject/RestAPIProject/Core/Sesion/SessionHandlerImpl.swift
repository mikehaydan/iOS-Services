//
//  SessionHandlerImpl.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

actor SessionHandlerImpl: SessionAdapter, SessionHandler {

    // MARK: - Properties

    let apiClient: APIClient
    let requestBuilder: URLRequestBuilder
    let keychain: Keychain

    private var refreshTask: Task<Session, Error>?

    // MARK: - LifeCycle

    init(
        apiClient: APIClient,
        requestBuilder: URLRequestBuilder,
        keychain: Keychain
    ) {
        self.apiClient = apiClient
        self.requestBuilder = requestBuilder
        self.keychain = keychain
    }

    // MARK: - Public

    func refresh(session: Session) async throws -> Session {
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }

        let task = Task<Session, Error> {
            defer {
                refreshTask = nil
            }
            let request = PostRefresh(refreshToken: session.refreshToken)
            guard let urlRequest = requestBuilder.makeURLRequest(from: request) else {
                throw APIError.invalidRequest
            }
            let refreshedSession: Session = try await apiClient.send(request: urlRequest)
            self.keychain.save(refreshedSession, for: Session.identifier)

            return refreshedSession
        }

        self.refreshTask = task

        return try await task.value
    }

    func save(session: Session) async throws {
        keychain.save(session, for: Session.identifier)
    }

    func clear() async throws {
        keychain.clear(Session.self, for: Session.identifier)
    }

    func adapt<R: APIRequest>(_ urlRequest: inout URLRequest, apiRequest: R) async throws {
        let session: Session? = keychain.retrieve(for: Session.identifier)

        guard let session else {
            throw APIError.unAuthorized
        }

        if session.expiresAt > Date() {
            urlRequest.addHTTPHeader(.authorization(bearerToken: session.accessToken))
        } else {
            let session = try await refresh(session: session)
            urlRequest.addHTTPHeader(.authorization(bearerToken: session.accessToken))
        }
    }
}
