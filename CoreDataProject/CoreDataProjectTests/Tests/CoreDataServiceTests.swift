//
//  CoreDataServiceTests.swift
//  CoreDataProjectTests
//
//  Created by Mykhailo Haidan on 02/10/2025.
//

import CoreData
import Testing
@testable import CoreDataProject

struct CoreDataServiceTests {
    
    // MARK: - Properties
    
    var sut: CoreDataService!
    
    // MARK: - Lifecycle
    
    init() {
        let container = NSPersistentContainer(name: "CoreDataModel")
        let engine = CoreDataEngine(
            storeName: "test_store",
            useInMemoryStore: true,
            persistentContainer: container
        )
        sut = CoreDataService(engine: engine)
    }
    
    // MARK: - Tests
    
    // MARK: - Create
    
    @Test("Test single object creation")
    func objectCreations() async throws {
        // When
        try await sut.create(UserModel.self) { object in
            object.name = "Name"
            object.surname = "Surname"
        }
    }
    
    @Test("Test multiple objects creation")
    func multipleObjectCreations() async throws {
        // Given
        var numberOFCalls = 0
        
        // When
        try await sut.create(UserModel.self, count: 3) { _, object in
            object.name = "Name"
            object.surname = "Surname"
            numberOFCalls += 1
        }
        
        // Then
        #expect(numberOFCalls == 3)
    }
    
    // MARK: - Fetch
    
    @Test("Test fetching all objects")
    func fetchingAllObjects() async throws {
        // Given
        try await sut.create(UserModel.self) { object in
            object.name = "Name1"
            object.surname = "Surname1"
        }
        try await sut.create(UserModel.self) { object in
            object.name = "Name2"
            object.surname = "Surname2"
        }
        
        // When
        let count = try await sut.fetchAll(UserModel.self).count
        
        // Then
        #expect(count == 2)
    }
    
    @Test("Test fetching an object by predicate")
    func fetchingSingleObjectByPredicate() async throws {
        // Given
        try await sut.create(UserModel.self) { object in
            object.name = "Name1"
            object.surname = "Surname1"
        }
        try await sut.create(UserModel.self) { object in
            object.name = "Name2"
            object.surname = "Surname2"
        }
        
        // When
        let models = try await sut.fetch(UserModel.self) { request in
            request.predicate = NSPredicate(format: "name == 'Name2'")
        }
        
        // Then
        #expect(models.count == 1)
        #expect(models[0].name == "Name2")
        #expect(models[0].surname == "Surname2")
    }
    
    // MARK: - Delete
    
    @Test("Test all objects deletion")
    func deleteAllObjects() async throws {
        // Given
        try await sut.create(UserModel.self) { object in
            object.name = "Name1"
            object.surname = "Surname1"
        }
        try await sut.create(UserModel.self) { object in
            object.name = "Name2"
            object.surname = "Surname2"
        }
        
        // When
        try await sut.deleteAll(UserModel.self)
        
        // Then
        #expect(try await sut.fetchAll(UserModel.self).isEmpty)
    }
    
    @Test("Test object deletion by predicate")
    func deleteSingleObjectByPredicate() async throws {
        // Given
        try await sut.create(UserModel.self) { object in
            object.name = "Name1"
            object.surname = "Surname1"
        }
        try await sut.create(UserModel.self) { object in
            object.name = "Name2"
            object.surname = "Surname2"
        }
        
        // When
        try await sut.delete(UserModel.self, configure: { request in
            request.predicate = NSPredicate(format: "name == 'Name1'")
        })
        
        // Then
        let fetchedUsers: [UserModel] = try await sut.fetchAll(UserModel.self)
        #expect(fetchedUsers.count == 1)
        #expect(fetchedUsers[0].name == "Name2")
    }
    
    // MARK: - Update
    
    @Test("Test updating object by predicate")
    func updateObject() async throws {
        // Given
        try await sut.create(UserModel.self) { object in
            object.name = "Name1"
            object.surname = "Surname1"
        }
        
        // When
        try await sut.update(UserModel.self) { request in
            request.predicate = NSPredicate(format: "name == 'Name1'")
        } update: { model in
            model.name = "UpdatedName"
        }
        
        // Then
        let fetchedUsers: [UserModel] = try await sut.fetchAll(UserModel.self)
        #expect(fetchedUsers.count == 1)
        #expect(fetchedUsers[0].name == "UpdatedName")
    }
    
    @Test("Test updating all objects")
    func updateAllObjects() async throws {
        // Given
        var callCount = 0
        try await sut.create(UserModel.self) { object in
            object.name = "Name1"
            object.surname = "Surname1"
        }
        try await sut.create(UserModel.self) { object in
            object.name = "Name2"
            object.surname = "Surname2"
        }
        
        // When
        try await sut.updateAll(UserModel.self) { object in
            object.name = "New Name"
            callCount += 1
        }
        
        // Then
        let fetchedUsers: [UserModel] = try await sut.fetchAll(UserModel.self)
        #expect(fetchedUsers.count == 2)
        #expect(callCount == 2)
        #expect(fetchedUsers.allSatisfy{ $0.name == "New Name" })
    }
}
