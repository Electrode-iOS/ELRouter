//
//  MockNavigator.swift
//  THGRouter
//
//  Created by Angelo Di Paolo on 12/22/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation
import THGRouter

@objc final class MockNavigator: NSObject, Navigator {
    var selectedViewController: UIViewController?
    var selectedIndex: Int = 0
    var testNavigationController: UINavigationController?
    
    override init() {
        let navigationConroller = UINavigationController(rootViewController: UIViewController(nibName: nil, bundle: nil))
        testNavigationController = navigationConroller
        selectedViewController = navigationConroller
    }
    
    func setViewControllers(viewControllers: [UIViewController]?, animated: Bool) {
        
    }
}
