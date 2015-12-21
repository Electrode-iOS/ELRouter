//
//  NavigationSyncing.swift
//  THGRouter
//
//  Created by Brandon Sneed on 10/15/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation
import UIKit
import THGFoundation
import THGDispatch

typealias NavSyncAction = () -> Void

extension Array {
    
    //Stack - LIFO
    mutating func push(newElement: Element) {
        self.append(newElement)
    }
    
    mutating func pop() -> Element? {
        if self.count > 0 {
            return self.removeLast()
        }
        return nil
    }
    
    func peekAtStack() -> Element? {
        if self.count > 0 {
            return self.last
        }
        return nil
    }
    
    //Queue - FIFO
    mutating func enqueue(newElement: Element) {
        self.append(newElement)
    }
    
    mutating func dequeue() -> Element? {
        if self.count > 0 {
            return self.removeAtIndex(0)
        }
        return nil
    }
    
    func peekAtQueue() -> Element? {
        if self.count > 0 {
            return self.first
        }
        return nil
    }
}

extension Array where Element : Equatable {
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

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
    }
    
    func push(viewController: UIViewController, animated: Bool, navController: UINavigationController) {
        if animated {
            Dispatch().async(queue) {
                while !self.lock.trylock() {
                    print("Waiting (push)...")
                    sleep(0)
                }
                
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
                while !self.lock.trylock() {
                    print("Waiting (present)...")
                    sleep(0)
                }
                
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
