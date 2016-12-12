//
//  RouteCollectionTypeTests.swift
//  ELRouter
//
//  Created by Angelo Di Paolo on 12/10/15.
//  Copyright © 2015 Walmart. All rights reserved.
//

import XCTest
@testable import ELRouter

class RouteCollectionTypeTests: XCTestCase {
    func test_filterByName_returnsRoutesForValidName() {
        let routeName = "filterByName"
        let routes = [Route(routeName, type: .other), Route(routeName, type: .fixed), Route("otherName", type: .fixed)]
        
        let filteredRoutes = routes.filterByName(routeName)
        XCTAssertFalse(filteredRoutes.isEmpty)
        XCTAssertEqual(filteredRoutes.count, 2)
        
        for route in filteredRoutes {
            XCTAssertNotNil(route.name)
            XCTAssertEqual(route.name, routeName)
        }
    }
    
    func test_filterByName_returnsEmptyArrayForBogusName() {
        let routeName = "filterByName"
        let routes = [Route(routeName, type: .other), Route(routeName, type: .fixed)]
        
        let filteredRoutes = routes.filterByName("bogusName")
        XCTAssertTrue(filteredRoutes.isEmpty)
    }

    func test_filterByType_returnsRoutesForValidType() {
        let routeName = "routesByType"
        let routes = [Route(routeName, type: .other), Route(routeName, type: .other), Route(routeName, type: .fixed)]
        
        let filteredRoutes = routes.filterByType(.other)
        XCTAssertFalse(filteredRoutes.isEmpty)
        XCTAssertEqual(filteredRoutes.count, 2)
        
        for route in filteredRoutes {
            XCTAssertEqual(route.type, RoutingType.other)
        }
    }
    
    func test_filterByType_returnsEmptyArrayForBogusType() {
        let routeName = "routesByType"
        let routes = [Route(routeName, type: .other), Route(routeName, type: .other)]
        
        let filteredRoutes = routes.filterByType(.fixed)
        XCTAssertTrue(filteredRoutes.isEmpty)
    }
}
