//
//  PromocodeModel.swift
//  Eber
//
//  Created by Rohit on 04/08/23.
//  Copyright © 2023 Elluminati. All rights reserved.
//

import Foundation

struct PromoCode{
    var code_value : Int?
    var state : Int?
    var start_date : String?
    var description : String?
    var completed_trips_type : Int?
    var created_at : String?
    var _id : String?
    var user_used_promo : Int?
    var countryid : String?
    var code_expiry : String?
    var completed_trips_value : Int?
    var cityid : [String]?
    var code_type : Int?
    var promocode : String?
    var updated_at : String?
    var code_uses : Int?
    var __v : Int?
}

extension PromoCode : JSONParsable{
    init?(json: JSONType?) {
        self.code_value = json?["code_value"] as? Int ?? 0
        self.state = json?["state"] as? Int ?? 0
        self.start_date = json?["start_date"] as? String ?? ""
        self.description = json?["description"] as? String ?? ""
        self.completed_trips_type = json?["completed_trips_type"] as? Int ?? 0
        self.created_at = json?["created_at"] as? String ?? ""
        self._id = json?["_id"] as? String ?? ""
        self.user_used_promo = json?["user_used_promo"] as? Int ?? 0
        self.countryid = json?["countryid"] as? String ?? ""
        self.code_expiry = json?["code_expiry"] as? String ?? ""
        self.completed_trips_value = json?["completed_trips_value"] as? Int ?? 0
        self.cityid = json?["cityid"] as? [String]
        self.code_type = json?["code_type"] as? Int ?? 0
        self.promocode = json?["promocode"] as? String ?? ""
        self.updated_at = json?["updated_at"] as? String ?? ""
        self.code_uses = json?["code_uses"] as? Int ?? 0
        self.__v = json?["__v"] as? Int ?? 0
    }
}
