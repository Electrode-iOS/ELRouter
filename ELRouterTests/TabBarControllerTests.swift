//
//  TabBarControllerTests.swift
//  ELRouter
//
//  Created by Angelo Di Paolo on 12/1/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import XCTest
import UIKit
import ELRouter

class TabBarControllerTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
    }
    
    func test_navigator_properTabIsSelectedWhenEvaluatingComponent() {
        let router = Router()
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        router.navigator = tabBarController
        
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
            XCTAssertEqual(tabBarController.selectedIndex, 1)
            XCTAssertEqual(router.navigator!.selectedIndex, 1)
        }
    }
    
    func test_navigator_properTabIsSelectedWhenEvaluatingSimpleURL() {
        let router = Router()
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        router.navigator = tabBarController
        
        let tabTwoExpectation = expectationWithDescription("route handler should run")
        
        router.register(Route("tabOne", type: .Static) { (variable) in
            XCTAssertTrue(true, "Tab one handler should not be run when evaluating tab two")
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.register(Route("tabTwo", type: .Static) { (variable) in
            XCTAssertTrue(true, "Tab two handler should not be run when evaluating tab three")
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.register(Route("tabThree", type: .Static) { (variable) in
            tabTwoExpectation.fulfill()
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
        })
        
        router.updateNavigator()
        
        router.evaluateURL(NSURL(string: "scheme://tabThree")!)
        
        waitForExpectationsWithTimeout(2.0) { error in
            XCTAssertNotNil(router.navigator)
            XCTAssertEqual(tabBarController.selectedIndex, 2)
            XCTAssertEqual(router.navigator!.selectedIndex, 2)
        }
    }
    
    func test_navigator_properTabIsSelectedWhenEvaluatingComplexURL() {
        let router = Router()
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        router.navigator = tabBarController
        
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
        
        router.register(Route("tabThree", type: .Static) { (variable) in
            XCTAssertTrue(true, "Tab two handler should not be run when evaluating tab three")
            let vc = UIViewController(nibName: nil, bundle: nil)
            return UINavigationController(rootViewController: vc)
            })
        
        router.updateNavigator()
        
        router.evaluateURL(NSURL(string: "scheme://tabTwo:5150/foo/bar/tabTwo?a=b&b=c")!)
        
        waitForExpectationsWithTimeout(2.0) { error in
            XCTAssertNotNil(router.navigator)
            XCTAssertEqual(tabBarController.selectedIndex, 1)
            XCTAssertEqual(router.navigator!.selectedIndex, 1)
        }
    }
}
