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
    public let sharedInstance = Router()
    
    public func register(route: Route) {
        if route.name != nil {
            routes.append(route)
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
        if let components = url.pathComponents {
            evaluate(components)
        }
    }
    
    public func evaluate(components: [String]) {
        for i in 0..<components.count {
            let item = components[i]
            print(item)
        }
    }
    
    private var routes = [Route]()
    
    private var translation = [String : String]()
}
