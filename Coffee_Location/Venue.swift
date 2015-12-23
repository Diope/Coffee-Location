//
//  Venue.swift
//  Coffee_Location
//
//  Created by Dion Pettaway on 12/22/15.
//  Copyright © 2015 Dipet_Low. All rights reserved.
//

import RealmSwift
import MapKit

class Venue: Object {
    dynamic var id: String = ""
    dynamic var name: String = ""
    
    dynamic var latitude: Float = 0
    dynamic var longitude: Float = 0
    
    dynamic var address: String = ""
    
    var coordinate: CLLocation {
        return CLLocation(latitude: Double(latitude), longitude: Double(longitude))
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
