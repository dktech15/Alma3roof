//
//  StripPayment.swift
//  Eber
//
//  Created by MacPro3 on 22/07/22.
//  Copyright © 2022 Elluminati. All rights reserved.
//

import UIKit
import Foundation
import Stripe

class SplitPaymentPay: NSObject {
    
    fileprivate var param = [String:Any]()
    fileprivate var vc = UIViewController()
    
    var currencyCode: String = ""
    
    var onSuccessPayment : (() -> Void)? = nil
    var onFailPayment : (() -> Void)? = nil
    var removeDialog : (() -> Void)? = nil
    
    var applePay: StripeApplePayHelper?
    var dialogForPayment: CustomPaymentSelectionDialog?
    var socketHelper:SocketHelper = SocketHelper.shared
    
    init(param: [String:Any], inVC: UIViewController) {
        self.param = param
        self.param[PARAMS.IS_TRIP] = true
        self.param[PARAMS.is_split_payment] = true
        self.param[PARAMS.AMOUNT] = CurrentTrip.shared.splitPaymentReq.total ?? 0
        vc = inVC
        super.init()
        self.startTripLisner()
    }
    
    func startPayment() {
        
        if CurrentTrip.shared.splitPaymentReq.payment_mode == PaymentMode.APPLE_PAY {
            self.wsGetStripeApplePayIntent()
        } else {
            wsGetStripeIntent()
        }
        
    }
    
    func startTripLisner() {
        stopTripLisner()
        
        let myTripid = "'\(CurrentTrip.shared.splitPaymentReq.trip_id ?? "")'"
        self.socketHelper.socket?.emit("room", myTripid)
        self.socketHelper.socket?.on(myTripid) {
            [weak self] (data, ack) in
            Utility.hideLoading()
            print("Socket Response \(data)")
            guard let self = self else { return }
            guard let response = data.first as? [String:Any] else { return }
            let isTripUpdate = (response[PARAMS.IS_TRIP_UPDATED] as? Bool) ?? false
            if isTripUpdate {
                if self.onSuccessPayment != nil {
                    self.onSuccessPayment!()
                }
            }
        }
    }
    
    func stopTripLisner() {
        let myTripid = "'\(CurrentTrip.shared.splitPaymentReq.trip_id ?? "")'"
        self.socketHelper.socket?.off(myTripid)
    }
    
