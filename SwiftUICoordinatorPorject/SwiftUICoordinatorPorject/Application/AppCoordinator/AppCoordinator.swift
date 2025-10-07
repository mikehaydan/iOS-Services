//
//  AppCoordinator.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import SwiftUI

enum AppFlow {
    case flow1(Flow1CoordinatorImpl)
    case flow2(Flow2CoordinatorImpl)
    case none
}

protocol AppCoordinator: Coordinator, ObservableObject {
    var selectedFlow: AppFlow { get set }

    func createFlow1()
    func createFlow2()
}

final class AppCoordinatorImpl: ObservableObject, AppCoordinator {

    // MARK: - Types

    // MARK: - Properties

    let coordinatorFactory: AppCoordinatorFactory

    var childCoordinators: [any Coordinator] = []
    weak var parent: (any Coordinator)?

    @Published var selectedFlow: AppFlow = .none

    // MARK: - Lifecycle

    init(coordinatorFactory: AppCoordinatorFactory) {
        self.coordinatorFactory = coordinatorFactory
    }

    // MARK: - Private

    func createFlow1() {
        if case .flow1 = selectedFlow {
            return
        }
        let coordinator = coordinatorFactory.makeFlow1Coordinator()
        coordinator.parent = self

        childCoordinators.forEach({ $0.beforeRemove() })

        let oldCoordinators = childCoordinators
        childCoordinators = [coordinator]
        selectedFlow = .flow1(coordinator)

        oldCoordinators.forEach({ $0.afterRemove() })

        coordinator.start()
    }

    func createFlow2() {
        print("begin createFlow2")
        if case .flow2 = selectedFlow {
            return
        }
        let coordinator = coordinatorFactory.makeFlow2Coordinator()
        coordinator.parent = self

        childCoordinators.forEach({ $0.beforeRemove() })

        let oldCoordinators = childCoordinators
        childCoordinators = [coordinator]
        selectedFlow = .flow2(coordinator)

        oldCoordinators.forEach({ $0.afterRemove() })

        coordinator.start()

        print("end createFlow2")
    }

    func clearChildCoordinators() {
        childCoordinators.removeAll()
    }

    // MARK: - Public

    func start() {
        createFlow1()
    }
}

extension AppCoordinatorImpl {
    @ViewBuilder
    var root: some View {
        VStack {
            switch selectedFlow {
            case .flow1(let coordinator):
                coordinator.root
            case .flow2(let coordinator):
                coordinator.root
            case .none:
                EmptyView()
            }
            HStack(alignment: .center) {
                Button(action: {
                    print("change flow to f1")
                    self.createFlow1()
                }, label: {
                    Text("Flow 1")
                })
                Button(action: {
                    print("change flow to f2")
                    self.createFlow2()
                }, label: {
                    Text("Flow 2")
                })
            }
            .frame(height: 35)
        }
    }
}
