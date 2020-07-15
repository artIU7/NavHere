//
//  circle maps.swift
//  MiraLite
//
//  Created by Артем Стратиенко on 29.05.2020.
//  Copyright © 2020 Артем Стратиенко. All rights reserved.
//

import Foundation
import heresdk
extension ViewController {
    func createMapCircle(positon : GeoCoordinates) -> MapPolygon {
        let geoCircle = GeoCircle(center: positon,
                                  radiusInMeters: 2.0)

        let geoPolygon = GeoPolygon(geoCircle: geoCircle)
        let fillColor = Color(red: 0x00, green: 0x90, blue: 0x8A, alpha: 0xA0)
        let mapPolygon = MapPolygon(geometry: geoPolygon, color: fillColor)
        let metadata = Metadata()
            metadata.setString(key: "key_poly", value: "Poly #\(countPoly)")
            mapPolygon.metadata = metadata
        return mapPolygon
    }
    func myLocationHere(location : GeoCoordinates) {
        // add circle
        let mapPolygon = createMapCircle(positon: location)
        let mapScene = mapHere.mapScene
        mapScene.addMapPolygon(mapPolygon)
    }
}

