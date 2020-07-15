//
//  marker maps .swift
//  MiraLite
//
//  Created by Артем Стратиенко on 04.06.2020.
//  Copyright © 2020 Артем Стратиенко. All rights reserved.
//

import Foundation
import heresdk
import UIKit

extension ViewController {
    func createMapMarker(positon : GeoCoordinates) -> MapMarker? {
        guard
            let image = UIImage(named: "poi.png"),
            let imageData = image.pngData() else {
                print("Error: Image not found.")
                return nil
        }
        
        // The bottom, middle position should point to the location.
        // By default, the anchor point is set to 0.5, 0.5.
        let anchorPoint = Anchor2D(horizontal: 0.5, vertical: 1)
        let mapMarker = MapMarker(at: positon,
                                  image: MapImage(pixelData: imageData,
                                                  imageFormat: ImageFormat.png),
                                  anchor: anchorPoint)
        let metadata = Metadata()
        metadata.setString(key: "key_poi", value: "POI #\(countPoi)")
        mapMarker.metadata = metadata
        return mapMarker
        //mapHere.mapScene.addMapMarker(mapMarker)
    }
}
