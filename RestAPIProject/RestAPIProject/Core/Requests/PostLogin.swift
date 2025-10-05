//
//  PostLogin.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

struct PostLogin: APIRequest {
    typealias Response = UserAuthAPIModel

    let method: HTTPMethod = .post

    let path: String = "/auth/login"

    let authorizationRequired = false

    var body: Data? {
        try? buildBodyData(from: [
            "username": username,
            "password": password,
            "expiresInMins": "1"
        ])
    }

    var contentType: HTTPHeader? {
        .defaultContentType
    }

    let username: String
    let password: String

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
