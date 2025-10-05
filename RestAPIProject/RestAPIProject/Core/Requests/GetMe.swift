//
//  GetMe.swift
//  
//
//  Created by Mykhailo Haidan on 03/10/2025.
//

import Foundation

struct GetMe: APIRequest {
    typealias Response = UserAPIModel
    
    let method: HTTPMethod = .get
    
    let path: String = "/auth/me"
    
    var contentType: HTTPHeader? {
        .defaultContentType
    }
}
