//
//  Logging.swift
//  RouterExample
//
//  Created by John Liedtke on 8/7/18.
//  Copyright © 2018 theholygrail.io. All rights reserved.
//

import ELRouter
import Foundation
import os.log

class Logger: ELRouter.Logger {
    static let shared = Logger()

    @available (iOS 10, *)
    private static let osLog = OSLog(subsystem: "com.routerExample", category: "ELRouter")

    func log(_ flag: LogFlag, _ message: @autoclosure () -> String) {
        if #available(iOS 10, *) {
            os_log("%@", log: Logger.osLog, type: getOSType(for: flag), message())
        } else {
            NSLog("@", message())
        }
    }

    @available(iOS 10, *)
    private func getOSType(for flag: LogFlag) -> OSLogType {
        switch flag {
        case .fatal, .error: return .error
        case .warning: return .fault
        case .info: return .info
        case .debug, .verbose: return .debug
        default: return .default
        }
    }
}
