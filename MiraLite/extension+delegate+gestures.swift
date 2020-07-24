//
//  extension+delegate+gestures.swift
//  MiraLite
//
//  Created by Артем Стратиенко on 29.05.2020.
//  Copyright © 2020 Артем Стратиенко. All rights reserved.
//

import Foundation
import heresdk
import UIKit


extension ViewController : TapDelegate,DoubleTapDelegate,LongPressDelegate,PanDelegate {
    
    // MARK :: TapDelegate
    // realizing conform methods protocol TapDelegate
    func onTap(origin: Point2D) {
        let geoCoordinates = mapHere.viewToGeoCoordinates(viewCoordinates: origin)!
        
        //mapHere.pickMapItems(at: origin, radius: 2, completion: onMapItemsPickedPoly)
        mapHere.pickMapItems(at: origin, radius: 10, completion: onMapItemsPickedMarker)
        //
        print("Tap at: \(String(describing: geoCoordinates))")
    }
    // MARK :: DoubleDelegate
    // realizing conform methods protocol TapDelegate
    func onDoubleTap(origin: Point2D) {
        //
        let geoCoordinates = mapHere.viewToGeoCoordinates(viewCoordinates: origin)!
        arrayPolyLine?.append(geoCoordinates)
        self.countPoi += 1
        let testMarker = createMapMarker(positon: mapHere.viewToGeoCoordinates(viewCoordinates: origin)!)
        if testMarker != nil {
            let mapScene = mapHere.mapScene
            mapMarkers.append(testMarker!)
            mapScene.addMapMarker(testMarker!)
            
        }
    }
    // MARK :: longPressDelegate
    // realizing conform methods protocol TapDelegate
    func onLongPress(state: GestureState, origin: Point2D) {
        //
        switch state {
            
        case .begin:
            var position = mapHere.viewToGeoCoordinates(viewCoordinates: origin)!
            position = GeoCoordinates(latitude: position.latitude, longitude: position.longitude, altitude: 0.0)
            addAction(position as Any)
        case .update: break
        //
        case .end: break
        //
        case .cancel: break
        //
        @unknown default: break
            //
        }
    }
    // MARK :: TapDelegate
    // realizing conform methods protocol TapDelegate
    func onPan(state: GestureState, origin: Point2D, translation: Point2D, velocity: Double) {
        //
        
    }
    // Sub method actionUI
    func addAction(_ object : Any) {
        // MARK add UI Alert test delegate
        let alert = UIAlertController(title: "Location From Tap Delegate", message: "\(String(describing: object))", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Отмена", style: .default) {
            (_) -> Void in
        }
        let deleteAction = UIAlertAction(title: "Удалить обьекты", style: .destructive) { (_) -> Void in
            let newObjectsMarker = self.mapMarkers.filter({(objectMarker : MapMarker) -> Bool in return objectMarker .metadata?.getString(key: "key_poi") == (object as! String)}) 
            let newObjectsPolyline = self.mapPolyliness.filter({(objectPoly : MapPolyline) -> Bool in return objectPoly .metadata?.getString(key: "key_poly") == (object as! String)})
            
            if newObjectsMarker != [] {
                self.mapHere.mapScene.removeMapMarker(newObjectsMarker[0])
            } else if newObjectsPolyline != [] {
                self.mapHere.mapScene.removeMapPolyline(newObjectsPolyline[0])
            }
            
        }
        let routeAction = UIAlertAction(title: "Маршрут", style: .default) {
            (_) -> Void in
            if self.isMapSceneLoaded {
                let lastCoordinate = object as! GeoCoordinates
                print(lastCoordinate) //
                    self.routingExample.addRoute(last: lastCoordinate)
                    //   self.createMapPolyline(arrayPolyline: drawNewPRoute!)
               
                 /*   let alertController = UIAlertController(title: "Error", message: "no last position found", preferredStyle: .alert)
                       alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                       self.present(alertController, animated: true, completion: nil) */
            }
        }
        alert.addAction(deleteAction)
        alert.addAction(routeAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    // get marker info
    // Completion handler to receive picked map items.
    func onMapItemsPickedMarker(pickedMapItems: PickMapItemsResult?) {
        
        if let pickObjectMarker = pickedMapItems?.markers.first {
            print(pickObjectMarker)
            if let message_poi = pickObjectMarker.metadata?.getString(key: "key_poi") {
                addAction(message_poi)
                return
            }
            addAction(pickObjectMarker.coordinates)
            return
        }
        if let pickObjectPolyline = pickedMapItems?.polylines.first {
            print(pickObjectPolyline)
            var coord = pickObjectPolyline as MapPolyline
            
            if let message_poly = pickObjectPolyline.metadata?.getString(key: "key_poly") {
                addAction(message_poly)
                return
            }
            addAction(pickObjectPolyline.hashValue)
            return
        }
        
        
        
        /*
         guard let topmostMapMarker = pickedMapItems?.markers.first else {
         print("non markers")
         return
         }
         
         if let message_poi = topmostMapMarker.metadata?.getString(key: "key_poi") {
         addAction(message_poi)
         print("marker non metadata")
         return
         }
         guard let topmostMapPoly = pickedMapItems?.polylines.first else {
         print("non polyline")
         return
         }
         
         if let message_poly = topmostMapPoly.metadata?.getString(key: "key_poly") {
         addAction(message_poly)
         return
         }*/
        //    addAction("")
    }
    // Completion handler to receive picked map items.
    func onMapItemsPickedPoly(pickedMapItems: PickMapItemsResult?) {
        print(pickedMapItems?.polylines)//.polylines)
        guard let topmostMapPoly = pickedMapItems?.polylines.first else {
            return
        }
        
        if let message = topmostMapPoly.metadata?.getString(key: "key_poly") {
            addAction(message)
            return
        }
        addAction(topmostMapPoly.hashValue)
    }
}


extension PickMapItemsResult {
    /* func addPolygon() -> MapPolygon {
     var polygon: [heresdk.MapPolygon]
     var polygonReturn : MapPolygon
     return polygonReturn
     } */
}
