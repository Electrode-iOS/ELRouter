//
//  ELRouterTests.swift
//  ELRouterTests
//
//  Created by Brandon Sneed on 10/19/15.
//  Copyright © 2015 Walmart. All rights reserved.
//

import XCTest
import ELRouter

class ELRouterTests: XCTestCase {
    
    func testNSURLPathBehavior() {
        let url = URL(string: "walmart://something/1234/abcd?blah1=1,blah2=2")
        print(url!.pathComponents)

        let url2 = URL(string: "walmart://:something/1234/abcd?blah1=1,blah2=2")
        print(url2!.pathComponents)
    }
}
