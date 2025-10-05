//
//  HTTPMethod.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

enum HTTPMethod: String, Sendable {
    case post = "POST"
    case get = "GET"
    case patch = "PATCH"
    case delete = "DELETE"
    case put = "PUT"
    case head = "HEAD"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
}
