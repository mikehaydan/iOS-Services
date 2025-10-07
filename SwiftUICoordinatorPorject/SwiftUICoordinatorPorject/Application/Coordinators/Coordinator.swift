//
//  Coordinator.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import SwiftUI

@MainActor
protocol Coordinator: AnyObject {
    associatedtype RootView: View
    var childCoordinators: [any Coordinator] { get set }
    var parent: (any Coordinator)? { get set }

    func start()
    func removeChild(_ child: (any Coordinator)?)

    func beforeRemove()
    func afterRemove()

    @ViewBuilder
    var root: RootView { get }
}

extension Coordinator {
    func removeChild(_ child: (any Coordinator)?) {
        childCoordinators = childCoordinators.filter { $0 !== child }
    }

    func beforeRemove() {

    }

    func afterRemove() {

    }
}
