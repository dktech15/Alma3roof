//
//	VehicleListResponse.swift
//
//	Create by MacPro3 on 17/9/2018
//	Copyright © 2018. All rights reserved.


import Foundation

class VehicleListResponse: Model {

	var cityDetail : CityDetail!
	var citytypes : [Citytype]!
	var currency : String!
    var currencyCode : String!
	var message : String!
	var paymentGateway : [PaymentGateway]!
	var serverTime : String!
	var success : Bool!
    var isCorporateRequest : Bool = false
    var pooltypes : [Citytype] = []
    var is_allow_trip_bidding = false
    var is_user_can_set_bid_price = false
    var user_min_bidding_limit: Double = 0
    var driver_max_bidding_limit: Double = 0
 
	init(fromDictionary dictionary: [String:Any]) {
		if let cityDetailData = dictionary["city_detail"] as? [String:Any]{
			cityDetail = CityDetail(fromDictionary: cityDetailData)
		}
		citytypes = [Citytype]()
		if let citytypesArray = dictionary["citytypes"] as? [[String:Any]]{
			for dic in citytypesArray{
				let value = Citytype(fromDictionary: dic)
				citytypes.append(value)
			}
		}
        
        pooltypes = [Citytype]()
        if let value = dictionary["pooltypes"] as? [[String:Any]]{
            for dic in value {
                let value = Citytype(fromDictionary: dic)
                pooltypes.append(value)
            }
        }
        
		currency = (dictionary["currency"] as? String) ?? ""
        currencyCode = (dictionary["currencycode"] as? String) ?? ""
		message = (dictionary["message"] as? String) ?? ""
		paymentGateway = [PaymentGateway]()
		if let paymentGatewayArray = dictionary["payment_gateway"] as? [[String:Any]]{
			for dic in paymentGatewayArray{
				let value = PaymentGateway(fromDictionary: dic)
				paymentGateway.append(value)
			}
		}
		serverTime = (dictionary["server_time"] as? String) ?? ""
		success = (dictionary["success"] as? Bool) ?? false
        isCorporateRequest = (dictionary["is_corporate_request"] as? Bool) ?? false
        is_allow_trip_bidding = (dictionary["is_allow_trip_bidding"] as? Bool) ?? false
        is_user_can_set_bid_price = (dictionary["is_user_can_set_bid_price"] as? Bool) ?? false
        user_min_bidding_limit = (dictionary["user_min_bidding_limit"] as? Double) ?? 0
        driver_max_bidding_limit = (dictionary["driver_max_bidding_limit"] as? Double) ?? 0
    }

}

class PoolTypes {
    public var _id : String?
    public var countryid : String?
    public var is_hide : Int?
    public var surge_multiplier : Int?
    public var surge_start_hour : Int?
    public var surge_end_hour : Int?
    public var is_surge_hours : Int?
    public var is_zone : Int?
    public var rich_area_surge: [Rich_Area_Surge] = []
    public var surge_hours : [Surge_hours] = []
    public var is_business : Int?
    public var countryname : String?
    public var cityid : String?
    public var cityname : String?
    public var typeid : String?
    public var type_image : String?
    public var min_fare : Int?
    public var provider_profit : Int?
    public var typename : String?
    public var is_car_rental_business : Int?
    public var car_rental_ids : [String] = []
    public var base_price_distance : Int?
    public var base_price_time : Int?
    public var base_price : Int?
    public var price_per_unit_distance : Int?
    public var price_for_total_time : Int?
    public var waiting_time_start_after_minute : Int?
    public var price_for_waiting_time : Int?
    public var waiting_time_start_after_minute_multiple_stops : Int?
    public var price_for_waiting_time_multiple_stops : Int?
    public var tax : Int?
    public var max_space : Int?
    public var cancellation_fee : Int?
    public var user_miscellaneous_fee : Int?
    public var provider_miscellaneous_fee : Int?
    public var user_tax : Int?
    public var provider_tax : Int?
    public var zone_ids : [String] = []
    public var created_at : String?
    public var updated_at : String?
    public var __v : Int?
    public var type_details : Type_details?

