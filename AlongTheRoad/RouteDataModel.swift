//
//  RouteDataModel.swift
//  AlongTheRoad
//
//  Created by Linus Aidan Meyer-Teruel on 8/31/15.
//  Copyright (c) 2015 Linus Aidan Meyer-Teruel. All rights reserved.
//

import UIKit
import MapKit

class RouteDataModel: NSObject {
    
    class var sharedInstance: RouteDataModel {
        struct Static {
            static var instance: RouteDataModel?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = RouteDataModel()
        }
        
        return Static.instance!
    }

    var destination: String
    var startingPoint: String
    var route: MKRoute?
    var routes: [AnyObject]
    var searchRadius:Int
    var searchSection: String
    var restaurants: [AnyObject]
    var isDestination: Bool
    var restaurantDictionary: [String: AnyObject]
    var selectedRestaurant: AnyObject?

    override init(){
        routes = []
        destination = ""
        startingPoint = ""
        searchRadius = 1600//Default at the beginning
        searchSection = "food"
        restaurants = [AnyObject]()
        isDestination = false
        restaurantDictionary = [String: AnyObject]()
    }
    
}