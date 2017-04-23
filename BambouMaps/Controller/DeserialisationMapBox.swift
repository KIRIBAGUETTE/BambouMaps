//
//  DeserialisationMapBox.swift
//  BambouMaps
//
//  Created by KIRIBAGUETTE on 23/04/2017.
//  Copyright © 2017 KIRIBAGUETTE. All rights reserved.
//

import Foundation
import SwiftyJSON

class DeserialisationMapBox {
    func DeserialisationMapBoxAutocomplete(Json:JSON) -> [Int:addressClass] {
        
        var stockAddress:[Int:addressClass] = [:]
        
        if let addresses = Json["features"].array {
            for address in addresses {
                let addressUnit:addressClass = addressClass()
                if let id = address["id"].string {
                    addressUnit._id = id
                }
                if let place_name = address["place_name"].string {
                    addressUnit._place_name = place_name
                }
                if let lattitude = address["geometry"]["coordinates"][0].float {
                    addressUnit._lattitude = lattitude
                }
                if let longitude = address["geometry"]["coordinates"][1].float {
                    addressUnit._longitude = longitude
                }
                stockAddress[stockAddress.count] = addressUnit
            }
        }
        return stockAddress
    }
}
