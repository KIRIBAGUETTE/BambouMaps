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
        
    var locationManager:CLLocationManager {
        set {
            }
        
        get {
            return _locationManager
        }
    }
}
