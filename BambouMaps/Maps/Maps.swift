//
//  Maps.swift
//  BambouMaps
//
//  Created by KIRIBAGUETTE on 26/04/2017.
//  Copyright © 2017 KIRIBAGUETTE. All rights reserved.
//

import UIKit
import Mapbox

public protocol Maps {
    associatedtype MapType
    var mapView:MapType! { set get }
    func configMaps(frame: CGRect)
    func putAPinOnTheMap(latitude:Double, longitude:Double, title:String, subtitle:String)
    func moveCamera(latitude:Double, longitude:Double, title:String, subtitle:String)
}

class MapBox: NSObject, Maps {
    public var mapView: MGLMapView!
    typealias MapType = MGLMapView
    let pin:MGLPointAnnotation = MGLPointAnnotation()
    
    func configMaps(frame: CGRect) {
        mapView = MGLMapView(frame: frame)
        mapView.styleURL = MGLStyle.outdoorsStyleURL(withVersion: 9)
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    
    func putAPinOnTheMap(latitude:Double, longitude:Double, title:String, subtitle:String) {
        let position:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        pin.coordinate = position
        pin.title = title
        pin.subtitle = subtitle
        mapView.addAnnotation(pin)
    }
    
    func moveCamera(latitude:Double, longitude:Double, title:String, subtitle:String) {
        let position:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let camera = MGLMapCamera(lookingAtCenter: position, fromDistance: 4500, pitch: 15, heading: 180)
        mapView.setCamera(camera, withDuration: 3, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
    }
    
    func centerCameraOnUser(latitude:Double, longitude:Double) {
        let position:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.setCenter(position, zoomLevel: 12, direction: 0, animated: false)
    }
}

extension MapBox:MGLMapViewDelegate {}

class MapModule<T:Maps> {
    var map:T
    
    init(viewMaps:UIView, mapType:T) {
        map = mapType
        map.configMaps(frame:viewMaps.bounds)
        //        viewMaps.addSubview(map.mapView as! UIView)
        viewMaps.insertSubview(map.mapView as! UIView, at: 1)
    }
}
