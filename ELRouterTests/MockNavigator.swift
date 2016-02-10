//
//  MockNavigator.swift
//  ELRouter
//
//  Created by Angelo Di Paolo on 12/22/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation
import ELRouter

@objc final class MockNavigator: NSObject, Navigator {
    var viewControllers: [UIViewController]? = nil
    
    var selectedViewController: UIViewController? {
        didSet(newValue) {
            if let controller = newValue {
                let index = viewControllers?.indexOf(controller)
                selectedIndex = index!
            }
        }
    }
    
    var selectedIndex: Int = 0
    var testNavigationController: UINavigationController?
    
    override init() {
        let navigationConroller = UINavigationController(rootViewController: UIViewController(nibName: nil, bundle: nil))
        testNavigationController = navigationConroller
        selectedViewController = navigationConroller
    }
    
    func setViewControllers(viewControllers: [UIViewController]?, animated: Bool) {
        self.viewControllers = viewControllers
        
        selectedViewController = viewControllers?.first
    }
}
