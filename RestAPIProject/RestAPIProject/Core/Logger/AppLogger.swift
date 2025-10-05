//
//  AppLogger.swift
//  
//
//  Created by Mykhailo Haidan on 05/10/2025.
//

import OSLog

protocol AppLogger: AnyObject {
    static var shared: AppLogger { get }
    func log(_ message: String, level: LogLevel, file: StaticString, function: StaticString, line: UInt)
}

final class AppLoggerFactory {
    nonisolated(unsafe) static let logger: AppLogger = {
        #if DEBUG
        return AppLoggerImpl.shared
        #else
        return NullAppLogger()
        #endif
    }()

    // MARK: - Lifecycle

    private init() {}
}

private final class AppLoggerImpl: AppLogger {

    // MARK: - Types

    private enum LogHeader {
        static let error = "[🛑Error]"
        static let debug = "[🔎Debug]"
        static let verbose = "[ℹ️Verbose]"
    }

    // MARK: - Properties

    nonisolated(unsafe) static let shared: AppLogger = AppLoggerImpl()

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DefaultSubsystem",
        category: "Application"
    )

    // MARK: - Lifecycle

    private init() {}

    // MARK: - Public

    func log(_ message: String, level: LogLevel, file: StaticString, function: StaticString, line: UInt) {

        let formattedMessage = "\(message)\n\nfile: \(file)\nfunction: \(function)\nline: \(line)"

        switch level {
        case .verbose:
             // uncomment to display logs
             // logger.info("\(LogHeader.verbose)\n\(formattedMessage, privacy: .public)")
             break
        case .debug:
            #if DEBUG
            logger.debug("\(LogHeader.debug) \(formattedMessage, privacy: .public)")
            #else
            break
            #endif
        case .error:
            logger.error("\(LogHeader.error) \(formattedMessage, privacy: .public)")
        }
    }
}

private final class NullAppLogger: AppLogger {
    nonisolated(unsafe) static let shared: AppLogger = NullAppLogger()

    func log(_ message: String, level: LogLevel, file: StaticString, function: StaticString, line: UInt) {}
}
