//
//  AlamofireHelper.swift
//  Store
//
//  Created by Disha Ladani on 07/02/17.
//  Copyright © 2017 Elluminati. All rights reserved.
//

import Foundation

class Parser: NSObject
{
    //MARK: - parseBasicSettingDetails
    class func parseAppSettingDetail(response:[String:Any])-> Bool
    {
        if let settingResponse = response["setting_detail"] as? [String:Any]
        {
            let setting:SettingResponse = SettingResponse.init(fromDictionary: settingResponse)
            
            preferenceHelper.setStripeKey(setting.stripePublishableKey);
            preferenceHelper.setGoogleKey(setting.iosUserAppGoogleKey)
            preferenceHelper.setGooglePlacesAutocompleteKey(setting.ios_places_autocomplete_key)
            preferenceHelper.setIsEmailVerification(setting.userEmailVerification)
            preferenceHelper.setIsPhoneNumberVerification(setting.userSms)
            preferenceHelper.setContactEmail(setting.contactUsEmail)
            preferenceHelper.setContactNumber(setting.adminPhone)
            preferenceHelper.setIsPathdraw(setting.userPath)
            preferenceHelper.setIsTwillioEnable(setting.isTwilioCallMasking)
            preferenceHelper.setIsShowEta(setting.isShowEta)
            preferenceHelper.setPrivacyPolicy(setting.privacyPolicyUrl)
            preferenceHelper.setPaymentGateway(setting.payment_gateway_type)
//            preferenceHelper.setPrivacyPolicy(WebService.BASE_URL + WebService.PRIVACY_POLICY_URL)
//            preferenceHelper.setTermsAndCondition(WebService.BASE_URL + WebService.TERMS_CONDITION_URL)
            preferenceHelper.setTermsAndCondition(setting.termsCondition)

            preferenceHelper.setIsRequiredForceUpdate(setting.iosUserAppForceUpdate)
            preferenceHelper.setPreSchedualTripTime(setting.scheduledRequestPreStartMinute)
            preferenceHelper.setLatestVersion(setting.iosUserAppVersionCode)
            
            preferenceHelper.setMinMobileLength(setting.mobileMinLenfth)
            preferenceHelper.setMaxMobileLength(setting.mobileMaxLenfth)
            preferenceHelper.setIsUseSocialLogin(setting.is_user_social_login)
            preferenceHelper.setMaxSplitUser(setting.max_split_user)
            preferenceHelper.setIsSplitPayment(setting.is_split_payment)
            
            preferenceHelper.setMultipleStopCount(setting.multipleStopCount)
            preferenceHelper.setIsAllowMultipleStop(setting.isAllowMultipleStop)
            
            preferenceHelper.setPaypalClientId(setting.paypal_client_id)
            preferenceHelper.setPaypalEnvironment(setting.paypal_environment)
            preferenceHelper.setIsLoginWithOTP(setting.is_user_login_using_otp)
            preferenceHelper.setFireBaseKey(setting.android_user_app_gcm_key);
            
            if (setting.imageBaseUrl.isEmpty()) {
                preferenceHelper.setImageBaseUrl(WebService.BASE_URL)
                //WebService.IMAGE_BASE_URL = WebService.BASE_URL
            } else {
                preferenceHelper.setImageBaseUrl(setting.imageBaseUrl)
                //WebService.IMAGE_BASE_URL = setting.imageBaseUrl
            }
        }

        if isSuccess(response: response, withSuccessToast: false, andErrorToast: true) {
            if let userResponse = response["user_detail"] as? [String:Any]  {
                CurrentTrip.shared.user = UserDataResponse.init(fromDictionary: userResponse)
                preferenceHelper.setCountryCode(CurrentTrip.shared.user.countryPhoneCode)
                preferenceHelper.setIsSendMoney(CurrentTrip.shared.user.isSendMoney)
            }
            if let value = response["split_payment_request"] as? [String:Any]  {
                CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: value)
            } else {
                CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: [:]) //need to fill empty to remove old dialog
            }
            return true;
        }
        else {
            return false;
        }
    }

