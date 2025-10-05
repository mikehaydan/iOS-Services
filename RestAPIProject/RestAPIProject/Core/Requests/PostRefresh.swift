//
//  PostRefresh.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

struct PostRefresh: APIRequest {
    
    typealias Response = Session
    
    let method: HTTPMethod = .post
    
    let path: String = "/auth/refresh"
    
    var contentType: HTTPHeader? {
        .defaultContentType
    }
    
    var body: Data? {
        try? buildBodyData(from: [
            "refreshToken": refreshToken,
            "expiresInMins": "30"
        ])
    }
    
    let refreshToken: String
    
    init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
