//
//  Flow1CoordinatorRootView.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import SwiftUI

struct Flow1CoordinatorRootView<C: Flow1Coordinator>: View {
    @ObservedObject var coordinator: C

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            Flow1SubView(makeViewModel: coordinator.rootFlow1SubflowViewModel())
                .navigationDestination(for: Flow1CoordinatorImpl.Route.self) { route in
                    coordinator.destination(for: route)
                }
        }
        .alert(model: $coordinator.alertModel)
    }
}

#Preview {
    Flow1CoordinatorRootView(
        coordinator: Flow1CoordinatorImpl(
            coordinatorFactory: CoordinatorFactory(
                dependencies: AppDependencies()
            )
        )
    )
}
