//
//  ELRouter.swift
//
//  Created by Brandon Sneed on 12/20/15.
//  Copyright © 2015 Walmart. All rights reserved.
//

/*

This provides a simple way to enable/disable things in a module.

*/

import Foundation
import ELLog

@objc
public class ELRouter: NSObject {
    public static let logging = Logger()
}

internal func log(level: LogLevel, _ message: String) {
    ELRouter.logging.log(level, message: "\(ELRouter.self): " + message)
}
