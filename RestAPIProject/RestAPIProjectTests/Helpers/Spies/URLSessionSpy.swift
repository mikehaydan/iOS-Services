//
//  URLSessionSpy.swift
//  
//
//  Created by Mykhailo Haidan on 03/10/2025.
//

import Foundation
@testable import RestAPIProject

final class URLSessionSpy: URLSessionProtocol {
    
    var dataForRequestCalledCount = 0
    var dataForRequestErrorToBeReturned: Error?
    var dataForRequestResponseToBeReturned: (Data, URLResponse)!
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        dataForRequestCalledCount += 1
        if let dataForRequestErrorToBeReturned = dataForRequestErrorToBeReturned {
            throw dataForRequestErrorToBeReturned
        }
        return dataForRequestResponseToBeReturned
    }
    
    
    var startDataTaskCallCount = 0
    var response: (Data?, URLResponse?, (any Error)?)?
    var taskCancellableToBeReturned: TaskCancellable!
    func startDataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> TaskCancellable {
        startDataTaskCallCount += 1
        if let response = response {
            completionHandler(response.0, response.1, response.2)
        }
        
        return taskCancellableToBeReturned
    }
    
    
}
