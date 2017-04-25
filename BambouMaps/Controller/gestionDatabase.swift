//
//  gestionDatabase.swift
//  BambouMaps
//
//  Created by KIRIBAGUETTE on 25/04/2017.
//  Copyright © 2017 KIRIBAGUETTE. All rights reserved.
//

import UIKit
import CoreData

class gestionDatabase {
 
    var archiveAddress:[Int:addressClass] = [:]
    
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
                self.archiveAddress.removeAll()
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
                    }
                    self.archiveAddress[archiveAddress.count] = newAddress
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
        self.getAddressFromDatabase()
        
    }
}
