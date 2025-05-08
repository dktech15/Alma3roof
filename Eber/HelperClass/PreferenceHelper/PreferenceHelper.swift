//
//  PreferenceHelper.swift
//  tableViewDemo
//
//  Created by Elluminati on 12/01/17.
//  Copyright © 2017 tag. All rights reserved.
//

import UIKit

class PreferenceHelper: NSObject
{
    //MARK: - Setting Preference Keys
    private let KEY_GOOGLE_KEY = "google_key";
    private let KEY_GOOGLE_PLACES_AUTOCOMPLETE_KEY = "google_autocomplete_key";
    private let KEY_STRIPE_KEY = "stripe_key";

    private let KEY_CONTACT_EMAIL = "contact_email"
    private let KEY_CONTACT_NUMBER = "contact_number"

    private let KEY_LANGUAGE = "language"
    private let KEY_APPLE_USER_NAME = "apple_user_name"
    private let KEY_APPLE_EMAIL = "apple_email"
    private let KEY_TERMS_AND_CONDITION = "terms_and_condition"
    private let KEY_PRIVACY_AND_POLICY = "privacy_and_policy"

    private let KEY_IS_EMAIL_VERIFICATION = "email_verification"

    private let KEY_IS_PHONE_NUMBER_VERIFICATION = "phone_number_verification"
    private let KEY_IS_REQUIRED_FORCE_UPDATE = "is_force_update_required"

    private let KEY_IS_PATH_DRAW = "is_path_draw"
    private let KEY_PRE_TRIP_TIME = "pre_trip_time"
    private let KEY_LATEST_VERSION = "latest_version"
    private let KEY_TWILLIO_ENABLE = "twillio_enable"
    private let IS_USER_SOCIAL_LOGIN = "is_user_social_login"
    private let is_split_payment = "is_split_payment"
    private let max_split_user = "max_split_user"

    //MARK: - User Preference Keys
    private let KEY_IS_SOUND_ON = "is_sound_on"
    private let KEY_IS_PUSH_SOUND_ON = "is_push_sound_on"
    private let KEY_IS_DRIVER_ARRIVED_SOUND = "is_driver_arrived_sound_on";
    private let KEY_IS_ADMIN_DOCUMENT_MANDATORY = "is_admin_document_mandatory";
    private let KEY_IS_CODE_CONFIRMATION_SHOW = "is_code_confirmation_show"

    //MARK: - User Preference Keys
    private let KEY_USER_ID = "user_id"
    private let KEY_SESSION_TOKEN = "session_token"
    private let KEY_DEVICE_TOKEN = "device_token";
    private let KEY_CHAT_NAME = "chat_name"
    private let KEY_PHONE_NUMBER_MAX_LENGTH = "phone_number_max_length";
    private let KEY_PHONE_NUMBER_MIN_LENGTH = "phone_number_min_length";
    private let KEY_IS_USER_SHOW_ETA = "is_user_show_eta"
    private let KEY_LANGUAGE_CODE = "language_code"
    private let KEY_PAYMENT_GATEWAY_TYPE = "payment_gateway_type"
    private let KEY_FIREBASE_TOKEN = "firebase_token"
    private let KEY_IMAGE_BASE_URL = "imageBaseURL"
    
    static let KEY_CURRENT_APP_MODE = "current_app_mode"
    
    private let KEY_MIN_MOBILE_LENGTH = "minimum_phone_number_length"
    private let KEY_MAX_MOBILE_LENGTH = "maximum_phone_number_length"
    
    private let KEY_IS_ALLOWED_MULTIPLE_STOP = "is_allow_multiple_stop"
    private let KEY_MULTIPLE_STOP_COUNT = "multiple_stop_count"
    
    private let is_allow_trip_bidding = "is_allow_trip_bidding"
    private let is_user_can_set_bid_price = "is_user_can_set_bid_price"
    private let paypal_client_id = "paypal_client_id"
    private let paypal_environment = "paypal_environment"
    private let KEY_MINIMUM_REDEEM_POINTS = "minimum_redeem_points"
    private let KEY_TOTAL_REDEEM_POINTS = "total_redeem_points"
    private let KEY_REDEEM_POINTS_VALUES = "redeem_points_values"
    private let KEY_WALLET_CURRNCY_CODE = "wallet_currency_code"
    private let KEY_LOGIN_OTP = "is_user_login_using_otp"
    private let KEY_FIREBASE = "android_user_app_gcm_key"
    private let COUNTRY_PHONE_CODE = "countryPhoneCode"
    
