//
//  CoordinatorFactory.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import Foundation

// The idea of DI factory is takes from:
// https://www.swiftbysundell.com/articles/dependency-injection-using-factories-in-swift/
// https://stevenpcurtis.medium.com/mvvm-c-architecture-with-dependency-injection-testing-3b7197eb2e4d

@MainActor
protocol BaseFactory: AnyObject {
    var dependencies: Dependencies { get }

    func concreteFactory<F: BaseFactory>() -> F
}

extension BaseFactory {

    func concreteFactory<F>() -> F {
        // swiftlint:disable force_cast
        self as! F
        // swiftlint:enable force_cast
    }
}

@MainActor
final class CoordinatorFactory: BaseFactory {

    let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
