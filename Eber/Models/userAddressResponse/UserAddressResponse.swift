//
//	RootClass.swift
//
//	Create by MacPro3 on 17/9/2018
//	Copyright © 2018. All rights reserved.


import Foundation

class UserAddressResponse: Model {

	var success : Bool!
	var userAddress : UserAddress!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		success = dictionary["success"] as? Bool
		if let userAddressData = dictionary["user_address"] as? [String:Any]{
			userAddress = UserAddress(fromDictionary: userAddressData)
		}
	}

}

class RecentAddressesResponse: Model {

    var success: Bool!
    var recentAddresses: [RecentAddress]!

    init(fromDictionary dictionary: [String: Any]) {
        success = dictionary["success"] as? Bool
        recentAddresses = [RecentAddress]()
        if let recentAddressesArray = dictionary["recent_addresses"] as? [[String: Any]] {
            for item in recentAddressesArray {
                let recentAddress = RecentAddress(fromDictionary: item)
                recentAddresses.append(recentAddress)
            }
        }
    }
}

class RecentAddress: Model {

    var address: String!
    var location: [Double]!

    init(fromDictionary dictionary: [String: Any]) {
        address = dictionary["address"] as? String
        location = dictionary["location"] as? [Double]
    }
}
