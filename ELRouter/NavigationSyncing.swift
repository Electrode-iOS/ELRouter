//
//  NavigationSyncing.swift
//  ELRouter
//
//  Created by Brandon Sneed on 10/15/15.
//  Copyright © 2015 Walmart. All rights reserved.
//

/* 

TODO:

Consider getting rid of this file.  It's only needed to sync manual navigation events
with to prevent collison with router based nav events.  Do we need to do this?

If not, we just need to uncomment the swizzle in Router.swift.

*/

import Foundation
import UIKit
import ELFoundation

typealias NavSyncAction = () -> Void

public protocol RouterEventFirehose: class {
    func viewControllerAppeared(_ viewController: UIViewController)
    func viewControllerPresented(_ viewController: UIViewController)
    func viewControllerPushed(_ viewController: UIViewController)
    func routerWillEvaluate(components: [String], associatedData: AssociatedData?, animated: Bool)
}

internal class NavSync: NSObject {
    internal static var sharedInstance = NavSync()

    internal var scheduledControllers = NSHashTable<AnyObject>.weakObjects()
    
    let routerQueue: DispatchQueue
    weak var eventFirehose: RouterEventFirehose?
    
    override init() {
        routerQueue = DispatchQueue(label: "ELRouterSync", qos: DispatchQoS.background)
        super.init()
    }
    
    internal func appeared(_ controller: UIViewController, animated: Bool) {
        eventFirehose?.viewControllerAppeared(controller)
        
        controller.swizzled_viewDidAppear(animated)
        Router.lock.unlock()
    }
    
    internal func push(_ viewController: UIViewController, animated: Bool, navController: UINavigationController, fromRouter: Bool) {
        // add it to the scheduled ones in the case of a double-show to prevent a system blow up.
        if scheduledControllers.contains(viewController) {
            return
        } else {
            scheduledControllers.add(viewController)
        }
        
        eventFirehose?.viewControllerPushed(viewController)
        
        // if routes are in process and a manual nav event was attempted, it's ignore it and continue on.
        if !fromRouter && Router.sharedInstance.processing {
            // if the navController has no view controllers, this is coming from the rootViewController initializer, so let it pass.
            if navController.viewControllers.count > 0 {
                if !isInUnitTest() {
                    exceptionFailure("Attempted to push a ViewController while routes were being processed!")
                }
                return
            }
        }
        
        if animated {
            routerQueue.async {
                DispatchQueue.main.sync {
                    navController.swizzled_pushViewController(viewController, animated: animated)
                    self.scheduledControllers.remove(viewController)
                }
            }
        } else {
            navController.swizzled_pushViewController(viewController, animated: animated)
            scheduledControllers.remove(viewController)
        }
    }

    internal func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?, fromController: UIViewController, fromRouter: Bool) {
        // add it to the scheduled ones in the case of a double-show to prevent a system blow up.
        if scheduledControllers.contains(viewController) {
            return
        } else {
            scheduledControllers.add(viewController)
        }
        
        eventFirehose?.viewControllerPresented(viewController)

        // if routes are in process and a manual nav event was attempted, it's ignore it and continue on.
        if !fromRouter && Router.sharedInstance.processing {
            if !isInUnitTest() {
                exceptionFailure("Attempted to present a ViewController while routes were being processed!")
            }
            return
        }
        
        if animated {
            routerQueue.async {
                DispatchQueue.main.sync {
                    fromController.swizzled_presentViewController(viewController, animated: animated) {
                        self.scheduledControllers.remove(viewController)
                        if let closure = completion {
                            closure()
                        }
                    }
                }
            }
        } else {
            fromController.swizzled_presentViewController(viewController, animated: animated) {
                self.scheduledControllers.remove(viewController)
                if let closure = completion {
                    closure()
                }
            }
        }
    }
    
    internal func performSegueWithIdentifier(_ identifier: String, sender: AnyObject?, fromController: UIViewController, fromRouter: Bool) {
        // if routes are in process and a manual nav event was attempted, it's ignore it and continue on.
        if !fromRouter && Router.sharedInstance.processing {
            if !isInUnitTest() {
                exceptionFailure("Attempted to perform a segue while routes were being processed!")
            }

            return
        }

        fromController.performSegue(withIdentifier: identifier, sender: sender)
    }
}

extension UINavigationController {
    @objc internal func swizzled_pushViewController(_ viewController: UIViewController, animated: Bool) {
        NavSync.sharedInstance.push(viewController, animated: animated, navController: self, fromRouter: false)
    }
    
    internal func router_pushViewController(_ viewController: UIViewController, animated: Bool) {
        NavSync.sharedInstance.push(viewController, animated: animated, navController: self, fromRouter: true)
    }
}

extension UIViewController {
    @objc internal func swizzled_viewDidAppear(_ animated: Bool) {
        // release whatever lock is present
        NavSync.sharedInstance.appeared(self, animated: animated)
    }
    
    @objc internal func swizzled_presentViewController(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        NavSync.sharedInstance.present(viewControllerToPresent, animated: animated, completion: completion, fromController: self, fromRouter: false)
    }
    
    internal func router_presentViewController(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        NavSync.sharedInstance.present(viewControllerToPresent, animated: animated, completion: completion, fromController: self, fromRouter: true)
    }
    
    internal func router_performSegueWithIdentifier(_ identifier: String, sender: AnyObject?) {
        NavSync.sharedInstance.performSegueWithIdentifier(identifier, sender: sender, fromController: self, fromRouter: true)
    }
}

// MARK: Swizzle Injection

internal func injectRouterSwizzles() {

    UINavigationController.swizzleInstanceMethod(#selector(UINavigationController.pushViewController(_:animated:)), swizzledSelector: #selector(UINavigationController.swizzled_pushViewController(_:animated:)))
    UIViewController.swizzleInstanceMethod(#selector(UIViewController.viewDidAppear(_:)), swizzledSelector: #selector(UIViewController.swizzled_viewDidAppear(_:)))
    UIViewController.swizzleInstanceMethod(#selector(UIViewController.present), swizzledSelector: #selector(UIViewController.swizzled_presentViewController(_:animated:completion:)))
}
