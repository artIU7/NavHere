//
//  ViewController.swift
//  MiraLite
//
//  Created by Артем Стратиенко on 28.05.2020.
//  Copyright © 2020 Артем Стратиенко. All rights reserved.
//

import UIKit
import heresdk
import CoreLocation
//
// MARK add Enum Shema Map
//
enum shema {
    case day
    case night
}
var tempPositin : CLLocationCoordinate2D!

class ViewController: UIViewController {
    // MARK route
    var routingExample: RoutingExample!
    var isMapSceneLoaded = false
    // MARK Array Polylines
    var mapPolyliness = [MapPolyline]()
    // MARK Array Marker
    var mapMarkers = [MapMarker]()
    // MARK poi count
    var countPoi : Int = 0
    // MARK poly count
    var countPoly : Int = 0
    //
    var arrayPolyLine : [GeoCoordinates]? = []
    //
    @IBOutlet weak var helpView: CardView!
    // add var mapHere
    
    @IBOutlet var mapHere: MapView!
    // MARK Switch UI
    @IBOutlet weak var locationSwitchState: UISwitch!
    //
    // MARK Switch Gesture
    @IBOutlet weak var panGestureDefault: UISwitch!
    @IBOutlet weak var polyDrawState: UISwitch!
    
    @IBAction func locationSwitchAction(_ sender: Any) {
        if locationSwitchState.isOn {
            startLocation()
        } else {
            stopLocation()
        }
    }
    @IBAction func panGestureDefaultSwitch(_ sender: Any) {
        if panGestureDefault.isOn {
            mapHere.gestures.disableDefaultAction(forGesture: .doubleTap)
            mapHere.gestures.doubleTapDelegate = self
        } else {
            mapHere.gestures.enableDefaultAction(forGesture: .doubleTap)
            mapHere.gestures.doubleTapDelegate = nil
            for object in mapMarkers {
                print(object.metadata?.getString(key: "key_poi") as Any)
            }
            for line in mapPolyliness {
                print(line.metadata?.getString(key: "key_poly"))
            }
        }
    }
    @IBAction func polyDrawStateStart (_ sender: Any) {
        if polyDrawState.isOn {
            if arrayPolyLine!.count > 0 {
                if let polyline = self.createMapPolyline(arrayPolyline: arrayPolyLine!) {
                    let mapScene = mapHere.mapScene
                    countPoly += 1
                    mapPolyliness.append(polyline)
                    mapScene.addMapPolyline(polyline)
                }
            }
        } else {
            if arrayPolyLine!.count > 0 {
                arrayPolyLine?.removeAll()
            }
        }
    }
    // MARK Segment UI
    //
    @IBAction func actionSegement(_ sender: Any) {
        var type = shema.day
        switch switchShema.selectedSegmentIndex
        {
        case 0:
            type = .day
            changeShema(type: type)
        case 1:
            type = .night
            changeShema(type: type)
        default:
            break
        }
    }
    
    @IBOutlet weak var switchShema: UISegmentedControl!
    //
    let locationManager = CLLocationManager()
    //
    // MARK viewDidLoad
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // call mapView
        mapHere.mapScene.loadScene(mapScheme: MapScheme.greyDay, completion: onLoadScene)
        //
        // MARK add delegate TapDelegate
        //
        mapHere.gestures.tapDelegate = self
        mapHere.gestures.longPressDelegate = self
        initLocationManager()
        
    }
    // Load scene mapView
    private func onLoadScene(mapError: MapError?) {
        guard mapError == nil else {
            print("Error: Map scene not loaded, \(String(describing: mapError))")
            return
        }
        self.isMapSceneLoaded = true
        mapHere.mapScene.setLayerState(layerName: MapScene.Layers.trafficFlow,
                                       newState: MapScene.LayerState.visible)
        mapHere.mapScene.setLayerState(layerName:MapScene.Layers.trafficIncidents,
                                       newState: MapScene.LayerState.visible)
        /*let camera = mapHere.camera
         let orientation = MapCamera.OrientationUpdate(bearing: 90,
         tilt: 0)
         mapHere.camera.lookAt(point: GeoCoordinates(latitude: 52.373556, longitude: 13.114358),
         orientation: orientation,
         distanceInMeters: 1000 * 7) */
        
        // Configure the map.
        guard tempPositin != nil else {
            return
        }
        let camera = mapHere.camera
        camera.setDistanceToTarget(distanceInMeters: 100)
        camera.lookAt(point: GeoCoordinates(latitude: tempPositin.latitude, longitude: tempPositin.longitude), distanceInMeters: 100*2)
        // Start the example.
        self.routingExample =
            RoutingExample(viewController: self, mapView:self.mapHere!)
    }
    private func changeShema(type : shema) {
        //MapScheme.normalNight
        switch type {
        case .day:
            mapHere.mapScene.loadScene(mapScheme: MapScheme.normalDay,completion: onLoadScene)
        case .night:
            mapHere.mapScene.loadScene(mapScheme: MapScheme.normalNight,completion: onLoadScene)
        }
    }
    // didReceiveMemory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        mapHere.handleLowMemory()
    }
    @IBAction func onAddRouteButtonClicked(_ sender: Any) {
        if isMapSceneLoaded {
            if let polyline =   self.createMapPolyline(arrayPolyline: routingExample.polylineRoute!) {
                mapHere.mapScene.addMapPolyline(polyline)
            }
        }
    }
}


