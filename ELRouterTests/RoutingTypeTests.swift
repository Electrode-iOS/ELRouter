//
//  RoutingTypeTests.swift
//  ELRouter
//
//  Created by Angelo Di Paolo on 12/22/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import XCTest
@testable import ELRouter

class RoutingTypeTests: XCTestCase {
    func test_description() {
        XCTAssertEqual(RoutingType.Modal.description, "Modal")
        XCTAssertEqual(RoutingType.Segue.description, "Segue")
        XCTAssertEqual(RoutingType.Static.description, "Static")
        XCTAssertEqual(RoutingType.Push.description, "Push")
        XCTAssertEqual(RoutingType.Variable.description, "Variable")
        XCTAssertEqual(RoutingType.Other.description, "Other")
    }
}
