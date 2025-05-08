//
//  FeedbackVC.swift
//  Edelivery Provider
//
//  Created by Elluminati iMac on 25/04/17.
//  Copyright © 2017 Elluminati iMac. All rights reserved.
//

import UIKit
import Stripe

class FeedbackVC: BaseVC, RatingViewDelegate, UITextViewDelegate{

    @IBOutlet var viewForFavourite: UIView!
    @IBOutlet var lblFavourite: UILabel!
    @IBOutlet var lblIconForFavourite: UILabel!
    @IBOutlet var imgIconForFavourite: UIImageView!
    @IBOutlet var btnFavourite: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var txtComment: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblDistanceValue: UILabel!
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var lblTotalTimeValue: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var lblIconETA: UILabel!
    @IBOutlet weak var imgIconETA: UIImageView!
    @IBOutlet weak var lblIconDistance: UILabel!
    @IBOutlet weak var imgIconDistance: UIImageView!
    @IBOutlet weak var lblDivider: UIView!
    @IBOutlet weak var vwForTip: UIView!
    @IBOutlet weak var txtTipAmount: ACFloatingTextfield!
    @IBOutlet weak var stkvwTip: UIStackView!
    @IBOutlet weak var btnTip1: UIButton!
    @IBOutlet weak var btnTip2: UIButton!
    @IBOutlet weak var btnTip3: UIButton!
    @IBOutlet weak var btnTip4: UIButton!
    @IBOutlet weak var btnTip5: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblTiptoDriver: UILabel!
    
    var tripDetail:InvoiceTrip = InvoiceTrip.init(fromDictionary: [:])
    var applePay: StripeApplePayHelper?
    var isFromHistory:Bool = false
    var providerDetail:InvoiceProvider = InvoiceProvider.init(fromDictionary: [:])
    let toolBar = UIToolbar()
    var rate:Float =  0.0
    var payStackVC:PayStackVC!
    var invoiceResponse: InvoiceResponse?
    var socketHelper:SocketHelper = SocketHelper.shared

    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLocalization()
        self.setupRevealViewController()
        self.lblTiptoDriver.text = "TXT_GIVE_TIP_TO_DRIVER".localized
        self.lblTiptoDriver.textColor = UIColor.themeTextColor
        self.lblTiptoDriver.font = FontHelper.font(size: FontSize.large, type: .Regular)
        self.wsGetInvoice()
        self.updateUIForFavouriteDriver(isFavourite: CurrentTrip.shared.tripStaus.trip.isFavouriteProvider)
//        btnMenu.setTitle(FontAsset.icon_menu, for: .normal)
//        btnMenu.setUpTopBarButton()
        self.startTripListner()
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        imgProfilePic.setRound()
        navigationView.navigationShadow()
    }

    //MARK: - Set localized layout
    func setLocalization()
    {
        self.createToolbar(textview: txtComment)
        rate = 0.0
        // Required float rating view params
        
        // Optional params
        self.ratingView.delegate = self
        self.ratingView.contentMode = UIView.ContentMode.scaleAspectFit
        self.ratingView.maxRating = 5
        self.ratingView.minRating = 1
        self.ratingView.rating = 0.0
        self.ratingView.editable = true
        self.ratingView.minImageSize = CGSize.init(width: 20, height: 20)

        txtComment.text = ""
        txtComment.placeholder = "TXT_COMMENT_PLACEHOLDER".localized

        // COLORS
        lblName.textColor = UIColor.themeTextColor
        txtComment.textColor = UIColor.themeLightTextColor
        txtComment.tintColor = UIColor.themeLightTextColor
        lblDivider.backgroundColor = UIColor.themeTextColor

        //LOCALIZED
        self.title = "TXT_FEEDBACK".localized
        self.lblTitle.text = "TXT_FEEDBACK".localized
        self.lblTitle.font = FontHelper.font(size: FontSize.medium, type: FontType.Bold)
        self.lblTitle.textColor = UIColor.themeTextColor

        txtComment.delegate = self
        /*Set Font*/
        lblName.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        txtComment.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)

        lblDistance.text = "TXT_DISTANCE".localized
        lblDistance.textColor = UIColor.themeLightTextColor
        lblDistance.font = FontHelper.font(size: FontSize.small, type: FontType.Bold)

        lblComments.text = "TXT_COMMENTS".localized
        lblComments.textColor = UIColor.themeLightTextColor
        lblComments.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        
        lblTotalTime.text = "TXT_TIME".localized
        lblTotalTime.textColor = UIColor.themeLightTextColor
        lblTotalTime.font = FontHelper.font(size: FontSize.small, type: FontType.Bold)
        
        lblDistanceValue.textColor = UIColor.themeTextColor
        lblDistanceValue.font = FontHelper.font(size: FontSize.small, type: FontType.Bold)

        lblTotalTimeValue.textColor = UIColor.themeTextColor
        lblTotalTimeValue.font = FontHelper.font(size: FontSize.small, type: FontType.Bold)

        btnCancel.setTitleColor(UIColor.themeLightTextColor, for: UIControl.State.normal)
        btnCancel.titleLabel?.font =  FontHelper.font(size: FontSize.small, type:FontType.Regular)
        btnCancel.setTitle("TXT_CANCEL".localizedCapitalized, for: .normal)

        btnSubmit.setTitleColor(UIColor.themeButtonTitleColor, for: UIControl.State.normal)
        btnSubmit.backgroundColor = UIColor.themeButtonBackgroundColor
        btnSubmit.setupButton()
        btnSubmit.setTitle("TXT_SUBMIT".localizedCapitalized, for: UIControl.State.normal)
        btnSubmit.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)

        imgIconETA.tintColor = UIColor.themeImageColor
        
