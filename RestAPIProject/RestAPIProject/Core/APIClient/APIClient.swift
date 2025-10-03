//
//  APIClient.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

protocol APIClient: AnyObject {
    func send<T: Decodable>(request: URLRequest) async throws -> T
    func send<T: Decodable>(
        _ request: URLRequest,
        taskCreated: ((TaskCancellable?) -> Void)?,
        completion: @escaping (Result<T, APIError>) -> Void
    )
}
