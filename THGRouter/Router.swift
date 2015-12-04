//
//  Router.swift
//  THGRouter
//
//  Created by Brandon Sneed on 10/15/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation
import THGFoundation

/// 
@objc
public class Router: NSObject {
    static public let sharedInstance = Router()
    public var navigator: Navigator? = nil
    public private(set) var routes = [Route]()
    
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
    public func updateNavigator() {
        guard let navigator = navigator else { return }
        
        let tabRoutes = routesByType(.Static)
        var controllers = [UIViewController]()
        
        for route in tabRoutes {
            if let vc = route.execute(false) {
                controllers.append(vc)
            }
        }
        
        navigator.setViewControllers(controllers, animated: false)
    }
}

// MARK: - Registering Routes

extension Router {
    public func register(route: Route) {
        route.parentRouter = self
        
        if route.name != nil {
            routes.append(route)
        }
    }
}

// MARK: - Evaluating Routes

extension Router {
    public func evaluateURL(url: NSURL) -> Bool {
        guard let components = url.deepLinkComponents else { return false }
        return evaluate(components)
    }
    
    public func evaluate(components: [String]) -> Bool {
        var route: Route? = nil
        var routeWasExecuted = false
        
        if validate(components) {
            for i in 0..<components.count {
                let item = components[i]
                if i == 0 {
                    let routes = routesByName(item)
                    // TODO: Handle multiple routes coming back.
                    if routes.count > 0 {
                        route = routes[0]
                        route?.execute(false)
                        routeWasExecuted = true
                    } else {
                        break
                    }
                } else {
                    // TODO: Fill this in.
                }
            }
        }
        
        return routeWasExecuted
    }
    
    private func validate(components: [String]) -> Bool {
        return true
    }
}

// MARK: - Getting Routes

extension Router {
    public func routesByName(name: String) -> [Route] {
        return routes.filter { $0.name == name }
    }
    
    public func routesByType(type: RoutingType) -> [Route] {
        return routes.filter { $0.type == type }
    }
}
