//
//  SpyStubGenerator.swift
//  TestDoubles
//
//  Created by Mykhailo Haidan on 27/02/2026.
//

import Foundation

enum SpyStubGenerator {

    static func generate(from proto: ParsedProtocol, isSpy: Bool) -> String {
        let suffix = isSpy ? "Spy" : "Stub"
        let className = "\(proto.name)\(suffix)"

        var lines: [String] = []
        lines.append("final class \(className): \(proto.name) {")
        lines.append("")

        // Stored properties from protocol `var` declarations
        for variable in proto.variables {
            let keyword = variable.isStatic ? "static var" : "var"
            let type = variable.typeName
            // Non-optional types need an IUO so the class compiles without an explicit init
            if !type.hasSuffix("?") && !type.hasSuffix("!") {
                lines.append("    // swiftlint:disable:next force_unwrapping")
                lines.append("    \(keyword) \(variable.name): \(type)!")
            } else {
                lines.append("    \(keyword) \(variable.name): \(type)")
            }
        }
        if !proto.variables.isEmpty { lines.append("") }

        // One block per protocol function
        for (index, function) in proto.functions.enumerated() {
            let members = buildFunctionMembers(for: function, isSpy: isSpy)
            lines.append(contentsOf: members.map { "    \($0)" })
            if index < proto.functions.count - 1 { lines.append("") }
        }

        lines.append("}")
        return lines.joined(separator: "\n")
    }

    // MARK: - Per-Function Generation

    private static func buildFunctionMembers(for function: ParsedFunction, isSpy: Bool) -> [String] {
        var lines: [String] = []
        let name = function.name

        // 1. Call count (Spy only)
        if isSpy {
            lines.append("var \(name)CallCount = 0")
        }

        // 2. Error injection for throwing functions
        if function.isThrowing {
            lines.append("var \(name)ErrorToBeReturned: Error?")
        }

        // 3. Return value (non-void, non-closure-param functions)
        if !function.hasClosureParam, let retType = function.returnType {
            let propType = propertyType(retType, genericParams: function.genericParams)
            if propType.hasSuffix("!") {
                lines.append("// swiftlint:disable:next force_unwrapping")
            }
            lines.append("var \(name)ToBeReturned: \(propType)")
        }

        // 4. The method implementation — split into individual lines so each
        //    gets the class-level indent applied by the caller.
        let implLines = buildImpl(for: function, isSpy: isSpy)
            .components(separatedBy: "\n")
        lines.append(contentsOf: implLines)

        return lines
    }

    private static func buildImpl(for function: ParsedFunction, isSpy: Bool) -> String {
        let name = function.name

        // Reconstruct the clean signature from the parsed one
        var sig = cleanedSignature(function.fullSignature)

        let discardable = (!function.hasClosureParam &&
                           function.returnType != nil &&
                           function.isDiscardableResult) ? "@discardableResult\n" : ""

        // Build the body lines
        var body: [String] = []

        if isSpy {
            body.append("    \(name)CallCount += 1")
        }
        if function.isThrowing {
            body.append("    if let error = \(name)ErrorToBeReturned { throw error }")
        }
        if !function.hasClosureParam, let retType = function.returnType {
            let stmt = returnStatement(name: name, retType: retType, genericParams: function.genericParams)
            if stmt.contains("as!") {
                body.append("    // swiftlint:disable:next force_unwrapping")
            }
            body.append("    \(stmt)")
        }
        if function.hasClosureParam {
            body.append("    // TODO: Implement closure/callback behavior")
        }

        let bodyStr = body.isEmpty ? "" : "\n\(body.joined(separator: "\n"))\n"
        return "\(discardable)\(sig) {\(bodyStr)}"
    }

    // MARK: - Type Resolution

    private static func propertyType(
        _ retType: String,
        genericParams: [(name: String, constraint: String)]
    ) -> String {
        let names = Set(genericParams.map { $0.name })

        // Optional generic: D?  →  (any Constraint)?
        if retType.hasSuffix("?") {
            let inner = String(retType.dropLast()).td_stripped
            if names.contains(inner),
               let constraint = genericParams.first(where: { $0.name == inner })?.constraint {
                return "(any \(constraint))?"
            }
        }

        // Non-optional generic: T  →  (any Constraint)!
        if names.contains(retType),
           let constraint = genericParams.first(where: { $0.name == retType })?.constraint {
            return "(any \(constraint))!"
        }

        // Concrete type
        return "\(retType)!"
    }

    private static func returnStatement(
        name: String,
        retType: String,
        genericParams: [(name: String, constraint: String)]
    ) -> String {
        let names = Set(genericParams.map { $0.name })

        // Optional generic: return as?
        if retType.hasSuffix("?") {
            let inner = String(retType.dropLast()).td_stripped
            if names.contains(inner) { return "return \(name)ToBeReturned as? \(inner)" }
        }

        // Non-optional generic: return as!
        if names.contains(retType) { return "return \(name)ToBeReturned as! \(retType)" }

        return "return \(name)ToBeReturned"
    }

    // MARK: - Signature Cleaning

    /// Strips leading attributes (except keeping @discardableResult if needed),
    /// ensures it starts with `func`, and removes any trailing `{`.
    private static func cleanedSignature(_ signature: String) -> String {
        var sig = signature

        // Remove @discardableResult since we'll prepend it conditionally
        sig = sig.replacingOccurrences(of: "@discardableResult", with: "").td_stripped

        // Remove any other leading `@attribute` lines before `func`
        if let funcRange = sig.range(of: "func ") {
            sig = String(sig[funcRange.lowerBound...])
        }

        // Remove trailing `{` if the protocol had a default implementation
        if sig.hasSuffix("{") {
            sig = String(sig.dropLast()).td_stripped
        }

        // Final strip — ensures any stray \n from XcodeKit buffer lines is removed
        return sig.td_stripped
    }
}

// MARK: - String Helpers

private extension String {
    // Must use .whitespacesAndNewlines — XcodeKit buffer lines include a trailing \n
    var td_stripped: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
