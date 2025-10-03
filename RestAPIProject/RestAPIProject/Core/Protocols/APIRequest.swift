//
//  APIRequest.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

/// Protocol abstracting the request format we use for our API Client
protocol APIRequest: Sendable {

    /// The response type of the request
    associatedtype Response: (Decodable & Sendable)

    /// The HTTP request method
    var method: HTTPMethod { get }

    /// The path subcomponent of the URL
    var path: String { get }

    /// The full URL. If url is not nil, `path` and `queryItems` will be ignored
    var completeUrl: String? { get }

    /// The data sent as the message body of the request
    /// such as for HTTP POST request.
    var body: Data? { get }

    /// content Type of the message body
    var contentType: HTTPHeader? { get }

    /// URL query items such as for HTTP GET request
    var queryItems: [URLQueryItem]? { get }

    /// Extra HTTP Headers specific for the request
    var extraHTTPHeaders: [HTTPHeader]? { get }

    /// Authorization required
    var authorizationRequired: Bool { get }

    /// Timeout Interval option
    /// the default URL session timeoutInterval will be used if this value is empty
    var timeoutInterval: TimeInterval? { get }
}

/// Default implementation for the body, query items and extra HTTP headers
/// since they're not mandatory for all type of requests
extension APIRequest {

    var body: Data? { return nil }

    var contentType: HTTPHeader? { return nil }

    var queryItems: [URLQueryItem]? { return nil }

    var extraHTTPHeaders: [HTTPHeader]? { return nil }

    var authorizationRequired: Bool { return true }

    var timeoutInterval: TimeInterval? { return nil }

    var completeUrl: String? { return nil }
}

extension APIRequest {
    func buildBodyData(from data: Codable) throws -> Data? {
        try? JSONEncoder().encode(data)
    }
}