    required public init?(dictionary: NSDictionary) {

        _id = dictionary["_id"] as? String
        countryid = dictionary["countryid"] as? String
        is_hide = dictionary["is_hide"] as? Int
        surge_multiplier = dictionary["surge_multiplier"] as? Int
        surge_start_hour = dictionary["surge_start_hour"] as? Int
        surge_end_hour = dictionary["surge_end_hour"] as? Int
        is_surge_hours = dictionary["is_surge_hours"] as? Int
        is_zone = dictionary["is_zone"] as? Int
        
        if let value = dictionary["rich_area_surge"] as? [[String:Any]] {
            rich_area_surge.removeAll()
            for obj in value {
                rich_area_surge.append(Rich_Area_Surge(dictionary: obj))
            }
        }
        
        if let value = dictionary["surge_hours"] as? [[String:Any]] {
            surge_hours.removeAll()
            for obj in value {
                surge_hours.append(Surge_hours(dictionary: obj))
            }
        }

        is_business = dictionary["is_business"] as? Int
        countryname = dictionary["countryname"] as? String
        cityid = dictionary["cityid"] as? String
        cityname = dictionary["cityname"] as? String
        typeid = dictionary["typeid"] as? String
        type_image = dictionary["type_image"] as? String
        min_fare = dictionary["min_fare"] as? Int
        provider_profit = dictionary["provider_profit"] as? Int
        typename = dictionary["typename"] as? String
        is_car_rental_business = dictionary["is_car_rental_business"] as? Int
        
        if let value = dictionary["car_rental_ids"] as? [String] {
            car_rental_ids.removeAll()
            for obj in value {
                car_rental_ids.append(obj)
            }
        }
        
        base_price_distance = dictionary["base_price_distance"] as? Int
        base_price_time = dictionary["base_price_time"] as? Int
        base_price = dictionary["base_price"] as? Int
        price_per_unit_distance = dictionary["price_per_unit_distance"] as? Int
        price_for_total_time = dictionary["price_for_total_time"] as? Int
        waiting_time_start_after_minute = dictionary["waiting_time_start_after_minute"] as? Int
        price_for_waiting_time = dictionary["price_for_waiting_time"] as? Int
        waiting_time_start_after_minute_multiple_stops = dictionary["waiting_time_start_after_minute_multiple_stops"] as? Int
        price_for_waiting_time_multiple_stops = dictionary["price_for_waiting_time_multiple_stops"] as? Int
        tax = dictionary["tax"] as? Int
        max_space = dictionary["max_space"] as? Int
        cancellation_fee = dictionary["cancellation_fee"] as? Int
        user_miscellaneous_fee = dictionary["user_miscellaneous_fee"] as? Int
        provider_miscellaneous_fee = dictionary["provider_miscellaneous_fee"] as? Int
        user_tax = dictionary["user_tax"] as? Int
        provider_tax = dictionary["provider_tax"] as? Int
        
        if let value = dictionary["zone_ids"] as? [String] {
            zone_ids.removeAll()
            for obj in value {
                zone_ids.append(obj)
            }
        }
        
        created_at = dictionary["created_at"] as? String
        updated_at = dictionary["updated_at"] as? String
        __v = dictionary["__v"] as? Int
        
        type_details = Type_details(dictionary: dictionary["type_details"] as? NSDictionary ?? [:])
    }
    
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self._id, forKey: "_id")
        dictionary.setValue(self.countryid, forKey: "countryid")
        dictionary.setValue(self.is_hide, forKey: "is_hide")
        dictionary.setValue(self.surge_multiplier, forKey: "surge_multiplier")
        dictionary.setValue(self.surge_start_hour, forKey: "surge_start_hour")
        dictionary.setValue(self.surge_end_hour, forKey: "surge_end_hour")
        dictionary.setValue(self.is_surge_hours, forKey: "is_surge_hours")
        dictionary.setValue(self.is_zone, forKey: "is_zone")
        dictionary.setValue(self.is_business, forKey: "is_business")
        dictionary.setValue(self.countryname, forKey: "countryname")
        dictionary.setValue(self.cityid, forKey: "cityid")
        dictionary.setValue(self.cityname, forKey: "cityname")
        dictionary.setValue(self.typeid, forKey: "typeid")
        dictionary.setValue(self.type_image, forKey: "type_image")
        dictionary.setValue(self.min_fare, forKey: "min_fare")
        dictionary.setValue(self.provider_profit, forKey: "provider_profit")
        dictionary.setValue(self.typename, forKey: "typename")
        dictionary.setValue(self.is_car_rental_business, forKey: "is_car_rental_business")
        dictionary.setValue(self.base_price_distance, forKey: "base_price_distance")
        dictionary.setValue(self.base_price_time, forKey: "base_price_time")
        dictionary.setValue(self.base_price, forKey: "base_price")
        dictionary.setValue(self.price_per_unit_distance, forKey: "price_per_unit_distance")
        dictionary.setValue(self.price_for_total_time, forKey: "price_for_total_time")
        dictionary.setValue(self.waiting_time_start_after_minute, forKey: "waiting_time_start_after_minute")
        dictionary.setValue(self.price_for_waiting_time, forKey: "price_for_waiting_time")
        dictionary.setValue(self.waiting_time_start_after_minute_multiple_stops, forKey: "waiting_time_start_after_minute_multiple_stops")
        dictionary.setValue(self.price_for_waiting_time_multiple_stops, forKey: "price_for_waiting_time_multiple_stops")
        dictionary.setValue(self.tax, forKey: "tax")
        dictionary.setValue(self.max_space, forKey: "max_space")
        dictionary.setValue(self.cancellation_fee, forKey: "cancellation_fee")
        dictionary.setValue(self.user_miscellaneous_fee, forKey: "user_miscellaneous_fee")
        dictionary.setValue(self.provider_miscellaneous_fee, forKey: "provider_miscellaneous_fee")
        dictionary.setValue(self.user_tax, forKey: "user_tax")
        dictionary.setValue(self.provider_tax, forKey: "provider_tax")
        dictionary.setValue(self.created_at, forKey: "created_at")
        dictionary.setValue(self.updated_at, forKey: "updated_at")
        dictionary.setValue(self.__v, forKey: "__v")
        dictionary.setValue(self.type_details?.dictionaryRepresentation(), forKey: "type_details")

        return dictionary
    }

}

