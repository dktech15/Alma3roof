//
//	DayTime.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class DayTime: ModelNSObj, NSCoding{

	var endTime : String!
	var multiplier : String!
	var startTime : String!

	init(fromDictionary dictionary: [String:Any]){
		endTime = dictionary["end_time"] as? String
        
        multiplier = String(describing: dictionary["multiplier"] ?? "1")
        
		startTime = dictionary["start_time"] as? String
	}

	func toDictionary() -> [String:Any] {
		var dictionary = [String:Any]()
		if endTime != nil{
			dictionary["end_time"] = endTime
		}
		if multiplier != nil{
			dictionary["multiplier"] = multiplier
		}
		if startTime != nil{
			dictionary["start_time"] = startTime
		}
		return dictionary
	}

    @objc required init(coder aDecoder: NSCoder) {
         endTime = aDecoder.decodeObject(forKey: "end_time") as? String
         multiplier = aDecoder.decodeObject(forKey: "multiplier") as? String
         startTime = aDecoder.decodeObject(forKey: "start_time") as? String
	}

    @objc func encode(with aCoder: NSCoder) {
		if endTime != nil{
			aCoder.encode(endTime, forKey: "end_time")
		}
		if multiplier != nil{
			aCoder.encode(multiplier, forKey: "multiplier")
		}
		if startTime != nil{
			aCoder.encode(startTime, forKey: "start_time")
		}
	}

}