    private func wsGetStripeIntent(isRetry: Bool = false) {
        Utility.showLoading()
        
        if isRetry {
            param[PARAMS.is_for_retry] = true
        } else {
            param[PARAMS.is_for_retry] = false
        }
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_STRIPE_PAYMENT_INTENT, methodName: AlamofireHelper.POST_METHOD, paramData: param) { (response, error) -> (Void) in
            
            Utility.hideLoading()
            print(response)
            
            if (error == nil) {
                if Parser.isSuccess(response: response, andErrorToast: false) {
                    if let value = response["payment_gateway_type"] as? Int {
                        PaymentMethod.Payment_gateway_type = "\(value)"
                    }
                    if PaymentMethod.Payment_gateway_type == PaymentMethod.Paypal_ID {
                        let paypal = PaypalHelper.init(currrencyCode: CurrentTrip.shared.splitPaymentReq.currency_code ?? "USD", amount: "\(CurrentTrip.shared.splitPaymentReq.total ?? 0)")
                        paypal.delegate = self
                        return
                    }
                    if let redirect_url = response["authorization_url"] as? String {
                        let payStackVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PayStackVC") as! PayStackVC
                        payStackVC.gotPayUResopnse = { [weak self] (_ message: String, _ isCallIntentAPI:Bool, _ showPaymentRetryDialog:Bool, _ ispaytab:Bool) -> Void in
                            guard let self = self else { return }
                            if showPaymentRetryDialog{
                                CustomDialogSplitPay.disable()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    CustomDialogSplitPay.enable()
                                    Utility.hideLoading()
                                    self.openRetryPaymentDialog()
                                }
                            }else if ispaytab {
                                if self.onSuccessPayment != nil {
                                    self.onSuccessPayment!()
                                }
                            }
                        }
                        //remove dialog because we don't want dialog over webview screen
                        if self.removeDialog != nil {
                            self.removeDialog!()
                        }
                        payStackVC.htmlDataString = redirect_url
                        PaymentMethod.Payment_gateway_type = PaymentMethod.PayTabs
                        payStackVC.iSFrom = "split_pay"
                        if let pbMenuVC = self.vc as? PBRevealViewController {
                            if let navigationVC = pbMenuVC.mainViewController as? UINavigationController {
                                navigationVC.pushViewController(payStackVC, animated: true)
                            } else {
                                self.vc.navigationController?.pushViewController(payStackVC, animated: true)
                            }
                        } else {
                            self.vc.navigationController?.pushViewController(payStackVC, animated: true)
                        }
                        
                    }  else {
                        let htplFrom = response["html_form"] as? String ?? ""
                        let msg = response["message"] as? String ?? ""
                        let paymentMethod = response["payment_method"] as? String ?? ""
                        if !htplFrom.isEmpty {
                            self.payUPayment(response: response)
                        } else if msg == "109" {
                            //success
                            if self.onSuccessPayment != nil {
                                self.onSuccessPayment!()
                            }
                        } else if paymentMethod.isEmpty() {
                            self.openRetryPaymentDialog()
                        } else {
                            //strip sdk
                            self.stripPay(response: response)
                        }
                    }
                } else {
                    let reqParam = response[PARAMS.REQUIRED_PARAM] as? String ?? ""
                    if !reqParam.isEmpty {
                        self.openPaystackPinVerificationDialog(requiredParam: response[PARAMS.REQUIRED_PARAM] as? String ?? "", reference: response["reference"] as? String ?? "")
                    } else {
                        //payment fail popup
                        self.openRetryPaymentDialog()
                    }
                }
            }
        }
    }
    
    func wsGetStripeApplePayIntent() {
        Utility.showLoading()
        let dictParam : [String : Any] =
            [PARAMS.USER_ID      : preferenceHelper.getUserId()  ,
             PARAMS.TOKEN  : preferenceHelper.getSessionToken(),
             PARAMS.PAYMENT_GATEWAY_TYPE : PaymentMethod.Stripe_ID,
             PARAMS.TRIP_ID : CurrentTrip.shared.splitPaymentReq.trip_id ?? "",
             PARAMS.is_split_payment : true,
             PARAMS.TYPE : CONSTANT.TYPE_USER]

        let alamoFire:AlamofireHelper = AlamofireHelper();
        
        alamoFire.getResponseFromURL(url: WebService.WS_TRIP_REMANING_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        {
            (response, error) -> (Void) in
            Utility.hideLoading()
            if Parser.isSuccess(response: response) {
                if let client_secret = response["client_secret"] as? String {
                    if let country = response["country_code"] as? String {
                        if let total_amount = response["total_amount"] as? Double {
                            if let currency_code = response["currency_code"] as? String {
                                let model = ApplePayHelperModel(amount: total_amount.clean, currencyCode: currency_code, country: country, applePayClientSecret: client_secret)
                                self.applePay = StripeApplePayHelper(model: model)
                                self.applePay?.delegate = self
                                self.applePay?.openApplePayDialog()
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: PayU
    private func payUPayment(response: [String:Any]) {
        let payStackVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PayStackVC") as! PayStackVC
        payStackVC.iSFrom = "split_pay"
        payStackVC.gotPayUResopnse = { [weak self] (_ message: String, _ isCallIntentAPI:Bool, _ showPaymentRetryDialog:Bool, _ ispaytabs: Bool) -> Void in
            guard let self = self else { return }
            if showPaymentRetryDialog {
                CustomDialogSplitPay.disable()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    CustomDialogSplitPay.enable()
                    Utility.hideLoading()
                    self.openRetryPaymentDialog()
                }
            } else {
                //success
                if self.onSuccessPayment != nil {
                    self.onSuccessPayment!()
                }
            }
        }
        payStackVC.htmlDataString = response["html_form"] as? String ?? ""
        
        if self.removeDialog != nil {
            self.removeDialog!() //to remove dialog
        }
        
        if let pbMenuVC = self.vc as? PBRevealViewController {
            if let navigationVC = pbMenuVC.mainViewController as? UINavigationController {
                navigationVC.pushViewController(payStackVC, animated: true)
            } else {
                self.vc.navigationController?.pushViewController(payStackVC, animated: true)
            }
        } else {
            self.vc.navigationController?.pushViewController(payStackVC, animated: true)
        }
    }
    
    //MARK: Paystack
    private func openPaystackPinVerificationDialog(requiredParam:String,reference:String) {
        switch requiredParam {
        case PaymentMethod.VerificationParameter.SEND_PIN:
            let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_PIN".localized, message: "EG_1234".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_PIN".localized,isHideBackButton: true)
            
            dialogForPromo.onClickLeftButton =
            { [unowned dialogForPromo] in
                dialogForPromo.removeFromSuperview();
            }
            dialogForPromo.onClickRightButton =
            { [unowned self, unowned dialogForPromo] (text:String) in
                if (text.count <  1) {
                    Utility.showToast(message: "PLEASE_ENTER_PIN".localized)
                }
                else {
                    self.wsSendPaystackRequiredDetail(requiredParam: requiredParam, reference: reference,pin: text,otp : "", phone: "", dialog: dialogForPromo)
                }
            }
        case PaymentMethod.VerificationParameter.SEND_OTP:
            let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_OTP".localized, message: "EG_123456".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_OTP".localized,isHideBackButton: true)
            
            dialogForPromo.onClickLeftButton = { [unowned dialogForPromo] in
                dialogForPromo.removeFromSuperview();
            }
            dialogForPromo.onClickRightButton = { [unowned self, unowned dialogForPromo] (text:String) in
                if (text.count <  1) {
                    Utility.showToast(message: "PLEASE_ENTER_OTP".localized)
                }
                else {
                    self.wsSendPaystackRequiredDetail(requiredParam: requiredParam, reference: reference,pin: "",otp : text, phone: "", dialog: dialogForPromo)
                }
            }
        case PaymentMethod.VerificationParameter.SEND_PHONE:
            let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_PHONE_NUMBER".localized, message: "MINIMUM_10_DIGITS".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_PHONE_NUMBER".localized,isHideBackButton: true)
            
            dialogForPromo.onClickLeftButton = { [unowned dialogForPromo] in
                dialogForPromo.removeFromSuperview();
            }
            
            dialogForPromo.onClickRightButton = { [unowned self, unowned dialogForPromo] (text:String) in
                if (text.count <  1) {
                    Utility.showToast(message: "PLEASE_ENTER_PHONE_NO".localized)
                }
                else {
                    self.wsSendPaystackRequiredDetail(requiredParam: requiredParam, reference: reference,pin: "",otp : "",phone:text, dialog: dialogForPromo)
                }
            }
        case PaymentMethod.VerificationParameter.SEND_BIRTHDAY:
            let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_BIRTHDATE".localized, message: "EG_DD-MM-YYYY".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_BIRTHDATE".localized,isHideBackButton: true, isShowBirthdayTextfield: true)
            
            dialogForPromo.onClickLeftButton = { [unowned dialogForPromo] in
                dialogForPromo.removeFromSuperview();
            }
            
            dialogForPromo.onClickRightButton = { [unowned self, unowned dialogForPromo] (text:String) in
                if (text.count <  1) {
                    Utility.showToast(message: "PLEASE_ENTER_BIRTHDATE".localized)
                }
                else {
                    self.wsSendPaystackRequiredDetail(requiredParam: requiredParam, reference: reference,pin: "",otp : "",phone:text, dialog: dialogForPromo)
                }
            }
        case PaymentMethod.VerificationParameter.SEND_ADDRESS:
            print(PaymentMethod.VerificationParameter.SEND_ADDRESS)
        default:
            break
        }
    }
    
    private func wsSendPaystackRequiredDetail(requiredParam:String,reference:String,pin:String,otp:String,phone:String,dialog:CustomPinVerificationDialog)
    {
        Utility.showLoading()
        
        let dictParam : [String : Any] =
        [PARAMS.USER_ID      : preferenceHelper.getUserId(),
         PARAMS.TOKEN  : preferenceHelper.getSessionToken(),
         PARAMS.TYPE : CONSTANT.TYPE_USER,
         PARAMS.PAYMENT_GATEWAY_TYPE : PaymentMethod.Payment_gateway_type,
         PARAMS.REFERENCE : reference,
         PARAMS.REQUIRED_PARAM : requiredParam,
         PARAMS.PIN : pin,
         PARAMS.OTP : otp,
         PARAMS.BIRTHDAY : "",
         PARAMS.ADDRESS : "",
         PARAMS.PHONE : "",
         PARAMS.TRIP_ID : self.param[PARAMS.TRIP_ID] as? String ?? ""]
        
        let alamoFire:AlamofireHelper = AlamofireHelper();
        alamoFire.getResponseFromURL(url: WebService.SEND_PAYSTACK_REQUIRED_DETAIL, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        { (response, error) -> (Void) in
            Utility.hideLoading()
            if Parser.isSuccess(response: response, withSuccessToast: false, andErrorToast: false)
            {
                dialog.removeFromSuperview()
                Utility.hideLoading()
                //success
                if self.onSuccessPayment != nil {
                    self.onSuccessPayment!()
                }
            }else{
                dialog.removeFromSuperview()
                if (response[PARAMS.REQUIRED_PARAM] as? String)?.count ?? "".count > 0{
                    self.openPaystackPinVerificationDialog(requiredParam: response[PARAMS.REQUIRED_PARAM] as? String ?? "", reference: response["reference"] as? String ?? "")
                }else{
                    Utility.showToast(message: response["error_message"] as? String ?? "")
                    self.openRetryPaymentDialog(message: (response["error"] as? String) ?? "")
                }
            }
        }
    }
    
    //MARK: Strip Paymetn Req
    private func stripPay(response: [String:Any]) {
        if let paymentMethod =  response["payment_method"] as? String {
            if let clientSecret: String = response["client_secret"] as? String {
                self.openStripePaymentMethod(paymentMethod: paymentMethod, clientSecret: clientSecret)
            }
        }
    }
    
    private func openStripePaymentMethod(paymentMethod:String, clientSecret: String) {
        StripeAPI.defaultPublishableKey = preferenceHelper.getStripeKey()
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        paymentIntentParams.paymentMethodId = paymentMethod
        
        //Submit the payment
        let paymentHandler = STPPaymentHandler.shared()
        paymentHandler.confirmPayment(paymentIntentParams, with: self) { [weak self] (status, paymentIntent, error) in
            guard let self = self else { return }
            switch (status) {
            case .failed:
                print("Payment failed = \(error?.localizedDescription ?? "")")
                self.openRetryPaymentDialog(message: (error?.localizedDescription) ?? "")
                //self.wsFailPayment()
                break
            case .canceled:
                self.openRetryPaymentDialog(message: (error?.localizedDescription) ?? "")
                //self.wsFailPayment()
                break
            case .succeeded:
                self.wsPayStripeIntentPayment() { (success) -> (Void) in}
                break
            @unknown default:
                fatalError()
                break
            }
        }
    }
    
    private func wsPayStripeIntentPayment(handler: @escaping (_ success:Bool) -> (Void)) {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] =  self.param[PARAMS.TRIP_ID] as? String ?? ""
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.PAY_STRIPE_INTENT_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if (error != nil) {
            } else {
                if Parser.isSuccess(response: response) {
                    //success
                    if self.onSuccessPayment != nil {
                        self.onSuccessPayment!()
                    }
                    return;
                } else {
                    handler(false)
                }
            }
        }
    }
    
    private func wsPaypalPayStripeIntentPayment(orderID: String, payerId: String) {
        
        Utility.showLoading()
        
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] =  self.param[PARAMS.TRIP_ID] as? String ?? ""
        dictParam[PARAMS.PAYMENT_GATEWAY_TYPE] = PaymentMethod.Paypal_ID
        dictParam[PARAMS.PAYMENT_INTENT_ID] = orderID
        dictParam[PARAMS.CARD_ID] = payerId
        dictParam[PARAMS.last_four] = "paypal"
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        
        afh.getResponseFromURL(url: WebService.PAY_STRIPE_INTENT_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if Parser.isSuccess(response: response) {
                if self.onSuccessPayment != nil {
                    self.onSuccessPayment!()
                }
            }
        }
    }
    
    private func openRetryPaymentDialog(message:String = "") {
        
        if self.removeDialog != nil {
            self.removeDialog!()
        }
        if PaymentMethod.Payment_gateway_type == PaymentMethod.Paypal_ID {
            let actYes = UIAlertAction(title: "TXT_PAY_AGAIN".localized, style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                self.wsGetStripeIntent(isRetry: true)
            }
            Common.alert("TXT_PAYMENT_FAILED".localized, message, [actYes])
        } else if PaymentMethod.Payment_gateway_type != PaymentMethod.PayU_ID{
            let actYes = UIAlertAction(title: "TXT_PAY_AGAIN".localized, style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                self.wsGetStripeIntent(isRetry: true)
            }
            let actNo = UIAlertAction(title: "TXT_ADD_CARD".localized, style: UIAlertAction.Style.cancel) {
                (act: UIAlertAction) in
                if let navigationVC: UINavigationController  = self.vc.revealViewController()?.mainViewController as? UINavigationController {
                    navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_PAYMENT, sender: self)
                }
            }
            
            var arrActions = [actYes, actNo]
            
            if CurrentTrip.shared.isCashModeAvailable == 1 {
                let cash = UIAlertAction(title: "txt_pay_by_cash".localized, style: UIAlertAction.Style.default) {
                    (act: UIAlertAction) in
                    self.wsAnotherPaymentMode()
                }
                arrActions.append(cash)
            } else {
                let wallet = UIAlertAction(title: "TXT_WALLET".localized, style: UIAlertAction.Style.default) {
                    (act: UIAlertAction) in
                    self.wsAnotherPaymentMode()
                }
                arrActions.append(wallet)
            }
            
            Common.alert("TXT_PAYMENT_FAILED".localized, message, arrActions)
        }else{
            let actYes = UIAlertAction(title: "TXT_PAY_AGAIN".localized, style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                self.wsGetStripeIntent(isRetry: true)
            }
            
            var arrActions = [actYes]
            
            if CurrentTrip.shared.isCashModeAvailable == 1 {
                let cash = UIAlertAction(title: "txt_pay_by_cash".localized, style: UIAlertAction.Style.cancel) {
                    (act: UIAlertAction) in
                    self.wsAnotherPaymentMode()
                }
                arrActions.append(cash)
            } else {
                let cash = UIAlertAction(title: "TXT_WALLET".localized, style: UIAlertAction.Style.default) {
                    (act: UIAlertAction) in
                    self.wsAnotherPaymentMode()
                }
                arrActions.append(cash)
            }
            Common.alert("TXT_PAYMENT_FAILED".localized, message, arrActions)
        }
    }
    
    private func wsAnotherPaymentMode() {
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] =  self.param[PARAMS.TRIP_ID] as? String ?? ""
        
        Utility.showLoading()
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.pay_by_other_payment_mode, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if (error != nil) {
            } else {
                if Parser.isSuccess(response: response, withSuccessToast: true) {
                    //success
                    if self.onSuccessPayment != nil {
                        self.onSuccessPayment!()
                    }
                }
            }
        }
    }

    deinit {
        printE("deinit StripPayment")
    }
}

