//
//  TabBarControllerTests.swift
//  THGRouter
//
//  Created by Angelo Di Paolo on 12/1/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import XCTest
import UIKit
import THGRouter

class TabBarControllerTests: XCTestCase {
    private var tabBarController: UITabBarController?
    
    override func setUp() {
        super.setUp()
        
        tabBarController = UITabBarController(nibName: nil, bundle: nil)
        Router.sharedInstance.tabBarController = tabBarController
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func findTabBarViewControllers() -> [UIViewController] {
        let tabRoutes = Router.sharedInstance.routesByType(.Tab)
        
        var result = [UIViewController]()
        for route in tabRoutes {
            let vc = route.execute(false)
            if let vc = vc {
                result.append(vc)
            }
        }
        
        return result
    }
    
    func testSelectedTabRoute() {
        let router = Router.sharedInstance
        let tabTwoExpectation = expectationWithDescription("route handler should run")

        router.register(Route("tabOne", type: .Tab) { (variable) in
            XCTAssertTrue(true, "Tab one handler should not be run when evaluating tab two")
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.register(Route("tabTwo", type: .Tab) { (variable) in
            tabTwoExpectation.fulfill()
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        
        router.tabBarController?.viewControllers = findTabBarViewControllers()
        router.evaluate(["tabTwo"])
        
        waitForExpectationsWithTimeout(2.0) { error in
            XCTAssertNotNil(router.tabBarController)
            XCTAssertEqual(router.tabBarController!.selectedIndex, 1)
        }
    }
    
}
