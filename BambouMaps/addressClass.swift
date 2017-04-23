//
//  address.swift
//  BambouMaps
//
//  Created by KIRIBAGUETTE on 23/04/2017.
//  Copyright © 2017 KIRIBAGUETTE. All rights reserved.
//

import Foundation

class addressClass {
    var _place_name:String!
    var _lattitude:Double!
    var _longitude:Double!
    var _id:String
    
    var place_name:String {
        set {
            
        }
        get {
            return _place_name
        }
    }
    
    var lattitude:Double {
        set {
            
        }
        get {
            return _lattitude
        }
    }
    
    var longitude:Double {
        set {
            
        }
        get {
            return _longitude
        }
    }
    
    var id:String {
        set {
            
        }
        get {
            return _id
        }
    }
    
    init(place_name:String, lattitude:Double, longitude:Double, id:String) {
        self._place_name = place_name
        self._longitude = lattitude
        self._longitude = longitude
        self._id = id
    }
    
    init() {
        self._place_name = ""
        self._longitude = 0
        self._lattitude = 0
        self._id = ""
    }
}
