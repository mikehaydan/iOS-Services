//
//  DummyHTTPURLResponse.swift
//  
//
//  Created by Mykhailo Haidan on 03/10/2025.
//

import Foundation

extension HTTPURLResponse {
    static func dummy(
        statusCode: Int = 200,
        url: URL = .dummy
    ) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
