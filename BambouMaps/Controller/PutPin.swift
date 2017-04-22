//
//  PutPin.swift
//  BambouMaps
//
//  Created by KIRIBAGUETTE on 22/04/2017.
//  Copyright © 2017 KIRIBAGUETTE. All rights reserved.
//

import Foundation
import Mapbox

class PutPin : NSObject, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    // Positionnement d'une pin sur la carte
    
    func putAPinOnTheMap(mapView:MGLMapView, position:CLLocationCoordinate2D, title:String, subtitle:String) {
        let pin:MGLPointAnnotation = MGLPointAnnotation()
        pin.coordinate = position
        pin.title = title
        pin.subtitle = subtitle
        mapView.addAnnotation(pin)
    }
    
}