extension SplitPaymentPay: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return vc
    }
}

extension SplitPaymentPay: PaypalHelperDelegate {
    func paymentSucess(capture: PaypalCaptureResponse) {
        self.wsPaypalPayStripeIntentPayment(orderID: capture.paymentId, payerId: capture.payerId)
    }
    func paymentCancel() {
        openRetryPaymentDialog()
    }
}

extension SplitPaymentPay: StripeApplePayHelperDelegate {
    func didComplete() {
        Utility.showLoading()
    }
    
    func didFailed(err: String) {
        openRetryPaymentDialog()
    }
    
}

class SplitPaymentDialogHelper: NSObject {
    
    var splitPaymentPay: SplitPaymentPay?
    
    func splitPayment(inVc: UIViewController) {
        if preferenceHelper.getUserId().isEmpty() || preferenceHelper.getUserId().count == 0 {
            return
        }
        let dialog = CustomDialogSplitPay.showCustomAlertDialog(title: "txt_split_payment".localized, message: "TXT_TOTAL".localized, titleLeftButton: "".localized, titleRightButton: "txt_pay".localized, currency: CurrentTrip.shared.splitPaymentReq.currency ?? "", amount: CurrentTrip.shared.splitPaymentReq.total ?? 0, tag: DialogTags.splitPaymentPayDailog)
        dialog.isHidden = false
        dialog.onClickLeftButton = {
            dialog.removeFromSuperview()
        }
        dialog.onClickRightButton = {
            var  dictParam : [String : Any] = [:]
            dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
            dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
            dictParam[PARAMS.TRIP_ID] =  CurrentTrip.shared.splitPaymentReq.trip_id ?? ""
            self.splitPaymentPay = SplitPaymentPay(param: dictParam, inVC: inVc)
            if let obj = self.splitPaymentPay {
                obj.startPayment()
                obj.onSuccessPayment = {
                    dialog.removeFromSuperview()
                    CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: [:])
                }
                obj.onFailPayment = {
                    dialog.removeFromSuperview()
                }
                obj.removeDialog = {
                    dialog.isHidden = true
                    //dialog.removeFromSuperview()
                }
            }
        }
    }
}

