//
//  DataProcessor.swift
//  AlongTheRoad
//
//  Created by Linus Aidan Meyer-Teruel on 9/4/15.
//  Copyright (c) 2015 Linus Aidan Meyer-Teruel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RouteDataFilter: NSObject {
    class var sharedInstance: RouteDataFilter {
        struct Static {
            static var instance: RouteDataFilter?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = RouteDataFilter()
        }
        
        return Static.instance!
    } 
    
    
    /* function: getSections
    * ---------------------------------
    * This function takes in a route and finds all the sections to be queried from the FourSquare API. It will filter
    * through all the possible sections of the route and determine which gps coordinates to discard as well as which
    * to infer for better search areas.
    */
    func getSections(route: MKRoute) -> [CLLocationCoordinate2D]{
        var mapPoints = route.polyline.points()
        //Convert the mapPoints to actual lon/lat route points
        var routePoints = [CLLocationCoordinate2D]()
        for i in 0..<route.polyline.pointCount {
            routePoints.append(MKCoordinateForMapPoint(mapPoints[i]))
            
        }
        return self.filterPoints(routePoints)
    }
    
    /* function: filterPoints
    * -----------------------
    * This function goes through the proccess of filtering through all the query points to determine which should
    * be actually queried by the API. It does this by selecting regions that are 3 kilometers apart and then sending new requests
    * to the API
    */
    func filterPoints(points:[CLLocationCoordinate2D]) -> [CLLocationCoordinate2D]{
        var latToKilometer: Double = 95
        var longToKilometer: Double = 95
        var desiredDistance = 3
        
        var querySections = [CLLocationCoordinate2D]()
        querySections.append(points[1]) //Add the second one and start it after so it doesn't querry start
        for i in 2..<points.count {
            var lastPoint = querySections[querySections.count-1]
            var latChange = (lastPoint.latitude - points[i].latitude)*latToKilometer
            var longChange = (lastPoint.longitude - points[i].longitude)*longToKilometer
            
            var totalChange = sqrt(latChange*latChange + longChange*longChange)
            if totalChange >= 3.0  {
                querySections.append(points[i])
            }
        }
        
        
        return querySections
    }
    
    /* function: findRegion
     * -----------------------------
     * This function takes in an array of CLLocationCoordinates and returns the MKRegion
     * that matches the desired region
     *
    */
    func findRegion (locations:[CLLocationCoordinate2D]) -> MKCoordinateRegion {
        //These limits are initialized to the maximal values so that they will always be overwritten
        var upperLimit = CLLocationCoordinate2D(latitude: -180, longitude: -180)
        var lowerLimit = CLLocationCoordinate2D(latitude: 180, longitude: 180)
        
        //This section iterates through all the locations to determine the limits
        for(var i = 0 ; i < locations.count ; i++ ) {
            if(locations[i].latitude > upperLimit.latitude) {
                upperLimit.latitude = locations[i].latitude
            }
            if(locations[i].latitude < lowerLimit.latitude) {
                lowerLimit.latitude = locations[i].latitude
            }
            if(locations[i].longitude > upperLimit.longitude) {
                upperLimit.longitude = locations[i].longitude
            }
            if(locations[i].longitude < lowerLimit.longitude) {
                lowerLimit.longitude = locations[i].longitude
            }
        }
        
        //Creates and sets the span object for the
        var locationSpan = MKCoordinateSpan()
        locationSpan.longitudeDelta = (upperLimit.longitude - lowerLimit.longitude)*2
        locationSpan.latitudeDelta = (upperLimit.latitude - lowerLimit.latitude)*2
        
        var center = CLLocationCoordinate2D()
        center.latitude = (upperLimit.latitude + lowerLimit.latitude)/2
        center.longitude = (upperLimit.longitude + lowerLimit.longitude)/2
        
        

        var region = MKCoordinateRegion(center: center, span: locationSpan)
        return region
    }
    
    
    
}
