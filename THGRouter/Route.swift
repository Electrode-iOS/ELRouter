//
//  Route.swift
//  THGRouter
//
//  Created by Brandon Sneed on 10/15/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation
import UIKit

//public typealias RouteActionCompletion = () -> Void
public typealias RouteActionClosure = (variable: String?) -> UIViewController?

@objc
public enum RoutingType: UInt {
    case Static
    case Segue
    case Screen
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
    public private(set) var parentRoute: Route?

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
    
    public func execute(animated: Bool, variable: String? = nil) -> UIViewController? {
        // bail out when missing a valid action
        guard let action = action else { return nil }
        
        var result: UIViewController? = nil

        if let navigator = parentRouter?.navigator {
            if let staticValue = staticValue {
                result = staticValue
                parentRouter?.navigator?.selectedViewController = staticValue
            } else {
                result = action(variable: variable)
                
                let navController = navigator.selectedViewController as? UINavigationController
                
                switch(type) {
                case .Static:
                    // do nothing.  tab's are handled slightly differently above.
                    // TODO: say some meaningful shit about why this works this way.
                    if let vc = result {
                        if !(vc is UINavigationController) {
                            result = UINavigationController(rootViewController: vc)
                        }
                    }
                    staticValue = result
                    
                case .Screen:
                    if let vc = result {
                        navController?.pushViewController(vc, animated: animated)
                    }
                    
                case .Modal:
                    if let vc = result {
                        if navController?.topViewController?.presentedViewController != nil {
                            navController?.topViewController?.presentedViewController?.dismissViewControllerAnimated(animated) { () -> Void in
                                // do something in the completion block?
                            }
                        } else {
                            navController?.topViewController?.presentViewController(vc, animated: animated) {
                                // do something in the completion block?
                            }
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
    
    private weak var staticValue: UIViewController? = nil
    internal weak var parentRouter: Router?
}

// MARK: Searching

extension Route {
    public func routesByName(name: String) -> [Route] {
        return subRoutes.filter { return $0.name == name }
    }
    
    public func routeByName(name: String) -> Route? {
        let routes = routesByName(name)
        if routes.count > 0 {
            return routes[0]
        }
        return nil
    }
    
    public func routesByType(type: RoutingType) -> [Route] {
        return subRoutes.filter { return $0.type == type }
    }
    
    public func routeByType(type: RoutingType) -> Route? {
        let routes = routesByType(type)
        if routes.count > 0 {
            return routes[0]
        }
        return nil
    }
}