    private let KEY_SET_SEND_MONEY = "is_send_money_for_user"

    let ph = UserDefaults.standard;
    static let preferenceHelper = PreferenceHelper()

    private override init(){
    }

    deinit {
        printE("\(self) \(#function)")
    }

    //MARK: - Getter Setters
    func getLanguageCode() -> String {
        return (ph.value(forKey: KEY_LANGUAGE_CODE) as? String) ?? "en"
    }
    func setLanguageCode(code: String) {
        ph.set(code, forKey: KEY_LANGUAGE_CODE);
        ph.synchronize();
    }

    func setIsShowEta(_ isOn: Bool) {
        ph.set(isOn, forKey: KEY_IS_USER_SHOW_ETA);
        ph.synchronize();
    }
    func getIsShowEta() -> Bool {
        return (ph.value(forKey: KEY_IS_USER_SHOW_ETA) as? Bool) ?? false
    }

    func setIsTwillioEnable(_ isEnable:Bool)
    {
        ph.set(isEnable, forKey: KEY_TWILLIO_ENABLE);
        ph.synchronize();
    }
    func getIsTwillioEnable() -> Bool
    {
        return (ph.value(forKey: KEY_TWILLIO_ENABLE) as? Bool) ?? false
    }

    func setContactEmail(_ email:String){
        ph.set(email, forKey: KEY_CONTACT_EMAIL);
        ph.synchronize();
    }
    func getContactEmail() -> String{
        return (ph.value(forKey: KEY_CONTACT_EMAIL) as? String) ?? ""
    }

    func setChatName(_ name:String){
        ph.set(name, forKey: KEY_CHAT_NAME);
        ph.synchronize();
    }
    func getChatName() -> String{
        return (ph.value(forKey: KEY_CHAT_NAME) as? String) ?? ""
    }

    func setContactNumber(_ contact:String)
    {
        ph.set(contact, forKey: KEY_CONTACT_NUMBER);
        ph.synchronize();
    }
    func getContactNumber() -> String
    {
        return (ph.value(forKey: KEY_CONTACT_NUMBER) as? String) ?? ""
    }

    func setTermsAndCondition(_ url:String)
    {
        ph.set(url, forKey: KEY_TERMS_AND_CONDITION);
        ph.synchronize();
    }
    func getTermsAndCondition() -> String
    {
        return (ph.value(forKey: KEY_TERMS_AND_CONDITION) as? String) ?? ""
    }

    func setPrivacyPolicy(_ url:String)
    {
        ph.set(url, forKey: KEY_PRIVACY_AND_POLICY);
        ph.synchronize();
    }
    func getPrivacyPolicy() -> String
    {
        return (ph.value(forKey: KEY_PRIVACY_AND_POLICY) as? String) ?? ""
    }

    func setIsEmailVerification(_ isEmailVerification:Bool)
    {
        ph.set(isEmailVerification, forKey: KEY_IS_EMAIL_VERIFICATION);
        ph.synchronize();
    }
    func getIsEmailVerification() -> Bool
    {
        return (ph.value(forKey: KEY_IS_EMAIL_VERIFICATION) as? Bool) ?? false
    }

    func setIsPhoneNumberVerification(_ isPhoneNumberVerification:Bool)
    {
        ph.set(isPhoneNumberVerification, forKey: KEY_IS_PHONE_NUMBER_VERIFICATION);
        ph.synchronize();
    }
    func getIsPhoneNumberVerification() -> Bool
    {
        return (ph.value(forKey: KEY_IS_PHONE_NUMBER_VERIFICATION) as? Bool) ?? false
    }

    func setIsRequiredForceUpdate(_ fUpdate:Bool)
    {
        ph.set(fUpdate, forKey: KEY_IS_REQUIRED_FORCE_UPDATE);
        ph.synchronize();
    }
    func getIsRequiredForceUpdate() -> Bool
    {
        return (ph.value(forKey: KEY_IS_REQUIRED_FORCE_UPDATE) as? Bool) ?? false
    }

    func setGoogleKey(_ googleKey:String)
    {
        ph.set(googleKey, forKey: KEY_GOOGLE_KEY);
        ph.synchronize();
    }
    func getGoogleKey() -> String
    {
        return (ph.value(forKey: KEY_GOOGLE_KEY) as? String) ?? ""
    }

