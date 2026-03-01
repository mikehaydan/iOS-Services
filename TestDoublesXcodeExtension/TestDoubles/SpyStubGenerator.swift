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
        var usedNames: Set<String> = []
        lines.append("final class \(className): \(proto.name) {")
        lines.append("")

        // Properties from protocol `var` declarations
        for variable in proto.variables {
            let keyword = variable.isStatic ? "static var" : "var"
            let type = variable.typeName
            let isOptional = type.hasSuffix("?") || type.hasSuffix("!")

            if isOptional {
                // Optional type: can use stored property directly
                lines.append("    \(keyword) \(variable.name): \(type)")
            } else {
                // Non-optional type: need backing IUO property + computed property
                let backingName = uniqueName("\(variable.name)ToBeReturned", usedNames: &usedNames)
                lines.append("    // swiftlint:disable:next force_unwrapping")
                lines.append("    \(keyword) \(backingName): \(type)!")
                lines.append("    \(keyword) \(variable.name): \(type) {")
                lines.append("        get { \(backingName) }")
                lines.append("        set { \(backingName) = newValue }")
                lines.append("    }")
            }
        }
        if !proto.variables.isEmpty { lines.append("") }

        // One block per protocol function
        for (index, function) in proto.functions.enumerated() {
            let members = buildFunctionMembers(for: function, isSpy: isSpy, usedNames: &usedNames)
            lines.append(contentsOf: members.map { "    \($0)" })
            if index < proto.functions.count - 1 { lines.append("") }
        }

        lines.append("}")
        return lines.joined(separator: "\n")
    }

    // MARK: - Name Uniqueness

    private static func uniqueName(_ base: String, usedNames: inout Set<String>) -> String {
        var name = base
        var counter = 2
        while usedNames.contains(name) {
            name = "\(base)\(counter)"
            counter += 1
        }
        usedNames.insert(name)
        return name
    }

    // MARK: - Per-Function Generation

    private static func buildFunctionMembers(
        for function: ParsedFunction,
        isSpy: Bool,
        usedNames: inout Set<String>
    ) -> [String] {
        var lines: [String] = []
        let name = function.name
        let varKeyword = function.isStatic ? "static var" : "var"

        // Generate unique names for helper properties
        var callCountName: String?
        var errorName: String?
        var returnName: String?

        // 1. Call count (Spy only)
        if isSpy {
            callCountName = uniqueName("\(name)CallCount", usedNames: &usedNames)
            lines.append("\(varKeyword) \(callCountName!) = 0")
        }

        // 2. Error injection for throwing functions
        if function.isThrowing {
            errorName = uniqueName("\(name)ErrorToBeReturned", usedNames: &usedNames)
            lines.append("\(varKeyword) \(errorName!): Error?")
        }

        // 3. Return value (non-void, non-closure-param functions)
        if !function.hasClosureParam, let retType = function.returnType {
            returnName = uniqueName("\(name)ToBeReturned", usedNames: &usedNames)
            let propType = propertyType(retType, genericParams: function.genericParams)
            if propType.hasSuffix("!") {
                lines.append("// swiftlint:disable:next force_unwrapping")
            }
            lines.append("\(varKeyword) \(returnName!): \(propType)")
        }

        // 4. The method implementation — split into individual lines so each
        //    gets the class-level indent applied by the caller.
        let implLines = buildImpl(
            for: function,
            isSpy: isSpy,
            callCountName: callCountName,
            errorName: errorName,
            returnName: returnName
        ).components(separatedBy: "\n")
        lines.append(contentsOf: implLines)

        return lines
    }

    private static func buildImpl(
        for function: ParsedFunction,
        isSpy: Bool,
        callCountName: String?,
        errorName: String?,
        returnName: String?
    ) -> String {
        // Reconstruct the clean signature from the parsed one
        let sig = cleanedSignature(function.fullSignature)

        let discardable = (!function.hasClosureParam &&
                           function.returnType != nil &&
                           function.isDiscardableResult) ? "@discardableResult\n" : ""

        // Build the body lines
        var body: [String] = []

        if isSpy, let callCountName = callCountName {
            body.append("    \(callCountName) += 1")
        }
        if function.isThrowing, let errorName = errorName {
            body.append("    if let error = \(errorName) { throw error }")
        }
        if !function.hasClosureParam, let retType = function.returnType, let returnName = returnName {
            let stmt = returnStatement(name: returnName, retType: retType, genericParams: function.genericParams)
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
            // Concrete optional type: keep as-is (no IUO needed)
            return retType
        }

        // Non-optional generic: T  →  (any Constraint)!
        if names.contains(retType),
           let constraint = genericParams.first(where: { $0.name == retType })?.constraint {
            return "(any \(constraint))!"
        }

        // Concrete non-optional type: needs IUO
        return "\(retType)!"
    }

    private static func returnStatement(
        name propertyName: String,
        retType: String,
        genericParams: [(name: String, constraint: String)]
    ) -> String {
        let names = Set(genericParams.map { $0.name })

        // Optional generic: return as?
        if retType.hasSuffix("?") {
            let inner = String(retType.dropLast()).td_stripped
            if names.contains(inner) { return "return \(propertyName) as? \(inner)" }
        }

        // Non-optional generic: return as!
        if names.contains(retType) { return "return \(propertyName) as! \(retType)" }

        return "return \(propertyName)"
    }

    // MARK: - Signature Cleaning

    /// Strips leading attributes (except keeping @discardableResult if needed),
    /// ensures it starts with `static func`, `class func`, or `func`, and removes any trailing `{`.
    private static func cleanedSignature(_ signature: String) -> String {
        var sig = signature

        // Remove @discardableResult since we'll prepend it conditionally
        sig = sig.replacingOccurrences(of: "@discardableResult", with: "").td_stripped

        // Remove any other leading `@attribute` lines before `func`, but keep static/class
        if let staticFuncRange = sig.range(of: "static func ") {
            sig = String(sig[staticFuncRange.lowerBound...])
        } else if let classFuncRange = sig.range(of: "class func ") {
            // Replace `class func` with `static func` for final class compatibility
            let afterClassFunc = String(sig[classFuncRange.upperBound...])
            sig = "static func " + afterClassFunc
        } else if let funcRange = sig.range(of: "func ") {
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
