//
//  RoutingTypeTests.swift
//  ELRouter
//
//  Created by Angelo Di Paolo on 12/22/15.
//  Copyright © 2015 Walmart. All rights reserved.
//

import XCTest
@testable import ELRouter

class RoutingTypeTests: XCTestCase {
    func test_description() {
        XCTAssertEqual(RoutingType.modal.description, "Modal")
        XCTAssertEqual(RoutingType.segue.description, "Segue")
        XCTAssertEqual(RoutingType.fixed.description, "Fixed")
        XCTAssertEqual(RoutingType.push.description, "Push")
        XCTAssertEqual(RoutingType.variable.description, "Variable")
        XCTAssertEqual(RoutingType.other.description, "Other")
    }
}
