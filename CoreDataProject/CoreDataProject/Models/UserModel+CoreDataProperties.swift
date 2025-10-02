//
//  UserModel+CoreDataProperties.swift
//  CoreDataProject
//
//  Created by Mykhailo Haidan on 01/10/2025.
//
//

import Foundation
import CoreData

extension UserModel {
    class func fetchRequest() -> NSFetchRequest<UserModel> {
        return NSFetchRequest<UserModel>(entityName: String(describing: UserModel.self))
    }

    @NSManaged public var name: String
    @NSManaged public var surname: String

}

extension UserModel: Identifiable {

}
