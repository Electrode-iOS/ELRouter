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

extension Router {
    /// Update the view controllers that are managed by the navigator
    public func updateNavigator() {
        guard let navigator = navigator else { return }
        
        let navigatorRoutes = routesByType(.Static)
        var controllers = [UIViewController]()
        
        for route in navigatorRoutes {
            if let vc = route.execute(false) {
                if let vc = vc as? UINavigationController {
                    controllers.append(vc)
                }
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
        return (Router.routesInFlight != nil)
    }
    
    /**
     Evaluate a URL String. Routes matching the URL will be executed.
     
     - parameter url: The URL to evaluate.
     */
    public func evaluateURLString(urlString: String, animated: Bool = false) -> Bool {
        let url = NSURL(string: urlString)
        if let url = url {
            return evaluateURL(url, animated: animated)
        } else {
            return false
        }
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
    */
    public func evaluate(components: [String], animated: Bool = false) -> Bool {
        var result = false
        
        // if we have routes in flight, return false.  We can't do anything
        // until those have finished.
        var inFlight = false
        synchronized(self) {
            inFlight = Router.routesInFlight != nil
        }
        if inFlight {
            return result
        }
        
        let routes = routesToExecute(masterRoute, components: components)
        let valid = routes.count == components.count
        
        if valid && routes.count > 0 {
            synchronized(self) {
                Router.routesInFlight = routes
            }
            
            serializedRoute(routes, components: components, animated: animated)
            
            result = true
        }
        
        return result
    }
    
    private func routesToExecute(startRoute: Route, components: [String]) -> [Route] {
        var result = [Route]()
        
        var currentRoute: Route = startRoute
        
        for i in 0..<components.count {
            let component = components[i]
            
            if let route = currentRoute.routeByName(component) {
                // oh, it's a route.  add that shit.
                result.append(route)
                currentRoute = route
            } else {
                // is it a variable?
                
                // we're more likely to have multiple variables, so check them against the
                // next component in the set.
                let variables = currentRoute.routesByType(.Variable)
                var nextComponent: String? = nil
                
                if i < components.count - 1 {
                    nextComponent = components[i+1]
                }
                
                // if there are multiple variables specified, dig in to see if any match the next component.
                var matchingVariableFound = false

                if let nextComponent = nextComponent {
                    for item in variables {
                        if item.routeByName(nextComponent) != nil || i == components.count - 1 {
                            result.append(item)
                            currentRoute = item
                            matchingVariableFound = true
                        }
                    }
                }
                
                // if there's only 1 variable specified here, just register it
                // if there's no nextComponent.
                if variables.count == 1 && !matchingVariableFound && nextComponent == nil {
                    let item = variables[0]
                    result.append(item)
                    currentRoute = item
                }
            }
        }
        
        return result
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
        return routes.filter { return $0.name == name }
    }
    
    /**
     Get all routes of a particular routing type.
     
     - parameter type: The routing type of the routes to get.
    */
    public func routesByType(type: RoutingType) -> [Route] {
        return routes.filter { return $0.type == type }
    }
}

// MARK: - Route/Navigation synchronization

/*extension UIViewController {
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
        }
    }
    
    internal func router_viewDidAppear(animated: Bool) {
        // release the lock that's holding up route execution.
        Router.lock.unlock()
    }
}*/

extension Router {
    internal func serializedRoute(routes: [Route], components: [String], animated: Bool) {
        
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

