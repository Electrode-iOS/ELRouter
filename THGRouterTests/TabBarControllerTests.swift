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
        Router.sharedInstance.navigator = tabBarController
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSelectedTabRoute() {
        let router = Router.sharedInstance
        let tabTwoExpectation = expectationWithDescription("route handler should run")

        router.register(Route("tabOne", type: .Static) { (variable) in
            XCTAssertTrue(true, "Tab one handler should not be run when evaluating tab two")
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.register(Route("tabTwo", type: .Static) { (variable) in
            tabTwoExpectation.fulfill()
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.updateNavigator()
        
        router.evaluate(["tabTwo"])
        
        waitForExpectationsWithTimeout(2.0) { error in
            XCTAssertNotNil(router.navigator)
            XCTAssertEqual(router.navigator!.selectedIndex, 1)
        }
    }
    
}
