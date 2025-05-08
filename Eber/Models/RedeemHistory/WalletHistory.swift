

import Foundation
 


public class WalletHistory {
	public var total_redeem_point : Int?
	public var country_id : String?
	public var user_unique_id : Int?
	public var added_redeem_point : Int?
	public var redeem_point_type : Int?
	public var created_at : String?
	public var _id : String?
	public var user_id : String?
	public var redeem_point_currency : String?
	public var redeem_point_description : String?
	public var unique_id : Int?
	public var updated_at : String?
	public var wallet_status : Int?
	public var __v : Int?
	public var user_type : Int?


    public class func modelsFromDictionaryArray(array:NSArray) -> [WalletHistory]
    {
        var models:[WalletHistory] = []
        for item in array
        {
            models.append(WalletHistory(dictionary: item as! NSDictionary)!)
        }
        return models
    }


	required public init?(dictionary: NSDictionary) {

		total_redeem_point = dictionary["total_redeem_point"] as? Int
		country_id = dictionary["country_id"] as? String
		user_unique_id = dictionary["user_unique_id"] as? Int
		added_redeem_point = dictionary["added_redeem_point"] as? Int
		redeem_point_type = dictionary["redeem_point_type"] as? Int
		created_at = dictionary["created_at"] as? String
		_id = dictionary["_id"] as? String
		user_id = dictionary["user_id"] as? String
		redeem_point_currency = dictionary["redeem_point_currency"] as? String
		redeem_point_description = dictionary["redeem_point_description"] as? String
		unique_id = dictionary["unique_id"] as? Int
		updated_at = dictionary["updated_at"] as? String
		wallet_status = dictionary["wallet_status"] as? Int
		__v = dictionary["__v"] as? Int
		user_type = dictionary["user_type"] as? Int
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.total_redeem_point, forKey: "total_redeem_point")
		dictionary.setValue(self.country_id, forKey: "country_id")
		dictionary.setValue(self.user_unique_id, forKey: "user_unique_id")
		dictionary.setValue(self.added_redeem_point, forKey: "added_redeem_point")
		dictionary.setValue(self.redeem_point_type, forKey: "redeem_point_type")
		dictionary.setValue(self.created_at, forKey: "created_at")
		dictionary.setValue(self._id, forKey: "_id")
		dictionary.setValue(self.user_id, forKey: "user_id")
		dictionary.setValue(self.redeem_point_currency, forKey: "redeem_point_currency")
		dictionary.setValue(self.redeem_point_description, forKey: "redeem_point_description")
		dictionary.setValue(self.unique_id, forKey: "unique_id")
		dictionary.setValue(self.updated_at, forKey: "updated_at")
		dictionary.setValue(self.wallet_status, forKey: "wallet_status")
		dictionary.setValue(self.__v, forKey: "__v")
		dictionary.setValue(self.user_type, forKey: "user_type")

		return dictionary
	}

}
