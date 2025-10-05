//
//  CoreDataEngine.swift
//  CoreDataProject
//
//  Created by Mykhailo Haidan on 01/10/2025.
//

import CoreData

final class CoreDataEngine {
    
    // MARK: - Properties
    
    let persistentContainer: PersistentContainer
    
    // MARK: - Lifecycle
    
    init(
        storeName: String,
        useInMemoryStore: Bool = false,
        persistentContainer: PersistentContainer
    ) {
        self.persistentContainer = persistentContainer
        persistentContainer.setupStore(storeName: storeName, inMemory: useInMemoryStore)
    }
    
    // MARK: - Public
    
    func performBackgroundTask(
        _ block:  @escaping (_ context: NSManagedObjectContext) throws -> Void) async throws {
        try await performBackgroundTask(save: false, block)
    }
    
    func performBackgroundTaskAndSave(
        _ block:  @escaping (_ context: NSManagedObjectContext) throws -> Void) async throws {
        try await performBackgroundTask(save: true, block)
    }
    
    func fetch<T: NSFetchRequestResult>(
        request: NSFetchRequest<T>
    ) async throws -> [T] {
        try await persistentContainer.viewContext.perform {
            return try self.persistentContainer.viewContext.fetch(request)
        }
    }
    
    func delete<T: NSManagedObject>(
        request: NSFetchRequest<T>
    ) async throws {
        try await performBackgroundTaskAndSave { context in
            let objects = try context.fetch(request)
            objects.forEach { context.delete($0) }
        }
    }
    
    // MARK: - Private
    
    private func performBackgroundTask(
        save: Bool,
        _ block:  @escaping (_ context: NSManagedObjectContext) throws -> Void) async throws {
        try await persistentContainer.performBackgroundTask { context in
            try block(context)
            
            if save {
                try self.save(context)
            }
        }
    }
    
    private func save(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
