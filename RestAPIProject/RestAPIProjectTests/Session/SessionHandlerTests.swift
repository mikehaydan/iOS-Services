//
//  SessionHandlerTests.swift
//  
//
//  Created by Mykhailo Haidan on 05/10/2025.
//

import Foundation
import Testing
@testable import RestAPIProject

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
            async let result1 = sut.refresh(session: oldSession)
            async let result2 = sut.refresh(session: oldSession)
            async let result3 = sut.refresh(session: oldSession)
            async let result4 = sut.refresh(session: oldSession)
            
            let sessions = try await (result1, result2, result3, result4)
            
            // Then
            #expect(requestBuilder.makeURLRequestCallCount == 1)
            #expect(keychain.saveCallCount == 1)
            
            #expect(sessions.0 == newSession)
            #expect(sessions.1 == newSession)
            #expect(sessions.2 == newSession)
            #expect(sessions.3 == newSession)
        } catch {
            Issue.record("Error should not be returned")
        }
    }
}

