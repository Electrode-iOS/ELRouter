//
//  Route.swift
//  ELRouter
//
//  Created by Brandon Sneed on 10/15/15.
//  Copyright © 2015 Walmart. All rights reserved.
//

import Foundation
import UIKit
import ELFoundation

public typealias RouteActionClosure = (variable: String?, remainingComponents: [String], inout associatedData: AssociatedData?) -> Any?

@objc
public enum RoutingType: UInt {
    case Segue
    case Static
    case Push
    case Modal
    case Variable
    case Redirect
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
        case .Redirect:
            return "Redirect"
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
    
    public init(_ route: RouteEnum, parentRoute: Route! = nil, action: RouteActionClosure! = nil) {
        self.name = route.spec.name
        self.type = route.spec.type
        self.action = action
        self.parentRoute = parentRoute
    }
    
    internal init(_ name: String, type: RoutingType, parentRoute: Route! = nil, action: RouteActionClosure! = nil) {
        self.name = name
        self.type = type
        self.action = action
        self.parentRoute = parentRoute
    }
    
    internal init(type: RoutingType, parentRoute: Route! = nil, action: RouteActionClosure! = nil) {
        self.name = nil
        self.type = type
        self.parentRoute = parentRoute
        self.action = action
    }
    
    private weak var staticValue: AnyObject? = nil
    internal weak var parentRouter: Router?

    // MARK: - Adding sub routes
    public func variable(action: RouteActionClosure! = nil) -> Route {
        if routeByType(.Variable) != nil {
            let message = "A variable route already exists on \(self.name)!"
            if isInUnitTest() {
                exceptionFailure(message)
            } else {
                assertionFailure(message)
            }
        }
        
        let variable = Route(type: .Variable, parentRoute: self, action: action)
        variable.parentRouter = parentRouter
        subRoutes.append(variable)
        return variable
    }
    
    public func route(route: RouteEnum, action: RouteActionClosure! = nil) -> Route {
        return self.route(route.spec.name, type: route.spec.type, action: action)
    }
    
    /** 
     Create a subroute based on an existing Route object.  This effectively copies the existing
     route that is passed in, it does not copy any subroutes though.  Just name/type/action.
     */
    public func route(route: Route) -> Route {
        if route.type == .Variable || routeByName(route.name!) != nil {
            // throw an error
            let message = "A variable or route with the same name already exists on \(self.name)!"
            if isInUnitTest() {
                exceptionFailure(message)
            } else {
                assertionFailure(message)
            }
        }
        
        let newRoute = Route(route.name!, type: route.type, parentRoute: self, action: route.action)
        newRoute.parentRouter = parentRouter
        subRoutes.append(newRoute)
        return newRoute
    }

    // MARK: - Adding sub routes, for testability only!
    public func route(name: String, type: RoutingType, action: RouteActionClosure! = nil) -> Route {
        if let existing = routeByName(name) {
            let message = "A route already exists named \(existing.name!)!"
            if isInUnitTest() {
                exceptionFailure(message)
            } else {
                assertionFailure(message)
            }
        }

        let route = Route(name, type: type, parentRoute: self, action: action)
        route.parentRouter = parentRouter
        subRoutes.append(route)
        return route
    }

    // MARK: - Executing Routes
    /**
     For testability only!
    */
    internal func execute(animated: Bool, variable: String? = nil) -> Any? {
        var data: AssociatedData? = nil
        return execute(animated, variable: variable, remainingComponents: [String](), associatedData: &data)
    }
    
    /**
     Execute the route's action
     
     - parameter animated: Determines if the view controller action should be animated.
     - parameter variable: The variable value extracted from the URL component.
     - parameter associatedData: Potentially extra data passed in from the outside.
    */
    internal func execute(animated: Bool, variable: String?, remainingComponents: [String], inout associatedData: AssociatedData?) -> Any? {
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
                    if let nav = vc as? UINavigationController {
                        if nav.viewControllers.count > 1 {
                            nav.popToRootViewControllerAnimated(animated)
                            navActionOccurred = true
                        }
                    }
                }
            } else {
                result = action(variable: variable, remainingComponents: remainingComponents, associatedData: &associatedData)
                
                let navController = navigator.selectedViewController as? UINavigationController
                let lastVC = navController?.topViewController
                
                switch(type) {
                case .Static:
                    // do nothing.  tab's are handled slightly differently above.
                    // TODO: say some meaningful shit about why this works this way.
                    if let vc = result as? UIViewController {
                        staticValue = vc
                    }
                    
                case .Push:
                    if let vc = result as? UIViewController {
                        navController?.router_pushViewController(vc, animated: animated)
                        navActionOccurred = true
                    }
                    
                case .Modal:
                    if let vc = result as? UIViewController {
                        lastVC?.router_presentViewController(vc, animated: animated, completion: nil)
                        navActionOccurred = true
                    }
                    
                case .Segue:
                    if let segueID = result as? String {
                        lastVC?.router_performSegueWithIdentifier(segueID, sender: self)
                        navActionOccurred = true
                    }
                    
                case .Other, .Redirect, .Variable: break
                }
            }
        } else {
            // they don't have a navigator setup, so just run it.
            result = action(variable: variable, remainingComponents: remainingComponents, associatedData: &associatedData)
        }
        
        // if no navigation action actually happened, unlock so route execution can continue.
        // otherwise, let the swizzle for viewDidAppear: in Router.swift do the unlock.
        if navActionOccurred == false {
            Router.lock.unlock()
        }
        
        return result
    }

    // MARK: - Finding Routes
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
                results.append(route)
                currentRoute = route
            } else if let variableRoute = currentRoute.routeByType(.Variable) {
                // it IS a variable.
                results.append(variableRoute)
                currentRoute = variableRoute
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
