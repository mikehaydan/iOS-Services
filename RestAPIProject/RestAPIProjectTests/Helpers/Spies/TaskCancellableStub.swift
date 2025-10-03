//
//  TaskCancellableSpy.swift
//
//
//  Created by Mykhailo Haidan on 03/10/2025.
//

import Foundation
@testable import RestAPIProject

final class TaskCancellableSpy: TaskCancellable {
    var cancelTaskCallCount = 0
    func cancelTask() {
        cancelTaskCallCount += 1
    }
}