    func setStripeKey(_ stripeKey:String)
    {
        ph.set(stripeKey, forKey: KEY_STRIPE_KEY);
        ph.synchronize();
    }
    func getStripeKey() -> String
    {
        return (ph.value(forKey: KEY_STRIPE_KEY) as? String) ?? ""
    }

    func setIsPathdraw(_ isPathDraw:Bool)
    {
        ph.set(isPathDraw, forKey: KEY_IS_PATH_DRAW);
        ph.synchronize();
    }
    func getIsPathdraw() -> Bool
    {
        return (ph.value(forKey: KEY_IS_PATH_DRAW) as? Bool) ?? false
    }

    func setIsArivedSoundOn(_ isOn:Bool)
    {
        ph.set(isOn, forKey: KEY_IS_DRIVER_ARRIVED_SOUND);
        ph.synchronize();
    }
    func getIsArivedSoundOn() -> Bool
    {
        return (ph.value(forKey: KEY_IS_DRIVER_ARRIVED_SOUND) as? Bool) ?? true
    }

    func setIsSoundOn(_ isOn:Bool)
    {
        ph.set(isOn, forKey: KEY_IS_SOUND_ON);
        ph.synchronize();
    }
    func getIsSoundOn() -> Bool
    {
        return (ph.value(forKey: KEY_IS_SOUND_ON) as? Bool) ?? true
    }

    func setIsPushSoundOn(_ isOn:Bool)
    {
        ph.set(isOn, forKey: KEY_IS_PUSH_SOUND_ON);
        ph.synchronize();
    }
    func getIsPushSoundOn() -> Bool
    {
        return (ph.value(forKey: KEY_IS_PUSH_SOUND_ON) as? Bool) ?? true
    }
    
    func setIsCodeConfirmationShowOn(_ isOn:Bool)
    {
        ph.set(isOn, forKey: KEY_IS_CODE_CONFIRMATION_SHOW);
        ph.synchronize();
    }
    func getIsCodeConfirmationShowOn() -> Bool
    {
        return (ph.value(forKey: KEY_IS_CODE_CONFIRMATION_SHOW) as? Bool) ?? true
    }
    

    func getMinPhoneNumberLength() -> Int
    {
        return (ph.value(forKey: KEY_PHONE_NUMBER_MIN_LENGTH) as? Int) ?? 8
    }
    func setMinPhoneNumberLength(_ length:Int)
    {
        ph.set(length, forKey: KEY_PHONE_NUMBER_MIN_LENGTH);
        ph.synchronize();
    }

    func setPreSchedualTripTime(_ timeInMin:Int)
    {
        ph.set(timeInMin, forKey: KEY_PRE_TRIP_TIME);
        ph.synchronize();
    }
    
    func getPreSchedualTripTime() -> Int
    {
        return (ph.value(forKey: KEY_PRE_TRIP_TIME) as? Int) ?? 0
    }

    func setLatestVersion(_ version:String)
    {
        ph.set(version, forKey: KEY_LATEST_VERSION);
        ph.synchronize();
    }
    func getLatestVersion() -> String
    {
        return (ph.value(forKey: KEY_LATEST_VERSION) as? String) ?? ""
    }

    //MARK: - Preference User Getter Setters
    func setDeviceToken(_ token:String)
    {
        ph.set(token, forKey: KEY_DEVICE_TOKEN);
        ph.synchronize();
    }
    func getDeviceToken() -> String
    {
        return (ph.value(forKey: KEY_DEVICE_TOKEN) as? String) ?? ""
    }

    func setLanguage(_ index:Int)
    {
        ph.set(index, forKey: KEY_LANGUAGE);
        ph.synchronize();
    }
    func getLanguage() -> (Int)
    {
        return (ph.value(forKey: KEY_LANGUAGE) as? Int) ?? 0
    }

    func setUserId(_ userId:String)
    {
        ph.set(userId, forKey: KEY_USER_ID);
        ph.synchronize();
    }
    func getUserId() -> String
    {
        return (ph.value(forKey: KEY_USER_ID) as? String) ?? ""
    }

    func setSessionToken(_ sessionToken:String)
    {
        ph.set(sessionToken, forKey: KEY_SESSION_TOKEN);
        ph.synchronize();
    }
    func getSessionToken() -> String
    {
        return (ph.value(forKey: KEY_SESSION_TOKEN) as? String) ?? ""
    }

    func clearAll()
    {
        ph.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        ph.synchronize();
    }

