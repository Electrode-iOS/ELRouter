//
//  NSURL+DeepLink.swift
//  THGRouter
//
//  Created by Brandon Sneed on 10/20/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import Foundation

public extension NSURL {
    public var deepLinkComponents: [String]? {
        // a deep link doesn't have the notion of a host, construct it as such
        if let pathComponents = pathComponents {
            var components = [String]()
            
            // if we have a host, it's considered a component.
            if let host = host {
                components.append(host)
            }
            
            // out "/" and append our components
            let filtered = pathComponents.filter { (item) -> Bool in
                if item == "/" {
                    return false
                } else {
                    return true
                }
            }
            
            components.appendContentsOf(filtered)
            
            return components
        }
        
        return nil
    }
    
    /*public var queryAsPairsif : [String : String]? {
        if let query = query {
            let components = query.componentsSeparatedByString("&")
            
        }
        
        return nil
    }*/
}
