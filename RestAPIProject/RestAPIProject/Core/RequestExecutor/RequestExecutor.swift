//
//  RequestExecutor.swift
//  
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

protocol RequestExecutor: AnyObject {
    func execute<R: APIRequest>(_ request: R) async throws -> R.Response
}