    func setGooglePlacesAutocompleteKey(_ googleKey:String)
    {
        ph.set(googleKey, forKey: KEY_GOOGLE_PLACES_AUTOCOMPLETE_KEY);
        ph.synchronize();
    }
    func getGooglePlacesAutocompleteKey() -> String
    {
        return (ph.value(forKey: KEY_GOOGLE_PLACES_AUTOCOMPLETE_KEY) as? String) ?? ""
    }
    func setSigninWithAppleUserName(_ username:String) {
        ph.set(username, forKey: KEY_APPLE_USER_NAME)
        ph.synchronize()
    }
    
    func getSigninWithAppleUserName() -> String {
        return (ph.value(forKey: KEY_APPLE_USER_NAME) as? String) ?? ""
    }
    
    func setSigninWithAppleEmail(_ email:String) {
        ph.set(email, forKey: KEY_APPLE_EMAIL)
        ph.synchronize()
    }
    
    func getSigninWithAppleEmail() -> String {
        return (ph.value(forKey: KEY_APPLE_EMAIL) as? String) ?? ""
    }

    func setPaymentGatewayType(_ index:Int)
    {
        ph.set(index, forKey: KEY_PAYMENT_GATEWAY_TYPE);
    }

    func getsetPaymentGatewayType() -> Int
    {
        return (ph.value(forKey: KEY_PAYMENT_GATEWAY_TYPE) as? Int) ?? 0
    }
    
    func setPaymentGateway(_ index:String)
    {
        ph.set(index, forKey: KEY_PAYMENT_GATEWAY_TYPE);
    }

    func getsPaymentGateway() -> String
    {
        return (ph.value(forKey: KEY_PAYMENT_GATEWAY_TYPE) as? String) ?? "0"
    }
    
    func getCurrentAppMode() -> Int {
        return (ph.value(forKey: PreferenceHelper.KEY_CURRENT_APP_MODE) as? Int) ?? 0
    }
    
    func setCurrentAppMode(_ length:Int) {
        ph.set(length, forKey: PreferenceHelper.KEY_CURRENT_APP_MODE);
        ph.synchronize();
    }
    
    func setImageBaseUrl(_ str:String)
    {
        ph.set(str, forKey: KEY_IMAGE_BASE_URL);
        ph.synchronize();
    }
    
    func getImageBaseUrl() -> String?
    {
        return (ph.value(forKey: KEY_IMAGE_BASE_URL) as? String)
    }
    
    func removeImageBaseUrl() {
        ph.removeObject(forKey: KEY_IMAGE_BASE_URL)
        ph.synchronize()
    }
    
    func setAuthToken(_ token:String) {
        ph.set(token, forKey: KEY_FIREBASE_TOKEN)
        ph.synchronize()
    }
    func getAuthToken() -> String {
        return (ph.value(forKey: KEY_FIREBASE_TOKEN) as? String) ?? ""
    }
    
    func setMinMobileLength(_ int:Int) {
        ph.set(int, forKey: KEY_MIN_MOBILE_LENGTH)
        ph.synchronize()
    }
    
    func getMinMobileLength() -> Int {
        return (ph.value(forKey: KEY_MIN_MOBILE_LENGTH) as? Int) ?? 7
    }
    
    func setMaxMobileLength(_ int:Int) {
        ph.set(int, forKey: KEY_MAX_MOBILE_LENGTH)
        ph.synchronize()
    }
    
    func getMaxMobileLength() -> Int {
        return (ph.value(forKey: KEY_MAX_MOBILE_LENGTH) as? Int) ?? 12
    }
    
    func getIsUseSocialLogin() -> Bool
    {
        return (ph.value(forKey: IS_USER_SOCIAL_LOGIN) as? Bool) ?? false
    }

    func setIsUseSocialLogin(_ bool:Bool)
    {
        ph.set(bool, forKey: IS_USER_SOCIAL_LOGIN);
        ph.synchronize();
    }
    
    func getIsSplitPayment() -> Bool
    {
        return (ph.value(forKey: is_split_payment) as? Bool) ?? false
    }

    func setIsSplitPayment(_ bool:Bool)
    {
        ph.set(bool, forKey: is_split_payment);
        ph.synchronize();
    }
    
    func getMaxSplitUser() -> Int
    {
        return (ph.value(forKey: max_split_user) as? Int) ?? 1
    }

    func setMaxSplitUser(_ value:Int)
    {
        ph.set(value, forKey: max_split_user);
        ph.synchronize();
    }
    
    func setMultipleStopCount(_ int:Int) {
        ph.set(int, forKey: KEY_MULTIPLE_STOP_COUNT)
        ph.synchronize()
    }
    
