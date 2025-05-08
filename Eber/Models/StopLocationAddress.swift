//
//  StopLocationAddress.swift
//  Eber
//
//  Created by Maulik Desai on 14/07/22.
//  Copyright © 2022 Elluminati. All rights reserved.
//

import Foundation

class StopLocationAddress : NSObject{

    var address: String!
    var latitude: Double!
    var longitude: Double!
    

    public required override init() {
    }
    
    init(fromDictionary dictionary: [String:Any]){
        
        address = dictionary["address"] as? String ?? ""
        latitude = dictionary["latitude"] as? Double ?? 0.0
        longitude = dictionary["longitude"] as? Double ?? 0.0
    }
    
    init(addres: String, lat: Double, long: Double) {
        address = addres
        latitude = lat
        longitude = long
    }
}
