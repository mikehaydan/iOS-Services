//
//  PersistentContainer.swift
//  CoreDataProject
//
//  Created by Mykhailo Haidan on 01/10/2025.
//

import Foundation
import CoreData

protocol PersistentContainer: AnyObject {
    var viewContext: NSManagedObjectContext { get }

    func setupStore(storeName: String, inMemory: Bool)
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async rethrows -> T
}

extension PersistentContainer {
    func setupStore(storeName: String) {
        setupStore(storeName: storeName, inMemory: true)
    }
}

extension NSPersistentContainer: PersistentContainer {
    func setupStore(storeName: String, inMemory: Bool) {
        let storeDescription: NSPersistentStoreDescription

        if inMemory {
            storeDescription = NSPersistentStoreDescription()
            storeDescription.type = NSInMemoryStoreType
        } else {
            let storeURL = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("\(storeName).sqlite")
            storeDescription = NSPersistentStoreDescription(url: storeURL)
            storeDescription.type = NSSQLiteStoreType
        }

        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = true
        persistentStoreDescriptions = [storeDescription]

        loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data store: \(error)")
            } else {
                print("Core Data SQLite store loaded at: \(description.url?.absoluteString ?? "unknown")")
            }
        }

        viewContext.automaticallyMergesChangesFromParent = true
    }
}
