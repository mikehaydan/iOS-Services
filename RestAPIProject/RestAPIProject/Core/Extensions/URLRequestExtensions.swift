//
//  URLRequestExtensions.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

// MARK: - URLRequest Initializers
extension URLRequest {
    /// Create URLRequest from URL string.
    ///
    /// - Parameter urlString: URL string to initialize URL request from
    init?(urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        self.init(url: url)
    }
}

// MARK: - URLRequest Methods
extension URLRequest {
    /// Add a `HTTPHeader` to the header field.
    mutating func addHTTPHeader(_ header: HTTPHeader) {
        addValue(header.value, forHTTPHeaderField: header.field)
    }
}

// MARK: - URLRequest Properties
extension URLRequest {
    /// Returns `allHTTPHeaderFields` as an `HTTPHeader` array.
    var headers: [HTTPHeader] {
        get {
            return allHTTPHeaderFields?.map { HTTPHeader(field: $0.key, value: $0.value) } ?? []
        }
        set {
            let fieldAndValues = newValue.map { ($0.field, $0.value) }
            allHTTPHeaderFields = Dictionary(fieldAndValues, uniquingKeysWith: { (_, last) in last })
        }
    }

    /// Returns the `httpMethod` as the internal `HTTPMethod` enum.
    var method: HTTPMethod? {
        get { return httpMethod.flatMap(HTTPMethod.init) }
        set { httpMethod = newValue?.rawValue }
    }

    /// Returns a cURL command representation of the URLRequest for easy debugging.
    var cURLString: String {
        #if DEBUG
        var result = "curl -k "

        if let method = httpMethod {
            result += "-X \(method) "
        }

        if let headerFields = allHTTPHeaderFields {
            for (field, value) in headerFields {
                result += "-H \"\(field): \(value)\" "
            }
        }

        if let body = httpBody, !body.isEmpty {
            let string = String(decoding: body, as: UTF8.self)
            if !string.isEmpty {
                result += "-d '\(string)' "
            }
        }

        if let url = url {
            result += url.absoluteString
        }

        return result
        #else
        return ""
        #endif
    }
}

extension URLSessionConfiguration {
    /// Returns `httpAdditionalHeaders` as an `HTTPHeader` array.
    var headers: [HTTPHeader] {
        get {
            return (httpAdditionalHeaders as? [String: String])?.map { HTTPHeader(field: $0.key, value: $0.value) } ?? []
        }
        set {
            let fieldAndValues = newValue.map { ($0.field, $0.value) }
            httpAdditionalHeaders = Dictionary(fieldAndValues, uniquingKeysWith: { (_, last) in last })
        }
    }
}
