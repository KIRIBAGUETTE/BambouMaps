//
//  ViewController.swift
//  BambouMaps
//
//  Created by KIRIBAGUETTE on 21/04/2017.
//  Copyright © 2017 KIRIBAGUETTE. All rights reserved.
//

import UIKit
import Mapbox

class ViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var subMapView: UIView!
    @IBOutlet weak var textFieldAddress: UITextField!
    
    @IBOutlet weak var textFieldAddressConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var textFieldAddressConstraintWidth: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let MBox:MBClass = MBClass(view: view)
        let PutPinClass:PutPin = PutPin()
        
        MBox._mapView.delegate = self

        self.configLocation(MBox:MBox)

        var position:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 48.8414, longitude: 2.2530)
        if MBox._locationManager.location != nil {
            position = (MBox._locationManager.location?.coordinate)!
        }
        
        MBox._mapView.setCenter(position, zoomLevel: 7, direction: 0, animated: false)
        view.addSubview(MBox._mapView)
        self.gestConstraint()
        view.addSubview(subMapView)
        PutPinClass.putAPinOnTheMap(mapView: MBox._mapView, position: position, title: "Your Position", subtitle: "This is your position")
    }
    
    // Gestion des contraintes graphiques
    
    func gestConstraint() {
        self.textFieldAddressConstraintTop.constant = self.subMapView.bounds.height * 15 / 100
        self.textFieldAddressConstraintWidth.constant = self.subMapView.bounds.width * 70 / 100
    }
    
    // Activation de la possibilite de cliquer sur la pin pour afficher les informations
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    // Configuration de la localisation de l'utilisateur
    
    func configLocation(MBox:MBClass) {
        MBox._locationManager = CLLocationManager()
        MBox._locationManager.desiredAccuracy = kCLLocationAccuracyBest
        MBox._locationManager.delegate = self
        MBox._locationManager.requestWhenInUseAuthorization()
    }
    
    // Action à effectuer après la fin du chargement de la carte
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        let camera = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, fromDistance: 4500, pitch: 15, heading: 180)
        mapView.setCamera(camera, withDuration: 3, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

