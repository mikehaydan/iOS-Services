//
//  UserModel+CoreDataClass.swift
//  CoreDataProject
//
//  Created by Mykhailo Haidan on 01/10/2025.
//
//

import Foundation
import CoreData

@objc(UserModel)
public class UserModel: NSManagedObject, ManagedObject {

    var user: User {
        get {
            User(name: name, surname: surname)
        } set {
            name = newValue.name
            surname = newValue.surname
        }
    }
}
