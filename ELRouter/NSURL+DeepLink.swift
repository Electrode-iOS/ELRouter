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
        guard pathComponents != nil else { return nil }

        // a deep link doesn't have the notion of a host, construct it as such
        var components = [String]()
        
        // if we have a host, it's considered a component.
        if let host = host {
            components.append(host)
        }

        // now add the path components, leaving the encoded parts intact
        if let urlComponents = NSURLComponents(string: absoluteString),
               percentEncodedPath = urlComponents.percentEncodedPath
        {
            // Note that the percentEncodedPath property of NSURLComponents does not add any encoding, it just returns any
            // encoding that is already in the path. Unencoded slashes will remain unencoded but escaped slashes will remain
            // escaped, which is what we want here.
            let pathComponents = percentEncodedPath.componentsSeparatedByString("/")
            // remove any empty strings, such as the one in the first element that results from the initial slash
            let pathComponentsAfterSlash = pathComponents.filter() { !$0.isEmpty }
            // append to our components
            components += pathComponentsAfterSlash
        }

        return components
    }
    
    /*public var queryAsPairsif : [String : String]? {
        if let query = query {
            let components = query.componentsSeparatedByString("&")
            
        }
        
        return nil
    }*/
}
