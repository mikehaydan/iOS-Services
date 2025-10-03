//
//  APIRequestAdapter.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

protocol APIRequestAdapter: AnyObject {
    func adapt<R: APIRequest>(_ urlRequest: inout URLRequest, apiRequest: R) async throws
}
