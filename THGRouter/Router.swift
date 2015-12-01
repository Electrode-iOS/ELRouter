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
    
    public var tabBarController: UITabBarController? = nil
    
    public func register(route: Route) {
        if route.name != nil {
            routes.append(route)
        }
        
        // if it's a .Tab route, we need to refresh the tabBarController.
        if route.type == .Tab {
            if let tabBarController = self.tabBarController {
                let tabRoutes = routesByType(.Tab)
                
                var controllers = [UIViewController]()
                for route in tabRoutes {
                    let vc = route.execute(false)
                    if let vc = vc {
                        controllers.append(vc)
                    }
                }
                
                tabBarController.setViewControllers(controllers, animated: false)
            }
        }
    }
    
    public func translate(from: String, to: String) {
        let existing = translation[from]
        if existing != nil {
            exceptionFailure("A translation for \(from) exists already!")
        }
        
        translation[from] = to
    }
    
    public func evaluateURL(url: NSURL) {
        if let components = url.deepLinkComponents {
            evaluate(components)
        }
    }
    
    public func evaluate(components: [String]) {
        var route: Route? = nil
        for i in 0..<components.count {
            let item = components[i]
            if i == 0 {
                let routes = routesByName(item)
                // TODO: Handle multiple routes coming back.
                if routes.count > 0 {
                    route = routes[0]
                    route?.execute(false)
                } else {
                    break
                }
            } else {
                // TODO: Fill this in.
            }
        }
    }
    
    public private(set) var routes = [Route]()
    
    private var translation = [String : String]()
}


extension Router {
    
    public func routesByName(name: String) -> [Route] {
        let result = routes.filter { (item) -> Bool in
            if item.name == name {
                return true
            } else {
                return false
            }
        }
        
        return result
    }
    
    public func routesByType(type: RoutingType) -> [Route] {
        let result = routes.filter { (item) -> Bool in
            if item.type == type {
                return true
            } else {
                return false
            }
        }
        return result
    }
    
}
