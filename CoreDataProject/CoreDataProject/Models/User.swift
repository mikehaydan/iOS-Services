//
//  User.swift
//  CoreDataProject
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import Foundation

struct User: Identifiable {
    let id = UUID()
    let name: String
    let surname: String
}
