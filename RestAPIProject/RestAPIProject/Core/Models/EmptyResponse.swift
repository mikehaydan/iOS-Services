//
//  EmptyResponse.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

/// A protocol for a type representing an empty response. Use `T.emptyValue` to get an instance.
protocol EmptyResponse {
    static func emptyValue() -> Self
}

/// A Decodable type representing an empty response. Use `Empty.value` to get the instance.
struct Empty: Decodable {
    public static let value = Empty()
}

extension Empty: EmptyResponse {
    static func emptyValue() -> Empty {
        value
    }
}
