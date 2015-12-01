//
//  RouterTests.swift
//  THGRouter
//
//  Created by Angelo Di Paolo on 12/1/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import XCTest
import THGRouter

class RouterTests: XCTestCase {
    
    func testBasicOtherRoute() {
        let router = Router.sharedInstance
        let handlerRanExpectation = expectationWithDescription("route handler should run")
        
        let route = Route("foo", type: .Other) { (variable) in
            handlerRanExpectation.fulfill()
            return nil
        }
        
        router.register(route)
        router.evaluate(["foo"])
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testRegister() {
        let router = Router.sharedInstance
        
        let route = Route("registerTest", type: .Other) { (variable) in
            return nil
        }
        
        let originalCount = router.routes.count
        router.register(route)
        XCTAssertTrue(router.routes.count > originalCount)
    }
    
    func testRoutesByName() {
        let router = Router.sharedInstance
        
        router.register(Route("testRouteName", type: .Other) { (variable) in
            return nil
        })
        
        
        router.register(Route("testRouteName", type: .Other) { (variable) in
            return nil
        })
        
        
        let namedRoutes = router.routesByName("testRouteName")
        let fakeRoutes = router.routesByName("definitelyNotARealRouteNameYo")

        XCTAssertEqual(namedRoutes.count, 2)
        XCTAssertEqual(fakeRoutes.count, 0)
    }
    
    func testRoutesByType() {
        let router = Router()
        
        router.register(Route("testRoutesByType", type: .Other) { (variable) in
            return nil
        })
        
        router.register(Route("testRoutesByType", type: .Other) { (variable) in
            return nil
        })
        
        let namedRoutes = router.routesByType(.Other)
        let fakeRoutes = router.routesByType(.Static)
        
        XCTAssertEqual(namedRoutes.count, 2)
        XCTAssertEqual(fakeRoutes.count, 0)
    }
}
