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
        let router = Router()
        let handlerRanExpectation = expectationWithDescription("route handler should run")
        
        let route = Route("foo", type: .Other) { (variable) in
            handlerRanExpectation.fulfill()
            return nil
        }
        
        router.register(route)
        router.navigator = UITabBarController(nibName: nil, bundle: nil)
        
        router.evaluate(["foo"])
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testRegister() {
        let router = Router()
        
        let route = Route("registerTest", type: .Other) { (variable) in
            return nil
        }
        
        let originalCount = router.routes.count
        router.register(route)
        XCTAssertTrue(router.routes.count > originalCount)
    }
    
    func testRoutesByName() {
        let router = Router()
        
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
    
    func testEvaluateURLAgainstSingleRouteComponent() {
        let router = Router()
        let handlerExpectation = expectationWithDescription("route handler should run")
        
        router.register(Route("walmart.com", type: .Other) { variable in
            handlerExpectation.fulfill()
            return nil
        })
        
        router.navigator = UITabBarController(nibName: nil, bundle: nil)
        let executed = router.evaluateURL(NSURL(string: "scheme://walmart.com")!)
        
        XCTAssert(executed, "This should've failed")
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    // TODO: make this test pass
    func testEvaluateURLAgainstSingleVariableComponent() {
        let router = Router()
        let handlerExpectation = expectationWithDescription("route handler should run")
        
        router.register(Route("walmart.com", type: .Other).variable() { variable in
            XCTAssertNotNil(variable)
            XCTAssertEqual(variable!, "12345")
            
            handlerExpectation.fulfill()
            return nil
        })
        
        
        router.evaluateURL(NSURL(string: "scheme://walmart.com/12345")!)
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    // TODO: make this test pass
    func testEvaluateURLAgainstMultipleRouteComponents() {
        let router = Router()
        let handlerExpectation = expectationWithDescription("route handler should run")
        
        router.register(Route("walmart.com", type: .Other).route("item", type: .Other).variable().route("something", type: .Other) { variable in
            XCTAssertNotNil(variable)
            XCTAssertEqual(variable!, "12345")
            handlerExpectation.fulfill()
            return nil
        })
        
        router.evaluateURL(NSURL(string: "scheme://walmart.com/item/12345/something")!)
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
}

// MARK: - Evaluate Tests

extension Router {
    func test_evaluate_returnsTrueForHandledURL() {
        let router = Router()
        
        router.register(Route("walmart.com", type: .Other) { variable in
            return nil
        })
        
        
        let routeWasHandled = router.evaluate(["walmart.com"])
        XCTAssertTrue(routeWasHandled)
    }
    
    func test_evaluate_returnsFalseForUnhandledURL() {
        let router = Router()
        
        let routeWasHandled = router.evaluate(["walmart.com"])
        XCTAssertFalse(routeWasHandled)
    }
}
