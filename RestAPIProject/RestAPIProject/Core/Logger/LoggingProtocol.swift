//
//  LoggingProtocol.swift
//  
//
//  Created by Mykhailo Haidan on 05/10/2025.
//

import Foundation
enum LogLevel {
    case verbose
    case debug
    case error
}

protocol Logging {}

extension Logging {
    func log(_ message: String, level: LogLevel = .debug, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        let shared = AppLoggerFactory.logger
        shared.log(message, level: level, file: file, function: function, line: line)
    }
}
