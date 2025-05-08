//
//  CountryModel.swift
//  Eber
//
//  Created by Rohit on 28/08/23.
//  Copyright © 2023 Elluminati. All rights reserved.
//

import Foundation

struct Countres{
    var _id : String?
    var alpha2 : String?
    var countryname : String?
    var countryphonecode : String?
    var currencycode : String?
    var phone_number_length : String?
    var phone_number_min_length : String?
    var city_list = [Cites]()
}
extension Countres : JSONParsable{
    init?(json: JSONType?) {
        self._id  = json?["_id"] as? String ?? ""
        self.alpha2  = json?["alpha2"] as? String ?? ""
        self.countryname  = json?["countryname"] as? String ?? ""
        self.countryphonecode  = json?["countryphonecode"] as? String ?? ""
        self.currencycode  = json?["currencycode"] as? String ?? ""
        self.phone_number_length  = json?["phone_number_length"] as? String ?? ""
        self.phone_number_min_length  = json?["phone_number_min_length"] as? String ?? ""
        if let data = json?["city_list"] as? [JSONType]{
            self.city_list.append(contentsOf: data.compactMap(Cites.init))
        }
    }
 }

struct Cites{
    var _id : String?
    var cityLatLong : [Double]?
    var cityname : String?
    var full_cityname : String?
}
extension Cites : JSONParsable{
    init?(json: JSONType?) {
        self._id  = json?["_id"] as? String ?? ""
        self.cityLatLong  = json?["cityLatLong"] as? [Double]
        self.cityname  = json?["cityname"] as? String ?? ""
        self.full_cityname  = json?["full_cityname"] as? String ?? ""
    }
}

