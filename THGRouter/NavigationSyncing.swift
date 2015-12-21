//
//  NavigationSyncing.swift
//  THGRouter
//
//  Created by Brandon Sneed on 10/15/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

/* 

TODO:

Consider getting rid of this file.  It's only needed to sync manual navigation events
with to prevent collison with router based nav events.  Do we need to do this?

If not, we just need to uncomment the swizzle in Router.swift.

*/

import Foundation
import UIKit
import THGFoundation
import THGDispatch

typealias NavSyncAction = () -> Void

public class NavSync: NSObject {
    public static var sharedInstance = NavSync()
    
    let queue: DispatchQueue
    internal let lock = Spinlock()
    
    override init() {
        queue = DispatchQueue.createSerial("THGRouterNavSync", targetQueue: .Background)
        super.init()
    }
    
    func appeared(controller: UIViewController, animated: Bool) {
        controller.router_viewDidAppear(animated)
        lock.unlock()
        // i wish we could tell if this appear came from a route being processed or a 
        // developer doing a push/present manually.
        Router.lock.unlock()
    }
    
    func push(viewController: UIViewController, animated: Bool, navController: UINavigationController) {
        if animated {
            Dispatch().async(queue) {
                Dispatch().async(.Main) {
                    navController.router_pushViewController(viewController, animated: animated)
                }
            }
        } else {
            navController.router_pushViewController(viewController, animated: animated)
        }
    }

    func present(viewController: UIViewController, animated: Bool, completion: (() -> Void)?, fromController: UIViewController) {
        if animated {
            Dispatch().async(queue) {
                Dispatch().async(.Main) {
                    fromController.router_presentViewController(viewController, animated: animated, completion: completion)
                }
            }
        } else {
            fromController.router_presentViewController(viewController, animated: animated, completion: completion)
        }
    }
}

extension UINavigationController {
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        // make sure this isn't a subclass
        if self !== UINavigationController.self {
            return
        }
        
        dispatch_once(&Static.token) {
            unsafeSwizzle(self, original: Selector("pushViewController:animated:"), replacement: Selector("router_pushViewController:animated:"))
            
            // TODO: figure out if we need to handle popViewController, popToRootViewController and popToViewController.
        }
    }
    
    // MARK: - Method Swizzling
    
    internal func router_pushViewController(viewController: UIViewController, animated: Bool) {
        NavSync.sharedInstance.push(viewController, animated: animated, navController: self)
    }

}

extension UIViewController {
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        // make sure this isn't a subclass
        if self !== UIViewController.self {
            return
        }
        
        dispatch_once(&Static.token) {
            unsafeSwizzle(self, original: Selector("viewDidAppear:"), replacement: Selector("router_viewDidAppear:"))
            unsafeSwizzle(self, original: Selector("presentViewController:animated:completion:"), replacement: Selector("router_presentViewController:animated:completion:"))
            
            // TODO: figure out if we need to handle dismissViewControllerAnimated
        }
    }
    
    // MARK: - Method Swizzling
    
    internal func router_viewDidAppear(animated: Bool) {
        // release whatever lock is present
        NavSync.sharedInstance.appeared(self, animated: animated)
    }
    
    internal func router_presentViewController(viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        NavSync.sharedInstance.present(viewControllerToPresent, animated: animated, completion: completion, fromController: self)
    }
}