//        lblIconETA.text = FontAsset.icon_time
//        lblIconDistance.text = FontAsset.icon_distance
//        lblIconForFavourite.text = FontAsset.icon_favourite
        imgIconDistance.tintColor = UIColor.themeImageColor 
//        lblIconDistance.setForIcon()
//        lblIconETA.setForIcon()
//        lblIconForFavourite.setForIcon()
//        lblIconForFavourite.textColor = UIColor.themeButtonTitleColor
        
        imgIconForFavourite.tintColor = UIColor.themeImageColor
        viewForFavourite.backgroundColor = UIColor.themeButtonBackgroundColor
        viewForFavourite.setRound(withBorderColor: UIColor.clear, andCornerRadious: 20, borderWidth: 1.0)
        lblFavourite.textColor = UIColor.themeButtonTitleColor
        lblFavourite.font = FontHelper.font(size: FontSize.regular, type: .Regular)
        lblFavourite.text = "TXT_FAVOURITE".localized
        
        self.btnTip1.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        self.btnTip1.backgroundColor = UIColor.themeButtonBackgroundColor
        
        self.btnTip2.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        self.btnTip2.backgroundColor = UIColor.themeButtonBackgroundColor
        
        self.btnTip3.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        self.btnTip3.backgroundColor = UIColor.themeButtonBackgroundColor

        self.btnTip4.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        self.btnTip4.backgroundColor = UIColor.themeButtonBackgroundColor
        
        self.btnTip5.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        self.btnTip5.backgroundColor = UIColor.themeButtonBackgroundColor

        payStackVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PayStackVC") as? PayStackVC
        payStackVC.gotPayUResopnse = { [unowned self] (_ message: String, _ isCallIntentAPI:Bool, _ showPaymentRetryDialog:Bool, _ ispaytabs: Bool) -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                Utility.hideLoading()
                if isCallIntentAPI {
                    self.wsRateToProvider()
                }
            }
        }
    }

    func setData() {
        lblName.text = providerDetail.first_name + " " + providerDetail.last_name

        imgProfilePic.downloadedFrom(link: providerDetail.picture)
        self.lblDistanceValue.text =  tripDetail.totalDistance.toString(places: 2) + " " + Utility.getDistanceUnit(unit: tripDetail.unit)
        self.lblTotalTimeValue.text = String(format:"%.2f%@", tripDetail.totalTime, MeasureUnit.MINUTES)

        self.btnTip1.setTitle(self.tripDetail.currency + " " + "5", for: .normal)
        self.btnTip2.setTitle(self.tripDetail.currency + " " + "10", for: .normal)
        self.btnTip3.setTitle(self.tripDetail.currency + " " + "15", for: .normal)
        self.btnTip4.setTitle(self.tripDetail.currency + " " + "20", for: .normal)
        self.btnTip5.setTitle(self.tripDetail.currency + " " + "25", for: .normal)
        self.txtTipAmount.text = ""
        if self.tripDetail.isTip && self.tripDetail.paymentMode != PaymentMode.CASH {
            self.vwForTip.isHidden = false
        } else {
            self.vwForTip.isHidden = true
        }
    }

    //MARK: - Textview Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {}

    @IBAction func btnTip1Tapped(_ sender: Any) {
        self.txtTipAmount.text = "5"
    }
    
    @IBAction func btnTip2Tapped(_ sender: Any) {
        self.txtTipAmount.text = "10"
    }
    
    @IBAction func btnTip3Tapped(_ sender: Any) {
        self.txtTipAmount.text = "15"
    }
    
    @IBAction func btnTip4Tapped(_ sender: Any) {
        self.txtTipAmount.text = "20"
    }
    
    @IBAction func btnTip5Tapped(_ sender: Any) {
        self.txtTipAmount.text = "25"
    }

    @IBAction func onClickBtnCancel(_ sender: Any) {
        self.stopTripListner()
        if self.isFromHistory
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            APPDELEGATE.gotoMap()
        }
    }

    @IBAction func onClickBtnFavourite(_ sender: Any) {
        if btnFavourite.isSelected
        {
            self.wsRemoveFromFavouriteProvider()
        }
        else
        {
            self.wsAddToFavouriteProvider()
        }
    }

    //MARK: - Create Toolbar
    func createToolbar(textview : UITextView) {
        toolBar.barStyle = UIBarStyle.black
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.white
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title: "TXT_DONE".localized,
            style: .plain,
            target: self,
            action: #selector(doneTextView(sender:))
        )
        doneButton.tag = textview.tag
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textview.inputAccessoryView = toolBar
    }

    @objc func doneTextView(sender : UIBarButtonItem) {
        txtComment.resignFirstResponder()
    }

    //MARK: - Button action methods
    @IBAction func onClickSubmit(_ sender: UIButton)
    {
        if rate != 0.0 {
            if txtTipAmount.text!.isEmpty() || txtTipAmount.text!.toDouble() <= 0.0 {
                wsRateToProvider()
            } else {
                if tripDetail.paymentMode == PaymentMode.CARD {
                    self.wsGetStripeIntent(amount: txtTipAmount.text!.toDouble())
                } else if tripDetail.paymentMode == PaymentMode.APPLE_PAY {
                    let amount = Double(txtTipAmount.text!) ?? 0
                    if StripeApplePayHelper.isApplePayAvailable() && (amount > 0) {
                        self.wsGetStripeApplePayIntent()
                    } else {
                        self.wsGetStripeIntent(amount: txtTipAmount.text!.toDouble())
                    }
                } else {
                    wsRateToProvider()
                }
            }
        }
        else {
            Utility.showToast(message: "VALIDATION_MSG_RATE_PROVIDER".localized)
        }
    }
    
    func RatingView(_ ratingView: RatingView, didUpdate rating: Float) {
        rate = rating
    }

    //MARK: - Web Service Calls
    func wsRateToProvider() {
        Utility.showLoading()
        var review:String = txtComment.text ?? ""
        if review.compare("TXT_COMMENT_PLACEHOLDER".localized) == .orderedSame {
            review = ""
        }
        
        let dictParam: Dictionary<String,Any> =
            [PARAMS.USER_ID:preferenceHelper.getUserId(),
             PARAMS.TOKEN:preferenceHelper.getSessionToken(),
             PARAMS.TRIP_ID:tripDetail.id!,
             PARAMS.REVIEW:review,
             PARAMS.RATING:rate
        ];

        let afn:AlamofireHelper = AlamofireHelper.init();
        afn.getResponseFromURL(url: WebService.RATE_PROVIDER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        { [weak self] (response, error) -> (Void) in
            guard let self = self else { return }
            Utility.hideLoading()
            if (Parser.isSuccess(response: response)) {
                self.stopTripListner()
                if self.isFromHistory {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    APPDELEGATE.gotoMap()
                }
                return
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func updateUIForFavouriteDriver(isFavourite: Bool) {
        btnFavourite.isSelected = isFavourite
        if isFavourite {
            lblIconForFavourite.textColor = UIColor.themeErrorTextColor
            imgIconForFavourite.tintColor = UIColor.themeErrorTextColor
        }
        else {
            lblIconForFavourite.textColor = UIColor.themeButtonTitleColor
            imgIconForFavourite.tintColor = UIColor.themeButtonTitleColor
        }
    }
}

extension FeedbackVC {

    func wsAddToFavouriteProvider() {
        Utility.showLoading()
        let dictParam: Dictionary<String,Any> =
            [PARAMS.USER_ID:preferenceHelper.getUserId(),
             PARAMS.TOKEN:preferenceHelper.getSessionToken(),
             PARAMS.PROVIDER_ID:tripDetail.providerId!,
        ];
        let afn:AlamofireHelper = AlamofireHelper.init();
        afn.getResponseFromURL(url: WebService.ADD_FAVOURITE_DRIVER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        { (response, error) -> (Void) in
            Utility.hideLoading()
            if (Parser.isSuccess(response: response)) {
                self.updateUIForFavouriteDriver(isFavourite: true)
            }
        }
    }
    
    func wsRemoveFromFavouriteProvider() {
        Utility.showLoading()
        let dictParam: Dictionary<String,Any> =
            [PARAMS.USER_ID:preferenceHelper.getUserId(),
             PARAMS.TOKEN:preferenceHelper.getSessionToken(),
             PARAMS.PROVIDER_ID:tripDetail.providerId!,
        ];
        let afn:AlamofireHelper = AlamofireHelper.init();
        afn.getResponseFromURL(url: WebService.REMOVE_FAVOURITE_DRIVER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        { (response, error) -> (Void) in
            Utility.hideLoading()
            if (Parser.isSuccess(response: response)) {
               self.updateUIForFavouriteDriver(isFavourite: false)
            }
        }
    }
}

extension FeedbackVC: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}

extension FeedbackVC {

    func wsGetInvoice()
    {
        Utility.showLoading()

        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache"
        ]

        let dictParam:[String:String] =
            [PARAMS.TOKEN : preferenceHelper.getSessionToken(),
             PARAMS.USER_ID : preferenceHelper.getUserId(),
             PARAMS.TRIP_ID : CurrentTrip.shared.tripId]

        let postData = try! JSONSerialization.data(withJSONObject: dictParam, options: [])

        let urlString:String = WebService.BASE_URL + WebService.GET_INVOICE

        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            print("\(#function)")
            if (error != nil)
            {
                Utility.hideLoading()
            }
            else
            {
                Utility.hideLoading()
                guard let data = data, error == nil else {
                    print("\(#function) error=\(String(describing: error))")
                    return
                }

                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("\(#function) statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("\(#function) response = \(String(describing: response))")
                }

                do {
                    print("\(#function) Data=\(data)")
                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    {
                        print("\(#function) Dictionary=\(convertedJsonIntoDict)")
                        if Parser.isSuccess(response: convertedJsonIntoDict)
                        {
                            OperationQueue.main.addOperation({
                                let invoiceResponse = InvoiceResponse.init(fromDictionary: convertedJsonIntoDict)
                                self.invoiceResponse = invoiceResponse
                                self.tripDetail = invoiceResponse.trip
                                self.providerDetail = invoiceResponse.providerDetail

                                PaymentMethod.Payment_gateway_type = "\(invoiceResponse.trip.payment_gateway_type!)"

                                self.setData()
                                Utility.hideLoading()
                            })
                        }

                    }
                } catch let error as NSError {
                    print()
                    print("\(#function) Error=\(error.localizedDescription)")
                }
            }
        })
        dataTask.resume()
    }

    /*
    func wsGetStripeIntentApplePay(paymentMethod:String, amount:Double, handler: @escaping (_ success:Bool, _ clientSecret:String, _ paymentMethod:String, _ errorMsg:String) -> (Void))
    {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TYPE] = CONSTANT.TYPE_USER
        dictParam[PARAMS.PAYMENT_METHOD] = paymentMethod
        dictParam[PARAMS.TRIP_ID] = CurrentTrip.shared.tripId
        dictParam[PARAMS.AMOUNT] = amount
        dictParam[PARAMS.IS_PAYMENT_FOR_TIP] = true

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_STRIPE_PAYMENT_INTENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response:response, andErrorToast:false) {
                        if let paymentMethod =  response["payment_method"] as? String {
                            if let clientSecret: String = response["client_secret"] as? String {
                                handler(true, clientSecret, paymentMethod, "")
                            }
                        } else {}
                } else {
                    Utility.hideLoading()
                    handler(false, "", "", response["error"] as? String ?? "")
                }
            }
        }
    }*/

    func wsGetStripeIntent(amount:Double) {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TYPE] = CONSTANT.TYPE_USER
        dictParam[PARAMS.AMOUNT] =  amount
        dictParam[PARAMS.TRIP_ID] = self.tripDetail.id
        dictParam[PARAMS.IS_PAYMENT_FOR_TIP] = true
        dictParam[PARAMS.is_tip] = true

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_STRIPE_PAYMENT_INTENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if let value = response["payment_gateway_type"] as? Int {
                    PaymentMethod.Payment_gateway_type = "\(value)"
                }
                
                if PaymentMethod.Payment_gateway_type == PaymentMethod.New_payment {
                    if Parser.isSuccess(response: response, andErrorToast:false) {
                        self.payStackVC.htmlDataString = response["url"] as? String ?? ""
                        self.payStackVC.iSFrom = "feedback"
                        self.payStackVC.isFromTipFeedBack = true
                        self.navigationController?.pushViewController(self.payStackVC, animated: true)
                    }else{
                        self.openRetryPaymentDialog()
                    }
                    
                } else if PaymentMethod.Payment_gateway_type == PaymentMethod.Stripe_ID{//stripe
                    if Parser.isSuccess(response: response, andErrorToast:false) {
                        if let paymentMethod =  response["payment_method"] as? String {
                            if let clientSecret: String = response["client_secret"] as? String {
                                self.openStripePaymentMethod(paymentMethod: paymentMethod, clientSecret: clientSecret)
                            }
                        } else {
                            Utility.hideLoading()
                        }
                    } else {
                        Utility.hideLoading()
                        Utility.showToast(message: response["error"] as? String ?? "")
                    }
                }else if PaymentMethod.Payment_gateway_type == PaymentMethod.PayStack_ID{
                    if Parser.isSuccess(response: response, andErrorToast:false) {
                        self.wsRateToProvider()
                    } else {
                        Utility.hideLoading()
                        if (response[PARAMS.REQUIRED_PARAM] as? String)?.count ?? "".count > 0{
                            self.openPaystackPinVerificationDialog(requiredParam: response[PARAMS.REQUIRED_PARAM] as? String ?? "", reference: response["reference"] as? String ?? "")
                        }else{
                            Utility.showToast(message: response["error_message"] as? String ?? "")
                            self.openRetryPaymentDialog(message: response["error_message"] as? String ?? "")
                        }
                    }
                }else if PaymentMethod.Payment_gateway_type == PaymentMethod.PayU_ID{
                    Utility.hideLoading()
                    if Parser.isSuccess(response: response, andErrorToast:false) {
                        self.payStackVC.htmlDataString = response["html_form"] as? String ?? ""
                        self.payStackVC.iSFrom = "feedback"
                        self.navigationController?.pushViewController(self.payStackVC, animated: true)
                    }else{
                        self.openRetryPaymentDialog()
                    }
                }else if PaymentMethod.Payment_gateway_type == PaymentMethod.RazorPay{
                    Utility.hideLoading()
                    if Parser.isSuccess(response: response, andErrorToast:false) {
                        self.payStackVC.htmlDataString = response["html_form"] as? String ?? ""
                        self.payStackVC.iSFrom = "feedback"
                        self.navigationController?.pushViewController(self.payStackVC, animated: true)
                    }else{
                        self.openRetryPaymentDialog()
                    }
                }else if PaymentMethod.Payment_gateway_type == PaymentMethod.Paypal_ID{
                    Utility.hideLoading()
                    if Parser.isSuccess(response: response, andErrorToast:false) {
                        let paypal = PaypalHelper.init(currrencyCode: self.invoiceResponse?.trip.currencycode ?? "", amount: "\(self.invoiceResponse?.trip.total ?? 0)")
                        paypal.delegate = self
                    }else{
                        self.openRetryPaymentDialog()
                    }
                } else if PaymentMethod.Payment_gateway_type == PaymentMethod.PayTabs {
                    
                    Utility.hideLoading()
                    if Parser.isSuccess(response: response, andErrorToast:false) {
                        self.payStackVC.htmlDataString = response["authorization_url"] as? String ?? ""
                        self.payStackVC.iSFrom = "feedback"
                        self.navigationController?.pushViewController(self.payStackVC, animated: true)
                    }else{
                        self.openRetryPaymentDialog()
                    }
                   
               } else if PaymentMethod.Payment_gateway_type == PaymentMethod.New_payment {
                   self.payStackVC.htmlDataString = response["url"] as? String ?? ""
                   self.payStackVC.isFromTipFeedBack = true
                   self.navigationController?.pushViewController(self.payStackVC, animated: true)
                   
               }
            }
        }
    }

    func openPaystackPinVerificationDialog(requiredParam:String,reference:String)
    {
        self.view.endEditing(true)

        switch requiredParam {
            case PaymentMethod.VerificationParameter.SEND_PIN:
                let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_PIN".localized, message: "EG_1234".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_PIN".localized, isHideBackButton: false)

                dialogForPromo.onClickLeftButton =
                    { [unowned dialogForPromo] in
                        dialogForPromo.removeFromSuperview();
                    }

                dialogForPromo.onClickRightButton =
                    { [unowned self, unowned dialogForPromo] (text:String) in

                        if (text.count <  1)
                        {
                            Utility.showToast(message: "PLEASE_ENTER_PIN".localized)
                        }
                        else
                        {
                            wsSendPaystackRequiredDetail(requiredParam: requiredParam, reference: reference,pin: text,otp : "", phone: "", dialog: dialogForPromo)
                        }
                    }
            case PaymentMethod.VerificationParameter.SEND_OTP:
                let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_OTP".localized, message: "EG_123456".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_OTP".localized,isHideBackButton: false)

                dialogForPromo.onClickLeftButton =
                    { [unowned dialogForPromo] in
                        dialogForPromo.removeFromSuperview();
                    }

                dialogForPromo.onClickRightButton =
                    { [unowned self, unowned dialogForPromo] (text:String) in
                        if (text.count <  1)
                        {
                            Utility.showToast(message: "PLEASE_ENTER_OTP".localized)
                        }
                        else
                        {
                            wsSendPaystackRequiredDetail(requiredParam: requiredParam, reference: reference,pin: "",otp : text, phone: "", dialog: dialogForPromo)
                        }
                    }
            case PaymentMethod.VerificationParameter.SEND_PHONE:
                let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_PHONE_NUMBER".localized, message: "MINIMUM_10_DIGITS".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_PHONE_NUMBER".localized,isHideBackButton: false)

                dialogForPromo.onClickLeftButton =
                    { [unowned dialogForPromo] in
                        dialogForPromo.removeFromSuperview();
                    }

                dialogForPromo.onClickRightButton =
                    { [unowned self, unowned dialogForPromo] (text:String) in
                        if (text.count <  1)
                        {
                            Utility.showToast(message: "PLEASE_ENTER_PHONE_NO".localized)
                        }
                        else
                        {
                            wsSendPaystackRequiredDetail(requiredParam: requiredParam, reference: reference,pin: "",otp : "",phone:text, dialog: dialogForPromo)
                        }
                    }
            case PaymentMethod.VerificationParameter.SEND_BIRTHDAY:
                let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_BIRTHDATE".localized, message: "EG_DD-MM-YYYY".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_BIRTHDATE".localized,isHideBackButton: false, isShowBirthdayTextfield: true)

                dialogForPromo.onClickLeftButton =
                    { [unowned dialogForPromo] in
                        dialogForPromo.removeFromSuperview();
                    }

                dialogForPromo.onClickRightButton =
                    { [unowned self, unowned dialogForPromo] (text:String) in
                        if (text.count <  1)
                        {
                            Utility.showToast(message: "PLEASE_ENTER_BIRTHDATE".localized)
                        }
                        else
                        {
                            wsSendPaystackRequiredDetail(requiredParam: requiredParam, reference: reference,pin: "",otp : "",phone:text, dialog: dialogForPromo)
                        }
                    }
            case PaymentMethod.VerificationParameter.SEND_ADDRESS:
                print(PaymentMethod.VerificationParameter.SEND_ADDRESS)
            default:
                break
        }
    }


    func wsSendPaystackRequiredDetail(requiredParam:String,reference:String,pin:String,otp:String,phone:String,dialog:CustomPinVerificationDialog)
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
             PARAMS.TRIP_ID : self.tripDetail.id!,
             PARAMS.IS_PAYMENT_FOR_TIP : true]

        print(dictParam)
        let alamoFire:AlamofireHelper = AlamofireHelper();
        alamoFire.getResponseFromURL(url: WebService.SEND_PAYSTACK_REQUIRED_DETAIL, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        { (response, error) -> (Void) in
            Utility.hideLoading()
            if Parser.isSuccess(response: response, withSuccessToast: false, andErrorToast: false)
            {
                dialog.removeFromSuperview()
                Utility.hideLoading()
                self.wsRateToProvider()
            }else{
                dialog.removeFromSuperview()
                if (response[PARAMS.REQUIRED_PARAM] as? String)?.count ?? "".count > 0{
                    self.openPaystackPinVerificationDialog(requiredParam: response[PARAMS.REQUIRED_PARAM] as? String ?? "", reference: response["reference"] as? String ?? "")
                }else{
                    if (response["error_code"] as? String)?.count ?? "".count > 0{
                        if (response["error_message"] as? String ?? "").count > 0{
                            Utility.showToast(message: (response["error_message"] as? String ?? "").localized)
                        }else{
                            Utility.showToast(message: "ERROR_CODE_\(response["error_code"] as? String ?? "")".localized)
                        }
                    }
                }
            }
        }
    }

    func wsPayTipPayment(handler: @escaping (_ success:Bool) -> (Void)) {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TYPE] = CONSTANT.TYPE_USER
        dictParam[PARAMS.TRIP_ID] = self.tripDetail.id
        
        if PaymentMethod.Payment_gateway_type == PaymentMethod.Paypal_ID {
            dictParam[PARAMS.AMOUNT] = txtTipAmount.text!
        }

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.PAY_TIP_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response: response) {
                    handler(true)
                } else {
                    Utility.hideLoading()
                    handler(false)
                }
            }
        }
    }
    
    func wsPaypalPayTipPayment(orderID: String, payerId: String) {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TYPE] = CONSTANT.TYPE_USER
        dictParam[PARAMS.TRIP_ID] = self.tripDetail.id
        
        if PaymentMethod.Payment_gateway_type == PaymentMethod.Paypal_ID {
            dictParam[PARAMS.AMOUNT] = txtTipAmount.text!
            dictParam[PARAMS.PAYMENT_GATEWAY_TYPE] = PaymentMethod.Paypal_ID
            dictParam[PARAMS.PAYMENT_INTENT_ID] = orderID
            dictParam[PARAMS.CARD_ID] = payerId
            dictParam[PARAMS.last_four] = "paypal"
            dictParam[PARAMS.AMOUNT] = CurrentTrip.shared.tripStaus.cancellationFee ?? 0
        }
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.PAY_TIP_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response: response) {
                    self.wsRateToProvider()
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
         PARAMS.TRIP_ID : tripDetail.id!,
         PARAMS.is_tip : true,
         PARAMS.AMOUNT : txtTipAmount.text!.toDouble(),
         PARAMS.TYPE : CONSTANT.TYPE_USER]
        
        let alamoFire:AlamofireHelper = AlamofireHelper();
        alamoFire.getResponseFromURL(url: WebService.WS_TRIP_REMANING_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        { [weak self] (response, error) -> (Void) in
            guard let self = self else { return }
            Utility.hideLoading()
            if Parser.isSuccess(response: response) {
                if let client_secret = response["client_secret"] as? String {
                    if let country = response["country_code"] as? String {
                        if let currency_code = response["currency_code"] as? String {
                            let model = ApplePayHelperModel(amount: Double(self.txtTipAmount.text!) ?? 0, currencyCode: currency_code, country: country, applePayClientSecret: client_secret)
                            self.applePay = StripeApplePayHelper(model: model)
                            self.applePay?.delegate = self
                            self.applePay?.openApplePayDialog()
                        }
                    }
                }
            }
        }
    }
    
    func wsVerifyPayment() {
        Utility.showLoading()
        let dictParam : [String : Any] =
            [PARAMS.USER_ID      : preferenceHelper.getUserId()  ,
             PARAMS.TOKEN  : preferenceHelper.getSessionToken(),
             PARAMS.TRIP_ID : tripDetail.id!]

        let alamoFire:AlamofireHelper = AlamofireHelper();
        alamoFire.getResponseFromURL(url: WebService.WS_VERIFY_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        { [weak self]
            (response, error) -> (Void) in
            Utility.hideLoading()
            guard let self = self else { return }
            if let status = response["payment_status"] as? Int {
                if status == PAYMENT_STATUS.COMPLETED {
                    self.wsRateToProvider()
                }
            }
        }
    }

    func openStripePaymentMethod(paymentMethod:String, clientSecret: String) {
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
                    Utility.hideLoading()
                    self.openRetryPaymentDialog(message: (error?.localizedDescription) ?? "")
                    break
                case .canceled:
                    Utility.hideLoading()
                    print("Payment canceled \(error?.localizedDescription ?? "")")
                    self.openRetryPaymentDialog(message: (error?.localizedDescription) ?? "")
                    break
                case .succeeded:
                    self.wsPayTipPayment() {(success) -> (Void) in
                        if success {
                            self.wsRateToProvider()
                        }
                    }
                    break
                @unknown default:
                    fatalError()
                    break
            }
        }
    }

    func openRetryPaymentDialog(message:String = "") {
        if PaymentMethod.Payment_gateway_type == PaymentMethod.Paypal_ID{
            let actYes = UIAlertAction(title: "Pay Again", style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                self.wsGetStripeIntent(amount: self.txtTipAmount.text!.toDouble())
            }
            Common.alert("Payment Failed", message, [actYes])
        } else if PaymentMethod.Payment_gateway_type != PaymentMethod.PayU_ID{
            let actYes = UIAlertAction(title: "Pay Again", style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                if self.tripDetail.paymentMode == PaymentMode.CARD {
                    self.wsGetStripeIntent(amount: self.txtTipAmount.text!.toDouble())
                } else if self.tripDetail.paymentMode == PaymentMode.APPLE_PAY {
                    self.onClickSubmit(self.btnSubmit)
                } else {}
            }
            
            let actNo = UIAlertAction(title: "Add New Card", style: UIAlertAction.Style.cancel) {
                (act: UIAlertAction) in
                if let navigationVC: UINavigationController  = self.revealViewController()?.mainViewController as? UINavigationController {
                    navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_PAYMENT, sender: self)
                }
            }
            Common.alert("Payment Failed", message, [actYes,actNo])
        } else {
            let actYes = UIAlertAction(title: "Pay Again", style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                if self.tripDetail.paymentMode == PaymentMode.CARD {
                    self.wsGetStripeIntent(amount: self.txtTipAmount.text!.toDouble())
                } else if self.tripDetail.paymentMode == PaymentMode.APPLE_PAY {
                    self.onClickSubmit(self.btnSubmit)
                } else {}
            }
            Common.alert("Payment Failed", message, [actYes])
        }
    }

    func displayDefaultAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension FeedbackVC:PBRevealViewControllerDelegate
{
    @IBAction func onClickBtnMenu(_ sender: Any) {}

    func setupRevealViewController() {
        self.revealViewController()?.panGestureRecognizer?.isEnabled = true
        btnMenu.addTarget(self.revealViewController(), action: #selector(PBRevealViewController.revealLeftView), for: .touchUpInside)
    }

    func revealController(_ revealController: PBRevealViewController, willShowLeft viewController: UIViewController) {
        revealController.mainViewController?.view.isUserInteractionEnabled = false;
    }

    func revealController(_ revealController: PBRevealViewController, willHideLeft viewController: UIViewController) {
        revealController.mainViewController?.view.isUserInteractionEnabled = true;
    }
}

extension FeedbackVC:PaypalHelperDelegate {
    func paymentSucess(capture: PaypalCaptureResponse) {
        wsPaypalPayTipPayment(orderID: capture.paymentId, payerId: capture.payerId)
    }
    
    func paymentCancel() {
        openRetryPaymentDialog()
    }
}

extension FeedbackVC: StripeApplePayHelperDelegate {
    func didComplete() {
        wsRateToProvider()
    }
    
    func didFailed(err: String) {
        openRetryPaymentDialog()
    }
}

extension FeedbackVC {
    func startTripListner() {
        let myTripid = "'\(CurrentTrip.shared.tripId)'"
        self.socketHelper.socket?.emit("room", myTripid)
        self.socketHelper.socket?.on(myTripid) {
            [weak self] (data, ack) in

            print("Socket Response \(data)")
            guard let `self` = self else { return }
            guard let response = data.first as? [String:Any] else { return }
            let isTripUpdate = (response[PARAMS.IS_TRIP_UPDATED] as? Bool) ?? false
            if isTripUpdate {
                print("Socket Response Feedback Updated \(data)")
                self.wsGetInvoice()
            }
        }
    }

    func stopTripListner() {
        let myTripid = "'\(CurrentTrip.shared.tripId)'"
        self.socketHelper.socket?.off(myTripid)
    }
}
