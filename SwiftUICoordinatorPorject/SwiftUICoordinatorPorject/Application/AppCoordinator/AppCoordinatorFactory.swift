//
//  AppCoordinatorFactory.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import Foundation

@MainActor
protocol AppCoordinatorFactory: BaseFactory {
    func makeFlow1Coordinator() -> Flow1CoordinatorImpl
    func makeFlow2Coordinator() -> Flow2CoordinatorImpl
}

extension CoordinatorFactory: AppCoordinatorFactory {
    func makeFlow1Coordinator() -> Flow1CoordinatorImpl {
        Flow1CoordinatorImpl(coordinatorFactory: concreteFactory())
    }

    func makeFlow2Coordinator() -> Flow2CoordinatorImpl {
        Flow2CoordinatorImpl(coordinatorFactory: concreteFactory())
    }
}
