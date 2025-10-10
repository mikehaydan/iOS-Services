//
//  Flow1Coordinator.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import SwiftUI

protocol Flow1Coordinator: Coordinator, ObservableObject {
    associatedtype DestinationView: View

    var path: NavigationPath { get set }
    var alertModel: AlertModel? { get set }

    @ViewBuilder
    func destination(for route: Flow1CoordinatorImpl.Route) -> DestinationView
    func showNext(index: Int)
    func show(title: String, message: String)
    func clearFlow()

    func rootFlow1SubflowViewModel() -> Flow1SubflowViewModel
}

final class Flow1CoordinatorImpl: ObservableObject, Flow1Coordinator {

    // MARK: - Types

    enum Route: Hashable {
        case showNext(Int)

        var id: Self { return self }
    }

    // MARK: - Properties

    let coordinatorFactory: Flow1CoordinatorFactory

    var childCoordinators: [any Coordinator] = []
    weak var parent: (any Coordinator)?

    @Published var path: NavigationPath = NavigationPath()
    @Published var alertModel: AlertModel?

    // MARK: - Lifecycle

    init(coordinatorFactory: Flow1CoordinatorFactory) {
        self.coordinatorFactory = coordinatorFactory
    }

    // MARK: - Public

    lazy var root: some View =  {
        Flow1CoordinatorRootView(coordinator: self)
    }()

    @ViewBuilder
    func destination(for route: Flow1CoordinatorImpl.Route) -> some View {
        Group {
            switch route {
            case .showNext(let index):
                Flow1SubView(
                    makeViewModel: self.coordinatorFactory.buildFlow1SubflowViewModel(coordinator: self, index: index)
                )
            }
        }
    }

    func start() {

    }

    func afterRemove() {
        clearFlow()
    }

    func showNext(index: Int) {
        path.append(Route.showNext(index))
    }

    func show(title: String, message: String) {
        alertModel = .init(title: title, message: message)
    }

    func clearFlow() {
        path.removeLast(path.count)
    }

    func rootFlow1SubflowViewModel() -> Flow1SubflowViewModel {
        coordinatorFactory.buildFlow1SubflowViewModel(coordinator: self, index: 0)
    }
}

final class Flow1CoordinatorPreview: Flow1Coordinator {

    var childCoordinators: [any Coordinator] = []
    weak var parent: (any Coordinator)?

    var path: NavigationPath = NavigationPath()
    var alertModel: AlertModel?

    func start() {

    }

    func showNext(index: Int) {

    }

    func show(title: String, message: String) {

    }

    @ViewBuilder
    var root: some View {
        EmptyView()
    }

    @ViewBuilder
    func destination(for route: Flow1CoordinatorImpl.Route) -> some View {
        EmptyView()
    }

    func clearFlow() {

    }

    func rootFlow1SubflowViewModel() -> Flow1SubflowViewModel {
        Flow1SubflowViewModel(coordinator: self, index: 0)
    }
}
