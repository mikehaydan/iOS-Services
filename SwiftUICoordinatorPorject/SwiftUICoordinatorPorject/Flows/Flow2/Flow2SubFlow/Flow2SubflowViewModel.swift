//
//  Flow2SubflowViewModel.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import Foundation

final class Flow2SubflowViewModel: ObservableObject {

    // MARK: - Properties

    unowned let coordinator: any Flow2Coordinator

    // MARK: - Lifecycle

    init(coordinator: any Flow2Coordinator) {
        self.coordinator = coordinator
    }

    // MARK: - Public

    func showMessage() {
        coordinator.show(title: "Title", message: "Message from Flow 2 Subflow")
    }
}
