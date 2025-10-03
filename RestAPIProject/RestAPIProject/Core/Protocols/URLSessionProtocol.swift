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

//
//protocol URLSessionProtocol: Sendable {
//    @discardableResult
//    func startDataTask(
//        with url: URL,
//        completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void
//    ) -> TaskCancellable
//
//    @discardableResult
//    func startDataTask(
//        with urlRequest: URLRequest,
//        completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void
//    ) -> TaskCancellable
//
//    func startDataTask(
//        with urlRequest: URLRequest
//    ) async -> URLSessionDataTaskResponse
//
//    func download(
//        from url: URL,
//        delegate: (URLSessionTaskDelegate)?
//    ) async throws -> (URL, URLResponse)
//}
//
//extension URLSession: URLSessionProtocol {
//    @discardableResult
//    func startDataTask(
//        with url: URL,
//        completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void
//    ) -> TaskCancellable {
//        let task = dataTask(with: url, completionHandler: completionHandler)
//        task.resume()
//        return task
//    }
//
//    @discardableResult
//    func startDataTask(
//        with urlRequest: URLRequest,
//        completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void
//    ) -> TaskCancellable {
//        let task = dataTask(with: urlRequest, completionHandler: completionHandler)
//        task.resume()
//        return task
//    }
//
//    func startDataTask(with urlRequest: URLRequest) async -> URLSessionDataTaskResponse {
//        do {
//            let response = try await data(for: urlRequest)
//            return URLSessionDataTaskResponse(
//                data: response.0,
//                response: response.1,
//                error: nil
//            )
//        } catch {
//            return URLSessionDataTaskResponse(
//                data: nil,
//                response: nil,
//                error: error
//            )
//        }
//    }
//}
//
extension URLSessionDataTask: TaskCancellable {
    func cancelTask() {
        cancel()
    }
}
