//
//  RouterTests.swift
//  THGRouter
//
//  Created by Angelo Di Paolo on 12/1/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import XCTest
@testable import THGRouter

class RouterTests: XCTestCase {
    func test_updateNavigator() {
        XCTAssertTrue(false)
    }
}

extension RouterTests {
    func test_routesByName_returnsRegisteredRoutesForValidName() {
        let router = Router()
        let name = "testRouteName"
        router.register(Route(name, type: .Other))
        router.register(Route(name, type: .Other))
        
        let namedRoutes = router.routesByName(name)
        XCTAssertEqual(namedRoutes.count, 2)
        
        for route in namedRoutes {
            XCTAssertNotNil(route.name)
            XCTAssertEqual(route.name, name)
        }
    }
    
    func test_routesByName_returnsEmptyArrayForBogusRouteName() {
        let router = Router()
        let fakeRoutes = router.routesByName("definitelyNotARealRouteNameYo")
        
        XCTAssertTrue(fakeRoutes.isEmpty)
    }
}

extension RouterTests {
    func test_routesByType_returnsRegisteredRoutesForValidType() {
        let router = Router()
        let routeName = "testRoutesByType"
        router.register(Route(routeName, type: .Other))
        router.register(Route(routeName, type: .Other))
        
        let namedRoutes = router.routesByType(.Other)
        XCTAssertEqual(namedRoutes.count, 2)
        
        for route in namedRoutes {
            XCTAssertNotNil(route.name)
            XCTAssertEqual(route.name, routeName)
            XCTAssertEqual(route.type, RoutingType.Other)
        }
    }
    
    func test_routesByType_returnsRegisteredRoutesForBogusType() {
        let router = Router()
        router.register(Route("testRoutesByType", type: .Other))
        router.register(Route("testRoutesByType", type: .Other))
        
        let fakeRoutes = router.routesByType(.Static)
        XCTAssertTrue(fakeRoutes.isEmpty)
    }
}

extension RouterTests {
    func test_register_namedRouteGetsAppendedToRoutes() {
        let router = Router()
        let route = Route("registerTest", type: .Other)
        
        router.register(route)
        XCTAssertEqual(router.routes.count, 1)
    }
    
    func test_register_unnamedRouteDoesNotGetAppendedToRoutes() {
        let router = Router()
        let route = Route("registerTest", type: .Other)
        let variableRoute = Route(type: .Variable, parentRoute: route)
        variableRoute.parentRoute = nil
        
        router.register(variableRoute)
        XCTAssertEqual(router.routes.count, 0)
    }
    
    func test_register_parentRouteIsAppendedWhenRegisteringItsSubRoute() {
        let router = Router()
        let route = Route("parentRoute", type: .Other)
        let subRoute = Route("subRoute", type: .Other, parentRoute: route)
        
        router.register(subRoute)
        XCTAssertEqual(router.routes[0], route)
        XCTAssertNotEqual(router.routes[0], subRoute)
    }
}

extension RouterTests {
    func test_evaluate_returnsTrueForHandledURL() {
        let router = Router()
        router.register(Route("walmart.com", type: .Other))
        
        let routeWasHandled = router.evaluate(["walmart.com"])
        XCTAssertTrue(routeWasHandled)
    }
    
    func test_evaluate_returnsFalseForUnhandledURL() {
        let router = Router()
        
        let routeWasHandled = router.evaluate(["walmart.com"])
        XCTAssertFalse(routeWasHandled)
    }
}

extension RouterTests {
    func test_evaluateURL_returnsTrueForHandledURL() {
        let router = Router()
        router.register(Route("walmart.com", type: .Other))
        let url = NSURL(string: "scheme://walmart.com")!
        let routeWasHandled = router.evaluateURL(url)
        
        XCTAssertTrue(routeWasHandled)
    }
    
    func test_evaluateURL_returnsFalseForUnhandledURL() {
        let router = Router()
        let url = NSURL(string: "scheme://walmart.com")!
        
        let routeWasHandled = router.evaluateURL(url)
        XCTAssertFalse(routeWasHandled)
    }
    
    func test_evaluateURL_executesActionWithMultipleURLComponents() {
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
    
    func test_evaluateURL_executesActionWithSingleVariableComponent() {
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
    
    
    func test_evaluateURL_executesActionWithSingleRouteComponent() {
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
    
    func test_evaulate_executesActionWithBasicOtherRoute() {
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
}

extension RouterTests {
    func test_evaluateURLString_returnsTrueForHandledURL() {
        let router = Router()
        router.register(Route("walmart.com", type: .Other))
        
        let routeWasHandled = router.evaluateURLString("scheme://walmart.com")
        XCTAssertTrue(routeWasHandled)
    }
    
    func test_evaluateURLString_returnsFalseForUnhandledURL() {
        let router = Router()
        
        let routeWasHandled = router.evaluateURLString("scheme://walmart.com")
        XCTAssertFalse(routeWasHandled)
    }
}

extension RouterTests {
    func test_routesForURL() {
        let router = Router()
        
        router.register(Route("walmart.com", type: .Other) { variable in
            return nil
        })
                
        
        router.register(Route("walmart.com", type: .Other) { variable in
            return nil
        }.variable() { variable in

            print("variable = \(variable)")
            return nil
        })
        
        router.register(Route("walmart.com", type: .Other).route("foo", type: .Other) { variable in
            return nil
        })
        
        
        let fooRoute = Route("walmart.com", type: .Other).route("foo", type: .Other)
        
        fooRoute.route("bar", type: .Other) { variable in
            return nil
        }
        
        fooRoute.route("bar", type: .Other) { variable in
            return nil
        }
        
        router.register(fooRoute)
        
        
        router.register(Route("walmart.com", type: .Other).route("bar", type: .Other) { variable in
            return nil
            })
        
        router.evaluate(["walmart.com", "foo", "bar"])
        
        let routes = router.routesForURL(NSURL(string: "scheme://walmart.com/foo/bar")!)
        
        XCTAssertNotNil(routes)
        XCTAssertEqual(routes!.count, 2)
        
        for route in routes! {
            XCTAssertEqual(route.name!, "bar")
        }
    }
    
    
    func test_routesForURL_variables() {
        let router = Router()
        
        router.register(Route("walmart.com", type: .Other) { variable in
            return nil
            })
        
        
        router.register(Route("walmart.com", type: .Other) { variable in
            return nil
            }.variable() { variable in
                
                print("variable = \(variable)")
                return nil
            })
        
        router.register(Route("walmart.com", type: .Other).route("foo", type: .Other) { variable in
            return nil
            })
        
        
        let fooRoute = Route("walmart.com", type: .Other).route("foo", type: .Other)
        
        fooRoute.route("bar", type: .Other) { variable in
            return nil
        }
        
        fooRoute.route("bar", type: .Other) { variable in
            return nil
        }
        
        router.evaluate(["walmart.com", "foo"])
        
        let routes = router.routesForURL(NSURL(string: "scheme://walmart.com/foo")!)
        
        XCTAssertNotNil(routes)
        XCTAssertEqual(routes!.count, 2)
        
        for route in routes! {
            XCTAssertEqual(route.name!, "bar")
        }
    }
}
