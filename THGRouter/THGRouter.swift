//
//  THGRouter.swift
//
//  Created by Brandon Sneed on 12/20/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

/*

This provides a simple way to enable/disable things in a module.

*/

import Foundation
import THGLog

@objc
public class THGRouter: NSObject {
    public static let logging = Logger()
}

internal func log(level: LogLevel, _ message: String) {
    THGRouter.logging.log(level, message: "\(THGRouter.self): " + message)
}
