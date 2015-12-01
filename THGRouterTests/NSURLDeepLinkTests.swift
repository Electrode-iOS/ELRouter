//
//  NSURLDeepLinkTests.swift
//  THGRouter
//
//  Created by Angelo Di Paolo on 12/1/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import XCTest
import THGRouter

class NSURLDeepLinkTests: XCTestCase {
    func testDeepLinkComponents() {
        let url = NSURL(string: "scheme://walmart.com/bar/foo")!
        
        let components = url.deepLinkComponents
        
        XCTAssertNotNil(components)
        XCTAssertEqual(components!.count, 3)
        XCTAssertEqual(components![0], "walmart.com")
        XCTAssertEqual(components![1], "bar")
        XCTAssertEqual(components![2], "foo")
    }
}
