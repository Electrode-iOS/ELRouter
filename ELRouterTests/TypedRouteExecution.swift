//
//  TypedRouteExecution.swift
//  ELRouter
//
//  Created by Brandon Sneed on 4/18/16.
//  Copyright © 2016 theholygrail.io. All rights reserved.
//

import XCTest
import ELRouter


public class WMListItemSpec: AssociatedData {
    init(blah argBlah: Int) {
        blah = argBlah
    }
    var blah: Int = 1
}

@objc
public enum WishListRoutes: Int, RouteEnum {
    case Home
    case AddToList
    case DeleteFromList
    
    public var spec: RouteSpec {
        switch self {
        case .Home: return (name: "Home", type: .Other, example: "home")
        case .AddToList: return (name: "AddToList", type: .Other, example: "addToList/variable")
        case .DeleteFromList: return (name: "DeleteFromList", type: .Other, example: "DeleteFromList")
        }
    }
}


class TypedRouteExecution: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTypedRoute() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let router = Router()
        
        //let homeNextType = expectationWithDescription("home route receives a nextType")
        let homeData = expectationWithDescription("home route receives associatedData")
        //let addToListNextType = expectationWithDescription("addToList route receives a nextType")
        let addToListData = expectationWithDescription("addToList route receives associatedData")
        //let deleteFromListNextType = expectationWithDescription("deleteFromList route receives a nextType")
        let deleteFromListData = expectationWithDescription("deleteFromList route receives associatedData")
        
        let comepletedAllRoutes = expectationWithDescription("All routes completed")
        
        let routes = Route(WishListRoutes.Home) { variable, associatedData in
            print ("WishListRoutes.Home route")
            XCTAssertTrue(variable == "12345")
            XCTAssertNil(associatedData)
            
            
            if associatedData == nil {
                homeData.fulfill()
            } else {
                XCTFail()
            }
            
            let newData = WMListItemSpec(blah: 2)
            associatedData = newData
            
            return nil
        }.variable { (variable, associatedData) -> Any? in
            print ("First variable route")
            return nil
        }.route(WishListRoutes.AddToList) { variable, associatedData in
            print ("WishListRoutes.AddToList route")
            XCTAssertTrue(variable == "XYZ")
            
            if let data = associatedData as? WMListItemSpec {
                // we set blah to 2 in our previous bit of the chain.
                XCTAssert(data.blah == 2, "Associated data should have a value of 2")
                if data.blah == 2 {
                    addToListData.fulfill()

                    let newData = WMListItemSpec(blah: 3)
                    associatedData = newData
                } else {
                    XCTFail()
                }
            } else {
                XCTFail()
            }
            return nil
        }.variable { variable, associatedData in
            print ("Second variable route")
              return nil
        }.route(WishListRoutes.DeleteFromList) { variable, associatedData in
            print ("WishListRoutes.DeleteFromList")
            XCTAssertTrue(variable == nil)
            
            if let data = associatedData as? WMListItemSpec {
                // we set blah to 3 in our previous bit of the chain.
                XCTAssert(data.blah == 3, "Associated data should have a value of 3")
                if data.blah == 3 {
                    deleteFromListData.fulfill()
                } else {
                    XCTFail()
                }
            } else {
                XCTFail()
            }
            return nil
        }
        
        router.register(routes)
        
        // Home/AddToList/<var>/DeleteFromList/<var>

        router.evaluate([WishListRoutes.Home, Variable("12345"), WishListRoutes.AddToList, Variable("XYZ"), WishListRoutes.DeleteFromList], associatedData: nil) {
            comepletedAllRoutes.fulfill()
        }
        
        waitForExpectationsWithTimeout(15, handler: nil)
    }

    func testObjcRoute1() {
        //let objc = ObjcTypedRouteExecution()
        //XCTAssertTrue(objc.performRoute1())
    }
    
    func testObjcRoute2() {
        //let objc = ObjcTypedRouteExecution()
        //XCTAssertTrue(objc.performRoute1())
    }

}
