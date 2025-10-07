//
//  Flow2CoordinatorFactory.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import Foundation

@MainActor
protocol Flow2CoordinatorFactory: BaseFactory {
    func flow2SubflowViewModel(coordinator: any Flow2Coordinator) -> Flow2SubflowViewModel
}

extension CoordinatorFactory: Flow2CoordinatorFactory {
    func flow2SubflowViewModel(coordinator: any Flow2Coordinator) -> Flow2SubflowViewModel {
        Flow2SubflowViewModel(coordinator: coordinator)
    }
}
