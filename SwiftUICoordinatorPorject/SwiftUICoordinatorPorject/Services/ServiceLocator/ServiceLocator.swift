//
//  ServiceLocator.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import Foundation

protocol Resolver {
    func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType
}

struct ServiceLocator: Resolver {

    private let factories: [AnyServiceFactory]

    init() {
        self.factories = []
    }

    private init(factories: [AnyServiceFactory]) {
        self.factories = factories
    }

    // MARK: Register

    func register<ServiceType>(
        _ interface: ServiceType.Type,
        instance: ServiceType
    ) -> ServiceLocator {
        assert(!factories.contains(where: { $0.type == interface }))

        let newFactory = AnyServiceFactory(
            resolve: instance,
            type: interface
        )
        return .init(factories: factories + [newFactory])
    }

    // MARK: Resolver

    func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType {
        guard let factory = factories.first(where: { $0.type == type }) else {
            fatalError("No suitable factory found")
        }
        return factory.resolve()
    }

    func factory<ServiceType>(for type: ServiceType.Type) -> () -> ServiceType {
        guard let factory = factories.first(where: { $0.type == type }) else {
            fatalError("No suitable factory found")
        }
        return { factory.resolve() }
    }
}

private final class AnyServiceFactory {
    private let resolveValue: Any
    let type: Any.Type

    init(resolve: Any, type: Any.Type) {
        self.resolveValue = resolve
        self.type = type
    }

    func resolve<ServiceType>() -> ServiceType {
        resolveValue as! ServiceType
    }
}
