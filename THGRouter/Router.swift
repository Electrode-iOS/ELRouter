//
//  Router.swift
//  THGRouter
//
//  Created by Brandon Sneed on 10/15/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation
import THGFoundation
import THGDispatch

/// 
@objc
public class Router: NSObject {
    static public let sharedInstance = Router()
    public var navigator: Navigator? = nil
    
    public var routes: [Route] {
        return masterRoute.subRoutes
    }
    
    private let masterRoute: Route = Route("MASTER", type: .Other)
    
    
    private var translation = [String : String]()

    public func translate(from: String, to: String) {
        let existing = translation[from]
        if existing != nil {
            exceptionFailure("A translation for \(from) exists already!")
        }
        
        translation[from] = to
    }
}

// MARK: - Managing the Navigator

extension Router {
    /// Update the view controllers that are managed by the navigator
    public func updateNavigator() {
        guard let navigator = navigator else { return }
        
        let navigatorRoutes = routesByType(.Static)
        var controllers = [UIViewController]()
        
        for route in navigatorRoutes {
            if let vc = route.execute(false) as? UINavigationController {
                controllers.append(vc)
            }
        }
        
        navigator.setViewControllers(controllers, animated: false)
    }
}

// MARK: - Registering Routes

extension Router {
    /**
     Registers a top level route.
     
     - parameter route: The Route being registered.
    */
    public func register(route: Route) {
        var currentRoute = route
        
        // we may given the final link in a chain, walk back up to the top and
        // get the primary route to register.
        while currentRoute.parentRoute != nil {
            currentRoute.parentRouter = self
            currentRoute = currentRoute.parentRoute!
        }
        
        if currentRoute.name != nil {
            currentRoute.parentRouter = self
            masterRoute.subRoutes.append(currentRoute)
        }
    }
}

// MARK: - Evaluating Routes

extension Router {
    /**
     Can be used to determine if Routes are currently be processed.
     */
    public var processing: Bool {
        var result = false
        synchronized(self) { () -> Void in
            result = (Router.routesInFlight != nil)
        }
        return result
    }
    
    /**
     Evaluate a URL String. Routes matching the URL will be executed.
     
     - parameter url: The URL to evaluate.
     */
    public func evaluateURLString(urlString: String, animated: Bool = false) -> Bool {
        guard let url = NSURL(string: urlString) else { return false }
        return evaluateURL(url, animated: animated)
    }
    
    /**
     Evaluate a URL. Routes matching the URL will be executed.
     
     - parameter url: The URL to evaluate.
    */
    public func evaluateURL(url: NSURL, animated: Bool = false) -> Bool {
        guard let components = url.deepLinkComponents else { return false }
        return evaluate(components, animated: animated)
    }
    
    /**
     Evaluate an array of components. Routes matching the URL will be executed.
     
     - parameter components: The array of components to evaluate.
     - parameter animated: Determines if the view controller action should be animated.
    */
    public func evaluate(components: [String], animated: Bool = false) -> Bool {
        var componentsWereHandled = false
        
        // if we have routes in flight, return false.  We can't do anything
        // until those have finished.
        if processing {
            return false
        }
        
        let routes = routesForComponents(components)
        let valid = routes.count == components.count
        
        if valid && routes.count > 0 {
            serializedRoute(routes, components: components, animated: animated)
            
            componentsWereHandled = true
        }
        
        return componentsWereHandled
    }
    
    internal static let lock = Spinlock()
    private static var routesInFlight: [Route]? = nil
}

// MARK: - Getting Routes

extension Router {
    /**
     Get all routes of a particular name.
     
     - parameter name: The name of the routes to get.
    */
    public func routesByName(name: String) -> [Route] {
        return routes.filterByName(name)
    }
    
    /**
     Get all routes of a particular routing type.
     
     - parameter type: The routing type of the routes to get.
    */
    public func routesByType(type: RoutingType) -> [Route] {
        return routes.filterByType(type)
    }
    
    /**
     Get all routes that match the given URL.
     
     - parameter url: The url to match against.
    */
    public func routesForURL(url: NSURL) -> [Route] {
        guard let components = url.deepLinkComponents else { return [Route]() }
        return routesForComponents(components)
    }
    
    /**
     Get all routes that match an array of components.
     
     - parameter components: The array of component strings to match against.
    */
    public func routesForComponents(components: [String]) -> [Route] {
        return masterRoute.routesForComponents(components)
    }
}

// MARK: - Route/Navigation synchronization

extension Router {
    internal func serializedRoute(routes: [Route], components: [String], animated: Bool) {
        if processing {
            return
        }
        
        // set our in-flight routes to what we were given.
        synchronized(self) {
            Router.routesInFlight = routes
        }
        
        let navController = navigator?.selectedViewController as? UINavigationController
        // clear any presenting controllers.
        if let presentedViewController = navController?.topViewController?.presentedViewController {
            presentedViewController.dismissViewControllerAnimated(animated, completion: nil)
        }
        
        // process routes in the background.
        Dispatch().async(.Background) {
            for i in 0..<components.count {
                let route = routes[i]

                var variable: String? = nil
                if route.type == .Variable {
                    variable = components[i]
                }
                
                if route.parentRoute?.type == .Variable {
                    if i > 0 {
                        variable = components[i-1]
                    }
                }
                
                // acquire the lock.  if there's a nav event in progress
                // this will wait until that event has finished.
                Router.lock.lock()
                
                log(.Debug, "Processing route: \((route.name ?? variable)!), \(route.type.description)")
                
                // execute route on the main thread.
                Dispatch().async(.Main) {
                    route.execute(animated, variable: variable)
                    log(.Debug, "Finished route: \((route.name ?? variable)!), \(route.type.description)")
                }
            }
            
            // clear our in-flight routes now that we're done.
            synchronized(self) {
                Router.routesInFlight = nil
            }
        }
    }
}

