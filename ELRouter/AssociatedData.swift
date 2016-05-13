//
//  AssociatedData.swift
//  ELRouter
//
//  Created by Brandon Sneed on 4/15/16.
//  Copyright © 2016 theholygrail.io. All rights reserved.
//

import Foundation

/**
 The AssociatedData protocol is used for conformance on passing data
 through a chain of routes.
 */
@objc
public protocol AssociatedData { }

/**
 Allows NSURL to be passed through as AssociateData for inspection by the
 route chain.
 */
extension NSURL: AssociatedData { }

