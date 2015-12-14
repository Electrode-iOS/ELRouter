//
//  Route.swift
//  THGRouter
//
//  Created by Brandon Sneed on 10/15/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation
import UIKit

public typealias RouteActionClosure = (variable: String?) -> Any?

@objc
public enum RoutingType: UInt {
    case Segue
    case Static
    case Push
    case Modal
    case Variable
    case Other // ??
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
    // someoneelse's route.
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
    
    public func execute(animated: Bool, variable: String? = nil) -> Any? {
        // bail out when missing a valid action
        guard let action = action else { return nil }
        
        var result: Any? = nil

        if let navigator = parentRouter?.navigator {
            if let staticValue = staticValue {
                result = staticValue
                if let vc = staticValue as? UIViewController {
                    parentRouter?.navigator?.selectedViewController = vc
                }
            } else {
                result = action(variable: variable)
                
                let navController = navigator.selectedViewController as? UINavigationController
                
                switch(type) {
                case .Static:
                    // do nothing.  tab's are handled slightly differently above.
                    // TODO: say some meaningful shit about why this works this way.
                    if let vc = result as? UIViewController {
                        staticValue = vc
                    }
                    
                case .Push:
                    if let vc = result as? UIViewController {
                        navController?.pushViewController(vc, animated: animated)
                    }
                    
                case .Modal:
                    if let vc = result as? UIViewController {
                        // is the VC presenting something already?
                        if navController?.topViewController?.presentedViewController != nil {
                            navController?.topViewController?.presentedViewController?.dismissViewControllerAnimated(animated) { () -> Void in
                                // show our new VC once dismissed.
                                navController?.topViewController?.presentViewController(vc, animated: animated) {
                                    // do something in the completion block?
                                }
                            }
                        } else {
                            navController?.topViewController?.presentViewController(vc, animated: animated) {
                                // do something in the completion block?
                            }
                        }
                    }
                    
                case .Segue:
                    if let segueID = result as? String {
                        // is the VC presenting something already?
                        if navController?.topViewController?.presentedViewController != nil {
                            navController?.topViewController?.presentedViewController?.dismissViewControllerAnimated(animated) { () -> Void in
                                // perform our segue once dismissed.
                                navController?.topViewController?.performSegueWithIdentifier(segueID, sender: navController?.topViewController)
                            }
                        } else {
                            navController?.topViewController?.performSegueWithIdentifier(segueID, sender: navController?.topViewController)
                        }
                    }
                    
                default:
                    break
                }
            }
        } else {
            // they don't have a navigator setup, so just run it.
            result = action(variable: variable)
        }
        
        return result
    }
    
    private weak var staticValue: AnyObject? = nil
    internal weak var parentRouter: Router?
}

// MARK: - Finding Routes

extension Route {
    public func routesByName(name: String) -> [Route] {
        return subRoutes.filterByName(name)
    }
    
    public func routeByName(name: String) -> Route? {
        let routes = routesByName(name)
        if routes.count > 0 {
            return routes[0]
        }
        return nil
    }
    
    public func routesByType(type: RoutingType) -> [Route] {
        return subRoutes.filterByType(type)
    }
    
    public func routeByType(type: RoutingType) -> Route? {
        let routes = routesByType(type)
        if routes.count > 0 {
            return routes[0]
        }
        return nil
    }
    
    /// Finds all routes that satisfy an array of components
    internal func routesForComponents(components: [String]) -> [Route] {
        var result = [Route]()
        
        var currentRoute: Route = self
        
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
}

// MARK: Filtering Route Collections

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
