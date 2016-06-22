//
//  NavigationTests.swift
//  ELRouter
//
//  Created by Brandon Sneed on 2/25/16.
//  Copyright © 2016 theholygrail.io. All rights reserved.
//

import XCTest
import ELFoundation
@testable import ELRouter

class NavigationTests: XCTestCase {
    
    var nav: UINavigationController?
    var root: UIViewController?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        root = UIViewController()
        nav = UINavigationController(rootViewController: root!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        root = nil
        nav = nil
        
        super.tearDown()
    }
    
    // this used to work, but i guess you can't test present like this anymore.
    /*func testPresentSwizzleIgnoreMultiShow() {
        let newController = UIViewController()
        
        // present the VC, this will in turn induce a delay.
        root!.navigationController?.presentViewController(newController, animated: true) {
            // should be 0 here since it's shown and now the completion block is executing.
            XCTAssertTrue(NavSync.sharedInstance.scheduledControllers.count == 0)
        }
        
        // should be 1 here since it's scheduled and hasn't actually executed yet.
        XCTAssertTrue(NavSync.sharedInstance.scheduledControllers.count == 1)
        
        // try to present it again.
        root!.navigationController?.presentViewController(newController, animated: true) {
            // this completion will never get called because it's scheduled for presentation already.
            XCTFail()
        }
        
        // it should still be 1 at this point because we want to make sure the 2nd present request
        // saw it was scheduled already and did nothing rather than present it again.
        XCTAssertTrue(NavSync.sharedInstance.scheduledControllers.count == 1)
        
        do {
            try waitForConditionsWithTimeout(4.0) { () -> Bool in
                return NavSync.sharedInstance.scheduledControllers.count == 0
            }
        } catch {
            // timeout occurred from waitForConditions.
            XCTFail()
        }
    }*/
    
    /* Broken Test
    func testPushSwizzleIgnoreMultiShow() {
        let newController = UIViewController()
        
        // present the VC, this will in turn induce a delay.
        root!.navigationController?.pushViewController(newController, animated: true)
        
        // should be 1 here since it's scheduled and hasn't actually executed yet.
        XCTAssertTrue(NavSync.sharedInstance.scheduledControllers.count == 1)
        
        // try to present it again.
        root!.navigationController?.pushViewController(newController, animated: true)
        
        // it should still be 1 at this point because we want to make sure the 2nd present request
        // saw it was scheduled already and did nothing rather than present it again.
        XCTAssertTrue(NavSync.sharedInstance.scheduledControllers.count == 1)
        
        do {
            try waitForConditionsWithTimeout(2.0) { () -> Bool in
                return NavSync.sharedInstance.scheduledControllers.count == 0
            }
        } catch {
            // timeout occurred from waitForConditions.
            XCTFail()
        }
    }*/
    
    /* Broken Test
    func testVCsStickAroundAfterDestructiveNavHeirarchy() {
        // Added test to verify in-flight viewControllers stick around even after a destructive nav event.
        
        let newController = UIViewController()
        
        // present the VC, this will in turn induce a delay.
        root!.navigationController?.pushViewController(newController, animated: true)
        
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        
        root!.navigationController?.setViewControllers([vc1, vc2], animated: false)
        
        // should be 1 here since it's scheduled and hasn't actually executed yet.
        XCTAssertTrue(NavSync.sharedInstance.scheduledControllers.count == 1)
        
        do {
            try waitForConditionsWithTimeout(2.0) { () -> Bool in
                return NavSync.sharedInstance.scheduledControllers.count == 0
            }
        } catch {
            // timeout occurred from waitForConditions.
            XCTFail()
        }
    } */
}
