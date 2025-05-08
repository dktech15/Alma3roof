//
//	SettingResponse.swift
//
//	Create by MacPro3 on 7/9/2018
//	Copyright © 2018. All rights reserved.


import Foundation

class SettingResponse: ModelNSObj {

	var adminPhone : String!
	var contactUsEmail : String!
	
    var iosUserAppForceUpdate : Bool!
	var iosUserAppGoogleKey : String!
    var ios_places_autocomplete_key : String!
	var iosUserAppVersionCode : String!
    var userEmailVerification : Bool!
    var userPath : Bool!
    var userSms : Bool!

	var isTip : Bool!
    var isShowEta : Bool!
	var scheduledRequestPreStartMinute : Int!
	var stripePublishableKey : String!
    var imageBaseUrl : String!
	var isTwilioCallMasking : Bool!
	var success : Bool!
    var termsCondition : String!
    var privacyPolicyUrl : String!
    
    var mobileMinLenfth = 7
    var mobileMaxLenfth = 12
    
    var is_user_social_login = false
    var isAllowMultipleStop : Bool!
    var multipleStopCount : Int = 0
    
    var is_split_payment = false
    var max_split_user = 1
    var paypal_client_id = ""
    var paypal_environment = ""
    var is_user_login_using_otp = false
    var android_user_app_gcm_key = ""
    var payment_gateway_type : String!
	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]) {
		adminPhone = (dictionary["admin_phone"] as? String) ?? ""

		contactUsEmail = (dictionary["contactUsEmail"] as? String) ?? ""
		iosUserAppForceUpdate = (dictionary["ios_user_app_force_update"] as? Bool) ?? false
        imageBaseUrl = (dictionary["image_base_url"] as? String) ?? ""
		iosUserAppGoogleKey = (dictionary["ios_user_app_google_key"] as? String) ?? ""
        ios_places_autocomplete_key = (dictionary["ios_places_autocomplete_key"] as? String) ?? ""
		iosUserAppVersionCode = (dictionary["ios_user_app_version_code"] as? String) ?? ""
        payment_gateway_type = (dictionary["payment_gateway_type"]  as? String) ?? "0"
        userEmailVerification = (dictionary["userEmailVerification"] as? Bool) ?? false
        userPath = (dictionary["userPath"] as? Bool) ?? false
        userSms = (dictionary["userSms"] as? Bool) ?? false
        isTwilioCallMasking = (dictionary["twilio_call_masking"] as? Bool) ?? false
        isShowEta = (dictionary["is_show_estimation_in_user_app"] as? Bool) ?? false
        isTip = (dictionary["is_tip"] as? Bool) ?? false
		scheduledRequestPreStartMinute = (dictionary["scheduled_request_pre_start_minute"] as? Int) ?? 0
		stripePublishableKey = (dictionary["stripe_publishable_key"] as? String) ?? ""
		success = (dictionary["success"] as? Bool) ?? false
        termsCondition = (dictionary["terms_and_condition_url"] as? String) ?? ""
        privacyPolicyUrl = (dictionary["privacy_policy_url"] as? String) ?? ""
        
        mobileMinLenfth = (dictionary["minimum_phone_number_length"] as? Int) ?? 7
        mobileMaxLenfth = (dictionary["maximum_phone_number_length"] as? Int) ?? 12

        isAllowMultipleStop = (dictionary["is_allow_multiple_stop"] as? Bool) ?? false
        multipleStopCount = (dictionary["multiple_stop_count"] as? Int) ?? 0
        
        let lhs = Utility.currentAppVersion()
        let rhs = Utility.getLatestVersion()
        if lhs.compare(rhs, options: .numeric) == .orderedDescending {
            is_user_social_login = false
        } else {
            is_user_social_login = (dictionary["is_user_social_login"] as? Bool) ?? false
        }
        
        is_split_payment = (dictionary["is_split_payment"] as? Bool) ?? false
        max_split_user = (dictionary["max_split_user"] as? Int) ?? 1
        paypal_client_id = (dictionary["paypal_client_id"] as? String) ?? ""
        paypal_environment = (dictionary["paypal_environment"] as? String) ?? ""
        is_user_login_using_otp = (dictionary["is_user_login_using_otp"] as? Bool) ?? false
        android_user_app_gcm_key = (dictionary["android_user_app_gcm_key"] as? String) ?? ""
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
        
        if isAllowMultipleStop != nil{
            dictionary["is_allow_multiple_stop"] = isAllowMultipleStop
        }
        if multipleStopCount != nil{
            dictionary["multiple_stop_count"] = multipleStopCount
        }
        
		if adminPhone != nil{
			dictionary["admin_phone"] = adminPhone
		}
        if isShowEta != nil{
            dictionary["is_show_estimation_in_user_app"] = isShowEta
        }
		if iosUserAppForceUpdate != nil{
			dictionary["ios_user_app_force_update"] = iosUserAppForceUpdate
		}
		if iosUserAppGoogleKey != nil{
			dictionary["ios_user_app_google_key"] = iosUserAppGoogleKey
		}
        if ios_places_autocomplete_key != nil {
            dictionary["ios_places_autocomplete_key"] = ios_places_autocomplete_key
        }
		if iosUserAppVersionCode != nil{
			dictionary["ios_user_app_version_code"] = iosUserAppVersionCode
		}

		if isTip != nil {
			dictionary["is_tip"] = isTip
		}
		
		if scheduledRequestPreStartMinute != nil{
			dictionary["scheduled_request_pre_start_minute"] = scheduledRequestPreStartMinute
		}
		if stripePublishableKey != nil{
			dictionary["stripe_publishable_key"] = stripePublishableKey
		}
        
        if isTwilioCallMasking != nil{
            dictionary["twilio_call_masking"] = isTwilioCallMasking
        }
		if success != nil{
			dictionary["success"] = success
		}
		if userEmailVerification != nil{
			dictionary["userEmailVerification"] = userEmailVerification
		}
		if userPath != nil{
			dictionary["userPath"] = userPath
		}
		if userSms != nil{
			dictionary["userSms"] = userSms
		}
        if privacyPolicyUrl != nil{
            dictionary["privacy_policy_url"] = privacyPolicyUrl
        }
        if termsCondition != nil{
            dictionary["terms_and_condition_url"] = termsCondition
        }
        
        dictionary["is_user_social_login"] = is_user_social_login
        dictionary["is_split_payment"] = is_split_payment
        dictionary["max_split_user"] = max_split_user
        dictionary["paypal_client_id"] = paypal_client_id
        dictionary["paypal_environment"] = paypal_environment
        dictionary["is_user_login_using_otp"] = is_user_login_using_otp
        dictionary["android_user_app_gcm_key"] = android_user_app_gcm_key
		return dictionary
    }
}
