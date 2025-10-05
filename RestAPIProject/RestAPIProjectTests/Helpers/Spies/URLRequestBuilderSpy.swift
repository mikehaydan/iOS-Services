//
//  URLRequestBuilderSpy.swift
//  
//
//  Created by Mykhailo Haidan on 05/10/2025.
//

import Foundation
@testable import RestAPIProject

final class URLRequestBuilderSpy: URLRequestBuilder, @unchecked Sendable {

    var makeURLRequestToBeReturned: URLRequest?
    var makeURLRequestCallCount = 0
    func makeURLRequest<R: APIRequest>(from request: R) -> URLRequest? {
        makeURLRequestCallCount += 1
        return makeURLRequestToBeReturned
    }

    static var defaultBuilder: URLRequestBuilder {
        URLRequestBuilderSpy()
    }
}
