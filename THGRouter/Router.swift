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
    
    public var routes: [Route] {
        return masterRoute.subRoutes
    }
    
    private let masterRoute: Route = Route("MASTER", type: .Other)
    
    
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
    /// Update the view controllers that are managed by the navigator
    public func updateNavigator() {
        guard let navigator = navigator else { return }
        
        let tabRoutes = routesByType(.Static)
        var controllers = [UIViewController]()
        
        for route in tabRoutes {
            if let vc = route.execute(false) {
                if let vc = vc as? UINavigationController {
                    controllers.append(vc)
                }
            }
        }
        
        navigator.setViewControllers(controllers, animated: false)
    }
}

// MARK: - Registering Routes

extension Router {
    /**
     Registers a top level route.
     
     - parameter route: The Route being registered.
    */
    public func register(route: Route) {
        var currentRoute = route
        
        // we may given the final link in a chain, walk back up to the top and
        // get the primary route to register.
        while currentRoute.parentRoute != nil {
            currentRoute.parentRouter = self
            currentRoute = currentRoute.parentRoute!
        }
        
        if currentRoute.name != nil {
            currentRoute.parentRouter = self
            masterRoute.subRoutes.append(currentRoute)
        }
    }
}

// MARK: - Evaluating Routes

extension Router {
    /**
     Evaluate a URL String. Routes matching the URL will be executed.
     
     - parameter url: The URL to evaluate.
     */
    public func evaluateURLString(urlString: String, animated: Bool = false) -> Bool {
        guard let url = NSURL(string: urlString) else { return false }
        return evaluateURL(url, animated: animated)
    }
    
    /**
     Evaluate a URL. Routes matching the URL will be executed.
     
     - parameter url: The URL to evaluate.
    */
    public func evaluateURL(url: NSURL, animated: Bool = false) -> Bool {
        guard let components = url.deepLinkComponents else { return false }
        return evaluate(components, animated: animated)
    }
    
    /**
     Evaluate an array of components. Routes matching the URL will be executed.
     
     - parameter components: The array of components to evaluate.
    */
    public func evaluate(components: [String], animated: Bool = false) -> Bool {
        var result = false
        
        let routes = routesToExecute(masterRoute, components: components)
        let valid = routes.count == components.count
        
        if valid && routes.count > 0 {
            for i in 0..<components.count {
                let route = routes[i]
                
                var variable: String? = nil
                if route.type == .Variable {
                    variable = components[i]
                }
                
                if route.parentRoute?.type == .Variable && i > 0  {
                    variable = components[i-1]
                }
                
                route.execute(animated, variable: variable)
            }
            
            result = true
        }
        
        return result
    }
    
    private func routesToExecute(startRoute: Route, components: [String]) -> [Route] {
        var result = [Route]()
        
        var currentRoute: Route = startRoute
        
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

// MARK: - Getting Routes

extension Router {
    /**
     Get all routes of a particular name.
     
     - parameter name: The name of the routes to get.
    */
    public func routesByName(name: String) -> [Route] {
        return routes.filterByName(name)
    }
    
    /**
     Get all routes of a particular routing type.
     
     - parameter type: The routing type of the routes to get.
    */
    public func routesByType(type: RoutingType) -> [Route] {
        return routes.filterByType(type)
    }
    
    /// Find the end routes that satisfy a URL
    public func routesForURL(url: NSURL) -> [Route]? {
        guard let components = url.deepLinkComponents else { return nil }
        
        var currentRouteSet: [Route] = [masterRoute]
        
        for index in 0..<components.count {
            let part = components[index]
            
            var routeSet = [Route]()
            
            for route in currentRouteSet {
                route.routesByName(part).each { routeSet.append($0) }
            }
            
            currentRouteSet = routeSet
        }
        
        return currentRouteSet
    }
}