//MARK: - parseUserData
    class func parseUserDetail(response:[String:Any])-> Bool
    {
        if isSuccess(response: response, withSuccessToast: false, andErrorToast: true)
        {
            if let value = response["split_payment_request"] as? [String:Any]  {
                CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: value)
            }
            if let userResponse = response["user_detail"] as? [String:Any]
            {
                print("user_detail \(userResponse)")
                CurrentTrip.shared.user = UserDataResponse.init(fromDictionary: userResponse)
                preferenceHelper.setUserId(CurrentTrip.shared.user.userId)
                preferenceHelper.setSessionToken(CurrentTrip.shared.user.token)
            }
            return true;
        }
        else
        {
            return false;
        }
    }
    
    class func parseCountry(response:[String:Any])-> Bool
    {
        if isSuccess(response: response, withSuccessToast: false, andErrorToast: true)
        {
            if let value = response["split_payment_request"] as? [String:Any]  {
                CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: value)
            }
            if let userResponse = response["user_detail"] as? [String:Any]
            {
                print("user_detail \(userResponse)")
                CurrentTrip.shared.user = UserDataResponse.init(fromDictionary: userResponse)
                preferenceHelper.setUserId(CurrentTrip.shared.user.userId)
                preferenceHelper.setSessionToken(CurrentTrip.shared.user.token)
            }
            return true;
        }
        else
        {
            return false;
        }
    }
    
    
    class func parseLogout(response:[String:Any])-> Bool
    {
        if isSuccess(response: response, withSuccessToast: false, andErrorToast: true)
        {
            CurrentTrip.shared.clearUserData()
            preferenceHelper.setUserId("")
            preferenceHelper.setSessionToken("")
            preferenceHelper.removeImageBaseUrl()
            return true;
        }
        else
        {
            return false;
        }
    }
    class func parseWalletHistory(_ response: [String:Any] ,toArray:NSMutableArray , completion: @escaping (_ result: Bool) -> Void)
    {
        toArray.removeAllObjects()
        if (isSuccess(response: response, withSuccessToast: false, andErrorToast: true))
        {
            let walletListResponse:WalletHistoryResponse = WalletHistoryResponse.init(fromDictionary: response)
            
            let walletHistoryList:[WalletHistoryItem] = walletListResponse.walletHistoryList
            
            if walletHistoryList.count > 0
            {
                for walletHistoryItem in walletHistoryList
                {
                    toArray.add(walletHistoryItem)
                }
                completion(true)
            }
            else
            {
                completion(false)
            }
        }
    }
    class func parseRedeemHistory(_ response: [String:Any] ,toArray:NSMutableArray , completion: @escaping (_ result: Bool) -> Void) {
        toArray.removeAllObjects()
        let walletListResponse:RedeemHistoryResponse = RedeemHistoryResponse(dictionary: response as! NSDictionary)!
        
        let walletHistoryList:[WalletHistory] = walletListResponse.wallet_history ?? []
        
        if walletHistoryList.count > 0
        {
            for walletHistoryItem in walletHistoryList
            {
                toArray.add(walletHistoryItem)
            }
            completion(true)
        }
        else
        {
            completion(false)
        }
    }

    class func parseInvoice(tripService:InvoiceTripservice, tripDetail:InvoiceTrip,arrForInvocie:inout [[Invoice]])-> Bool
    {
        arrForInvocie.removeAll()
        arrForInvocie.append([])
        arrForInvocie.append([])
        arrForInvocie.append([])

        let currencyCode:String = tripDetail.currencycode
        
        let distanceUnit = Utility.getDistanceUnit(unit: tripDetail.unit)
        
        let baseInvoiceTitle:String = ""
        let discountInvoiceTitle:String = "TXT_DISCOUNT".localized
        let totalInvoiceTitle:String = ""

        let promoValue = Invoice.init(sectionTitle: discountInvoiceTitle, title: "TXT_PROMO_BONUS".localized, subTitle: "", price: tripDetail.promoPayment.toCurrencyString(currencyCode: currencyCode))
        
        let referralValue = Invoice.init(sectionTitle: discountInvoiceTitle, title: "TXT_REFERRAL_BONUS".localized, subTitle: "", price:tripDetail.referralPayment.toCurrencyString(currencyCode: currencyCode))
        
        let taxSubTitle = tripService.tax.toString(places: 2) + " %"
        
        let taxValue = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_TAX".localized, subTitle: taxSubTitle, price:  tripDetail.taxFee.toCurrencyString(currencyCode: currencyCode))


        let totalServiceFees = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_SERVICE_PRICE".localized, subTitle: "", price: tripDetail.totalServiceFees.toCurrencyString(currencyCode: currencyCode))
        
        let surgePriceSubTitle = "X " + tripDetail.surgeMultiplier.toString(places: 2)
        let surgePriceValue = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_SURGE_PRICE".localized, subTitle: surgePriceSubTitle, price: tripDetail.surgeFee.toCurrencyString(currencyCode: currencyCode))

        let totalFixedFare = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_FIXED_RATE".localized, subTitle: "", price: tripDetail.fixedPrice.toCurrencyString(currencyCode: currencyCode))
        
        let totalTip = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_TIP".localized, subTitle: "", price: tripDetail.tipAmount.toCurrencyString(currencyCode: currencyCode))
        
        let totalToll = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_TOLL".localized, subTitle: "", price: tripDetail.tollAmount.toCurrencyString(currencyCode: currencyCode))

        var baseDistanceSubTitle = ""
        baseDistanceSubTitle = tripService.pricePerUnitDistance.toCurrencyString(currencyCode: currencyCode)  + "/" + distanceUnit

        var distancePriceValue = Invoice.init(title: "", subTitle: "", price: "")
        if tripService.is_use_distance_slot_calculation {
            if tripDetail.isFixedFare {
                distancePriceValue = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_DISTANCE_PRICE".localized, subTitle: baseDistanceSubTitle, price:tripDetail.distanceCost.toCurrencyString(currencyCode: currencyCode))
            } else {
                distancePriceValue = Invoice.init(sectionTitle: baseInvoiceTitle, title: "Distance Cost".localized, subTitle: "", price:tripService.basePrice.toCurrencyString(currencyCode: currencyCode))
            }
            
        } else {
            distancePriceValue = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_DISTANCE_PRICE".localized, subTitle: baseDistanceSubTitle, price:tripDetail.distanceCost.toCurrencyString(currencyCode: currencyCode))
        }
       

        var baseTimeSubTitle = ""
        baseTimeSubTitle = tripService.priceForTotalTime.toCurrencyString(currencyCode: currencyCode)  + "/" + MeasureUnit.MINUTES
        
        let timePriceValue = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_TIME_PRICE".localized, subTitle: baseTimeSubTitle, price: tripDetail.timeCost.toCurrencyString(currencyCode: currencyCode))

        var baseWaitingTimeSubTitle = ""
        baseWaitingTimeSubTitle = tripService.priceForWaitingTime.toCurrencyString(currencyCode: currencyCode)  + "/" + MeasureUnit.MINUTES
        
        let totalWaitTimeCost = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_WAIT_TIME_COST".localized, subTitle: baseWaitingTimeSubTitle, price: tripDetail.waitingTimeCost.toCurrencyString(currencyCode: currencyCode))

        let userCityTaxSubTitle =  tripService.userTax.toString(places: 1)  + " %"
        let totalUserCityTax = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_USER_CITY_TAX".localized, subTitle: userCityTaxSubTitle, price: tripDetail.userTaxFee.toCurrencyString(currencyCode: currencyCode))
        
        //let providerCityTaxSubTitle = tripService.userTax.toString(places: 1)  + " %"
        //let totalProviderCityTax = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_PROVIDER_CITY_TAX".localized, subTitle: providerCityTaxSubTitle, price: tripDetail.providerTaxFee.toCurrencyString(currencyCode: currencyCode))
        
        
        //let totalProviderMiscellaneousTax = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_PROVIDER_MISCELLANEOUS_TAX".localized, subTitle: "", price: tripDetail.providerMiscellaneousFee.toCurrencyString(currencyCode: currencyCode))
        
        let totalUserMiscellaneousTax = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_USER_MISCELLANEOUS_TAX".localized, subTitle: "", price: tripDetail.userMiscellaneousFee.toCurrencyString(currencyCode: currencyCode))
        
        let walletPayment = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_PAID_BY_WALLET".localized, subTitle: "", price: tripDetail.walletPayment.toCurrencyString(currencyCode: currencyCode))
        
        let totalRemainingPayment = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_REMAINING_TO_PAY".localized, subTitle: "", price: tripDetail.remainingPayment.toCurrencyString(currencyCode: currencyCode))
        
        let tripTypeAmount = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_FIXED_RATE".localized, subTitle: "", price: tripDetail.tripTypeAmount.toCurrencyString(currencyCode: currencyCode))


        // Code_By : Mayur  - git issue => issues/91
        // Code_Function => Before only tipAmount and tollAmount were in IF clause, CHANGE: removing the else
        
        if tripDetail.tripType == TripType.NORMAL{
            if tripDetail.isFixedFare && tripDetail.fixedPrice > 0.0{
                arrForInvocie[0].append(totalFixedFare)
            }
        }else if tripDetail.tripTypeAmount > 0.0{
            arrForInvocie[0].append(tripTypeAmount)
        }
        
        
        if !tripDetail.carRentalId.isEmpty()
        {
            let basePriceSubTitle =  tripService.basePriceTime.toString() + MeasureUnit.MINUTES + " & " + tripService.basePriceDistance.toString() + distanceUnit
            
            let invoiceObj = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_BASE_PRICE".localized, subTitle:  basePriceSubTitle, price: tripService.basePrice.toCurrencyString(currencyCode: currencyCode))
            if !tripService.is_use_distance_slot_calculation {
                arrForInvocie[0].append(invoiceObj)
            }
           
        }
        else if tripService.basePrice > 0 && !tripDetail.isFixedFare
        {
            let basePriceSubTitle = tripService.basePrice.toCurrencyString(currencyCode: currencyCode) + "/" + tripService.basePriceDistance.toString(places: 2) + distanceUnit
            
            let invoiceObj = Invoice.init(sectionTitle: baseInvoiceTitle, title: "TXT_BASE_PRICE".localized, subTitle:  basePriceSubTitle, price: tripService.basePrice.toCurrencyString(currencyCode: currencyCode))
            if !tripService.is_use_distance_slot_calculation {
                arrForInvocie[0].append(invoiceObj)
            }

        }
        
        if tripService.is_use_distance_slot_calculation {
            arrForInvocie[0].append(distancePriceValue)
        } else {
            if tripDetail.distanceCost > 0.0
            {
                arrForInvocie[0].append(distancePriceValue)
            }
        }
        

        if tripDetail.timeCost > 0.0
        {
            arrForInvocie[0].append(timePriceValue)
        }
        if tripDetail.waitingTimeCost > 0.0
        {
            arrForInvocie[0].append(totalWaitTimeCost)
        }
        if tripDetail.taxFee > 0.0
        {
            arrForInvocie[0].append(taxValue)
        }
        if tripDetail.surgeFee > 0.0
        {
            arrForInvocie[0].append(surgePriceValue)
        }
        if tripDetail.tipAmount > 0.0
        {
            arrForInvocie[0].append(totalTip)
        }
        if tripDetail.tollAmount > 0.0
        {
            arrForInvocie[0].append(totalToll)
        }
        if  tripDetail.userMiscellaneousFee > 0.0
        {
            arrForInvocie[0].append(totalUserMiscellaneousTax)
        }
        if tripDetail.userTaxFee > 0.0
        {
            arrForInvocie[0].append(totalUserCityTax)
        }
        if tripDetail.referralPayment > 0.0
        {
            arrForInvocie[1].append(referralValue)
        }
        if tripDetail.promoPayment > 0.0
        {
            arrForInvocie[1].append(promoValue)
        }
        if tripDetail.walletPayment > 0.0
        {
            arrForInvocie[0].append(walletPayment)
        }
        if tripDetail.remainingPayment > 0.0
        {
            arrForInvocie[0].append(totalRemainingPayment)
        }
        if tripDetail.cardPayment > 0 {
            let strCardPayment: String = {
                if tripDetail.paymentMode != PaymentMode.CARD && tripDetail.paymentMode != PaymentMode.CASH {
                    return "TXT_PAID_BY_APPLE_PAY".localized
                }
                return "TXT_PAID_BY_CARD".localized
            }()
            let paymentPaidBy = Invoice.init(sectionTitle: totalInvoiceTitle, title: strCardPayment, subTitle: "", price:tripDetail.cardPayment.toCurrencyString(currencyCode: currencyCode))
            arrForInvocie[0].append(paymentPaidBy)
        }
        
        if tripDetail.cashPayment > 0 {
            let paidBy =  "TXT_PAID_BY_CASH".localized
            let paymentPaidBy = Invoice.init(sectionTitle: totalInvoiceTitle, title: paidBy, subTitle: "", price: tripDetail.cashPayment.toCurrencyString(currencyCode: currencyCode))
            arrForInvocie[0].append(paymentPaidBy)
        }
        
        if arrForInvocie[2].count == 0
        {
            arrForInvocie.remove(at: 2)
        }
        if arrForInvocie[1].count == 0
        {
            arrForInvocie.remove(at: 1)
        }
        return true;
    }

    //MARK: - parseDocumentList
    class func parseDocumentList(_ response: [String:Any] ,toArray:NSMutableArray , completion: @escaping (_ result: Bool) -> Void)
    {
        if (isSuccess(response: response, withSuccessToast: false, andErrorToast: true))
        {
            let documentResponse:DocumentsResponse = DocumentsResponse.init(fromDictionary: response)
            //preferenceHelper.setIsUserDocumentUploaded(documentResponse.isDocumentUploaded!)
            toArray.removeAllObjects()
            for document in documentResponse.documents!
            {
                toArray.add(document)
            }
            completion(true)
        }
        else
        {
            completion(false)
        }
    }

