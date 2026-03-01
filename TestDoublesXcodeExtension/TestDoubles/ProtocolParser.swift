//
//  ProtocolParser.swift
//  TestDoubles
//
//  Created by Mykhailo Haidan on 27/02/2026.
//

import Foundation

// MARK: - Models

struct ParsedProtocol {
    let name: String
    let functions: [ParsedFunction]
    let variables: [ParsedVariable]
    let startLine: Int
    let endLine: Int
}

struct ParsedFunction {
    let name: String
    let fullSignature: String
    let isStatic: Bool
    let isAsync: Bool
    let isThrowing: Bool
    let returnType: String?          // nil means Void
    let isDiscardableResult: Bool
    let hasClosureParam: Bool
    let genericParams: [(name: String, constraint: String)]
}

struct ParsedVariable {
    let name: String
    let typeName: String
    let isStatic: Bool
    let isReadOnly: Bool  // true for `{ get }`, false for `{ get set }`
}

// MARK: - Parser

enum ProtocolParser {

    /// Finds the nearest protocol declaration at or above `cursorLine` and parses it.
    static func findProtocol(in lines: [String], cursorLine: Int) -> ParsedProtocol? {
        let searchFrom = min(cursorLine, lines.count - 1)

        // Walk backwards to find the nearest protocol keyword
        for i in stride(from: searchFrom, through: 0, by: -1) {
            let stripped = lines[i].td_stripped
            if stripped.td_matches(#"(public\s+|private\s+|internal\s+|fileprivate\s+|open\s+)*protocol\s+\w+"#) {
                return parseProtocol(lines: lines, startLine: i)
            }
        }
        return nil
    }

    // MARK: - Protocol Parsing

