//
//  URLSessionProtocol.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
    func startDataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> TaskCancellable
}

extension URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}

extension URLSession: URLSessionProtocol {
    func startDataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> any TaskCancellable {
        let task = self.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
        
        return task
    }
}

extension URLSessionDataTask: TaskCancellable {
    func cancelTask() {
        cancel()
    }
}
