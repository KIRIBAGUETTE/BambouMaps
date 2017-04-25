//
//  ViewController.swift
//  BambouMaps
//
//  Created by KIRIBAGUETTE on 21/04/2017.
//  Copyright © 2017 KIRIBAGUETTE. All rights reserved.
//

import UIKit
import CoreData
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
    var sizeCell:CGFloat!
    
    let PutPinClass:PutPin = PutPin()
    
    var DidUserMovedMaps:Int = 1 // Permettre d'éviter qu'on voit la pin se déplacer lorsqu'un user cherche une adresse lointaine // 1 = PIN bouge / 0 = PIN ne bouge pas
    
    @IBOutlet weak var tableAddress: UITableView!
    var stockAddress:[Int:addressClass] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAddressFromDatabase()
        
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
    
    // Recuperer toutes les adresses dans la base de données
    
    func getAddressFromDatabase() {
        print("Get Addresses")
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Address")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    let newAddress:addressClass = addressClass()
                    if let id = result.value(forKey: "id") as? String {
                        newAddress._id = id
                    }
                    if let longitude = result.value(forKey: "longitude") as? Double {
                        newAddress._longitude = longitude
                    }
                    if let lattitude = result.value(forKey: "lattitude") as? Double {
                        newAddress._lattitude = lattitude
                    }
                    if let place_name = result.value(forKey: "place_name") as? String {
                        newAddress._place_name = place_name
                        print(place_name)
                    }
                }
            }
        } catch {
            print("Error during acces to the database")
        }
    }
    
    // Verifier a chaque entree si on a 15 entrées si oui on supprime la première
    
    func checkNumberOfAddressesInBdd() {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Address")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            var i:Int = 0
            if results.count >= 15 {
                print("Delete Oldest Entry")
                for result in results as! [NSManagedObject] {
                    if i == 0 {
                        context.delete(result)
                        i = 1
                    }
                }
            }
        } catch {
            print("ERROR")
        }
        do {
            try context.save()
        } catch {
            print("Error")
        }
    }
    
    // Sauvegarder dans la BDD l'adresse que l'on a pointé
    
    func insertAddressInArchive(addressToArchive:addressClass) {
        self.checkNumberOfAddressesInBdd()
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newAddress = NSEntityDescription.insertNewObject(forEntityName: "Address", into: context)
        newAddress.setValue(addressToArchive._id, forKey: "id")
        newAddress.setValue(addressToArchive._lattitude, forKey: "lattitude")
        newAddress.setValue(addressToArchive._longitude, forKey: "longitude")
        newAddress.setValue(addressToArchive._place_name, forKey: "place_name")
        
        do {
            try context.save()
            print("Saving Address")
        } catch {
            print("Error during saving")
        }
        
    }
    
    // Recherche de l'adresse quand on arrête de déplacer la caméra à la main
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        
        self.getAddressFromMapBox(addressName: String(self.mapView.centerCoordinate.longitude) + "%2C" + String(self.mapView.centerCoordinate.latitude), types:"address", autocomplete:"false", limit:"1")
        if self.stockAddress.count > 0 {
            self.textFieldAddress.text = self.stockAddress[0]?._place_name
            self.insertAddressInArchive(addressToArchive: self.stockAddress[0]!)
        }
        self.DidUserMovedMaps = 1
    }
    
    // Déplacement de la pin quand on déplace la caméra à la main
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        if self.DidUserMovedMaps == 1 {
            self.PutPinClass.putAPinOnTheMap(mapView: self.mapView, position: self.mapView.centerCoordinate, title: "", subtitle: "")
        }
    }
    
    // Gestion de la table qui affiche les adresses de l'autocomplete
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {

        self.DidUserMovedMaps = 0
        let position:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (self.stockAddress[indexPath.row]?.lattitude)!, longitude: (self.stockAddress[indexPath.row]?.longitude)!)
        self.PutPinClass.putAPinOnTheMap(mapView: self.mapView, position: position, title: (self.stockAddress[indexPath.row]?._place_name)!, subtitle: "")
        let camera = MGLMapCamera(lookingAtCenter: position, fromDistance: 4500, pitch: 15, heading: 180)
        mapView.setCamera(camera, withDuration: 3, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        self.textFieldAddress.text = (self.stockAddress[indexPath.row]?._place_name)!
        self.textFieldAddress.resignFirstResponder()
        self.stockAddress.removeAll()
        self.tableAddress.isHidden = true
        self.insertAddressInArchive(addressToArchive: self.stockAddress[indexPath.row]!)
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
    
    func getAddressFromMapBox(addressName:String,
                              types:String,
                              autocomplete:String,
                              limit:String) {
        
        let DeserialisationMapBoxClass:DeserialisationMapBox = DeserialisationMapBox()
        
        let request:String = MAPBOXAPI.MAPBOX_AUTOCOMPLETE.rawValue + addressName.replacingOccurrences(of: " ", with: "%20") + ".json?access_token=" + MAPBOXAPI.KEYDEV.rawValue + "&types=" + types + "&autocomplete=" + autocomplete + "&limit=" + limit
        Alamofire.request(request, method: .get).responseJSON { response in
            if response.result.isSuccess {
                if response.response?.statusCode == 200 {
                    self.stockAddress = DeserialisationMapBoxClass.DeserialisationMapBoxAutocomplete(Json: JSON(response.result.value!))
                    if self.stockAddress.count > 0 && autocomplete == "true"{
                        self.tableAddress.reloadData()
                        self.gestConstraint()
                        self.tableAddress.isHidden = false
                    } else {
                        self.tableAddress.isHidden = true
                    }
                } else {
                    print("ERROR RETOUR MAPBOX : " + String(describing: response.response?.statusCode))
                }
            } else {
                print("ERROR MAPBOX")
            }
        }
    }
    
    // Recherche de l'adresse quand un user écrit dans la textfield
    
    func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.characters.count)! > 4 {
            self.getAddressFromMapBox(addressName: textFieldAddress.text!, types:"address", autocomplete:"true", limit:"5")
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
        self.textFieldAddressConstraintWidth.constant = self.mapView.bounds.width * 80 / 100
        self.tableAddressConstraintWidth.constant = self.mapView.bounds.width * 80 / 100
        self.sizeCell = self.mapView.bounds.height * 7 / 100
        self.tableAddressConstraintHeight.constant = self.sizeCell * CGFloat(self.stockAddress.count)
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

    // Fermeture du clavier quand on clique sur done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

