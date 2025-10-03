//
//  RESTClient.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

final class RESTClient: APIClient {
    
    // MARK: - Properties
    
    let session: URLSessionProtocol
    let decoder: JSONDecoder

    private let acceptableStatusCodes: Range<Int> = {
        200..<300
    }()
    
    private let unAuthorizedStatusCodes = 401
    
    // MARK: - LifeCycle
    
    init(
        session: URLSessionProtocol,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }
    
    // MARK: - Public
    
    func send<T: Decodable>(request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            return try process(response: response, data: data)
        } catch let urlError as URLError {
            throw APIError(urlError: urlError)
        } catch {
            throw error
        }
    }
    
    func send<T: Decodable>(
        _ request: URLRequest,
        taskCreated: ((TaskCancellable?) -> Void)?,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        let task = session.startDataTask(with: request) { data, response, error in
            taskCreated?(nil)
            
            if let error = error as? URLError {
                completion(.failure(.init(urlError: error)))
                return
            }
            
            guard let response = response else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.responseDataNilOrZeroLength))
                return
            }
            
            do {
                let decoded: T = try self.process(response: response, data: data)
                completion(.success(decoded))
            } catch let apiError as APIError {
                completion(.failure(apiError))
            } catch {
                completion(.failure(APIError.decodingFailed(description: "")))
            }
        }
        taskCreated?(task)
    }
    
    // MARK: - Private
    
    private func process<T: Decodable>(response: URLResponse, data: Data) throws -> T {
        guard let urlResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard acceptableStatusCodes.contains(urlResponse.statusCode) else {
            if urlResponse.statusCode == unAuthorizedStatusCodes {
                throw APIError.unAuthorized
            }
            throw APIError.unacceptableStatusCode(code: urlResponse.statusCode)
        }
        
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw APIError.decodingFailed(description: error.localizedDescription)
        }
    }
}
