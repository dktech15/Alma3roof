//
//  PayStackVC.swift
//  Eber
//
//  Created by Elluminati on 16/08/21.
//  Copyright © 2021 Elluminati. All rights reserved.
//

import UIKit
import WebKit

class PayStackVC: BaseVC {
    @IBOutlet var webView: WKWebView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var htmlDataString: String!
    
    var isFromTrip = false
    var isFromNewPayment = false
    var isFromInvoicePopUP = false
    var isFromTipFeedBack = false
    
    let socketHelper:SocketHelper = SocketHelper.shared
    var gotPayUResopnse: ((_ message: String, _ isCallIntentAPI:Bool, _ showPaymentRetryDialog: Bool, _ isPaytabs: Bool) -> Void)?
    var didApiCalled: ((_ response: AllCardResponse) -> Void)?
    var iSFrom : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
    }
    
    func initialViewSetup()
    {
        lblTitle.text = "TXT_PAYMENTS".localized
        lblTitle.textColor = UIColor.themeTextColor
        lblTitle.font = FontHelper.font(size: FontSize.medium, type: .Bold)
//        btnBack.setupBackButton()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.isHidden = true
        self.socketHelper.connectSocket()
        
        if isFromInvoicePopUP {
            self.registerTripInvoiceSocket(id: preferenceHelper.getUserId())
            if let url = URL(string: htmlDataString) {
                let request = URLRequest(url: url)
                self.webView.load(request)
                   } else {
                       print("Invalid URL")
                   }
            Utility.hideLoading()
        } else if isFromTipFeedBack {

            self.registerTipInvoiceSocket(id: preferenceHelper.getUserId())
            if let url = URL(string: htmlDataString) {
                let request = URLRequest(url: url)
                self.webView.load(request)
                   } else {
                       print("Invalid URL")
                   }
            Utility.hideLoading()
        } else {
            if PaymentMethod.Payment_gateway_type == PaymentMethod.PayU_ID{
                self.view.addSubview(self.webView)
                self.view.bringSubviewToFront(self.webView)
                
                self.webView.loadHTMLString(self.htmlDataString, baseURL: Bundle.main.bundleURL)
                self.webView.navigationDelegate = self
                
                Utility.hideLoading()
            }else if  PaymentMethod.Payment_gateway_type == PaymentMethod.New_payment {
    //            self.socketHelper.connectSocket()
                if !self.socketHelper.isConnected() {
                    self.socketHelper.connectSocket()
                } else {
                    self.registerProviderSocket(id: preferenceHelper.getUserId())
                }
                
    //            self.view.addSubview(self.webView)
    //            self.view.bringSubviewToFront(self.webView)
    //            if let htmlString = self.htmlDataString {
    //                if let url = URL(string: htmlString) {
    //                    self.webView.load(URLRequest(url: url))
    //                    self.webView.navigationDelegate = self
    //                }
    //            }
                if let url = URL(string: htmlDataString) {
                           // Create a URLRequest and load it into the web view
                    let request = URLRequest(url: url)
                    self.webView.load(request)
                       } else {
                           // Handle invalid URL
                           print("Invalid URL")
                       }
                Utility.hideLoading()
            } else if PaymentMethod.Payment_gateway_type == PaymentMethod.PayTabs{
                self.view.addSubview(self.webView)
                self.view.bringSubviewToFront(self.webView)
                if let htmlString = self.htmlDataString {
                    if let url = URL(string: htmlString) {
                        self.webView.load(URLRequest(url: url))
                        self.webView.navigationDelegate = self
                    }
                }
                Utility.hideLoading()
            }
            else if PaymentMethod.Payment_gateway_type == PaymentMethod.PayStack_ID{
                wsGetStripeIntentPayStack()
            }else if PaymentMethod.Payment_gateway_type == PaymentMethod.RazorPay{
                self.view.addSubview(self.webView)
                self.view.bringSubviewToFront(self.webView)
                
                self.webView.loadHTMLString(self.htmlDataString, baseURL: Bundle.main.bundleURL)
                self.webView.navigationDelegate = self
                
                Utility.hideLoading()
            }else{
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        socketHelper.disConnectSocket()
    }
    
    @IBAction func onClickBtnMenu(_ sender: Any) {
        if !isFromTrip {
            self.gotPayUResopnse?("Payment Failed.", false, true, false)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func registerProviderSocket(id:String) {
        let myUserId = "'tdsp_wallet_\(id)'"
        self.socketHelper.socket?.emit("room", myUserId)
        self.socketHelper.socket?.on(myUserId) {
            [weak self] (data, ack) in
            guard let `self` = self else { return }
            guard let response = data.first as? [String:Any] else
            { return }
            self.navigationController?.popViewController(animated: true)
            print("Soket Response\(response)")
        
        }
    }
    
    func registerTripInvoiceSocket(id:String) {
        let myUserId = "'tdsp_trip_\(id)'"
        self.socketHelper.socket?.emit("room", myUserId)
        self.socketHelper.socket?.on(myUserId) {
            [weak self] (data, ack) in
            guard let `self` = self else { return }
            guard let response = data.first as? [String:Any] else
            { return }
            self.navigationController?.popViewController(animated: true)
            print("Soket Response\(response)")
        
        }
    }
    func registerTipInvoiceSocket(id:String) {
        let myUserId = "'tdsp_tip_\(id)'"
        self.socketHelper.socket?.emit("room", myUserId)
        self.socketHelper.socket?.on(myUserId) {
            [weak self] (data, ack) in
            guard let `self` = self else { return }
            guard let response = data.first as? [String:Any] else
            { return }
            self.navigationController?.popViewController(animated: true)
            print("Soket Response\(response)")
        
        }
    }
    
}

extension PayStackVC: WKNavigationDelegate {
    
    //MARK: - Get Stripe Intent
    func wsGetStripeIntentPayStack()
    {
        Utility.showLoading()
        let dictParam : [String : Any] =
        [PARAMS.USER_ID      : preferenceHelper.getUserId()  ,
         PARAMS.TOKEN  : preferenceHelper.getSessionToken(),
         PARAMS.TYPE : CONSTANT.TYPE_USER,
         PARAMS.PAYMENT_GATEWAY_TYPE : PaymentMethod.Payment_gateway_type ]
        
        let alamoFire:AlamofireHelper = AlamofireHelper();
        alamoFire.getResponseFromURL(url: WebService.GET_STRIPE_ADD_CARD_INTENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        {
            (response, error) -> (Void) in
            if Parser.isSuccess(response: response) {
                Utility.hideLoading()
                print(response["authorization_url"] as? String ?? "")
                let pstkUrl = response["authorization_url"] as? String
                let urlRequest = URLRequest.init(url: URL.init(string: pstkUrl!)!)
                self.view.addSubview(self.webView)
                self.view.bringSubviewToFront(self.webView)
                DispatchQueue.main.async {
                    self.webView.navigationDelegate = self
                    self.webView.load(urlRequest)
                }
            } else {
                Utility.hideLoading()
            }
        }
    }
 
    //This is helper to get url params
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    // This is a WKNavigationDelegate func we can use to handle redirection
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void))  {
        if let url = navigationAction.request.url {
            
            if PaymentMethod.Payment_gateway_type == PaymentMethod.PayStack_ID{
                if url.absoluteString.contains("add_card_success"){
                    self.navigationController?.popViewController(animated: true)
                    decisionHandler(.cancel)
                }
                else{
                    decisionHandler(.allow)
                }
            }else if PaymentMethod.Payment_gateway_type == PaymentMethod.PayU_ID{
                if url.absoluteString.contains("\(WebService.PAYMENT_BASE_URL)payments/payments"){
                    if self.iSFrom == "feedback"{
                        self.gotPayUResopnse?("", true, false, false)
                    }else{
                        self.gotPayUResopnse?("MSG_CODE_91".localized, true, true, false)
                    }
                    self.navigationController?.popViewController(animated: true)
                    decisionHandler(.cancel)
                }else if url.absoluteString.contains("\(WebService.PAYMENT_BASE_URL)payments/fail_payment"){
                    self.gotPayUResopnse?("TXT_PAYMENT_FAILED".localized, true, false, false)
                    self.navigationController?.popViewController(animated: true)
                    decisionHandler(.cancel)
                }
                else if url.absoluteString.contains("\(WebService.PAYMENT_BASE_URL)fail_stripe_intent_payment"){
                    if self.iSFrom == "feedback"{
                        self.gotPayUResopnse?("Tip Payment Failed Dialog.", false, false, false)
                    }else{
                        self.gotPayUResopnse?("TXT_PAYMENT_FAILED".localized, false, true, false)
                    }
                    self.navigationController?.popViewController(animated: true)
                    decisionHandler(.cancel)
                }
                else{
                    decisionHandler(.allow)
                }
            }else if PaymentMethod.Payment_gateway_type == PaymentMethod.RazorPay{
                if url.absoluteString.contains("add_card_success") {
                    decisionHandler(.cancel)
                    self.gotPayUResopnse?("".localized, true, false, true)
                    self.navigationController?.popViewController(animated: true)
                } else if url.absoluteString.contains("\(WebService.PAYMENT_BASE_URL)payments/payment_fail"){
                    decisionHandler(.cancel)
                    self.gotPayUResopnse?("".localized, false, true, true)
                    self.navigationController?.popViewController(animated: true)
                } else if url.absoluteString.contains("\(WebService.PAYMENT_BASE_URL)payments/fail_stripe_intent_payment"){
                    decisionHandler(.cancel)
                    self.gotPayUResopnse?("".localized, false, false, true)
                    self.navigationController?.popViewController(animated: true)
                } else if url.absoluteString.contains("\(WebService.PAYMENT_BASE_URL)payments/success_payment"){
                    if self.iSFrom == "feedback"{
                        self.gotPayUResopnse?("", true, false, true)
                    }else if self.iSFrom == "split_pay" {
                        CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: [:])
                        self.gotPayUResopnse?("".localized, true, false, true)
                    } else{
                        self.gotPayUResopnse?("".localized, true, false, true)
                    }
                    self.navigationController?.popViewController(animated: true)
                    decisionHandler(.cancel)
                }else{
                    decisionHandler(.allow)
                }
            }else if PaymentMethod.Payment_gateway_type == PaymentMethod.PayTabs{
                print("2reference url******************* \(url)")

                if url.absoluteString.contains("add_card_success") {
                    decisionHandler(.cancel)
                    self.gotPayUResopnse?("".localized, true, false, true)
                    self.navigationController?.popViewController(animated: true)
                } else if url.absoluteString.contains("\(WebService.PAYMENT_BASE_URL)payments/payment_fail"){
                    decisionHandler(.cancel)
                    self.gotPayUResopnse?("".localized, false, true, true)
                    self.navigationController?.popViewController(animated: true)
                } else if url.absoluteString.contains("\(WebService.PAYMENT_BASE_URL)payments/fail_stripe_intent_payment"){
                    decisionHandler(.cancel)
                    self.gotPayUResopnse?("".localized, false, false, true)
                    self.navigationController?.popViewController(animated: true)
                } else if url.absoluteString.contains("\(WebService.PAYMENT_BASE_URL)payments/success_payment"){
                    if self.iSFrom == "feedback"{
                        self.gotPayUResopnse?("", true, false, true)
                    }else if self.iSFrom == "split_pay" {
                        CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: [:])
                        self.gotPayUResopnse?("".localized, true, false, true)
                    } else{
                        self.gotPayUResopnse?("".localized, true, false, true)
                    }
                    self.navigationController?.popViewController(animated: true)
                    decisionHandler(.cancel)
                }else{
                    decisionHandler(.allow)
                }
            }else{
                decisionHandler(.cancel)
            }
        }
    }
}
