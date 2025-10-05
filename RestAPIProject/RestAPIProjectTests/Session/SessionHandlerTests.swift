//
//  SessionHandlerTests.swift
//  
//
//  Created by Mykhailo Haidan on 05/10/2025.
//

import Foundation
import Testing
@testable import RestAPIProject

@Suite("SessionHandler tests")
struct SessionHandlerTests {
    
    // MARK: - Properties
    
    var sut: SessionHandlerImpl!
    
    var keychain: KeychainSpy!
    var apiClient: APIClientSpy!
    var requestBuilder: URLRequestBuilderSpy!

    // MARK: - Lifecycle
    
    init() {
        apiClient = .init()
        keychain = .init()
        requestBuilder = .init()
        sut = SessionHandlerImpl(apiClient: apiClient, requestBuilder: requestBuilder, keychain: keychain)
    }
    
    // MARK: - Tests
    
    @Test("Testing save session")
    func testSaveSession() async throws {
        // Given
        let session = Session(accessToken: "at", refreshToken: "rt")
        
        // When
        try await sut.save(session: session)
        
        // Then
        #expect(keychain.saveCallCount == 1)
    }
    
    @Test("Testing clear session")
    func testClearSession() async throws {
        // When
        try await sut.clear()
        
        // Then
        #expect(keychain.clearCallCount == 1)
    }
    
    @Test("Testing refresh session with invalid request")
    func testRefreshSessionInvalidRequest() async throws {
        // Given
        let session = Session(accessToken: "at", refreshToken: "rt")
        
        do {
            // When
            let _ = try await sut.refresh(session: session)
        } catch let error as APIError {
            // Then
            #expect(error == .invalidRequest)
            #expect(requestBuilder.makeURLRequestCallCount == 1)
            #expect(keychain.saveCallCount == 0)
        } catch {
            Issue.record("API error should be returned")
        }
    }
    
    @Test("Testing refresh session with API client error")
    func testRefreshSessionAPIClientError() async throws {
        // Given
        let session = Session(accessToken: "at", refreshToken: "rt")
        requestBuilder.makeURLRequestToBeReturned = .dummy
        apiClient.sendAsyncErrorToBeReturned = APIError.notFound
        
        do {
            // When
            let _ = try await sut.refresh(session: session)
        } catch let error as APIError {
            // Then
            #expect(error == .notFound)
            #expect(keychain.saveCallCount == 0)
            #expect(requestBuilder.makeURLRequestCallCount == 1)
        } catch {
            Issue.record("API error should be returned")
        }
    }
    
    @Test("Testing success session refresh")
    func testRefreshSessionSuccess() async throws {
        // Given
        let oldSession = Session(accessToken: "at", refreshToken: "rt")
        let newSession = Session(accessToken: "at2", refreshToken: "rt2", expiresAt: Date().addingTimeInterval(360))
        requestBuilder.makeURLRequestToBeReturned = .dummy
        apiClient.sendAsyncResponseToBeReturned = newSession
        
        do {
            // When
            let session = try await sut.refresh(session: oldSession)
            
            // Then
            #expect(requestBuilder.makeURLRequestCallCount == 1)
            #expect(session == newSession)
            #expect(keychain.saveCallCount == 1)
        } catch {
            Issue.record("Error should not be returned")
        }
    }
    
    @Test("Testing success session refresh with concurrent calls")
    func testRefreshSessionWithConcurrentCall() async throws {
        // Given
        let oldSession = Session(accessToken: "at", refreshToken: "rt")
        let newSession = Session(accessToken: "at2", refreshToken: "rt2", expiresAt: Date().addingTimeInterval(360))
        requestBuilder.makeURLRequestToBeReturned = .dummy
        apiClient.sendAsyncResponseToBeReturned = newSession
        apiClient.delay = 1_000_000_000
        
        do {
            // When
            let sessions = try await withThrowingTaskGroup(of: Session.self, returning: [Session].self) { group in
                for _ in 0..<15 {
                    group.addTask(operation: {
                        // When
                        try await sut.refresh(session: oldSession)
                    })
                }
                
                var sessions: [Session] = []
                for try await session in group {
                    sessions.append(session)
                }
                
                return sessions
            }
            
            // Then
            #expect(requestBuilder.makeURLRequestCallCount == 1)
            #expect(keychain.saveCallCount == 1)
            #expect(sessions.allSatisfy { $0 == newSession } )
        } catch {
            Issue.record("Error should not be returned")
        }
    }
    
    @Test("Testing adapt when no session is present")
    func testAdaptWhenNoSessionIsPresent() async throws {
        // Given
        keychain.retrieveToBeReturned = nil
        let apiRequest = FakePostRequest()
        var request = URLRequest.dummy
        
        // Then
        do {
            _ = try await sut.adapt(&request, apiRequest: apiRequest)
        } catch let error as APIError {
            #expect(keychain.retrieveCallCount == 1)
            #expect(error == .unAuthorized)
        } catch {
            Issue.record("API error should be returned")
        }
    }
    
    @Test("Testing adapt when session has expired")
    func testAdaptWithExpiredSession() async throws {
        // Given
        let session = Session(accessToken: "at", refreshToken: "rt", expiresAt: Date().addingTimeInterval(-1))
        let apiRequest = FakePostRequest()
        var request = URLRequest.dummy
        
        keychain.retrieveToBeReturned = session
        requestBuilder.makeURLRequestToBeReturned = .dummy
        apiClient.sendAsyncResponseToBeReturned = Session(accessToken: "at2", refreshToken: "rt2", expiresAt: Date().addingTimeInterval(20))
        
        do {
            // When
            try await sut.adapt(&request, apiRequest: apiRequest)
            
            // Then
            #expect(apiClient.sendAsyncRequestCalledCount == 1)
            #expect(requestBuilder.makeURLRequestCallCount == 1)
            #expect(keychain.saveCallCount == 1)
            #expect(keychain.retrieveCallCount == 1)
            #expect(request.headers.contains(.authorization(bearerToken: "at2")))
        } catch {
            Issue.record("API error should be returned")
        }
    }
    
    @Test("Testing adapt with not expired session")
    func testAdaptWithNotExpiredSession() async throws {
        // Given
        let session = Session(accessToken: "at", refreshToken: "rt", expiresAt: Date().addingTimeInterval(20))
        let apiRequest = FakePostRequest()
        var request = URLRequest.dummy
        
        keychain.retrieveToBeReturned = session
        requestBuilder.makeURLRequestToBeReturned = .dummy
        
        do {
            // When
            try await sut.adapt(&request, apiRequest: apiRequest)
            
            // Then
            #expect(apiClient.sendAsyncRequestCalledCount == 0)
            #expect(requestBuilder.makeURLRequestCallCount == 0)
            #expect(keychain.saveCallCount == 0)
            #expect(keychain.retrieveCallCount == 1)
            #expect(request.headers.contains(.authorization(bearerToken: "at")))
        } catch {
            Issue.record("API error should be returned")
        }
    }
}