    func getMultipleStopCount() -> Int {
        return (ph.value(forKey: KEY_MULTIPLE_STOP_COUNT) as? Int) ?? 0
    }
    
    func setIsAllowMultipleStop(_ isOn:Bool)
    {
        ph.set(isOn, forKey: KEY_IS_ALLOWED_MULTIPLE_STOP);
        ph.synchronize();
    }
    
    func getIsAllowMultipleStop() -> Bool
    {
        return (ph.value(forKey: KEY_IS_ALLOWED_MULTIPLE_STOP) as? Bool) ?? false
    }
    
    func setIsAllowTripBidding(_ isOn:Bool)
    {
        ph.set(isOn, forKey: is_allow_trip_bidding);
        ph.synchronize();
    }
    
    func getIsAllowTripBidding() -> Bool
    {
        return (ph.value(forKey: is_allow_trip_bidding) as? Bool) ?? false
    }
    
    func setIsUserCanSetBid(_ isOn:Bool)
    {
        ph.set(isOn, forKey: is_user_can_set_bid_price);
        ph.synchronize();
    }
    
    func getIsUserCanSetBid() -> Bool
    {
        return (ph.value(forKey: is_user_can_set_bid_price) as? Bool) ?? false
    }
    
    func setPaypalClientId(_ id:String)
    {
        ph.set(id, forKey: paypal_client_id);
        ph.synchronize();
    }
    
    func getPaypalClientId() -> String
    {
        return (ph.value(forKey: paypal_client_id) as? String) ?? ""
    }
    
    func setPaypalEnvironment(_ string:String)
    {
        ph.set(string, forKey: paypal_environment);
        ph.synchronize();
    }
    
    func getPaypalEnvironment() -> String
    {
        return (ph.value(forKey: paypal_environment) as? String) ?? ""
    }
    func setMinimumRedeemPoints(_ string:Int)
    {
        ph.set(string, forKey: KEY_MINIMUM_REDEEM_POINTS);
        ph.synchronize();
    }
    
    func getMinimumRedeemPoints() -> Int
    {
        return (ph.value(forKey: KEY_MINIMUM_REDEEM_POINTS) as? Int) ?? 0
    }
    func setTotalRedeemPoints(_ string:Double)
    {
        ph.set(string, forKey: KEY_TOTAL_REDEEM_POINTS);
        ph.synchronize();
    }
    func getTotalRedeemPoints() -> Double
    {
        return (ph.value(forKey: KEY_TOTAL_REDEEM_POINTS) as? Double) ?? 0.0
    }
    func setRedeemPointsValue(_ string:Double)
    {
        ph.set(string, forKey: KEY_REDEEM_POINTS_VALUES);
        ph.synchronize();
    }
    func getRedeemPointsValue() -> Double
    {
        return (ph.value(forKey: KEY_REDEEM_POINTS_VALUES) as? Double) ?? 0.0
    }
    func setWalletCurrencyCode(_ string:String)
    {
        ph.set(string, forKey: KEY_WALLET_CURRNCY_CODE);
        ph.synchronize();
    }
    func getWalletCurrencyCode() -> String
    {
        return (ph.value(forKey: KEY_WALLET_CURRNCY_CODE) as? String) ?? ""
    }
    func setIsLoginWithOTP(_ bool:Bool)
    {
        ph.set(bool, forKey: KEY_LOGIN_OTP);
        ph.synchronize();
    }
    func getIsLoginWithOTP() -> Bool
    {
        return (ph.value(forKey: KEY_LOGIN_OTP) as? Bool) ?? false
    }
    
    func setFireBaseKey(_ string:String)
    {
        ph.set(string, forKey: KEY_FIREBASE);
        ph.synchronize();
    }
    func getFireBaseKey() -> String
    {
        return (ph.value(forKey: KEY_FIREBASE) as? String) ?? ""
    }
    func setCountryCode(_ string:String)
    {
        ph.set(string, forKey: COUNTRY_PHONE_CODE);
        ph.synchronize();
    }
    func getCountryCode() -> String
    {
        return (ph.value(forKey: COUNTRY_PHONE_CODE) as? String) ?? ""
    }
    
    func setIsSendMoney(_ ioOn:Bool)
    {
        ph.set(ioOn, forKey: KEY_SET_SEND_MONEY);
        ph.synchronize();
    }
    func getIsSendMoney() -> Bool
    {
        return (ph.value(forKey: KEY_SET_SEND_MONEY) as? Bool) ?? false
    }
}
