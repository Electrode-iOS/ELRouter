//
//  StaticNavigator.swift
//  THGRouter
//
//  Created by Brandon Sneed on 12/1/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol StaticNavigator {
    var selectedViewController: UIViewController? { get set }
    var selectedIndex: Int { get set }
    
    func setViewControllers(viewControllers: [UIViewController]?, animated: Bool)
}


extension UITabBarController: StaticNavigator {
    // UITabBarController has the necessary stuff to conform to this already.
}