class Rich_Area_Surge {
    public var _id : String = ""
    public var surge_multiplier : Int = 0
    
    public init(dictionary: [String:Any]) {
        _id = dictionary["_id"] as? String ?? ""
        surge_multiplier = dictionary["surge_multiplier"] as? Int ?? 0
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self._id, forKey: "_id")
        dictionary.setValue(self.surge_multiplier, forKey: "surge_multiplier")
        return dictionary
    }
}

class Surge_hours {
    public var day : String = "0"
    public var day_time : [DayTime] = []
    public var is_surge : Bool = false

    required public init(dictionary: [String:Any]) {
        day = dictionary["day"] as? String ?? "0"
        if let value = dictionary["day_time"] as? [[String:Any]] {
            day_time.removeAll()
            for obj in value {
                day_time.append(DayTime(fromDictionary: obj))
            }
        }
        is_surge = dictionary["is_surge"] as? Bool ?? false
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.day, forKey: "day")
        dictionary.setValue(self.is_surge, forKey: "is_surge")
        
        var arrDayTime = [[String:Any]]()
        for obj in day_time {
            arrDayTime.append(obj.toDictionary())
        }
        dictionary.setValue(arrDayTime, forKey: "day_time")
 
        return dictionary
    }
}

class Type_details {
    public var _id : String?
    public var typename : String?
    public var description : String?
    public var type_image_url : String?
    public var map_pin_image_url : String?
    public var service_type : Int?
    public var priority : Int?
    public var is_business : Int?
    public var is_default_selected : Bool?
    public var is_ride_share : Int?
    public var ride_share_limit : Int?
    public var created_at : String?
    public var updated_at : String?
    public var __v : Int?

    required public init(dictionary: NSDictionary) {
        _id = dictionary["_id"] as? String ?? ""
        typename = dictionary["typename"] as? String ?? ""
        description = dictionary["description"] as? String  ?? ""
        type_image_url = dictionary["type_image_url"] as? String ?? ""
        map_pin_image_url = dictionary["map_pin_image_url"] as? String ?? ""
        service_type = dictionary["service_type"] as? Int ?? 0
        priority = dictionary["priority"] as? Int ?? 0
        is_business = dictionary["is_business"] as? Int ?? 0
        is_default_selected = dictionary["is_default_selected"] as? Bool ?? false
        is_ride_share = dictionary["is_ride_share"] as? Int ?? 0
        ride_share_limit = dictionary["ride_share_limit"] as? Int ?? 0
        created_at = dictionary["created_at"] as? String
        updated_at = dictionary["updated_at"] as? String
        __v = dictionary["__v"] as? Int ?? 0
    }

    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self._id, forKey: "_id")
        dictionary.setValue(self.typename, forKey: "typename")
        dictionary.setValue(self.description, forKey: "description")
        dictionary.setValue(self.type_image_url, forKey: "type_image_url")
        dictionary.setValue(self.map_pin_image_url, forKey: "map_pin_image_url")
        dictionary.setValue(self.service_type, forKey: "service_type")
        dictionary.setValue(self.priority, forKey: "priority")
        dictionary.setValue(self.is_business, forKey: "is_business")
        dictionary.setValue(self.is_default_selected, forKey: "is_default_selected")
        dictionary.setValue(self.is_ride_share, forKey: "is_ride_share")
        dictionary.setValue(self.ride_share_limit, forKey: "ride_share_limit")
        dictionary.setValue(self.created_at, forKey: "created_at")
        dictionary.setValue(self.updated_at, forKey: "updated_at")
        dictionary.setValue(self.__v, forKey: "__v")
        return dictionary
    }
}
