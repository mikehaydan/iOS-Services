//
//  APIClientSpy.swift
//  
//
//  Created by Mykhailo Haidan on 05/10/2025.
//

import Foundation
@testable import RestAPIProject

final class APIClientSpy: APIClient {
    
    var sendAsyncRequestCalledCount = 0
    var sendAsyncErrorToBeReturned: Error?
    var sendAsyncResponseToBeReturned: Decodable!
    var delay: UInt64?
    func send<T: Decodable>(request: URLRequest) async throws -> T {
        sendAsyncRequestCalledCount += 1
        if let delay = delay {
            try await Task.sleep(nanoseconds: delay)
        }
        if let errorToBeReturned = sendAsyncErrorToBeReturned {
            throw errorToBeReturned
        }
        return sendAsyncResponseToBeReturned as! T
    }
    
    var sendViaCompletionCalledCount = 0
    var sendViaCompletionTaskToBeReturned: TaskCancellable?
    var sendViaCompletionResult: Result<Decodable, APIError>!
    func send<T: Decodable>(
        _ request: URLRequest,
        taskCreated: ((TaskCancellable?) -> Void)?,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        sendViaCompletionCalledCount += 1
        if let sendViaCompletionTaskToBeReturned = sendViaCompletionTaskToBeReturned {
            taskCreated?(sendViaCompletionTaskToBeReturned)
        }
        
        switch sendViaCompletionResult {
        case .success(let response):
            completion(.success(response as! T))
        case .failure(let error):
            completion(.failure(error))
        case .none:
            fatalError("Should not be called")
        }
    }
}
