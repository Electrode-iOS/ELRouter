//
//  Navigator.swift
//  ELRouter
//
//  Created by Brandon Sneed on 12/1/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol Navigator {
    var selectedViewController: UIViewController? { get set }
    var selectedIndex: Int { get set }
    
    func setViewControllers(viewControllers: [UIViewController]?, animated: Bool)
}


extension UITabBarController: Navigator {
    // UITabBarController has the necessary stuff to conform to this already.
}
