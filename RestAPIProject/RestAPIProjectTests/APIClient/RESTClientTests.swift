//
//  RESTClientTests.swift
//  
//
//  Created by Mykhailo Haidan on 03/10/2025.
//

@testable import RestAPIProject
import Testing
import Foundation

struct RESTClientTests {
    
    // MARK: - Properties
    
    var sut: RESTClient!
    var session: URLSessionSpy!

    // MARK: - Lifecycle
    
    init() {
        session = .init()
        sut = RESTClient(session: session)
    }
    
    // MARK: - Tests
    
    @Test("Testing send request failure. Error returned")
    func sendRequestFailureWithError() async throws {
        // Given
        let errorToBeReturned = APIError.invalidRequest
        session.dataForRequestErrorToBeReturned = errorToBeReturned
        
        do {
            // When
            let _: FakeModel = try await sut.send(request: .dummy)
        } catch let error as APIError {
            // Then
            #expect(error == .invalidRequest)
        } catch {
            Issue.record("Incorrect error returned")
        }
    }
    
    @Test("Testing send request failure. Invalid response")
    func sendRequestFailureWithInvalidResponse() async throws {
        // Given
        session.dataForRequestResponseToBeReturned = (Data(), URLResponse())
        
        do {
            // When
            let _: FakeModel = try await sut.send(request: .dummy)
        } catch let error as APIError {
            // Then
            #expect(error == .invalidResponse)
        } catch {
            Issue.record("Incorrect error returned")
        }
    }
    
    @Test("Testing send request failure. Incorrect status code")
    func sendRequestFailureWithIncorrectStatusCode() async throws {
        // Given
        let httpResponse = HTTPURLResponse.dummy(statusCode: 400)
        session.dataForRequestResponseToBeReturned = (Data(), httpResponse)
        
        do {
            // When
            let _: FakeModel = try await sut.send(request: .dummy)
        } catch let error as APIError {
            // Then
            #expect(error == .unacceptableStatusCode(code: 400))
        } catch {
            Issue.record("Incorrect error returned")
        }
    }
    
    @Test("Testing send request failure. Unauthorized status code")
    func sendRequestFailureWithUnauthorizedStatusCode() async throws {
        // Given
        let httpResponse = HTTPURLResponse.dummy(statusCode: 401)
        session.dataForRequestResponseToBeReturned = (Data(), httpResponse)
        
        do {
            // When
            let _: FakeModel = try await sut.send(request: .dummy)
        } catch let error as APIError {
            // Then
            #expect(error == .unAuthorized)
        } catch {
            Issue.record("Incorrect error returned")
        }
    }
    
    @Test("Testing send request failure. Decoding Failed")
    func sendRequestFailureWithFailedDecoding() async throws {
        // Given
        session.dataForRequestResponseToBeReturned = (Data(), HTTPURLResponse.dummy())
        
        do {
            // When
            let _: FakeModel = try await sut.send(request: .dummy)
        } catch let error as APIError {
            // Then
            #expect(error == APIError.decodingFailed(description: "The data couldn’t be read because it isn’t in the correct format."))
        } catch {
            Issue.record("Incorrect error returned")
        }
    }
    
    @Test("Testing send request success")
    func sendRequestSuccess() async throws {
        // Given
        let modelToBeReturned = FakeModel(field: "tessst", secondField: 22)
        session.dataForRequestResponseToBeReturned = (modelToBeReturned.data, HTTPURLResponse.dummy())
        
        do {
            // When
            let model: FakeModel = try await sut.send(request: .dummy)
            
            // Then
            #expect(model == modelToBeReturned)
        } catch {
            Issue.record("Error should not be returned")
        }
    }
}
