//
//  polyline maps.swift
//  MiraLite
//
//  Created by Артем Стратиенко on 04.06.2020.
//  Copyright © 2020 Артем Стратиенко. All rights reserved.
//

import Foundation
import heresdk
import UIKit

extension ViewController {
 func createMapPolyline(arrayPolyline : [GeoCoordinates]) -> MapPolyline? {
    let coordinates = arrayPolyline

    // We are sure that the number of vertices is greater than two, so it will not crash.
    if coordinates.count < 2 {
        return nil
    }
        let geoPolyline = try! GeoPolyline(vertices: coordinates)
        let color_start = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        _ = Color(red: 0x00, green: 0x90, blue: 0x8A, alpha: 0xA0)
        let mapPolyline = MapPolyline(geometry: geoPolyline,
                                      widthInPixels: 5,
                                      color: Color(color_start))
        let metadata = Metadata()
                 metadata.setString(key: "key_poly", value: "Poly #\(countPoly)")
                 mapPolyline.metadata = metadata
    return mapPolyline
}
}
