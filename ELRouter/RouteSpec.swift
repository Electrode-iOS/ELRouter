//
//  RouteSpec.swift
//  ELRouter
//
//  Created by Brandon Sneed on 4/19/16.
//  Copyright © 2016 theholygrail.io. All rights reserved.
//

import Foundation

public protocol RouteEnum {
    var spec: RouteSpec { get }
}
/**
 Use a RouteSpec to document and define your routes.
 
 Example:

    struct WMListItemSpec: AssociatedData {
        let blah: Int
    }

    enum WishListRoutes: Int,  {
        case AddToList
        case DeleteFromList
        
        var spec: RouteSpec {
            switch self {
            case .AddToList: return (name: "AddToList", exampleURL: "scheme://item/<variable>/addToList")
            case .DeleteFromList: return (name: "DeleteFromList", exampleURL: "scheme://item/<variable>/deleteFromList")
            }
        }
    }
 
 */

public typealias RouteSpec = (name: String, type: RoutingType, example: String?)

/**
 */
func Variable(value: String) -> RouteSpec {
    return (name: value, type: .Variable, example: nil)
}
