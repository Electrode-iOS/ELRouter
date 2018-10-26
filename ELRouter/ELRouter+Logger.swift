//
//  ELRouter+Logger.swift
//
//  Created by Brandon Sneed on 12/20/15.
//  Copyright © 2015 Walmart. All rights reserved.
//

import Foundation

/// Represents the granularity and severity of a log message.
/// - Note: If your app has different `flag` values, you can override them value by setting your own.
public struct LogFlag: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static var fatal   = LogFlag(rawValue: UInt(1 << 0))
    public static var error   = LogFlag(rawValue: UInt(1 << 1))
    public static var warning = LogFlag(rawValue: UInt(1 << 2))
    public static var info    = LogFlag(rawValue: UInt(1 << 3))
    public static var debug   = LogFlag(rawValue: UInt(1 << 4))
    public static var verbose = LogFlag(rawValue: UInt(1 << 5))
}

/// Protocol for consuming logs of `ELRouter`.
public protocol Logger {

    /// Called when the framework wants to log a `message` with an associated `flag`.
    ///
    /// - Parameters:
    ///   - flag: The `flag` the `logMessage` was recorded with
    ///   - message: autoclosure returning the message
    func log(_ flag: LogFlag, _ message: @autoclosure () -> String)
}

/// Set to consume the logs of `ELRouter`
public var logger: Logger?

/// Convenient wrapper for sending messages to `logger`
internal func log(_ flag: LogFlag, _ message: @autoclosure () -> String) {
    logger?.log(flag, message)
}
