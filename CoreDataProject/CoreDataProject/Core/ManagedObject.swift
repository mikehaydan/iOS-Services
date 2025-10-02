//
//  ManagedObject.swift
//  CoreDataProject
//
//  Created by Mykhailo Haidan on 01/10/2025.
//

import CoreData

protocol ManagedObject: NSFetchRequestResult {
    init(context moc: NSManagedObjectContext)
}