//MARK: - pargeWeatherResponse is Success Or Notf
    static func isSuccess(response:[String:Any], withSuccessToast:Bool = false, andErrorToast:Bool = true) -> Bool
    {
        if response.count > 0
        {
            let isSuccess:ResponseModel = ResponseModel.init(fromDictionary: response)
            if isSuccess.success
            {
                if withSuccessToast
                {
                    DispatchQueue.main.async
                        { /*[unowned isSuccess] in*/

                            if isSuccess.message.count > 0{
                                print("message code--- \(String(isSuccess.message ))")
                                let messageCode:String = "MSG_CODE_" + String(isSuccess.message )
                                Utility.hideLoading()
                                Utility.showToast(message:messageCode.localized);
                        }
                    }
                }
                return true;
            }
            else
            {
                let errorCode:String = "ERROR_CODE_" + String(isSuccess.errorCode )
                if (errorCode.compare("ERROR_CODE_451") == ComparisonResult.orderedSame || errorCode.compare("ERROR_CODE_474") == ComparisonResult.orderedSame)
                {
                    Utility.hideLoading()
                    Utility.showToast(message: errorCode.localized);
                    print("message code L 380--- \(String(isSuccess.message ))")

                    preferenceHelper.setSessionToken("");
                    preferenceHelper.setUserId("");
                    APPDELEGATE.gotoLogin()
                    return false;
                }
                else if andErrorToast
                {
                    DispatchQueue.main.async {
                        print("message code L 390--- \(String(isSuccess.message ))")
                        Utility.hideLoading()
                        Utility.showToast(message: errorCode.localized);
                    }
                }
                return false;
            }
        }
        else
        {
            return false;
        }
    }

    class func parseCountries(_ response:[String:Any],toArray:NSMutableArray , completion: @escaping (_ result: Bool) -> Void)
    {
        /*if (isSuccess(response: response, withSuccessToast: false, andErrorToast: true))
        {
            //let jsonDecoder = JSONDecoder()
            do{
                
                /*let coutries:CountriesResponse =  try jsonDecoder.decode(CountriesResponse.self, from: data!)
                toArray.removeAllObjects()
                let coutryList:[Country] = coutries.country
                if coutryList.count > 0
                {
                    for country in coutryList
                    {
                        toArray.add(country)
                    }
                    completion(true)
                }
                else
                {
                    completion(false)
                }*/
            }
            catch
            {
                completion(false)
            }
        }
        else
        {
            completion(false)
        }*/
    }
    
}

