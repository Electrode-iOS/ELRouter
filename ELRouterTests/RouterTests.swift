//
//  RouterTests.swift
//  ELRouter
//
//  Created by Angelo Di Paolo on 12/1/15.
//  Copyright © 2015 Walmart. All rights reserved.
//

import XCTest
@testable import ELRouter
import ELFoundation

enum TestRoutes: RouteEnum {
    case Home
    case ScreenOne
    case ScreenTwo
    
    var spec: RouteSpec {
        switch self {
        case .Home: return (name: "home", type: .Static, example: "home://")
        case .ScreenOne: return (name: "screen-one", type: .Static, example: "screenone://")
        case .ScreenTwo: return (name: "screen-two", type: .Static, example: "screentwo://")
        }
    }
}

// MARK: - translate Tests

class RouterTests: XCTestCase {
    let longTimeout: NSTimeInterval = 15.0
    
    func test_updateNavigator_setsTabBarViewControllersBasedOnStaticRoutes() {
        let router = Router()
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        router.navigator = tabBarController
                
        router.register(Route("tabOne", type: .Static) { _, _ in
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.register(Route("tabTwo", type: .Static) { _, _ in
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.register(Route("tabThree", type: .Static) { _, _ in
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.updateNavigator()
        
        XCTAssertNotNil(tabBarController.viewControllers)
        XCTAssertEqual(tabBarController.viewControllers?.count, 3)
    }
    
    func test_updateNavigator_doesNotSetTabBarViewControllersWithNilActionReturns() {
        let router = Router()
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        router.navigator = tabBarController
        
        router.register(Route("tabOne", type: .Static) { _, _ in
            return nil
        })
        
        router.register(Route("tabTwo", type: .Static) { _, _ in
            return nil
        })
        
        router.register(Route("tabThree", type: .Static) { _, _ in
            return nil
        })
        
        router.updateNavigator()
        
        XCTAssertNil(tabBarController.viewControllers)
    }
    
    func test_updateNavigator_doesNotSetTabBarViewControllersWithNilActions() {
        let router = Router()
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        router.navigator = tabBarController
        
        router.register(Route("tabOne", type: .Static))
        router.register(Route("tabTwo", type: .Static))
        router.register(Route("tabThree", type: .Static))
        
        router.updateNavigator()
        
        XCTAssertNil(tabBarController.viewControllers)
    }
    
    func test_updateNavigator_executesStaticRoutes() {
        let router = Router()
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        router.navigator = tabBarController
        
        let tabOneExpectation = expectationWithDescription("tabOne static route executes")
        let tabTwoExpectation = expectationWithDescription("tabTwo static route executes")
        let tabThreeExpectation = expectationWithDescription("tabThree static route executes")

        router.register(Route("tabOne", type: .Static) { _, _ in
            tabOneExpectation.fulfill()
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.register(Route("tabTwo", type: .Static) { _, _ in
            tabTwoExpectation.fulfill()
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.register(Route("tabThree", type: .Static) { _, _ in
            tabThreeExpectation.fulfill()
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.updateNavigator()
        
        waitForExpectationsWithTimeout(longTimeout, handler: nil)
    }
    
    func test_updateNavigator_doesNotExecuteStaticRoutesWithNilNavigator() {
        let router = Router()
        
        router.register(Route("tabOne", type: .Static) { _, _ in
            XCTAssertTrue(false)
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.register(Route("tabTwo", type: .Static) { _, _ in
            XCTAssertTrue(false)
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.register(Route("tabThree", type: .Static) { _, _ in
            XCTAssertTrue(false)
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.updateNavigator()
    }
}

// MARK: - translate Tests

extension RouterTests {
    // TODO: implement tests
    func test_translate_shouldNotThrowExceptionForNewTranslation() {
        let router = Router()
        
        // nothing to assert because test will fail if exception is thrown
        router.translate("foo", to: "bar")
    }
    
    func test_translate_throwsExceptionForExistingTranslation() {
        let router = Router()
        router.translate("foo", to: "bar")
        
        XCTAssertThrows({ () -> Void in
            router.translate("foo", to: "bar")
        }, "Exception caught as expected.")

    }
}

// MARK: - routesForComponents Tests

extension RouterTests {
    func test_routesForComponents_returnsEmptyResultsForBogusComponents() {
        let router = Router()
        let results = router.routesForComponents(["walmart.com", "foo"])
        
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_routesForComponents_returnsEmptyResultsForEmptyComponents() {
        let router = Router()
        let results = router.routesForComponents([])
        
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_routesForComponents_returnsNamedRoutesForValidComponents() {
        let router = Router()
        let route = Route("walmart.com", type: .Other).route("foo", type: .Other)
        router.register(route)
        
        let results = router.routesForComponents(["walmart.com", "foo"])
        
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].name, "walmart.com")
        XCTAssertEqual(results[1].name, "foo")
    }
}

extension RouterTests {
    func test_routesForURL__returnsNamedRoutesForValidURL() {
        let router = Router()
        let route = Route("walmart.com", type: .Other).route("foo", type: .Other)
        router.register(route)
        let url = NSURL(string: "scheme://walmart.com/foo")!
        
        let results = router.routesForURL(url)
        
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].name, "walmart.com")
        XCTAssertEqual(results[1].name, "foo")
    }
    
    func test_routesForURL__returnsEmptyResultsForBadURL() {
        let router = Router()
        let url = NSURL(string: "::")!
        
        let results = router.routesForURL(url)
        
        XCTAssertTrue(results.isEmpty)
    }
}

// MARK: - routesByName Tests

extension RouterTests {
    /* Broken Test
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
    } */
    
    func test_routesByName_returnsEmptyArrayForBogusRouteName() {
        let router = Router()
        let fakeRoutes = router.routesByName("definitelyNotARealRouteNameYo")
        
        XCTAssertTrue(fakeRoutes.isEmpty)
    }
}

// MARK: - routesByType Tests

extension RouterTests {
    /* Broken Test
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
    }*/
}

// MARK: - register Tests

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

// MARK: - evaluate Tests

extension RouterTests {
    func test_evaluate_returnsTrueForHandledURL() {
        let router = Router()
        router.register(Route("walmart.com", type: .Other))
        
        let handlerExpectation = expectationWithDescription("route handler should run")

        let routeWasHandled = router.evaluate(["walmart.com"]) {
            handlerExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(longTimeout, handler: nil)
        XCTAssertTrue(routeWasHandled)
    }
    
    func test_evaluate_returnsFalseForUnhandledURL() {
        let router = Router()
        
        let routeWasHandled = router.evaluate(["walmart.com"])

        XCTAssertFalse(routeWasHandled)
    }
}

// MARK: - evaluateURL Tests

extension RouterTests {
    func test_evaluateURL_returnsTrueForHandledURL() {
        let router = Router()
        router.register(Route("walmart.com", type: .Other))
        let url = NSURL(string: "scheme://walmart.com")!
        
        let handlerExpectation = expectationWithDescription("route handler should run")
        let routeWasHandled = router.evaluateURL(url) {
            handlerExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(longTimeout, handler: nil)
        XCTAssertTrue(routeWasHandled)
    }
    
    func test_evaluateURL_returnsFalseForUnhandledURL() {
        let router = Router()
        let url = NSURL(string: "scheme://walmart.com")!
        
        let routeWasHandled = router.evaluateURL(url)
        
        XCTAssertFalse(routeWasHandled)
    }
    
    func test_evaluateURL_returnsFalseForBadURL() {
        let router = Router()
        let url = NSURL(string: "::")!
        
        let routeWasHandled = router.evaluateURL(url)
        
        XCTAssertFalse(routeWasHandled)
    }
    
    func test_evaluateURL_executesActionWithMultipleURLComponents() {
        let router = Router()
        let handlerExpectation = expectationWithDescription("route handler should run")

        router.register(Route("walmart.com", type: .Other).route("item", type: .Other, action: { variable, _ in
            XCTAssertNotNil(variable)
            XCTAssertEqual(variable!, "12345")
            return nil
        }).variable())
        
        router.evaluateURL(NSURL(string: "scheme://walmart.com/item/12345")!) {
            handlerExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(longTimeout, handler: nil)
    }
    
    func test_evaluateURL_executesActionWithSingleVariableComponent() {
        let router = Router()
        let handlerExpectation = expectationWithDescription("route handler should run")
        
        router.register(Route("walmart.com", type: .Other).variable() { variable, _ in
            XCTAssertNotNil(variable)
            XCTAssertEqual(variable!, "12345")
            return nil
        })
        
        router.evaluateURL(NSURL(string: "scheme://walmart.com/12345")!) {
            handlerExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(longTimeout, handler: nil)
    }
    
    func test_evaluateURL_executesActionWithSingleRouteComponent() {
        let router = Router()
        let handlerExpectation = expectationWithDescription("route handler should run")
        var didExecuteLastRoute = false
        
        router.register(Route("walmart.com", type: .Other) { variable, _ in
            didExecuteLastRoute = true
            return nil
            })
        
        router.navigator = UITabBarController(nibName: nil, bundle: nil)
        
        let executed = router.evaluateURL(NSURL(string: "scheme://walmart.com")!) {
            if didExecuteLastRoute {
                handlerExpectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(longTimeout, handler: nil)

        XCTAssert(executed, "This should've failed")
        XCTAssertTrue(didExecuteLastRoute)
    }
    
    func test_evaulate_executesActionWithBasicOtherRoute() {
        let router = Router()
        let handlerRanExpectation = expectationWithDescription("route handler should run")
        var didExecuteLastRoute = false
        
        let route = Route("foo", type: .Other) { variable, _ in
            didExecuteLastRoute = true
            return nil
        }
        
        router.register(route)
        router.navigator = UITabBarController(nibName: nil, bundle: nil)
        
        router.evaluate(["foo"]) {
            if didExecuteLastRoute {
                handlerRanExpectation.fulfill()
            }
        }
  
        waitForExpectationsWithTimeout(longTimeout, handler: nil)
    }
}

// MARK: - evaluateURLString Tests

extension RouterTests {
    func test_evaluateURLString_returnsTrueForHandledURL() {
        let router = Router()
        let completionRanExpectation = expectationWithDescription("route completion handler should run")
        
        router.register(Route("walmart.com", type: .Other))
        
        let routeWasHandled = router.evaluateURLString("scheme://walmart.com") {
            completionRanExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(longTimeout, handler: nil)
  
        XCTAssertTrue(routeWasHandled)
    }
    
    func test_evaluateURLString_hitsCompletionBlock() {
        let completionRanExpectation = expectationWithDescription("route completion handler should run")

        let router = Router()
        router.register(Route("walmart.com", type: .Other))
        
        let routeWasHandled = router.evaluateURLString("scheme://walmart.com", animated: false) {
            completionRanExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(longTimeout, handler: nil)
        
        XCTAssertTrue(routeWasHandled)
    }

    func test_evaluateURLString_returnsFalseForUnhandledURL() {
        let router = Router()
        
        // This is not evident, but the completion block will not be called when the route
        // fails to run, therefore you cannot rely on it for testing this scenario
        let routeWasHandled = router.evaluateURLString("scheme://walmart.com")
        
        XCTAssertFalse(routeWasHandled)
    }
    
    func test_evaluateURLString_returnsFalseForBadURLL() {
        let router = Router()
        
        let routeWasHandled = router.evaluateURLString("      ")
        
        XCTAssertFalse(routeWasHandled)
    }
}

// MARK: - processing Tests

extension RouterTests {
    func test_processing_returnsFalseWhenNoRoutesAreInFlight() {
        let router = Router()
        let processing = router.processing
        
        XCTAssertFalse(processing)
    }
}

// MARK: - associatedData Tests

extension NSString: AssociatedData { }

extension RouterTests {
    func test_evaulate_executesActionWithAssociatedData() {
        let router = Router()
       // let handlerRanExpectation = expectationWithDescription("route handler should run")
       // let handlerHasDataExpectation = expectationWithDescription("route handler should run")
        var capturedString = ""
        
        let route = Route("foo", type: .Other) { variable, associatedData in
            //handlerRanExpectation.fulfill()
            
            // Only capture the data here, don't use this to trigger
            // end of route execution because due to threading issues
            // parts of the next test could run when you are not expecting it to
            if let data = associatedData as? String {
                capturedString = data
            }
            
            return nil
        }
        
        router.register(route)
        router.navigator = UITabBarController(nibName: nil, bundle: nil)
        
        var didComplete = false
        router.evaluate(["foo"], associatedData: "blah") {
            if capturedString == "blah" {
                didComplete = true
            }
        }
        
        do {
            try waitForConditionsWithTimeout(longTimeout) { () -> Bool in
                return didComplete
            }
        } catch {
            // do nothing
            XCTFail()
        }
    }
}

// MARK: - Duplicate routes tests
extension RouterTests {
    func test_evaulate_duplicatedTopLevelRoute() {
        let router = Router()
        
        // Route 1
        let route1 = Route("foo", type: .Other) { variable, associatedData in
            return nil
            }.variable()
        router.register(route1)
        
        // Route 2
        let route2 = Route("foo", type: .Other) { variable, associatedData in
            return nil
        }.variable().variable()
        
        // this should throw because of dupes.
        XCTAssertThrows({
            router.register(route2)
        }, nil)
    }

    func test_evaulate_duplicatedSubRoute() {
        let router = Router()
        
        // Route 1
        let route1 = Route("foo", type: .Other) { variable, associatedData in
            return nil
        }
        router.register(route1)
        
        route1.route("foo", type: .Other) { _, _ in
            return nil
        }
        
        // this should throw because of dupes.
        XCTAssertThrows({
            route1.route("foo", type: .Other) { _, _ in
                return nil
            }
        }, nil)
    }

    func test_evaulate_duplicatedVariable() {
        let router = Router()
        
        // Route 1
        let route1 = Route("foo", type: .Other) { variable, associatedData in
            return nil
        }
        router.register(route1)
        
        route1.variable().route("foo", type: .Other) { _, _ in
            return nil
        }
        
        // this should throw because of dupes.
        XCTAssertThrows({
            route1.variable().route("bar", type: .Other) { _, _ in
                return nil
            }
        }, nil)
    }
    
    func test_evaluate_doubleVarRoute() {
        let router = Router()
        var didExectuteLastRoute = false
        
        // Route 1
        let route1 = Route("foo", type: .Other) { variable, associatedData in
            print("test_evaluate_doubleVarRoute foo route")
            return nil
        }.variable { (variable, associatedData) -> Any? in
            print("test_evaluate_doubleVarRoute first variable route")
            print(variable)
            return nil
        }.variable { (variable, associatedData) -> Any? in
            print("test_evaluate_doubleVarRoute second variable route")
            print(variable)
            didExectuteLastRoute = true
            return nil
        }
        router.register(route1)
        
        var didComplete = false
        router.evaluateURLString("walmart://foo/1234/5678") {
            didComplete = didExectuteLastRoute
        }
        
        do {
            try waitForConditionsWithTimeout(longTimeout, conditionsCheck: { () -> Bool in
                return didComplete
            })
        } catch {
            print("OMG!!!")
        }
        
        XCTAssertTrue(didComplete)
    }
    
    func test_evaluate_aliases() {
        let router = Router()
        let originalRouteExpectation = expectationWithDescription("original route completion handler should run")
        var didExecuteLastRoute = false

        var stagingMessage = ""
        
        // Route 1
        let route1 = Route("foo", type: .Other) { variable, associatedData in
            print(stagingMessage)
            print("test_evaluate_aliases foo route")
            return nil
        }.variable { (variable, associatedData) -> Any? in
            print("test_evaluate_aliases first variable route")
            print(variable)
            return nil
        }.variable { (variable, associatedData) -> Any? in
            print("test_evaluate_aliases second variable route")
            print(variable)
            didExecuteLastRoute = true
            return nil
        }
        router.register(route1)
        
        let aliasedRoute = Route("bar", type: .Alias) { variable, associatedData in
            return router.routeByName("foo")
        }

        router.register(aliasedRoute)
        
        stagingMessage = "Original route called"
        // check the main name.
        router.evaluateURLString("walmart://foo/1234/5678") {
            originalRouteExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(longTimeout, handler: nil)
        XCTAssertTrue(didExecuteLastRoute)
        
        // check the alias
        let aliasRouteExpectation = expectationWithDescription("alias route completion handler should run")

        stagingMessage = "Alias route called"
        didExecuteLastRoute = false
        let evaluated = router.evaluateURLString("walmart://bar/1234/5678") {
            aliasRouteExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(longTimeout, handler: nil)
    
        XCTAssertTrue(evaluated)
        XCTAssertTrue(didExecuteLastRoute)
        
    }

// TODO: Duplicated Routes are not allowed. Get an obj-c tryBlock added so we can catch NSException
//    func test_evaulate_duplicatedRoute() {
//        let router = Router()
//        
//        // Route 1
//        let route1 = Route("foo", type: .Other) { variable, associatedData in
//            return nil
//        }.variable()
//        router.register(route1)
//        
//        // Route 2
//        let route2 = Route("foo", type: .Other) { variable, associatedData in
//            return nil
//        }.variable().variable()
//        router.register(route2)
//        
//        let route1Result = router.evaluate(["foo", "bar"])
//        let route2Result = router.evaluate(["foo", "bar", "baz"])
//        
//        // wait for the router to finish processing.
//        do {
//            try waitForConditionsWithTimeout(2.0) { () -> Bool in
//                return router.processing == false
//            }
//        } catch {
//            // timeout occurred while processing.
//            XCTFail()
//        }
//        
//        XCTAssertTrue(route1Result)
//        XCTAssertTrue(route2Result)
//    }
}

// MARK: - serializedRoute Tests

extension RouterTests {
// TODO: fix this test. failing because UIViewController is being presented in a view that is not
// part of the view hiearchy
//    func test_serializedRoute_dismissesPresentedViewController() {
//        let router = Router()
//        let navigator = MockNavigator()
//        router.navigator = navigator
//        let viewController = UIViewController(nibName: nil, bundle: nil)
//        navigator.testNavigationController?.topViewController?.presentViewController(viewController, animated: false, completion: nil)
//        
//        XCTAssertNotNil(navigator.testNavigationController?.topViewController?.presentedViewController)
//
//        router.serializedRoute([], components: [], animated: false)
//        
//        XCTAssertNil(navigator.testNavigationController?.topViewController?.presentedViewController)
//    }
}

// MARK: Enum Tests

extension RouterTests {

    // Test routeByEnum success
    func testRouteByEnumFoundEnum() {
        let router = Router()

        let homeRoute = Route(TestRoutes.Home) { (_, _) in
            return nil
        }
        router.register(homeRoute)
        
        if let foundRoute = router.routeByEnum(TestRoutes.Home) {
            XCTAssert(foundRoute == homeRoute, "Routes do not match")
        } else {
            XCTFail("Route not found")
        }
    }
    
    // Test routeByEnum failure to find a route
    func testRouteByEnumMissingEnum() {
        let router = Router()
        
        let homeRoute = Route(TestRoutes.Home) { (_, _) in
            return nil
        }
        router.register(homeRoute)
        
        if let foundRoute = router.routeByEnum(TestRoutes.ScreenOne) {
            XCTFail("Should not have found a route, but found \(foundRoute))")
        }    }
}
