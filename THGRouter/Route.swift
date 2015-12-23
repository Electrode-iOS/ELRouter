//
//  Route.swift
//  THGRouter
//
//  Created by Brandon Sneed on 10/15/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation
import UIKit
import THGFoundation

public typealias RouteActionClosure = (variable: String?) -> Any?

@objc
public enum RoutingType: UInt {
    case Segue
    case Static
    case Push
    case Modal
    case Variable
    case Other // ??
    
    var description: String {
        switch self {
        case .Segue:
            return "Segue"
        case .Static:
            return "Static"
        case .Push:
            return "Push"
        case .Modal:
            return "Modal"
        case .Variable:
            return "Variable"
        case .Other:
            return "Other"
        }
    }
}

@objc
public class Route: NSObject {
    /// The name of the route, ie: "reviews"
    public let name: String?
    public let type: RoutingType
    public var userInfo = [String: AnyObject]()
    
    public internal(set) var subRoutes = [Route]()

    // this used to be weak, however due to the nature of how things are registered,
    // it can't be weak.  This creates a *retain loop*, however there is no mechanism
    // to remove existing route entries (we don't want someone unregistering
    // someoneelse's route).
    public internal(set) var parentRoute: Route?

    /// Action block
    public let action: RouteActionClosure?
    
    public init(_ name: String, type: RoutingType, action: RouteActionClosure! = nil) {
        self.name = name
        self.type = type
        self.action = action
        self.parentRoute = nil
    }
    
    internal init(_ name: String, type: RoutingType, parentRoute: Route, action: RouteActionClosure! = nil) {
        self.name = name
        self.type = type
        self.action = action
        self.parentRoute = parentRoute
    }
    
    internal init(type: RoutingType, parentRoute: Route, action: RouteActionClosure! = nil) {
        self.name = nil
        self.type = type
        self.parentRoute = parentRoute
        self.action = action
    }
    
    private weak var staticValue: AnyObject? = nil
    internal weak var parentRouter: Router?
}

// MARK: - Adding sub routes

extension Route {
    public func variable(action: RouteActionClosure! = nil) -> Route {
        let variable = Route(type: .Variable, parentRoute: self, action: action)
        variable.parentRouter = parentRouter
        subRoutes.append(variable)
        return variable
    }
    
    public func route(name: String, type: RoutingType, action: RouteActionClosure! = nil) -> Route {
        let route = Route(name, type: type, parentRoute: self, action: action)
        route.parentRouter = parentRouter
        subRoutes.append(route)
        return route
    }
}

// MARK: - Executing Routes

extension Route {
    /**
     Execute the route's action
     
     - parameter animated: Determines if the view controller action should be animated.
     - parameter variable: The variable value extracted from the URL component.
    */
    internal func execute(animated: Bool, variable: String? = nil) -> Any? {
        // bail out when missing a valid action
        guard let action = action else {
            Router.lock.unlock()
            return nil
        }
        
        var result: Any? = nil
        var navActionOccurred = false

        if let navigator = parentRouter?.navigator {
            if let staticValue = staticValue {
                result = staticValue
                if let vc = staticValue as? UIViewController {
                    parentRouter?.navigator?.selectedViewController = vc
                }
            } else {
                result = action(variable: variable)
                
                switch(type) {
                case .Static:
                    // do nothing.  tab's are handled slightly differently above.
                    // TODO: say some meaningful shit about why this works this way.
                    if let vc = result as? UIViewController {
                        staticValue = vc
                    }
                    
                case .Push:
                    if let vc = result as? UIViewController {
                        navigator.selectedNavigationController?.router_pushViewController(vc, animated: animated)
                        navActionOccurred = true
                    }
                    
                case .Modal:
                    if let vc = result as? UIViewController {
                        navigator.selectedNavigationController?.topViewController?.router_presentViewController(vc, animated: animated, completion: nil)
                        navActionOccurred = true
                    }
                    
                case .Segue:
                    if let segueID = result as? String {
                        navigator.selectedNavigationController?.topViewController?.router_performSegueWithIdentifier(segueID, sender: self)
                        navActionOccurred = true
                    }
                    
                case .Other, .Variable: break
                }
            }
        } else {
            // they don't have a navigator setup, so just run it.
            result = action(variable: variable)
        }
        
        // if no navigation action actually happened, unlock so route execution can continue.
        // otherwise, let the swizzle for viewDidAppear: in Router.swift do the unlock.
        if navActionOccurred == false {
            Router.lock.unlock()
        }
        
        return result
    }
}

// MARK: - Finding Routes

extension Route {
    /**
     Get all subroutes of a particular name.
     
     - parameter name: The name of the routes to get.
    */
    public func routesByName(name: String) -> [Route] {
        return subRoutes.filterByName(name)
    }
    
    /**
     Get the first subroute of a particular name.
     
     - parameter name: The name of the route to get.
    */
    public func routeByName(name: String) -> Route? {
        let routes = routesByName(name)
        if routes.count > 0 {
            return routes[0]
        }
        return nil
    }
    
    
    /**
     Get all subroutes of a particular routing type.
     
     - parameter type: The routing type of the routes to get.
    */
    public func routesByType(type: RoutingType) -> [Route] {
        return subRoutes.filterByType(type)
    }
    
    /**
     Get the first subroute of a particular routing type.
     
     - parameter type: The routing type of the routes to get.
    */
    public func routeByType(type: RoutingType) -> Route? {
        let routes = routesByType(type)
        if routes.count > 0 {
            return routes[0]
        }
        return nil
    }
    
    /**
     Get all subroutes that match an array of components.
    
     - parameter components: The array of component strings to match against.
    */
    internal func routesForComponents(components: [String]) -> [Route] {
        var results = [Route]()
        var currentRoute = self
        
        for i in 0..<components.count {
            let component = components[i]
            
            if let route = currentRoute.routeByName(component) {
                // oh, it's a route.  add that shit.
                results.append(route)
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
                            results.append(item)
                            currentRoute = item
                            matchingVariableFound = true
                        }
                    }
                }
                
                // if there's only 1 variable specified here, just register it
                // if there's no nextComponent.
                if variables.count == 1 && !matchingVariableFound && nextComponent == nil {
                    let item = variables[0]
                    results.append(item)
                    currentRoute = item
                }
            }
        }
        
        return results
    }
}

// MARK: Filtering Route Collections

/// Adds a basic filtering API for collections of Route objects
extension CollectionType where Generator.Element == Route {
    /**
     Filter a collection of Route objects by name.
     
     - parameter name: The name of the routes to filter by.
    */
    public func filterByName(name: String) -> [Route] {
        return filter { $0.name == name }
    }
    
    /**
     Filter a collection of Route objects by routing type.
     
     - parameter type: The routing type of the routes to filter by.
    */
    public func filterByType(type: RoutingType) -> [Route] {
        return filter { $0.type == type }
    }
}
