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

public typealias RouteActionClosure = (_ variable: String?, _ remainingComponents: [String], _ associatedData: inout AssociatedData?) -> Any?

@objc
public enum RoutingType: UInt {
    case segue
    case fixed
    case push
    case modal
    case variable
    case redirect
    case other // ??
    
    var description: String {
        switch self {
        case .segue:
            return "Segue"
        case .fixed:
            return "Fixed"
        case .push:
            return "Push"
        case .modal:
            return "Modal"
        case .variable:
            return "Variable"
        case .redirect:
            return "Redirect"
        case .other:
            return "Other"
        }
    }
}

@objc
open class Route: NSObject {
    /// The name of the route, ie: "reviews"
    open let name: String?
    open let type: RoutingType

    open var userInfo = [String: AnyObject]()
    
    open internal(set) var subRoutes = [Route]()

    // this used to be weak, however due to the nature of how things are registered,
    // it can't be weak.  This creates a *retain loop*, however there is no mechanism
    // to remove existing route entries (we don't want someone unregistering
    // someoneelse's route).
    open internal(set) var parentRoute: Route?

    /// Action block
    open let action: RouteActionClosure?
    
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
    
    fileprivate weak var staticValue: AnyObject? = nil
    internal weak var parentRouter: Router?

    // MARK: - Adding sub routes
    @discardableResult open func variable(_ action: RouteActionClosure! = nil) -> Route {
        if route(forType: .variable) != nil {
            let message = "A variable route already exists on \(self.name)!"
            if isInUnitTest() {
                exceptionFailure(message)
            } else {
                assertionFailure(message)
            }
        }
        
        let variable = Route(type: .variable, parentRoute: self, action: action)
        variable.parentRouter = parentRouter
        subRoutes.append(variable)
        return variable
    }
    
    open func route(_ route: RouteEnum, action: RouteActionClosure! = nil) -> Route {
        return self.route(route.spec.name, type: route.spec.type, action: action)
    }
    
    /** 
     Create a subroute based on an existing Route object.  This effectively copies the existing
     route that is passed in, it does not copy any subroutes though.  Just name/type/action.
     */
    open func route(_ route: Route) -> Route {
        if route.type == .variable || self.route(forName: route.name!) != nil {
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
    @discardableResult open func route(_ name: String, type: RoutingType, action: RouteActionClosure! = nil) -> Route {
        if let existing = self.route(forName: name) {
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
    @discardableResult internal func execute(_ animated: Bool, variable: String? = nil) -> Any? {
        var data: AssociatedData? = nil
        return execute(animated, variable: variable, remainingComponents: [String](), associatedData: &data)
    }
    
    /**
     Execute the route's action
     
     - parameter animated: Determines if the view controller action should be animated.
     - parameter variable: The variable value extracted from the URL component.
     - parameter associatedData: Potentially extra data passed in from the outside.
    */
    @discardableResult internal func execute(_ animated: Bool, variable: String?, remainingComponents: [String], associatedData: inout AssociatedData?) -> Any? {
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
                            nav.popToRootViewController(animated: animated)
                            navActionOccurred = true
                        }
                    }
                }
            } else {
                result = action(variable, remainingComponents, &associatedData)
                
                let navController = navigator.selectedViewController as? UINavigationController
                let lastVC = navController?.topViewController
                
                switch(type) {
                case .fixed:
                    // do nothing.  tab's are handled slightly differently above.
                    // TODO: say some meaningful shit about why this works this way.
                    if let vc = result as? UIViewController {
                        staticValue = vc
                    }
                    
                case .push:
                    if let vc = result as? UIViewController {
                        navController?.router_pushViewController(vc, animated: animated)
                        navActionOccurred = true
                    }
                    
                case .modal:
                    if let vc = result as? UIViewController {
                        lastVC?.router_presentViewController(vc, animated: animated, completion: nil)
                        navActionOccurred = true
                    }
                    
                case .segue:
                    if let segueID = result as? String {
                        lastVC?.router_performSegueWithIdentifier(segueID, sender: self)
                        navActionOccurred = true
                    }
                    
                case .other, .redirect, .variable: break
                }
            }
        } else {
            // they don't have a navigator setup, so just run it.
            result = action(variable, remainingComponents, &associatedData)
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
    open func routes(forName name: String) -> [Route] {
        return subRoutes.filterByName(name)
    }
    
    /**
     Get the first subroute of a particular name.
     
     - parameter name: The name of the route to get.
    */
    open func route(forName name: String) -> Route? {
        let results = routes(forName: name)
        if results.count > 0 {
            return results[0]
        }
        return nil
    }
    
    
    /**
     Get all subroutes of a particular routing type.
     
     - parameter type: The routing type of the routes to get.
    */
    open func routes(forType type: RoutingType) -> [Route] {
        return subRoutes.filterByType(type)
    }
    
    /**
     Get the first subroute of a particular routing type.
     
     - parameter type: The routing type of the routes to get.
    */
    open func route(forType type: RoutingType) -> Route? {
        let results = routes(forType: type)
        if results.count > 0 {
            return results[0]
        }
        return nil
    }
    
    /**
     Get all subroutes that match an array of components.
    
     - parameter components: The array of component strings to match against.
    */
    internal func routes(forComponents components: [String]) -> [Route] {
        var results = [Route]()
        var currentRoute = self
        
        for i in 0..<components.count {
            let component = components[i]
            
            if let route = currentRoute.route(forName: component) {
                results.append(route)
                currentRoute = route
            } else if let variableRoute = currentRoute.route(forType: .variable) {
                // it IS a variable.
                results.append(variableRoute)
                currentRoute = variableRoute
            }
        }
        
        return results
    }
}

extension Sequence where Iterator.Element : Route {
    /**
     Filter a collection of Route objects by name.
     
     - parameter name: The name of the routes to filter by.
    */
    public func filterByName(_ name: String) -> [Route] {
        return filter { $0.name == name }
    }
    
    /**
     Filter a collection of Route objects by routing type.
     
     - parameter type: The routing type of the routes to filter by.
    */
    public func filterByType(_ type: RoutingType) -> [Route] {
        return filter { $0.type == type }
    }
}
