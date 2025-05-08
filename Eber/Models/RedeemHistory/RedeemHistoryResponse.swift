

import Foundation
 
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class RedeemHistoryResponse {
	public var total_redeem_point : Int?
	public var wallet_history : Array<WalletHistory>?
	public var user_minimum_point_require_for_withdrawal : Int?
	public var user_redeem_point_value : Int?
	public var success : Bool?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let json4Swift_Base_list = Json4Swift_Base.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of Json4Swift_Base Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [RedeemHistoryResponse]
    {
        var models:[RedeemHistoryResponse] = []
        for item in array
        {
            models.append(RedeemHistoryResponse(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let json4Swift_Base = Json4Swift_Base(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: Json4Swift_Base Instance.
*/
	required public init?(dictionary: NSDictionary) {

		total_redeem_point = dictionary["total_redeem_point"] as? Int
        if (dictionary["wallet_history"] != nil) { wallet_history = WalletHistory.modelsFromDictionaryArray(array: dictionary["wallet_history"] as! NSArray) }
		user_minimum_point_require_for_withdrawal = dictionary["user_minimum_point_require_for_withdrawal"] as? Int
		user_redeem_point_value = dictionary["user_redeem_point_value"] as? Int
		success = dictionary["success"] as? Bool
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.total_redeem_point, forKey: "total_redeem_point")
		dictionary.setValue(self.user_minimum_point_require_for_withdrawal, forKey: "user_minimum_point_require_for_withdrawal")
		dictionary.setValue(self.user_redeem_point_value, forKey: "user_redeem_point_value")
		dictionary.setValue(self.success, forKey: "success")

		return dictionary
	}

}
