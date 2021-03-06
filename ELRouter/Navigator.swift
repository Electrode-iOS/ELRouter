//
//  Navigator.swift
//  ELRouter
//
//  Created by Brandon Sneed on 12/1/15.
//  Copyright © 2015 Walmart. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol Navigator {
    var selectedViewController: UIViewController? { get set }
    var selectedIndex: Int { get set }
    
    var viewControllers: [UIViewController]? { get set }
    func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool)
}


extension UITabBarController: Navigator {
    // UITabBarController has the necessary stuff to conform to this already.
}
