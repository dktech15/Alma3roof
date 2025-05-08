//
//	FareEstimateResponse.swift
//
//	Create by MacPro3 on 20/9/2018
//	Copyright © 2018. All rights reserved.


import Foundation

class FareEstimateResponse: Model {

	var basePrice : Double!
	var distance : Double!
	var estimatedFare : Double!
	var isMinFareUsed : Int!
	var message : String!
	var pricePerUnitDistance : String!
	var pricePerUnitTime : Double!
	var success : Bool!
	var time : Double!
	var tripType : String!
	var userMiscellaneousFee : Double!
	var userTaxFee : Int!
    var is_use_distance_slot_calculation : Bool!
    var selected_slot:SelectedSlot = SelectedSlot.init(fromDictionary: [:])
	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		basePrice = (dictionary["base_price"] as? Double) ?? 0.0
        if dictionary["distance"] is Double {
            distance = (dictionary["distance"] as? Double) ?? 0.0
        } else if dictionary["distance"] is String {
            distance = Double(dictionary["distance"] as? String ?? "0.00") ?? 0.0
        } else {}
		estimatedFare = (dictionary["estimated_fare"] as? Double) ?? 0.0
		isMinFareUsed = (dictionary["is_min_fare_used"] as?  Int) ?? 0
		message = (dictionary["message"] as? String) ?? ""
		pricePerUnitDistance = (dictionary["price_per_unit_distance"] as? String) ?? ""
		pricePerUnitTime = (dictionary["price_per_unit_time"] as? Double) ?? 0.0
		success = (dictionary["success"] as? Bool) ?? false
        is_use_distance_slot_calculation = (dictionary["is_use_distance_slot_calculation"] as? Bool) ?? false
		time = (dictionary["time"] as? Double) ?? 0.0
		tripType = (dictionary["trip_type"] as? String) ?? ""
		userMiscellaneousFee = (dictionary["user_miscellaneous_fee"] as? Double) ?? 0.0
		userTaxFee = (dictionary["user_tax_fee"] as? Int) ?? 0
        if let selected_slott = dictionary["selected_slot"] as? [String:Any]{
            selected_slot = SelectedSlot(fromDictionary: selected_slott)
        }
	}

}

class SelectedSlot: Model {
    
    var base_price : Double!
    var to : Double!
    var from : Double!
    var isEdit : Bool!
   
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        base_price = (dictionary["base_price"] as? Double) ?? 0.0
        
        if dictionary["to"] is Double {
            to = (dictionary["to"] as? Double) ?? 0.0
        } else if dictionary["to"] is String {
            to = Double(dictionary["to"] as? String ?? "0.00") ?? 0.0
        }
        
        if dictionary["from"] is Double {
            from = (dictionary["from"] as? Double) ?? 0.0
        } else if dictionary["from"] is String {
            from = Double(dictionary["from"] as? String ?? "0.00") ?? 0.0
        }
        isEdit = (dictionary["isEdit"] as? Bool) ?? false
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        
        if base_price != nil{
            dictionary["base_price"] = base_price
        }
        if to != nil{
            dictionary["to"] = to
        }
        
        if from != nil{
            dictionary["from"] = from
        }
        
        if isEdit != nil{
            dictionary["isEdit"] = isEdit
        }
        return dictionary
    }
}
