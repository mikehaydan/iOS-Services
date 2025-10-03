//
//  EnvironmentConfiguration.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

struct EnvironmentConfiguration: Sendable {

    let baseURL: URL

    let urlSessionConfiguration: URLSessionConfiguration

    init(baseURL: URL, urlSessionConfiguration: URLSessionConfiguration = .default) {
        self.baseURL = baseURL
        self.urlSessionConfiguration = urlSessionConfiguration
    }
}
