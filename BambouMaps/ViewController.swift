//
//  ViewController.swift
//  BambouMaps
//
//  Created by KIRIBAGUETTE on 21/04/2017.
//  Copyright © 2017 KIRIBAGUETTE. All rights reserved.
//

import UIKit
import Mapbox
import Alamofire

class ViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet var mapView: MGLMapView!
    @IBOutlet weak var textFieldAddress: UITextField!
    @IBOutlet weak var textFieldAddressConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var textFieldAddressConstraintWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let MBox:MBClass = MBClass()
        let PutPinClass:PutPin = PutPin()
        
        self.textFieldAddress.delegate = self
        self.textFieldAddress.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.configLocation(MBox:MBox)
        
        var position:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 48.8414, longitude: 2.2530)
        if MBox._locationManager.location != nil {
            position = (MBox._locationManager.location?.coordinate)!
        }
        
        self.mapView.setCenter(position, zoomLevel: 12, direction: 0, animated: false)
        self.gestConstraint()
        PutPinClass.putAPinOnTheMap(mapView: self.mapView, position: position, title: "Your Position", subtitle: "This is your position")
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.characters.count)! > 4 {
            let request:String = MAPBOXAPI.MAPBOX_AUTOCOMPLETE.rawValue + textField.text!.replacingOccurrences(of: " ", with: "%20") + ".json?access_token=" + MAPBOXAPI.KEYDEV.rawValue
            Alamofire.request(request, method: .get).responseJSON { response in
                if response.result.isSuccess {
                    print(response.response?.statusCode)
                    print(response.result.value)
                } else {
                    print("ERROR")
                }
            }
        }
    }
    
    // Configuration de la map
    
    func gestMaps() {
        self.mapView.styleURL = MGLStyle.outdoorsStyleURL(withVersion: 9)
        self.mapView.showsUserLocation = true
        
    }
    
    // Gestion des contraintes graphiques
    
    func gestConstraint() {
        self.textFieldAddressConstraintTop.constant = self.mapView.bounds.height * 15 / 100
        self.textFieldAddressConstraintWidth.constant = self.mapView.bounds.width * 70 / 100
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
    
    // Action à effectuer après la fin du chargement de la vue
    
    override func viewDidAppear(_ animated: Bool) {
        let camera = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, fromDistance: 4500, pitch: 15, heading: 180)
        mapView.setCamera(camera, withDuration: 3, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Fermeture du clavier quand on clique sur done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

