//
//  BidTrips.swift
//  Eber
//
//  Created by Mayur on 19/06/23.
//  Copyright © 2023 Elluminati. All rights reserved.
//

import Foundation

public class Bids {
    public var bid_at : String?
    public var status : Int?
    public var provider_id : String?
    public var last_name : String?
    public var picture : String?
    public var is_favourite_provider : Bool?
    public var ask_bid_price : Double?
    public var bid_end_at : String?
    public var currency : String?
    public var first_name : String?
    public var rate : Double?

    required public init(dictionary: NSDictionary) {

        bid_at = dictionary["bid_at"] as? String
        status = dictionary["status"] as? Int
        provider_id = dictionary["provider_id"] as? String
        last_name = dictionary["last_name"] as? String
        picture = dictionary["picture"] as? String
        is_favourite_provider = dictionary["is_favourite_provider"] as? Bool
        ask_bid_price = dictionary["ask_bid_price"] as? Double
        bid_end_at = dictionary["bid_end_at"] as? String
        currency = dictionary["currency"] as? String
        first_name = dictionary["first_name"] as? String
        rate = dictionary["rate"] as? Double ?? 0
    }

    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.bid_at, forKey: "bid_at")
        dictionary.setValue(self.status, forKey: "status")
        dictionary.setValue(self.provider_id, forKey: "provider_id")
        dictionary.setValue(self.last_name, forKey: "last_name")
        dictionary.setValue(self.picture, forKey: "picture")
        dictionary.setValue(self.is_favourite_provider, forKey: "is_favourite_provider")
        dictionary.setValue(self.ask_bid_price, forKey: "ask_bid_price")
        dictionary.setValue(self.bid_end_at, forKey: "bid_end_at")
        dictionary.setValue(self.currency, forKey: "currency")
        dictionary.setValue(self.first_name, forKey: "first_name")
        dictionary.setValue(self.rate, forKey: "rate")

        return dictionary
    }

}

