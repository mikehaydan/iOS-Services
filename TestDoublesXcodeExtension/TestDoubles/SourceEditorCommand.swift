//
//  SourceEditorCommand.swift
//  TestDoubles
//
//  Created by Mykhailo Haidan on 27/02/2026.
//

import Foundation
import XcodeKit

final class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        completionHandler(nil)
    }
}
