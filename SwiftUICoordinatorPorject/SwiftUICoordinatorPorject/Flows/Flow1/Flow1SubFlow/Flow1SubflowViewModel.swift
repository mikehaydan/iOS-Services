//
//  Flow1SubflowViewModel.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import SwiftUI

final class Flow1SubflowViewModel: ObservableObject {

    // MARK: - Properties

    unowned let coordinator: any Flow1Coordinator

    let index: Int

    // MARK: - Lifecycle

    init(coordinator: any Flow1Coordinator, index: Int) {
        print("Flow1SubflowViewModel init")
        self.coordinator = coordinator
        self.index = index
    }

    deinit {
        print("Flow1SubflowViewModel deinit")
    }

    // MARK: - Public

    func showNext() {
        coordinator.showNext(index: index + 1)
    }

    func showMessage() {
        coordinator.show(title: "Title", message: "Message from Flow 1 Subflow, index \(index)")
    }
}
