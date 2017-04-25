//
//  PutPin.swift
//  BambouMaps
//
//  Created by KIRIBAGUETTE on 22/04/2017.
//  Copyright © 2017 KIRIBAGUETTE. All rights reserved.
//

import Foundation
import Mapbox

class gestionMapsController : NSObject, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    // Positionnement d'une pin sur la carte
    let pin:MGLPointAnnotation = MGLPointAnnotation()
    
    func putAPinOnTheMap(mapView:MGLMapView, position:CLLocationCoordinate2D, title:String, subtitle:String) {
        
        self.pin.coordinate = position
        self.pin.title = title
        self.pin.subtitle = subtitle
        mapView.addAnnotation(self.pin)
    }
    
}
