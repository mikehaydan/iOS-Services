//
//  Flow1CoordinatorFactory.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import Foundation

@MainActor
protocol Flow1CoordinatorFactory: BaseFactory {
    func buildFlow1SubflowViewModel(
        coordinator: any Flow1Coordinator,
        index: Int
    ) -> Flow1SubflowViewModel
}

extension CoordinatorFactory: Flow1CoordinatorFactory {
    func buildFlow1SubflowViewModel(
        coordinator: any Flow1Coordinator,
        index: Int
    ) -> Flow1SubflowViewModel {
        Flow1SubflowViewModel(coordinator: coordinator, index: index)
    }
}
