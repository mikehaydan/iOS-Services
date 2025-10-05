//
//  URLRequestBuilder.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

protocol URLRequestBuilder: Sendable {
    func makeURLRequest<R: APIRequest>(from request: R) -> URLRequest?
    static var defaultBuilder: URLRequestBuilder { get }
}

struct URLRequestBuilderImpl: URLRequestBuilder {

    static let defaultBuilder: any URLRequestBuilder = {
        URLRequestBuilderImpl(baseURL: URL(string: "https://dummyjson.com")!)
    }()

    let baseURL: URL

    func makeURLRequest<R: APIRequest>(
        from request: R
    ) -> URLRequest? {
        var requestURL: URL
        if let urlString = request.completeUrl {
            guard let apiUrl = URL(string: urlString) else {
                return nil
            }
            requestURL = apiUrl
        } else {
            var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
            urlComponents?.path = request.path
            urlComponents?.queryItems = request.queryItems

            guard let apiUrl = urlComponents?.url else {
                return nil
            }
            requestURL = apiUrl
        }

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.method = request.method

        if let body = request.body {
            urlRequest.httpBody = body
        }

        if let contentType = request.contentType {
            urlRequest.addHTTPHeader(contentType)
        }

        if let extraHeaders = request.extraHTTPHeaders {
            urlRequest.headers = extraHeaders
        }

        if let timeout = request.timeoutInterval {
            urlRequest.timeoutInterval = timeout
        }

        return urlRequest
    }
}
