//
//  NSURL+DeepLink.swift
//  ELRouter
//
//  Created by Brandon Sneed on 10/20/15.
//  Copyright © 2015 Walmart. All rights reserved.
//

import Foundation

public extension NSURL {
    public var deepLinkComponents: [String]? {
        guard let pathComponents = pathComponents else { return nil }
        
        // a deep link doesn't have the notion of a host, construct it as such
        var components = [String]()
        
        // if we have a host, it's considered a component.
        if let host = host {
            components.append(host)
        }
        
        // out "/" and append our components
        components.appendContentsOf(pathComponents.filter { !($0 == "/") })
        
        return components
    }
    
    /*public var queryAsPairsif : [String : String]? {
        if let query = query {
            let components = query.componentsSeparatedByString("&")
            
        }
        
        return nil
    }*/
}
