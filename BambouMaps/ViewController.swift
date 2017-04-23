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
import SwiftyJSON

class ViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet var mapView: MGLMapView!
    @IBOutlet weak var textFieldAddress: UITextField!
    @IBOutlet weak var textFieldAddressConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var textFieldAddressConstraintWidth: NSLayoutConstraint!
    @IBOutlet weak var tableAddressConstraintWidth: NSLayoutConstraint!
    @IBOutlet weak var tableAddressConstraintHeight: NSLayoutConstraint!
    
    let PutPinClass:PutPin = PutPin()
    
    var sizeCell:Int = 50
    
    @IBOutlet weak var tableAddress: UITableView!
    var stockAddress:[Int:addressClass] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let TableViewCellAddress = UINib(nibName: "TableViewCellAddress", bundle: nil)
        self.tableAddress.register(TableViewCellAddress, forCellReuseIdentifier: "ADDRESS")
    
        let MBox:MBClass = MBClass()
        
        self.textFieldAddress.delegate = self
        self.textFieldAddress.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.configLocation(MBox:MBox)
        
        var position:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 48.8414, longitude: 2.2530)
        if MBox._locationManager.location != nil {
            position = (MBox._locationManager.location?.coordinate)!
        }
        
        self.mapView.setCenter(position, zoomLevel: 12, direction: 0, animated: false)
        self.gestConstraint()
        self.PutPinClass.putAPinOnTheMap(mapView: self.mapView, position: position, title: "Your Position", subtitle: "This is your position")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {

        let position:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (self.stockAddress[indexPath.row]?.lattitude)!, longitude: (self.stockAddress[indexPath.row]?.longitude)!)
        self.PutPinClass.putAPinOnTheMap(mapView: self.mapView, position: position, title: (self.stockAddress[indexPath.row]?._place_name)!, subtitle: "")
        let camera = MGLMapCamera(lookingAtCenter: position, fromDistance: 4500, pitch: 15, heading: 180)
        mapView.setCamera(camera, withDuration: 3, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        self.textFieldAddress.text = (self.stockAddress[indexPath.row]?._place_name)!
        self.textFieldAddress.resignFirstResponder()
        self.stockAddress.removeAll()
        self.tableAddress.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stockAddress.count
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(self.sizeCell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:TableViewCellAddress = self.tableAddress.dequeueReusableCell(withIdentifier: "ADDRESS") as! TableViewCellAddress
        cell.textLabel?.text = self.stockAddress[indexPath.row]?._place_name
        return cell
    }
    
    // Appel à l'API de Mapbox si on a au moins X caractères dans le textfield
    
    func textFieldDidChange(_ textField: UITextField) {
        let DeserialisationMapBoxClass:DeserialisationMapBox = DeserialisationMapBox()
        
        if (textField.text?.characters.count)! > 4 {
            self.tableAddress.isHidden = false
            let request:String = MAPBOXAPI.MAPBOX_AUTOCOMPLETE.rawValue + textField.text!.replacingOccurrences(of: " ", with: "%20") + ".json?access_token=" + MAPBOXAPI.KEYDEV.rawValue + "&types=address&autocomplete=true"
            Alamofire.request(request, method: .get).responseJSON { response in
                if response.result.isSuccess {
                    if response.response?.statusCode == 200 {
                        self.stockAddress = DeserialisationMapBoxClass.DeserialisationMapBoxAutocomplete(Json: JSON(response.result.value!))
                        self.tableAddress.reloadData()
                        self.gestConstraint()
                    } else {
                        print("ERROR RETOUR MAPBOX : " + String(describing: response.response?.statusCode))
                    }
                } else {
                    print("ERROR MAPBOX")
                }
            }
        } else {
            self.tableAddress.isHidden = true
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
        self.tableAddressConstraintWidth.constant = self.mapView.bounds.width * 70 / 100
        self.tableAddressConstraintHeight.constant = CGFloat(self.sizeCell * self.stockAddress.count)
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

