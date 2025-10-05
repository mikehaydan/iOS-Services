//
//  Session.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

struct Session: Codable, Equatable {

    private enum CodingKeys: CodingKey {
        case accessToken
        case refreshToken
        case expiresAt
    }

    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    init(accessToken: String, refreshToken: String, expiresAt: Date = Date().addingTimeInterval(30)) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }

    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<Session.CodingKeys> = try decoder.container(keyedBy: Session.CodingKeys.self)

        self.accessToken = try container.decode(String.self, forKey: Session.CodingKeys.accessToken)
        self.refreshToken = try container.decode(String.self, forKey: Session.CodingKeys.refreshToken)
        self.expiresAt = (try? container.decode(Date.self, forKey: Session.CodingKeys.expiresAt)) ?? Date().addingTimeInterval(30)

    }

    func encode(to encoder: any Encoder) throws {
        var container: KeyedEncodingContainer<Session.CodingKeys> = encoder.container(keyedBy: Session.CodingKeys.self)

        try container.encode(self.accessToken, forKey: Session.CodingKeys.accessToken)
        try container.encode(self.refreshToken, forKey: Session.CodingKeys.refreshToken)
        try container.encode(self.expiresAt, forKey: Session.CodingKeys.expiresAt)
    }
}

extension Session: KeychainRepresentable {
    static let attrServer = "accounts.tokenauth.com"
    static let identifier = "tokenId"

    var data: Data? {
        try? JSONEncoder().encode(self)
    }
}