class SplitPaymentListner: NSObject {
    
    var socketHelper = SocketHelper()
    static let shared = SplitPaymentListner()
    
    override init() {
        super.init()
        socketHelper.connectSocket()
        
        socketHelper.socket?.on(clientEvent: .disconnect, callback: { data, act in
            print("SplitPaymentListner socket disconnect")
            SplitPaymentListner.shared.updateSplitNotification()
            SplitPaymentListner.shared.startLister()
        })
    }
    
    func startLister() {
        socketHelper.connectSocket()
        if preferenceHelper.getUserId().isEmpty {
            return
        }
        print("Listner SplitPayment Start Watching")
        let myid = "\(preferenceHelper.getUserId())"
        self.socketHelper.socket?.emit("room", myid)
        socketHelper.socket?.on(myid) {
            [weak self] (data, ack) in
            guard let `self` = self else {
                return
            }
            guard let response = data.first as? [String:Any] else {
                return
            }
            if response["type_id"] != nil {
                SplitPaymentListner.shared.updateSplitNotification()
            }
            printE("Soket SplitPaymentListner Response\(response)")
        }
    }
    
    func updateSplitNotification() {
        Utility.wsGetSetting { response, error in
            if Parser.parseAppSettingDetail(response: response) {
                SplitPaymentListner.shared.updateSplitPayment()
                //NotificationCenter.default.post(name: .updateSplitPaymentDialog, object: nil)
            }
        }
    }
    
