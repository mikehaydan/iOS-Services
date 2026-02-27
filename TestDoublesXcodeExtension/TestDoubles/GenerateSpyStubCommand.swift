//
//  GenerateSpyStubCommand.swift
//  TestDoubles
//
//  Created by Mykhailo Haidan on 27/02/2026.
//

import Foundation
import XcodeKit

// MARK: - Commands

final class GenerateSpyCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        performGeneration(with: invocation, isSpy: true, completionHandler: completionHandler)
    }
}

final class GenerateStubCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        performGeneration(with: invocation, isSpy: false, completionHandler: completionHandler)
    }
}

// MARK: - Shared Logic

private func performGeneration(
    with invocation: XCSourceEditorCommandInvocation,
    isSpy: Bool,
    completionHandler: @escaping (Error?) -> Void
) {
    let buffer = invocation.buffer
    let lines = buffer.lines.compactMap { $0 as? String }
    let cursorLine = (buffer.selections.firstObject as? XCSourceTextRange)?.start.line ?? 0

    guard let proto = ProtocolParser.findProtocol(in: lines, cursorLine: cursorLine) else {
        completionHandler(TestDoublesError.noProtocolFound)
        return
    }

    let generated = SpyStubGenerator.generate(from: proto, isSpy: isSpy)

    // Insert a blank separator line then the generated class after the protocol's closing brace
    let insertAt = proto.endLine + 1
    let outputLines = ("\n" + generated + "\n").components(separatedBy: "\n")

    for (offset, line) in outputLines.enumerated() {
        buffer.lines.insert(line + "\n", at: insertAt + offset)
    }

    completionHandler(nil)
}

// MARK: - Errors

enum TestDoublesError: LocalizedError {
    case noProtocolFound

    var errorDescription: String? {
        "No protocol found at cursor position. Place your cursor inside a protocol declaration."
    }
}
