//
//  AppCoordinatorRootView.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import SwiftUI

struct AppCoordinatorRootView<C: AppCoordinator>: View {

    @ObservedObject var coordinator: C

    var body: some View {
        VStack {
            switch coordinator.selectedFlow {
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
                    coordinator.createFlow1()
                }, label: {
                    Text("Flow 1")
                })
                Button(action: {
                    print("change flow to f2")
                    coordinator.createFlow2()
                }, label: {
                    Text("Flow 2")
                })
            }
            .frame(height: 35)
        }
    }
}
