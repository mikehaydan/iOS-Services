//
//  Dependencies.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import Foundation
@MainActor
protocol Dependencies: AnyObject {
    var serviceLocator: ServiceLocator { get }

    func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType
}

@MainActor
final class AppDependencies: Dependencies {

    let serviceLocator: ServiceLocator = {
        return ServiceLocator()
    }()

    func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType {
        serviceLocator.resolve(type)
    }
}
