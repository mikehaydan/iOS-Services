//
//  CoreDataService.swift
//  CoreDataProject
//
//  Created by Mykhailo Haidan on 01/10/2025.
//

import Foundation
import CoreData

final class CoreDataService: AnyObject {
    
    // MARK: - Properties
    
    let engine: CoreDataEngine
    
    init(engine: CoreDataEngine) {
        self.engine = engine
    }
    
    // MARK: - Create
    
    func create<MO: ManagedObject>(
        _ type: MO.Type,
        configure: @escaping (MO) -> Void
    ) async throws {
        try await engine.performBackgroundTaskAndSave { context in
            let model = MO(context: context)
            configure(model)
        }
    }
    
    func create<MO: ManagedObject>(
        _ type: MO.Type,
        count: Int,
        configure: @escaping (_ index: Int, _ object: MO) -> Void
    ) async throws {
        try await engine.performBackgroundTaskAndSave { context in
            for i in 0..<count {
                let model = MO(context: context)
                configure(i, model)
            }
        }
    }
    
    // MARK: - Fetch
    
    func fetch<MO: ManagedObject>(
        _ type: MO.Type,
        configure: @escaping ((_ request: NSFetchRequest<MO>) -> Void)
    ) async throws -> [MO] {
        try await _fetch(type, configure: configure)
    }
    
    func fetchAll<MO: ManagedObject>(
        _ type: MO.Type,
    ) async throws -> [MO] {
        try await _fetch(type, configure: nil)
    }
    
    private func _fetch<MO: ManagedObject>(
        _ type: MO.Type,
        configure: ((_ request: NSFetchRequest<MO>) -> Void)?
    ) async throws -> [MO] {
        let fetchRequest = NSFetchRequest<MO>(entityName: String(describing: MO.self))
        configure?(fetchRequest)
        return try await engine.fetch(request: fetchRequest)
    }
    
    // MARK: - Delete
    
    func delete<MO: NSManagedObject>(
        _ type: MO.Type,
        configure: @escaping ((_ request: NSFetchRequest<MO>) -> Void)
    ) async throws {
        try await _delete(type, configure: configure)
    }
    
    func deleteAll<MO: NSManagedObject>(
        _ type: MO.Type,
    ) async throws {
       try await _delete(type, configure: nil)
    }
    
    private func _delete<MO: NSManagedObject>(
        _ type: MO.Type,
        configure: ((_ request: NSFetchRequest<MO>) -> Void)?
    ) async throws {
        let request = NSFetchRequest<MO>(entityName: String(describing: MO.self))
        configure?(request)
        try await engine.delete(request: request)
    }
    
    // MARK: - Update
    
    func updateAll<MO: NSManagedObject>(
        _ type: MO.Type,
        configure: ((_ request: NSFetchRequest<MO>) -> Void)? = nil,
        update: @escaping (MO) -> Void
    ) async throws {
        try await _update(type, configure: nil, update: update)
    }
    
    func update<MO: NSManagedObject>(
        _ type: MO.Type,
        configure: @escaping ((_ request: NSFetchRequest<MO>) -> Void),
        update: @escaping (MO) -> Void
    ) async throws {
        try await _update(type, configure: configure, update: update)
    }
    
    private func _update<MO: NSManagedObject>(
        _ type: MO.Type,
        configure: ((_ request: NSFetchRequest<MO>) -> Void)?,
        update: @escaping (MO) -> Void
    ) async throws {
        try await engine.performBackgroundTaskAndSave { context in
            let request = NSFetchRequest<MO>(entityName: String(describing: MO.self))
            configure?(request)
            
            let objects = try context.fetch(request)
            objects.forEach({ update($0) })
        }
    }
}
