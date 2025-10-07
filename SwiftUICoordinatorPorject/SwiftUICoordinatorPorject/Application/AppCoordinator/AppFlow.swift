//
//  AppFlow.swift
//  SwiftUICoordinatorPorject
//
//  Created by Mykhailo Haidan on 07/10/2025.
//

import Foundation

enum AppFlow {
    case flow1(Flow1CoordinatorImpl)
    case flow2(Flow2CoordinatorImpl)
    case none
}
