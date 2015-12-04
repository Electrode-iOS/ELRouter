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
    
    public var subRoutes = [Route]()

    /// Action block
    public let action: RouteActionClosure?
    
    public init(_ name: String, type: RoutingType, action: RouteActionClosure! = nil) {
        self.name = name
        self.type = type
        self.action = action
    }
    
    internal init(type: RoutingType, action: RouteActionClosure! = nil) {
        self.name = nil
        self.type = type
        self.action = action
    }
    
    public func variable(action: RouteActionClosure! = nil) -> Route {
        let variable = Route(type: .Variable, action: action)
        subRoutes.append(variable)
        return variable
    }
    
    public func route(name: String, type: RoutingType, action: RouteActionClosure! = nil) -> Route {
        let route = Route(name, type: type, action: action)
        subRoutes.append(route)
        return route
    }
    
    public func execute(animated: Bool, variable: String? = nil) -> UIViewController? {
        // bail out when missing a valid navigator or action
        guard let navigator = parentRouter?.navigator else { return nil }
        guard let action = action else { return nil }
        
        var result: UIViewController? = nil

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
                
            default: break
            }
        }
        
        return result
    }
    
    private weak var staticValue: UIViewController? = nil
    internal weak var parentRouter: Router?
}
