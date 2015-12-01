//
//  Route.swift
//  THGRouter
//
//  Created by Brandon Sneed on 10/15/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation
import UIKit

public typealias RouteActionCompletion = () -> Void
public typealias RouteActionClosure = (variable: String?) -> UIViewController?

@objc
public enum RoutingType: UInt {
    case Tab
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
        
        if self.type == .Tab {
            self.isStatic = true
        } else {
            self.isStatic = false
        }
    }
    
    internal init(type: RoutingType, action: RouteActionClosure! = nil) {
        self.name = nil
        self.type = type
        self.action = action
        
        if self.type == .Tab {
            self.isStatic = true
        } else {
            self.isStatic = false
        }
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
        var result: UIViewController? = nil
        
        if let action = self.action {
            if (staticValue != nil) {
                result = staticValue
                if let tabBarController = Router.sharedInstance.tabBarController {
                    tabBarController.selectedViewController = staticValue
                }
            } else {
                result = action(variable: variable)
                
                switch(type) {
                case .Tab:
                    // do nothing.  tab's are handled slightly differently above.
                    // TODO: say some meaningful shit about why this works this way.
                    staticValue = result
                    break
                    
                case .Screen:
                    break
                    
                case .Modal:
                    break
                    
                default:
                    break
                }
                
            }

        }
        
        return result
    }
    
    private let isStatic: Bool
    private weak var staticValue: UIViewController? = nil
}
