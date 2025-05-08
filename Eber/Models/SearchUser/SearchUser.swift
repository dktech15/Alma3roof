//
//  SearchUser.swift
//  Eber
//
//  Created by MacPro3 on 19/07/22.
//  Copyright © 2022 Elluminati. All rights reserved.
//

import UIKit

enum SplitPaymentStatus: Int {
    case waiting = 0
    case Accept = 1
    case Rejected = 2
    case None = -1
}

class SearchUser: Model {
    
    public var _id : String?
    public var first_name : String?
    public var last_name : String?
    public var email : String?
    public var country_phone_code : String?
    public var phone : String?
    public var picture : String?
    public var payment_intent_id : String?
    public var payment_mode : Int?
    public var payment_status : Int?
    public var total : Double?
    public var remaining_payment : Double?
    public var cash_payment : Double?
    public var card_payment : Double?
    public var wallet_payment : Double?
    public var is_trip_end : Int?
    public var trip_id : String?
    public var user_id : String?
    public var currency : String?
    public var currency_code : String?
    
    public var status = SplitPaymentStatus.None

    required public init(dictionary: [String:Any]) {
        _id = dictionary["_id"] as? String
        first_name = dictionary["first_name"] as? String
        last_name = dictionary["last_name"] as? String
        email = dictionary["email"] as? String
        country_phone_code = dictionary["country_phone_code"] as? String
        phone = dictionary["phone"] as? String
        picture = dictionary["picture"] as? String
        payment_intent_id = dictionary["payment_intent_id"] as? String
        payment_mode = dictionary["payment_mode"] as? Int
        payment_status = dictionary["payment_status"] as? Int
        total = dictionary["total"] as? Double
        remaining_payment = dictionary["remaining_payment"] as? Double
        cash_payment = dictionary["cash_payment"] as? Double
        card_payment = dictionary["card_payment"] as? Double
        wallet_payment = dictionary["wallet_payment"] as? Double
        is_trip_end = dictionary["is_trip_end"] as? Int
        trip_id = dictionary["trip_id"] as? String
        user_id = dictionary["user_id"] as? String
        currency = dictionary["currency"] as? String
        status = SplitPaymentStatus(rawValue: dictionary["status"] as? Int ?? -1) ?? .None
        currency_code = dictionary["currency_code"] as? String ?? ""
    }
}

