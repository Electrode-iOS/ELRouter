//
//  RouteTests.swift
//  ELRouter
//
//  Created by Angelo Di Paolo on 12/09/15.
//  Copyright © 2015 Walmart. All rights reserved.
//

import XCTest
@testable import ELRouter

// MARK: - initialization Tests

class RouteTests: XCTestCase {
    func test_initialization_withName() {
        let route = Route("testName", type: .other)
        
        XCTAssertNotNil(route.name)
        XCTAssertEqual(route.name, "testName")
        XCTAssertEqual(route.type, RoutingType.other)
        XCTAssertNil(route.parentRoute)
        XCTAssertNil(route.parentRouter)
        XCTAssertNil(route.action)
        XCTAssertTrue(route.userInfo.isEmpty)
        XCTAssertTrue(route.subRoutes.isEmpty)
    }
    
    func test_initialization_withNameAndAction() {
        let route = Route("testName", type: .other) { _, _, _ in
            return nil
        }
        
        XCTAssertNotNil(route.name)
        XCTAssertEqual(route.name, "testName")
        XCTAssertEqual(route.type, RoutingType.other)
        XCTAssertNil(route.parentRoute)
        XCTAssertNil(route.parentRouter)
        XCTAssertNotNil(route.action)
        XCTAssertTrue(route.userInfo.isEmpty)
        XCTAssertTrue(route.subRoutes.isEmpty)
    }
    
    func test_initialization_withoutName() {
        let parentRoute = Route("parent", type: .other)
        let route = Route(type: .other, parentRoute: parentRoute)
        
        XCTAssertNil(route.name)
        XCTAssertEqual(route.type, RoutingType.other)
        XCTAssertNotNil(route.parentRoute)
        XCTAssertEqual(route.parentRoute, parentRoute)
        XCTAssertNil(route.parentRouter)
        XCTAssertNil(route.action)
        XCTAssertTrue(route.userInfo.isEmpty)
        XCTAssertTrue(route.subRoutes.isEmpty)
    }
    
    func test_initialization_withTypeAndAction() {
        let parentRoute = Route("parent", type: .other)
        let route = Route(type: .other, parentRoute: parentRoute) { _, _, _ in
            return nil
        }
        
        XCTAssertNil(route.name)
        XCTAssertEqual(route.type, RoutingType.other)
        XCTAssertNotNil(route.parentRoute)
        XCTAssertEqual(route.parentRoute, parentRoute)
        XCTAssertNil(route.parentRouter)
        XCTAssertNotNil(route.action)
        XCTAssertTrue(route.userInfo.isEmpty)
        XCTAssertTrue(route.subRoutes.isEmpty)
    }
    
    func test_initialization_withNamedAndParentRoute() {
        let parentRoute = Route("parent", type: .other)
        let route = Route("sub", type: .other, parentRoute: parentRoute) { _, _, _ in
            return nil
        }
        
        XCTAssertNotNil(route.name)
        XCTAssertEqual(route.name, "sub")
        XCTAssertEqual(route.type, RoutingType.other)
        XCTAssertNotNil(route.parentRoute)
        XCTAssertNil(route.parentRouter)
        XCTAssertNotNil(route.action)
        XCTAssertTrue(route.userInfo.isEmpty)
        XCTAssertTrue(route.subRoutes.isEmpty)
    }
}

// MARK: - variable Tests

extension RouteTests {
    func test_variable_appendsSubRoute() {
        let parentRoute = Route("variableTest", type: .other)
        parentRoute.variable()
        
        XCTAssertFalse(parentRoute.subRoutes.isEmpty)
        XCTAssertEqual(parentRoute.subRoutes.count, 1)
    }
    
    func test_variable_returnsSubRoute() {
        let parentRoute = Route("variableTest", type: .other)
        let variableRoute = parentRoute.variable()
        
        XCTAssertEqual(variableRoute.type, RoutingType.variable)
    }
    
    func test_variable_setsParentRouter() {
        let router = Router()
        let parentRoute = Route("variableTest", type: .other)
        parentRoute.parentRouter = router
        
        parentRoute.variable()
        XCTAssertEqual(parentRoute.subRoutes[0].parentRouter, router)
    }
    
    func test_variable_setsParentRoute() {
        let parentRoute = Route("variableTest", type: .other)
        
        parentRoute.variable()
        XCTAssertEqual(parentRoute.subRoutes[0].parentRoute, parentRoute)
    }
}

// MARK: - route Tests

extension RouteTests {
    func test_route_appendsSubRoute() {
        let parentRoute = Route("routeTest", type: .other)
        parentRoute.route("sub", type: .other)
        
        XCTAssertFalse(parentRoute.subRoutes.isEmpty)
        XCTAssertEqual(parentRoute.subRoutes.count, 1)
    }
    
