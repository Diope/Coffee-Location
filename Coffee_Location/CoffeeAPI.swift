//
//  CoffeeAPI.swift
//  Coffee_Location
//
//  Created by Dion Pettaway on 12/22/15.
//  Copyright © 2015 Dipet_Low. All rights reserved.
//

import QuadratTouch
import MapKit
import RealmSwift

struct API {
    struct notifications {
        static let venuesUpdated = "Venues Updated"
    }
}

class CoffeeAPI {
    static let sharedInstance = CoffeeAPI()
    var session: Session?
    
    init()
    {
        let client = Client(clientID: "...", clientSecret: "...", redirectURL: "")
        let configuration = Configuration(client: client)
        Session.setupSharedSessionWithConfiguration(configuration)
        
        self.session = Session.sharedSession()
    }
    
    func getCoffeeShopsWithLocation(location: CLLocation) {
        if let session = self.session {
            var parameters = location.parameters()
            parameters += [Parameter.categoryId: "4bf58dd8d48988d1e0931735"]
            parameters += [Parameter.radius: "2000"]
            parameters += [Parameter.limit: "50"]
            
            //Start a "search" async'ly
            let searchTask = session.venues.search(parameters) { (result) -> Void in
                
                if let response = result.response {
                    if let venues = response["venues"] as? [[String: AnyObject]] {
                        autoreleasepool {
                            let realm = try! Realm()
                            realm.beginWrite()
                            
                            for venue:[String:AnyObject] in venues
                            {
                                let venueObject: Venue = Venue()
                                
                                if let id = venue["id"] as? String
                                {
                                    venueObject.id = id
                                }
                                
                                if let name = venue["name"] as? String
                                {
                                    venueObject.name = name
                                }
                                
                                if let location = venue["location"] as? [String: AnyObject]
                                {
                                    if let longitude = location["lng"] as? Float
                                    {
                                        venueObject.longitude = longitude
                                    }
                                    
                                    if let latitude = location["lat"] as? Float
                                    {
                                        venueObject.latitude = latitude
                                    }
                                    
                                    if let formattedAddress = location["formattedAddress"] as? [String]
                                    {
                                        venueObject.address = formattedAddress.joinWithSeparator(" ")
                                    }
                                }
                                realm.add(venueObject, update:true)
                            }
                            
                            do {
                                try realm.commitWrite()
                                print("Committing write...")
                            }
                            catch (let e)
                            {
                                print("Ermah Gawd, the error is...\(e)")
                            }
                        }
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(API.notifications.venuesUpdated, object: nil, userInfo: nil)
                    }
                }
            }
            
            searchTask.start()
        }
    }
}

extension CLLocation {
    func parameters() -> Parameters
    {
        let ll = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc = "\(self.horizontalAccuracy)"
        let alt = "\(self.altitude)"
        let altAcc = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc
        ]
        return parameters
    }
}
