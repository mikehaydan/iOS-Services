//
//  SwiftUICoordinatorPorjectApp.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import SwiftUI

@main
struct SwiftUICoordinatorPorjectApp: App {

    @StateObject var appCoordinator = AppCoordinatorImpl(
        coordinatorFactory: CoordinatorFactory(
            dependencies: AppDependencies()
        )
    )

    var body: some Scene {
        WindowGroup {
            appCoordinator.root
                .onAppear {
                    appCoordinator.start()
                }
        }
    }
}
