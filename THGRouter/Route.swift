//
//  Route.swift
//  THGRouter
//
//  Created by Brandon Sneed on 10/15/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation

public typealias RouteActionCompletion = () -> Void
public typealias RouteActionClosure = (animated: Bool, completion: RouteActionCompletion) -> Void

@objc
public class Route: NSObject {
    /// The name of the route, ie: "reviews"
    public let name: String?
    
    public var userInfo = [String: AnyObject]()
    
    public var subRoutes = [Route]()

    /// Action block
    public let action: RouteActionClosure?
    
    init(_ name: String, action: RouteActionClosure! = nil) {
        self.name = name
        self.action = action
    }
    
    init(action: RouteActionClosure! = nil) {
        self.name = nil
        self.action = action
    }
    
    public func variable(action: RouteActionClosure! = nil) -> Route {
        let variable = Route()
        subRoutes.append(variable)
        return variable
    }
    
    public func route(name: String, action: RouteActionClosure! = nil) -> Route {
        let screen = Route(name, action: action)
        subRoutes.append(screen)
        return screen
    }
}
