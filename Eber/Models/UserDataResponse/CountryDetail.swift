//
//	CountryDetail.swift
//
//	Create by MacPro3 on 10/9/2018
//	Copyright © 2018. All rights reserved.


import Foundation


class CountryDetail: ModelNSObj {

	var isReferral : Bool!
    var payment_gateway_type : Int!

    /**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any])
    {
		isReferral = (dictionary["is_referral"] as? Bool) ?? false
        payment_gateway_type = (dictionary["payment_gateway_type"] as? Int) ?? 0
        
        print("  payment_gateway_type  \(payment_gateway_type)")

	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if isReferral != nil{
			dictionary["is_referral"] = isReferral
		}

        if payment_gateway_type != nil{
            dictionary["payment_gateway_type"] = payment_gateway_type
        }
		return dictionary
	}
}
