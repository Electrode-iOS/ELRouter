//
//  THGRouterTests.swift
//  THGRouterTests
//
//  Created by Brandon Sneed on 10/19/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import XCTest
import THGRouter

class THGRouterTests: XCTestCase {
    
    func testNSURLPathBehavior() {
        let url = NSURL(string: "walmart://something/1234/abcd?blah1=1,blah2=2")
        print(url!.pathComponents)

        let url2 = NSURL(string: "walmart://:something/1234/abcd?blah1=1,blah2=2")
        print(url2!.pathComponents)
    }
}
