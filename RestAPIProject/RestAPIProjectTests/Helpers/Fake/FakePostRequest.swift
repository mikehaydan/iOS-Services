//
//  FakePostRequest.swift
//  
//
//  Created by Mykhailo Haidan on 05/10/2025.
//

import Foundation
@testable import RestAPIProject

struct FakePostRequest: APIRequest {
    
    typealias Response = FakeModel
    
    let method: HTTPMethod = .post
    
    let path: String = "/fake/t1"
    
    var contentType: HTTPHeader? {
        .defaultContentType
    }
    
    var body: Data? {
        try? buildBodyData(from: [
            "field": "field"
        ])
    }
}


