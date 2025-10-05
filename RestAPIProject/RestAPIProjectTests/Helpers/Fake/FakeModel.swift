//
//  FakeModel.swift
//  
//
//  Created by Mykhailo Haidan on 03/10/2025.
//

import Foundation

struct FakeModel: Codable, Equatable {
    var field: String = "testing"
    var secondField: Int = 1

    var data: Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(self)
    }
}
