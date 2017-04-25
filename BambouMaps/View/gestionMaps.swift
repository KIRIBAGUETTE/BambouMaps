//
//  gestionMaps.swift
//  BambouMaps
//
//  Created by KIRIBAGUETTE on 25/04/2017.
//  Copyright © 2017 KIRIBAGUETTE. All rights reserved.
//

import Foundation
import Mapbox

class gestionMaps {
    
    // Configuration de la map
    
    func gestMaps(mapView:MGLMapView) {
        mapView.styleURL = MGLStyle.outdoorsStyleURL(withVersion: 9)
        mapView.showsUserLocation = true
    }
    
}
