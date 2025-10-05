//
//  UserAuthAPIModel.swift
//
//
//  Created by Mykhailo Haidan on 03/10/2025.
//

import Foundation

struct UserAuthAPIModel: Codable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: String
    let image: String
    let accessToken: String
    let refreshToken: String
}