    private static func parseProtocol(lines: [String], startLine: Int) -> ParsedProtocol? {
        guard let name = extractCapture(#"protocol\s+(\w+)"#, from: lines[startLine]) else { return nil }

        // Locate the outer braces
        var braceDepth = 0
        var endLine = startLine

        for i in startLine..<lines.count {
            for ch in lines[i] {
                if ch == "{" { braceDepth += 1 }
                else if ch == "}" {
                    braceDepth -= 1
                    if braceDepth == 0 { endLine = i; break }
                }
            }
            if endLine > startLine { break }
        }

        guard endLine > startLine else { return nil }

        // Collect body lines (inside the outer braces, excluding the protocol line itself)
        let bodyRange = (startLine + 1)...endLine
        let bodyLines = Array(zip(bodyRange, lines[bodyRange]))

        // Parse members
        var functions: [ParsedFunction] = []
        var variables: [ParsedVariable] = []
        var i = 0

        while i < bodyLines.count {
            let (_, text) = bodyLines[i]
            let stripped = text.td_stripped

            // @discardableResult on its own line precedes the func
            if stripped.contains("@discardableResult") && !stripped.contains("func ") {
                i += 1
                if i < bodyLines.count {
                    let sig = collectFunctionSignature(from: bodyLines, startIndex: i)
                    if let f = parseFunction(sig, isDiscardableResult: true) {
                        functions.append(f)
                    }
                }
            } else if stripped.hasPrefix("func ")
                   || stripped.hasPrefix("static func ")
                   || stripped.hasPrefix("class func ")
                   || stripped.td_matches(#"\s+func\s+"#) {
                let sig = collectFunctionSignature(from: bodyLines, startIndex: i)
                if let f = parseFunction(sig, isDiscardableResult: false) {
                    functions.append(f)
                }
            } else if stripped.hasPrefix("var ")
                   || stripped.hasPrefix("static var ")
                   || stripped.hasPrefix("class var ") {
                if let v = parseVariable(stripped) {
                    variables.append(v)
                }
            }

            i += 1
        }

        return ParsedProtocol(
            name: name,
            functions: functions,
            variables: variables,
            startLine: startLine,
            endLine: endLine
        )
    }

    // MARK: - Function Signature Collection

    /// Collects a potentially multi-line function signature (balanced parentheses).
    private static func collectFunctionSignature(
        from lines: [(Int, String)],
        startIndex: Int
    ) -> String {
        var parts: [String] = []
        var parenDepth = 0
        var i = startIndex

        while i < lines.count {
            let text = lines[i].1.td_stripped
            parts.append(text)

            for ch in text {
                if ch == "(" { parenDepth += 1 }
                else if ch == ")" { parenDepth -= 1 }
            }

            // Once parens are balanced, check if we also have the return type
            let joined = parts.joined(separator: " ")
            if parenDepth <= 0 && !joined.hasSuffix("->") {
                break
            }
            i += 1
        }

        return parts.joined(separator: " ")
    }

    // MARK: - Function Parsing

    private static func parseFunction(_ signature: String, isDiscardableResult: Bool) -> ParsedFunction? {
        guard let name = extractCapture(#"func\s+(\w+)"#, from: signature) else { return nil }

        let isStatic = signature.contains("static func") || signature.contains("class func")
        let isAsync = signature.contains(" async")
        let isThrowing = signature.contains(" throws")

        // Return type: text after the last `->` (outside of parentheses / angle brackets)
        let returnType = extractReturnType(from: signature)

        // Generic type parameters: e.g. <T: Decodable, D: KeychainRepresentable>
        let genericParams = extractGenericParams(from: signature)

        // Closure parameters: any parameter whose type is a function type
        let hasClosureParam = signature.contains("@escaping") || containsClosureParamType(signature)

        return ParsedFunction(
            name: name,
            fullSignature: signature,
            isStatic: isStatic,
            isAsync: isAsync,
            isThrowing: isThrowing,
            returnType: returnType,
            isDiscardableResult: isDiscardableResult,
            hasClosureParam: hasClosureParam,
            genericParams: genericParams
        )
    }

    // MARK: - Variable Parsing

    private static func parseVariable(_ line: String) -> ParsedVariable? {
        let isStatic = line.hasPrefix("static ") || line.hasPrefix("class ")

        guard let name = extractCapture(#"var\s+(\w+)"#, from: line) else { return nil }
        guard let colonIdx = line.firstIndex(of: ":") else { return nil }

        var typePart = String(line[line.index(after: colonIdx)...]).td_stripped

        // Determine if read-only: `{ get }` without `set`
        let isReadOnly = typePart.contains("{ get }") ||
                         (typePart.contains("{") && typePart.contains("get") && !typePart.contains("set"))

        // Strip trailing `{ get }` / `{ get set }` accessors
        if let braceIdx = typePart.firstIndex(of: "{") {
            typePart = String(typePart[..<braceIdx]).td_stripped
        }
        guard !typePart.isEmpty else { return nil }

        return ParsedVariable(name: name, typeName: typePart, isStatic: isStatic, isReadOnly: isReadOnly)
    }

    // MARK: - Type Helpers

    private static func extractReturnType(from signature: String) -> String? {
        // Find `->` that is NOT inside parentheses
        var depth = 0
        var arrowStart: String.Index? = nil
        var idx = signature.startIndex

        while idx < signature.endIndex {
            let ch = signature[idx]
            if ch == "(" || ch == "<" { depth += 1 }
            else if ch == ")" || ch == ">" { depth -= 1 }
            else if ch == "-" && depth == 0 {
                let next = signature.index(after: idx)
                if next < signature.endIndex && signature[next] == ">" {
                    arrowStart = next
                    break
                }
            }
            idx = signature.index(after: idx)
        }

        guard let arrowIdx = arrowStart else { return nil }

        var retPart = String(signature[signature.index(after: arrowIdx)...]).td_stripped

        // Remove trailing `where ...` clause and `{`
        for trailer in [" where ", "{"] {
            if let r = retPart.range(of: trailer) {
                retPart = String(retPart[..<r.lowerBound]).td_stripped
            }
        }

        guard !retPart.isEmpty, retPart != "Void", retPart != "()" else { return nil }
        return retPart
    }

    private static func extractGenericParams(from signature: String) -> [(name: String, constraint: String)] {
        // Find the angle-bracket clause immediately after `func name`
        guard let funcRange = signature.range(of: "func "),
              let nameEnd = signature.range(of: "(", range: funcRange.upperBound..<signature.endIndex),
              let angleStart = signature.range(of: "<", range: funcRange.upperBound..<nameEnd.lowerBound) else {
            return []
        }

        // Walk forward to find balanced `>`
        var depth = 0
        var angleEnd: String.Index? = nil
        var i = angleStart.lowerBound

        while i < signature.endIndex {
            if signature[i] == "<" { depth += 1 }
            else if signature[i] == ">" {
                depth -= 1
                if depth == 0 { angleEnd = i; break }
            }
            i = signature.index(after: i)
        }

        guard let endIdx = angleEnd else { return [] }

        let content = String(signature[signature.index(after: angleStart.lowerBound)..<endIdx])

        return content.components(separatedBy: ",").compactMap { param in
            let parts = param.td_stripped.components(separatedBy: ":")
            guard parts.count >= 2 else { return nil }
            let pName = parts[0].td_stripped
            let pConstraint = parts[1...].joined(separator: ":").td_stripped
            return (name: pName, constraint: pConstraint)
        }
    }

    private static func containsClosureParamType(_ signature: String) -> Bool {
        // Heuristic: looks for `-> ReturnType)` pattern inside parameter list,
        // indicating a closure parameter type like `(Data) -> Void`
        guard let parenStart = signature.firstIndex(of: "("),
              let parenEnd = signature.lastIndex(of: ")") else { return false }

        let paramSection = String(signature[parenStart...parenEnd])

        // If there's a `->` inside the param section (after stripping the outer parens), it's a closure
        return paramSection.contains("->") &&
               (paramSection.contains("@escaping") ||
                paramSection.contains("() ->") ||
                paramSection.contains(") ->"))
    }

    // MARK: - Regex Helper

    private static func extractCapture(_ pattern: String, from text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges > 1,
              let range = Range(match.range(at: 1), in: text) else { return nil }
        return String(text[range])
    }
}

// MARK: - String Helpers

private extension String {
    // Must use .whitespacesAndNewlines — XcodeKit buffer lines include a trailing \n
    var td_stripped: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    func td_matches(_ pattern: String) -> Bool {
        (try? NSRegularExpression(pattern: pattern))?
            .firstMatch(in: self, range: NSRange(startIndex..., in: self)) != nil
    }
}
