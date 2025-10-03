//
//  APIError.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

enum APIError: Error, Equatable, Sendable {
    case requestError(description: String)
    case invalidResponse
    case invalidRequest
    case unacceptableStatusCode(code: Int)
    case responseDataNilOrZeroLength
    case invalidEmptyResponse(type: String)
    case decodingFailed(description: String)
    case unAuthorized
    case notFound
}

extension APIError {
    init(urlError: URLError) {
        switch urlError.code {
        case .timedOut:
            self = .requestError(description: urlError.localizedDescription)
        case .cannotFindHost:
            self = .requestError(description: urlError.localizedDescription)
        case .cannotConnectToHost:
            self = .requestError(description: urlError.localizedDescription)
        case .notConnectedToInternet:
            self = .requestError(description: urlError.localizedDescription)
        case .networkConnectionLost:
            self = .requestError(description: urlError.localizedDescription)
        case .unsupportedURL, .badURL:
            self = .invalidRequest
        case .badServerResponse:
            self = .invalidResponse
        default:
            self = .requestError(description: urlError.localizedDescription)
        }
    }
}
