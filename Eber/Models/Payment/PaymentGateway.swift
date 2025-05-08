//
//	PaymentGateway.swift
//
//	Create by MacPro3 on 14/9/2018
//	Copyright © 2018. All rights reserved.


import Foundation

class PaymentGateway: Model {

	var id : Int!
	var name : String!
    var is_add_card : Bool!
    var type = PaymentMode.UNKNOWN

	init(fromDictionary dictionary: [String:Any]){
		id = (dictionary["id"] as? Int) ?? 0
        name = (dictionary["name"] as? String) ?? ""
        is_add_card = (dictionary["is_add_card"] as? Bool) ?? false
	}
    
    init(name: String, type: Int) {
        self.id = 0
        self.name = name
        self.type = type
        self.is_add_card = false
    }
    
}

