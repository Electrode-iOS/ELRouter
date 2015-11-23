//
//  THGRouterTests.swift
//  THGRouterTests
//
//  Created by Brandon Sneed on 10/19/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import XCTest

class THGRouterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testNSURLPathBehavior() {
        let url = NSURL(string: "walmart://something/1234/abcd?blah1=1,blah2=2")
        print(url!.pathComponents)

        let url2 = NSURL(string: "walmart://:something/1234/abcd?blah1=1,blah2=2")
        print(url2!.pathComponents)
    }
    
    
    
}
