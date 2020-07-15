//
//  RouteEngine.swift
//  MiraLite
//
//  Created by Артем Стратиенко on 04.06.2020.
//  Copyright © 2020 Артем Стратиенко. All rights reserved.
//

import Foundation
import heresdk
import UIKit

class RoutingExample {
    var polylineRoute : [GeoCoordinates]?
    private var viewController: UIViewController
    private var mapView: MapView
    private var mapMarkers = [MapMarker]()
    private var mapPolylineList = [MapPolyline]()
    private var routingEngine: RoutingEngine
    private var startGeoCoordinates: GeoCoordinates?
    private var destinationGeoCoordinates: GeoCoordinates?
    
    init(viewController: UIViewController, mapView: MapView) {
        self.viewController = viewController
        self.mapView = mapView
        let camera = mapView.camera
        camera.lookAt(point: GeoCoordinates(latitude: 52.520798, longitude: 13.409408),
                      distanceInMeters: 1000 * 10)
        
        do {
            try routingEngine = RoutingEngine()
        } catch let engineInstantiationError {
            fatalError("Failed to initialize routing engine. Cause: \(engineInstantiationError)")
        }
    }
    
    func addRoute(last : GeoCoordinates) /*-> [GeoCoordinates]? */{
        clearMap()
        if tempPositin != nil {
            startGeoCoordinates = GeoCoordinates(latitude: tempPositin.latitude, longitude: tempPositin.longitude)
        }
        destinationGeoCoordinates = last
        
        let carOptions = CarOptions()
        routingEngine.calculateRoute(with: [Waypoint(coordinates: startGeoCoordinates!),
                                            Waypoint(coordinates: destinationGeoCoordinates!)],
                                     carOptions: carOptions) { (routingError, routes) in
                                        
                                        if let error = routingError {
                                            self.showDialog(title: "Error while calculating a route:", message: "\(error)")
                                            return
                                        }
                                        
                                        // When routingError is nil, routes is guaranteed to contain at least one route.
                                        let route = routes!.first
                                        self.polylineRoute = route!.polyline
                                        self.showRouteDetails(route: route!)
                                        self.showRouteOnMap(route: route!)
                                        //self.showRouteDetails(route: route!)
                                        //self.showRouteOnMap(route: route!)
        }
        //  return polylineRoute
    }
    
    private func showRouteDetails(route: Route) {
        let estimatedTravelTimeInSeconds = route.durationInSeconds
        let lengthInMeters = route.lengthInMeters
        
        let routeDetails =
            "Travel Time: " + formatTime(sec: estimatedTravelTimeInSeconds)
                + ", Length: " + formatLength(meters: lengthInMeters)
        
        showDialog(title: "Route Details", message: routeDetails)
    }
    
    private func formatTime(sec: Int32) -> String {
        let hours: Int32 = sec / 3600
        let minutes: Int32 = (sec % 3600) / 60
        
        return "\(hours):\(minutes)"
    }
    
    private func formatLength(meters: Int32) -> String {
        let kilometers: Int32 = meters / 1000
        let remainingMeters: Int32 = meters % 1000
        
        return "\(kilometers).\(remainingMeters) km"
    }
    
    private func showRouteOnMap(route: Route) {
        // Show route as polyline.
        let routeGeoPolyline = try! GeoPolyline(vertices: route.polyline)
        let routeMapPolyline = MapPolyline(geometry: routeGeoPolyline,
                                           widthInPixels: 20,
                                           color: Color(red: 0x00, green: 0x90, blue: 0x8A, alpha: 0xA0))
        mapView.mapScene.addMapPolyline(routeMapPolyline)
        mapPolylineList.append(routeMapPolyline)
        
        // Draw a circle to indicate starting point and destination.
        addCircleMapMarker(geoCoordinates: startGeoCoordinates!, imageName: "green_dot.png")
        addCircleMapMarker(geoCoordinates: destinationGeoCoordinates!, imageName: "green_dot.png")
        
        // Log maneuver instructions per route leg / sections.
        let sections = route.sections
        for section in sections {
            logManeuverInstructions(section: section)
        }
    }
    
    private func logManeuverInstructions(section: Section) {
        print("Log maneuver instructions per section:")
        let maneuverInstructions = section.maneuvers
        for maneuverInstruction in maneuverInstructions {
            let maneuverAction = maneuverInstruction.action
            let maneuverLocation = maneuverInstruction.coordinates
            let maneuverInfo = "\(maneuverInstruction.text)"
                + ", Action: \(maneuverAction)"
                + ", Location: \(maneuverLocation)"
            print(maneuverInfo)
        }
    }
    
    
    func clearMap() {
        clearRoute()
    }
    
    
    private func clearRoute() {
        for mapPolyline in mapPolylineList {
            mapView.mapScene.removeMapPolyline(mapPolyline)
        }
        mapPolylineList.removeAll()
    }
    private func addCircleMapMarker(geoCoordinates: GeoCoordinates, imageName: String) {
        guard
            let image = UIImage(named: imageName),
            let imageData = image.pngData() else {
                return
        }
        let mapMarker = MapMarker(at: geoCoordinates,
                                  image: MapImage(pixelData: imageData,
                                                  imageFormat: ImageFormat.png))
        mapView.mapScene.addMapMarker(mapMarker)
        mapMarkers.append(mapMarker)
    }
    
    private func showDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alertController, animated: true, completion: nil)
    }
}