    func test_route_returnsSubRoute() {
        let parentRoute = Route("routeTest", type: .other)
        let subRoute = parentRoute.route("sub", type: .other)
        
        XCTAssertEqual(subRoute.name, "sub")
        XCTAssertEqual(subRoute.type, RoutingType.other)
    }
    
    func test_route_setsParentRouter() {
        let router = Router()
        let parentRoute = Route("routeTest", type: .other)
        parentRoute.parentRouter = router
        
        parentRoute.route("sub", type: .other)
        XCTAssertEqual(parentRoute.subRoutes[0].parentRouter, router)
    }
    
    func test_route_setsParentRoute() {
        let parentRoute = Route("variableTest", type: .other)
        
        parentRoute.route("sub", type: .other)
        XCTAssertEqual(parentRoute.subRoutes[0].parentRoute, parentRoute)
    }
}

// MARK: - execute Tests

extension RouteTests {
    func test_execute_returnsActionResult() {
        let route = Route("executeTest", type: .other) { variable, _, _ in
            return "foo"
        }
        
        var associatedData: AssociatedData? = nil
        let result = route.execute(false, variable: nil, remainingComponents: [String](), associatedData: &associatedData)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result is String)
        XCTAssertEqual(result as? String, "foo")
    }
    
    func test_execute_passesVariableToActionClosure() {
        let route = Route("executeTest", type:  .fixed) { variable, _, _ in
            XCTAssertNotNil(variable)
            XCTAssertEqual(variable, "foo")
            return nil
        }
        
        var associatedData: AssociatedData? = nil
        route.execute(false, variable: "foo", remainingComponents: [String](), associatedData: &associatedData)
    }
    
    /* Broken Test
    func test_execute_pushesViewController() {
        let router = Router()
        let navigator = MockNavigator()
        router.navigator = navigator
        let route = Route("executeTest", type:  .Push) { variable, _ in
            let vc = UIViewController(nibName: nil, bundle: nil)
            vc.title = "Push Test"
            return vc
        }
        route.parentRouter = router
        
        route.execute(false)
        
        XCTAssertEqual(navigator.testNavigationController?.viewControllers.count, 2)
        XCTAssertEqual(navigator.testNavigationController?.topViewController?.title, "Push Test")
    }*/

// TODO: Test fails due to lack of view hierarchy and I don't have a solution at this time.
//    func test_execute_presentsModalViewController() {
//        let router = Router()
//        let navigator = MockNavigator()
//        router.navigator = navigator
//        let route = Route("executeTest", type:  .Modal) { variable in
//            let vc = UIViewController(nibName: nil, bundle: nil)
//            vc.title = "Modal Test"
//            return vc
//        }
//        route.parentRouter = router
//        
//        route.execute(false)
//        
//        XCTAssertEqual(navigator.testNavigationController?.viewControllers.count, 1)
//        XCTAssertNotNil(navigator.testNavigationController?.topViewController?.presentedViewController)
//        XCTAssertEqual(navigator.testNavigationController?.topViewController?.presentedViewController?.title, "Modal Test")
//    }
    
    func test_execute_returnsStaticValue() {
        let route = Route("executeTest", type:  .fixed) { _, _, _ in
            let vc = UIViewController(nibName: nil, bundle: nil)
            vc.title = "Static Test"
            return vc
        }
        
        let staticValue = route.execute(false)
        
        XCTAssertNotNil(staticValue)
        XCTAssertTrue(staticValue is UIViewController)
        XCTAssertEqual((staticValue as? UIViewController)?.title, "Static Test")
    }
    
    func test_execute_performsSegue() {
        let router = Router()
        let navigator = MockNavigator()
        router.navigator = navigator
        let vc = ExecuteSegueTestViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: vc)
        navigator.setViewControllers([navVC], animated: false)
        navigator.selectedViewController = navVC
        let route = Route("segueTest", type:  .segue) { _, _, _ in
            return "fooSegue"
        }
        route.parentRouter = router

        route.execute(false)
        
        XCTAssertEqual(vc.segueIdentifierValue, "fooSegue")
    }
    
    func test_execute_setsSelectedViewController() {
        let router = Router()
        let navigator = MockNavigator()
        router.navigator = navigator
        let vc = UIViewController(nibName: nil, bundle: nil)
        let route = Route("selectTest", type: .fixed) { _, _, _ in
            return vc
        }
        route.parentRouter = router
        route.execute(false) // setup staticValue

        route.execute(false)
        
        XCTAssertEqual(vc, navigator.selectedViewController)
    }
}

