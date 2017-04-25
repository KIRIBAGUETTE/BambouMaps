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
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var textFieldAddress: UITextField!
    @IBOutlet weak var textFieldAddressConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var textFieldAddressConstraintWidth: NSLayoutConstraint!
    @IBOutlet weak var tableAddressConstraintWidth: NSLayoutConstraint!
    @IBOutlet weak var tableAddressConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var tableAddress: UITableView!
    @IBOutlet weak var tableMenu: UITableView!
    
    var stockAddress:[Int:addressClass] = [:]
    
    let gestionMapsControllerClass:gestionMapsController = gestionMapsController()
    var gestionMapsViewClass:gestionMapsView = gestionMapsView()
    var gestionDatabaseClass:gestionDatabase = gestionDatabase()
    var sizeCell:CGFloat!
    var DidUserMovedMaps:Int = 1 // Permettre d'éviter qu'on voit la pin se déplacer lorsqu'un user cherche une adresse lointaine // 1 = PIN bouge / 0 = PIN ne bouge pas
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gestionDatabaseClass.getAddressFromDatabase()
        
        let TableViewCellAddress = UINib(nibName: "TableViewCellAddress", bundle: nil)
        self.tableAddress.register(TableViewCellAddress, forCellReuseIdentifier: "ADDRESS")
        self.tableMenu.register(TableViewCellAddress, forCellReuseIdentifier: "ADDRESS")
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
        self.gestionMapsViewClass.configMaps(mapView: mapView)
    }
    
    // Ouverture de l'historique des adresses
    
    @IBAction func openMenuAddress(_ sender: Any) {
        self.menuView.isHidden = false
    }
    
    // Fermeture de l'historique des adresses
    
    @IBAction func closeMenuAddress(_ sender: Any) {
        self.menuView.isHidden = true
    }
    
    // Recherche de l'adresse quand on arrête de déplacer la caméra à la main
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        self.getAddressFromMapBox(addressName: String(self.mapView.centerCoordinate.longitude) + "%2C" + String(self.mapView.centerCoordinate.latitude), types:"address", autocomplete:"false", limit:"1")
        if self.stockAddress.count > 0 {
            self.textFieldAddress.text = self.stockAddress[0]?._place_name
            self.gestionDatabaseClass.insertAddressInArchive(addressToArchive: self.stockAddress[0]!)
            self.tableMenu.reloadData()
            self.gestionMapsControllerClass.putAPinOnTheMap(mapView: self.mapView, position: self.mapView.centerCoordinate, title: self.textFieldAddress.text!, subtitle: "")
        }
        self.DidUserMovedMaps = 1
    }
    
    // Déplacement de la pin quand on déplace la caméra à la main
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        if self.DidUserMovedMaps == 1 {
            self.gestionMapsControllerClass.putAPinOnTheMap(mapView: self.mapView, position: self.mapView.centerCoordinate, title: self.textFieldAddress.text!, subtitle: "")
        }
    }
    
    // Déplacer la caméra lorsqu'on a choisit une adresse
    
    func moveCameraAndPutAPin(stockAddress:[Int:addressClass], id: Int) {
        let position:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (stockAddress[id]?._lattitude)!, longitude: (stockAddress[id]?._longitude)!)
        self.gestionMapsControllerClass.putAPinOnTheMap(mapView: self.mapView, position: position, title: (stockAddress[id]?._place_name)!, subtitle: "")
        let camera = MGLMapCamera(lookingAtCenter: position, fromDistance: 4500, pitch: 15, heading: 180)
        mapView.setCamera(camera, withDuration: 3, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        self.textFieldAddress.text = (stockAddress[id]?._place_name)!
        self.textFieldAddress.resignFirstResponder()
        self.gestionDatabaseClass.insertAddressInArchive(addressToArchive: stockAddress[id]!)
        self.tableMenu.reloadData()
    }
    
    // Gestion de la table qui affiche les adresses de l'autocomplete
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {

        if tableView.tag == 10 {
            self.DidUserMovedMaps = 0
            self.moveCameraAndPutAPin(stockAddress: self.stockAddress, id: indexPath.row)
            self.tableAddress.isHidden = true
            self.stockAddress.removeAll()
        } else {
            self.DidUserMovedMaps = 0
            self.menuView.isHidden = true
            self.moveCameraAndPutAPin(stockAddress: self.gestionDatabaseClass.archiveAddress, id: indexPath.row)
        }
    }
    
    // Nombre de lignes dans chaque section
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 10 {
            return self.stockAddress.count
        } else {
            return self.gestionDatabaseClass.archiveAddress.count
        }
    }
    
    // Nombre de sections dans les tables
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        if tableView.tag == 10 {
            return 1
        } else {
            return 1
        }
    }
    
    // Hauteur des cellules des tables
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView.tag == 10 {
            return CGFloat(self.sizeCell)
        } else {
            return self.mapView.bounds.height / 16
        }
    }
    
    // Personnalisation des cell des tables
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.tag == 10 {
            let cell:TableViewCellAddress = self.tableAddress.dequeueReusableCell(withIdentifier: "ADDRESS") as! TableViewCellAddress
            cell.textLabel?.text = self.stockAddress[indexPath.row]?._place_name
            return cell
        } else {
            let cell:TableViewCellAddress = self.tableMenu.dequeueReusableCell(withIdentifier: "ADDRESS") as! TableViewCellAddress
            cell.textLabel?.text = self.gestionDatabaseClass.archiveAddress[indexPath.row]?._place_name
            return cell

        }
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
                        self.gestionMapsControllerClass.putAPinOnTheMap(mapView: self.mapView, position: self.mapView.centerCoordinate, title: (self.stockAddress[0]?._place_name)!, subtitle: "")
                        self.textFieldAddress.text = self.stockAddress[0]?._place_name
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

