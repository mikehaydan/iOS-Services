//
//  Flow2Coordinator.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import SwiftUI

protocol Flow2Coordinator: Coordinator, ObservableObject {
    var alertModel: AlertModel? { get set }

    func show(title: String, message: String)

    func rootFlow2SubflowViewModel() -> Flow2SubflowViewModel
}

final class Flow2CoordinatorImpl: ObservableObject, Flow2Coordinator {

    // MARK: - Properties

    let coordinatorFactory: Flow2CoordinatorFactory

    var childCoordinators: [any Coordinator] = []

    weak var parent: (any Coordinator)?

    @Published var alertModel: AlertModel?

    // MARK: - Lifecycle

    init(coordinatorFactory: Flow2CoordinatorFactory) {
        self.coordinatorFactory = coordinatorFactory
    }

    // MARK: - Public

    lazy var root: some View = {
        Flow2CoordinatorRootView(coordinator: self)
    }()

    func start() {

    }

    func show(title: String, message: String) {
        alertModel = .init(title: title, message: message)
    }

    func rootFlow2SubflowViewModel() -> Flow2SubflowViewModel {
        coordinatorFactory.flow2SubflowViewModel(coordinator: self)
    }
}

final class Flow2CoordinatorPreview: Flow2Coordinator {

    var childCoordinators: [any Coordinator] = []
    weak var parent: (any Coordinator)?

    var alertModel: AlertModel?

    func start() {

    }

    func showNext() {

    }

    func show(title: String, message: String) {

    }

    @ViewBuilder
    var root: some View {
        EmptyView()
    }

    func rootFlow2SubflowViewModel() -> Flow2SubflowViewModel {
        Flow2SubflowViewModel(coordinator: self)
    }
}