    func updateSplitPayment() {
        if CurrentTrip.shared.splitPaymentReq._id?.count ?? 0 > 0 {
            if (CurrentTrip.shared.splitPaymentReq.payment_status == PAYMENT_STATUS.WAITING || CurrentTrip.shared.splitPaymentReq.payment_status == PAYMENT_STATUS.FAILED) && (CurrentTrip.shared.splitPaymentReq.payment_mode == PaymentMode.CARD || CurrentTrip.shared.splitPaymentReq.payment_mode == PaymentMode.APPLE_PAY) && CurrentTrip.shared.splitPaymentReq.is_trip_end == 1 {
                //PayDialog
                if let vc = APPDELEGATE.window?.rootViewController {
                    CurrentTrip.shared.splitPaymentDialogHelper?.splitPayment(inVc: vc)
                }
            } else {
                print("\(#file) updateSplitPayment")
                APPDELEGATE.showFriendReqDialog(name: (CurrentTrip.shared.splitPaymentReq.first_name ?? "") + " " + (CurrentTrip.shared.splitPaymentReq.last_name ?? ""), contact: (CurrentTrip.shared.splitPaymentReq.country_phone_code ?? "")+(CurrentTrip.shared.splitPaymentReq.phone ?? "")) { isAddNewCard in
                    if isAddNewCard {
                        let paymentVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentVC")
                        if let vc = APPDELEGATE.window?.rootViewController {
                            vc.present(paymentVC, animated: true)
                        }
                    }
                }
            }
        } else {
            CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: [:])
            if let vw = (APPDELEGATE.window?.viewWithTag(DialogTags.splitPaymentReqDailog)) as? CustomDialogSplitPaymentReq {
                vw.removeFromSuperview()
            }
        }
    }
}