// MARK: - routesForComponents Tests

extension RouteTests {
    func test_routesForComponents_returnsEmptyResultsForBogusComponents() {
        let route = Route("variableTest", type: .other)
        let results = route.routes(forComponents: ["walmart.com", "foo"])
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_routesForComponents_returnsEmptyResultsForEmptyComponents() {
        let route = Route("variableTest", type: .other)
        let results = route.routes(forComponents: [])
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_routesForComponents_returnsNamedRoutesForValidComponents() {
        let route = Route("variableTest", type: .other)
        route.route("walmart.com", type: .other).route("foo", type: .other)
        
        let results = route.routes(forComponents: ["walmart.com", "foo"])
        
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].name, "walmart.com")
        XCTAssertEqual(results[1].name, "foo")
    }
    
    func test_routesForComponents_returnsVariableRoutesWhenNextComponentExists() {
        let route = Route("variableTest", type: .other)
        route.route("walmart.com", type: .other).variable().route("foo", type: .other)
        
        let results = route.routes(forComponents: ["walmart.com", "12345", "foo"])
        
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].name, "walmart.com")
        XCTAssertEqual(results[1].type, RoutingType.variable)
        XCTAssertEqual(results[2].name, "foo")
    }
    
    func test_routesForComponents_returnsVariableRoutesWhenNextComponentIsMissing() {
        let route = Route("variableTest", type: .other)
        route.route("walmart.com", type: .other).variable().route("foo", type: .other)
        
        let results = route.routes(forComponents: ["walmart.com", "12345"])
        
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].name, "walmart.com")
        XCTAssertEqual(results[1].type, RoutingType.variable)
    }
}

// MARK: - routesByName Tests

extension RouteTests {
    func test_routesByName_returnsRoutesForValidName() {
        let testName1 = "subRouteName1"
        let route = Route("routesByName", type: .other)
        route.variable()
        route.route(testName1, type: .other)
        
        let namedRoutes = route.routes(forName: testName1)
        XCTAssertFalse(namedRoutes.isEmpty)
        XCTAssertEqual(namedRoutes.count, 1)
        
        for route in namedRoutes {
            XCTAssertNotNil(route.name)
            XCTAssertEqual(route.name, testName1)
        }
    }
    
    func test_routesByName_returnsEmptyArrayForBogusName() {
        let testName1 = "subRouteName1"
        let testName2 = "subRouteName2"
        let route = Route("routesByName", type: .other)
        route.variable()
        route.route(testName1, type: .other)
        route.route(testName2, type: .fixed)
        
        let namedRoutes = route.routes(forName: "bogusName")
        XCTAssertTrue(namedRoutes.isEmpty)
    }
}

// MARK: - routesByType Tests

extension RouteTests {
    func test_routesByType_returnsRoutesForValidType() {
        let testName1 = "subRouteName1"
        let testName2 = "subRouteName2"
        let route = Route("routesByName", type: .other)
        route.variable()
        route.route(testName1, type: .fixed)
        route.route(testName2, type: .fixed)
        
        let filteredRoutes = route.routes(forType: .fixed)
        XCTAssertFalse(filteredRoutes.isEmpty)
        XCTAssertEqual(filteredRoutes.count, 2)
        
        for route in filteredRoutes {
            XCTAssertEqual(route.type, RoutingType.fixed)
        }
    }
    
    func test_routesByType_returnsEmptyArrayForBogusType() {
        let testName1 = "subRouteName1"
        let testName2 = "subRouteName2"
        let route = Route("routesByName", type: .other)
        route.variable()
        route.route(testName1, type: .fixed)
        route.route(testName2, type: .fixed)
        
        let filteredRoutes = route.routes(forType: .other)
        XCTAssertTrue(filteredRoutes.isEmpty)
    }
}

// MARK: - routeByType

extension RouteTests {
    func test_routeByType_returnsRouteForValidType() {
        let testName = "subRouteName"
        let route = Route("routeByName", type: .other)
        route.route(testName, type: .fixed)
        
        let fetchedRoute = route.route(forType: .fixed)
        
        XCTAssertNotNil(fetchedRoute)
        XCTAssertEqual(fetchedRoute?.type, RoutingType.fixed)
        XCTAssertEqual(fetchedRoute?.name, testName)
    }
    
    func test_routeByType_returnsNilForBogusType() {
        let route = Route("routeByName", type: .other)
        
        let fetchedRoute = route.route(forType: .fixed)
        
        XCTAssertNil(fetchedRoute)
    }
}

// MARK: - Mock vc

private class ExecuteSegueTestViewController: UIViewController {
    var segueIdentifierValue: String?
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        segueIdentifierValue = identifier
    }
}
