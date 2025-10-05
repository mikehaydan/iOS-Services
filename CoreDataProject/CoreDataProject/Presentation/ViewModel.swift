//
//  ViewModel.swift
//  CoreDataProject
//
//  Created by Mykhailo Haidan on 01/10/2025.
//

import Foundation
import CoreData
import SwiftUI

final class ViewModel: ObservableObject {

    enum Constants {
        static let modelName = "CoreDataModel"
        static let storeName = "coreDataStore"
    }

    let storageService: CoreDataService

    init() {
        let engine = CoreDataEngine(
            storeName: Constants.modelName,
            useInMemoryStore: false,
            persistentContainer: NSPersistentContainer(name: Constants.modelName)
        )
        self.storageService = CoreDataService(engine: engine)
    }

    @Published var users: [User] = []

    @MainActor
    func save(name: String, surname: String) {
        Task { [weak self] in
            do {
                try await self?.storageService.create(UserModel.self) { model in
                    model.name = name
                    model.surname = surname
                }
                self?.getAllUsers()
            } catch {
                print(error)
            }
        }
    }

    @MainActor
    func getAllUsers() {
        Task {
            do {
                let models = try await storageService.fetchAll(UserModel.self)
                self.users = models.map { $0.user }
            } catch {
                print(error)
            }
        }
    }

    @MainActor
    func delete() {
        Task { [weak self] in
            do {
                try await self?.storageService.deleteAll(UserModel.self)
                self?.getAllUsers()
            } catch {
                print(error)
            }
        }
    }

    @MainActor
    func update() {
        Task { [weak self] in
            do {
                try await self?.storageService.updateAll(UserModel.self) { object in
                    object.name = "\(object.name) upd"
                    object.surname = "\(object.surname) upd"
                }
                self?.getAllUsers()
            } catch {
                print(error)
            }
        }
    }
}
