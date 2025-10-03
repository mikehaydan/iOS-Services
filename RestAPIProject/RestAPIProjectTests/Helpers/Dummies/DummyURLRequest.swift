//
//  DummyURLRequest.swift
//  
//
//  Created by Mykhailo Haidan on 03/10/2025.
//

import Foundation

extension URLRequest {
    static var dummy: URLRequest {
        URLRequest(url: URL(string: "https://example.com")!)
    }
}
