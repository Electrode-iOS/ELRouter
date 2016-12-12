//
//  NSURLDeepLinkTests.swift
//  ELRouter
//
//  Created by Angelo Di Paolo on 12/1/15.
//  Copyright © 2015 Walmart. All rights reserved.
//

import XCTest
import ELRouter

class NSURLDeepLinkTests: XCTestCase {
    func test_deepLinkComponents_componentOutputMatchesOriginalURL() {
        let url = URL(string: "scheme://walmart.com:1234/bar/foo?a=b&b=c")!
        
        let components = url.deepLinkComponents
        
        XCTAssertNotNil(components)
        XCTAssertEqual(components!.count, 3)
        XCTAssertEqual(components![0], "walmart.com")
        XCTAssertEqual(components![1], "bar")
        XCTAssertEqual(components![2], "foo")
    }

    func test_deepLinkComponents_encodedPathPartsAreRetained() {
        let url = URL(string: "scheme://webview/https%3A%2F%2Fwww.foo.com%2Fbar")!
        
        let components = url.deepLinkComponents
        
        XCTAssertNotNil(components)
        XCTAssertEqual(components!.count, 2)
        XCTAssertEqual(components![0], "webview")
        XCTAssertEqual(components![1], "https%3A%2F%2Fwww.foo.com%2Fbar")
    }

    func test_deepLinkComponents_hostIsIncludedInComponents() {
        let url = URL(string: "scheme://walmart.com")!
        let host = url.host!
        let components = url.deepLinkComponents
        
        XCTAssertEqual(components![0], host)
    }
}
