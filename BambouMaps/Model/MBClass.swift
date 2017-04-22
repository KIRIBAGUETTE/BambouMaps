//
//  MBClass.swift
//  BambouMaps
//
//  Created by KIRIBAGUETTE on 22/04/2017.
//  Copyright © 2017 KIRIBAGUETTE. All rights reserved.
//

import Foundation
import Mapbox

class MBClass : NSObject, CLLocationManagerDelegate, MGLMapViewDelegate {
    var _locationManager:CLLocationManager!
    var _mapView:MGLMapView!
    
    var mapView:MGLMapView {
        set {
            _mapView.styleURL = MGLStyle.outdoorsStyleURL(withVersion: 9)
            _mapView.showsUserLocation = true
        }
        
        get {
            return _mapView
        }
    }
    
    var locationManager:CLLocationManager {
        set {
            }
        
        get {
            return _locationManager
        }
    }
    
    init(view:UIView) {
        self._mapView = MGLMapView(frame: view.bounds)
    }
}
