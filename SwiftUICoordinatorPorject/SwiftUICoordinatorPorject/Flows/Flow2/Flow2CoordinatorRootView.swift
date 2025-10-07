//
//  Flow2CoordinatorRootView.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import SwiftUI

struct Flow2CoordinatorRootView<C: Flow2Coordinator>: View {

    @ObservedObject var coordinator: C

    var body: some View {
        NavigationStack {
            Flow2SubView(
                makeViewModel: coordinator.rootFlow2SubflowViewModel()
            )
        }
        .alert(model: $coordinator.alertModel)
    }
}

#Preview {
    Flow2CoordinatorRootView(
        coordinator: Flow2CoordinatorImpl(
            coordinatorFactory: CoordinatorFactory(
                dependencies: AppDependencies()
            )
        )
    )
}
