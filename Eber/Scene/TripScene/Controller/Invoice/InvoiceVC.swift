//
//  InvoiceVC.swift
//  Edelivery
//   Created by Ellumination 23/04/17.
//  Copyright © 2017 Elluminati iMac. All rights reserved.
//

import UIKit
import Stripe

class InvoiceVC: BaseVC
{
    /*Header View*/
    @IBOutlet var navigationView: UIView!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnSubmit: UIButton!
    @IBOutlet var lblTripType: UILabel!
    
    @IBOutlet var viewForHeader: UIView!
    @IBOutlet var lblTotalTime: UILabel!
    @IBOutlet var imgPayment: UIImageView!
    @IBOutlet var lblPaymentIcon: UILabel!
    @IBOutlet var imgPaymentIcon: UIImageView!
    @IBOutlet var lblPaymentMode: UILabel!
    @IBOutlet var lblDistance: UILabel!
    
    @IBOutlet var lblTotal: UILabel!
    @IBOutlet var lblTotalValue: UILabel!
    
    @IBOutlet var viewForiInvoiceDialog: UIView!
    @IBOutlet var lblTripId: UILabel!
    @IBOutlet var lblMinFare: UILabel!
    
    @IBOutlet var tblForInvoice: UITableView!
    @IBOutlet var lblIconDistance: UILabel!
    @IBOutlet var imgIconDistance: UIImageView!
    
    @IBOutlet var lblIconEta: UILabel!
    @IBOutlet var imgIconEta: UIImageView!
    @IBOutlet var lblYouHaveToPayCash: UILabel!
    
    var arrForInvoice:[[Invoice]]  = []
    var invoiceResponse:InvoiceResponse = InvoiceResponse.init(fromDictionary: [:])
    var socketHelper:SocketHelper = SocketHelper.shared
    var isPaymentSuccess:Bool = false
    var errorMessage:String = ""
    var isStripeIntentCalled:Bool = false
    var payStackVC:PayStackVC!
    
    var applePay: StripeApplePayHelper?
    var paypal: PaypalHelper?
    
    /*Footer View*/
    override func viewDidLoad()
    {
        super.viewDidLoad()
        socketHelper.connectSocket()
        initialViewSetup()
        setupRevealViewController()
        self.wsGetInvoice()
       
    }
    
    @IBAction func onClickBtnSubmitInvoice(_ sender: Any) {
        self.wsSubmitInvoice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func initialViewSetup() {
        lblTitle.text = "TXT_INVOICE".localizedCapitalized
        lblTitle.font = FontHelper.font(size: FontSize.medium
                                        , type: FontType.Bold)
        lblTitle.textColor = UIColor.themeTextColor
        
        lblTotalTime.text = ""
        lblTotalTime.textColor = UIColor.themeTextColor
        lblTotalTime.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        
        lblDistance.text = ""
        lblDistance.textColor = UIColor.themeTextColor
        lblDistance.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        
        lblPaymentMode.text = ""
        lblPaymentMode.textColor = UIColor.themeTextColor
        lblPaymentMode.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        
        lblTotal.text = "TXT_TOTAL".localized
        lblTotal.textColor = UIColor.themeLightTextColor
        lblTotal.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        
        lblYouHaveToPayCash.text = ""
        lblYouHaveToPayCash.textColor = UIColor.themeTextColor
        lblYouHaveToPayCash.font = FontHelper.font(size: FontSize.large, type: FontType.Regular)
        
        lblMinFare.text = "TXT_MIN_FARE".localized
        lblMinFare.textColor = UIColor.themeErrorTextColor
        lblMinFare.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        
        lblTotalValue.text = ""
        lblTotalValue.textColor = UIColor.themeSelectionColor
        lblTotalValue.font = FontHelper.font(size: FontSize.doubleExtraLarge, type: FontType.Bold)
        
        
        lblTripId.text = ""
        lblTripId.textColor = UIColor.themeLightTextColor
        lblTripId.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        
        lblTripType.text = ""
        lblTripType.textColor = UIColor.themeTextColor
        lblTripType.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        
        self.view.backgroundColor = UIColor.themeViewBackgroundColor
        
        lblMinFare.isHidden = true
        self.tblForInvoice.tableHeaderView = UIView.init(frame: CGRect.zero)
        self.tblForInvoice.tableFooterView = UIView.init(frame: CGRect.zero)
        
        //btnSubmit.setTitle("TXT_SUBMIT".localized, for: .normal)
        //        btnSubmit.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        //        btnSubmit.setTitleColor(UIColor.themeTextColor  , for: .normal)
        
        imgIconDistance.tintColor = UIColor.themeImageColor
        imgIconEta.tintColor = UIColor.themeImageColor
        //        lblIconDistance.text = FontAsset.icon_distance
        //        lblIconEta.text = FontAsset.icon_time
        //        lblPaymentIcon.text = FontAsset.icon_payment_cash
        imgPaymentIcon.image = UIImage(named: "asset-cash")
        //        lblIconDistance.setForIcon()
        //        lblIconEta.setForIcon()
        //        lblPaymentIcon.setForIcon()
        //        btnSubmit.setTitle(FontAsset.icon_checked, for: .normal)
        //        btnSubmit.setUpTopBarButton()
        
        //        btnMenu.setTitle(FontAsset.icon_menu, for: .normal)
        //        btnMenu.setUpTopBarButton()
        
        btnSubmit.setImage(UIImage(named: "asset-selected"), for: .normal)
        payStackVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PayStackVC") as? PayStackVC
        payStackVC.gotPayUResopnse = { [weak self] (_ message: String, _ isCallIntentAPI:Bool, _ showPaymentRetryDialog:Bool, ispaytabs: Bool) -> Void in
            guard let self = self else { return }
            
            if showPaymentRetryDialog{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    Utility.hideLoading()
                    self.openRetryPaymentDialog()
                }
            } else if isCallIntentAPI {
                self.wsGetInvoice()
            }
            
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        setupLayout()
    }
    
    func setupLayout() {
        navigationView.navigationShadow()
    }
    
    func setupInvoice()
    {
        let tripDetail:InvoiceTrip = invoiceResponse.trip
        lblTripId.text = tripDetail.invoiceNumber
        lblTotalValue.text = tripDetail.total.toCurrencyString(currencyCode: tripDetail.currencycode)
        
        if tripDetail.paymentMode == PaymentMode.CASH {
            let cash = (tripDetail.total ?? 0)/Double(tripDetail.split_payment_users.count + 1)
            lblYouHaveToPayCash.isHidden = false
            lblYouHaveToPayCash.text = "txt_you_have_to_pay_cash".localized.replacingOccurrences(of: "****", with: "\(tripDetail.currency ?? "")\(cash)")
        } else {
            lblYouHaveToPayCash.isHidden = true
        }
        
        if tripDetail.paymentMode == PaymentMode.CASH
        {
            imgPayment.image = UIImage.init(named: "asset-cash")
            lblPaymentMode.text = "TXT_PAID_BY_CASH".localized
            imgPaymentIcon.image = UIImage(named: "asset-cash")
            //            self.lblPaymentIcon.text = FontAsset.icon_payment_cash
        }
        else if tripDetail.paymentMode == PaymentMode.CARD
        {
            imgPayment.image = UIImage.init(named: "asset-card")
            lblPaymentMode.text = "TXT_PAID_BY_CARD".localized
            imgPaymentIcon.image = UIImage(named: "asset-card")
            //            self.lblPaymentIcon.text = FontAsset.icon_payment_card
        }
        else {
            imgPayment.image = UIImage.init(named: "asset-apple-pay")
            lblPaymentMode.text = "TXT_PAID_BY_APPLE_PAY".localized
            //            self.lblPaymentIcon.text = FontAsset.icon_payment_card
            imgPaymentIcon.image = UIImage(named: "asset-card")
        }
        
        lblDistance.text = tripDetail.totalDistance.toString(places: 2) + Utility.getDistanceUnit(unit: tripDetail.unit)
        self.lblTotalTime.text = String(format:"%.2f%@", tripDetail.totalTime, MeasureUnit.MINUTES)
        
        if invoiceResponse.trip.tripType == TripType.AIRPORT || invoiceResponse.trip.tripType == TripType.CITY || invoiceResponse.trip.tripType == TripType.ZONE || tripDetail.isFixedFare
        {
            lblTripType.isHidden = false
            if invoiceResponse.trip.isFixedFare
            {
                lblTripType.text = "TXT_FIXED_FARE_TRIP".localized
            }
            else if invoiceResponse.trip.tripType == TripType.AIRPORT
            {
                lblTripType.text = "TXT_AIRPORT_TRIP".localized
            }
            else  if invoiceResponse.trip.tripType == TripType.ZONE
            {
                lblTripType.text = "TXT_ZONE_TRIP".localized
            }
            else  if invoiceResponse.trip.tripType == TripType.CITY
            {
                lblTripType.text = "TXT_CITY_TRIP".localized
            }
            else
            {
                lblTripType.isHidden = true
            }
        }
        else
        {
            lblTripType.isHidden = true
            
            if tripDetail.isMinFareUsed == TRUE
            {
                lblMinFare.isHidden = false
                lblMinFare.text = "TXT_MIN_FARE".localized + " " +  invoiceResponse.tripservice.minFare.toCurrencyString(currencyCode: tripDetail.currencycode) + " " + "TXT_APPLIED".localized
            }
            else
            {
                lblMinFare.isHidden = true
            }
        }
        print("\(#function) wsgetinvoice() data set")
    }
    
    func openRetryPaymentDialog(message:String = "")
    {
        if self.invoiceResponse.trip.paymentMode == PaymentMode.APPLE_PAY {
            let actYes = UIAlertAction(title: "TXT_PAY_AGAIN".localized, style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                self.wsGetStripeApplePayIntent()
            }
            let card = UIAlertAction(title: "Card", style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                self.wsGetStripeIntent(isRetry: true)
            }
            Common.alert("TXT_PAYMENT_FAILED".localized, message, [actYes, card])
        } else if PaymentMethod.Payment_gateway_type == PaymentMethod.Paypal_ID {
            let actYes = UIAlertAction(title: "TXT_PAY_AGAIN".localized, style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                self.wsGetStripeIntent(isRetry: true)
            }
            
            var arrActions = [actYes]
            
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
        } else if PaymentMethod.Payment_gateway_type != PaymentMethod.PayU_ID{
            let actYes = UIAlertAction(title: "TXT_PAY_AGAIN".localized, style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
//                self.wsGetStripeIntent(isRetry: true)
                self.payStackVC.htmlDataString = self.invoiceResponse.trip.payment_url ?? ""
                self.payStackVC.isFromInvoicePopUP = true
                self.navigationController?.pushViewController(self.payStackVC, animated: true)
            }
            let actNo = UIAlertAction(title: "TXT_ADD_CARD".localized, style: UIAlertAction.Style.cancel) {
                (act: UIAlertAction) in
                if let navigationVC: UINavigationController  = self.revealViewController()?.mainViewController as? UINavigationController
                {
                    //                    let vc = UIStoryboard.paymentStoryboard().instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
                    //                    vc.invoicePayment = PaymentMethod.Payment_gateway_type
                    //                    navigationVC.pushViewController(vc, animated: true)
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
    
    func showPayPayment(url: String) {
        let actYes = UIAlertAction(title: "Pay Now".localized, style: UIAlertAction.Style.destructive) {
            (act: UIAlertAction) in
            self.payStackVC.htmlDataString = self.invoiceResponse.trip.payment_url ?? ""
            self.payStackVC.isFromInvoicePopUP = true
            self.navigationController?.pushViewController(self.payStackVC, animated: true)
        }
        
        let actNo = UIAlertAction(title: "No".localized, style: UIAlertAction.Style.cancel) {
            (act: UIAlertAction) in
            
        }
        
        var arrActions = [actYes,actNo]
        
        Common.alert("Payment Online", "", arrActions)
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
    
    func wsAnotherPaymentMode() {
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] =  CurrentTrip.shared.tripId
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.pay_by_other_payment_mode, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if (error != nil) {
            } else {
                if Parser.isSuccess(response: response, withSuccessToast: true) {
                    self.btnSubmit.enable()
                } else {
                    
                }
            }
        }
    }
}

extension InvoiceVC :UITableViewDataSource,UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrForInvoice.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrForInvoice[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:InvoiceCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! InvoiceCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let currentInvoiceItem:Invoice = arrForInvoice[indexPath.section][indexPath.row]
        cell.setCellData(cellItem: currentInvoiceItem)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0
        {
            return 0
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "section")! as! InvoiceSection
        if arrForInvoice.count > section {
            if !arrForInvoice[section].isEmpty {
                sectionHeader.setData(title: arrForInvoice[section][0].sectionTitle)
            }
        }
        return sectionHeader
    }
}

extension InvoiceVC:PBRevealViewControllerDelegate
{
    @IBAction func onClickBtnMenu(_ sender: Any)
    {}
    func setupRevealViewController()
    {
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

extension InvoiceVC
{
    func openPaystackPinVerificationDialog(requiredParam:String,reference:String)
    {
        self.view.endEditing(true)
        
        switch requiredParam {
        case PaymentMethod.VerificationParameter.SEND_PIN:
            let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_PIN".localized, message: "EG_1234".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_PIN".localized,isHideBackButton: true)
            
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
            let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_OTP".localized, message: "EG_123456".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_OTP".localized,isHideBackButton: true)
            
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
            let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_PHONE_NUMBER".localized, message: "MINIMUM_10_DIGITS".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_PHONE_NUMBER".localized,isHideBackButton: true)
            
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
            let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_BIRTHDATE".localized, message: "EG_DD-MM-YYYY".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_BIRTHDATE".localized,isHideBackButton: true, isShowBirthdayTextfield: true)
            
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
         PARAMS.TRIP_ID : CurrentTrip.shared.tripId]
        
        let alamoFire:AlamofireHelper = AlamofireHelper();
        alamoFire.getResponseFromURL(url: WebService.SEND_PAYSTACK_REQUIRED_DETAIL, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        { (response, error) -> (Void) in
            Utility.hideLoading()
            if Parser.isSuccess(response: response, withSuccessToast: false, andErrorToast: false)
            {
                dialog.removeFromSuperview()
                Utility.hideLoading()
                self.wsGetInvoice()
                self.btnSubmit.enable()
            }else{
                dialog.removeFromSuperview()
                if (response[PARAMS.REQUIRED_PARAM] as? String)?.count ?? "".count > 0{
                    self.openPaystackPinVerificationDialog(requiredParam: response[PARAMS.REQUIRED_PARAM] as? String ?? "", reference: response["reference"] as? String ?? "")
                }else{
                    self.isStripeIntentCalled = false
                    Utility.showToast(message: response["error_message"] as? String ?? "")
                    self.openRetryPaymentDialog(message: (response["error"] as? String) ?? "")
                }
            }
        }
    }
    
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
                                          timeoutInterval: 60.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            print("\(#function)")
            if (error != nil)
            {
                self.wsGetInvoice()
                Utility.hideLoading()
            }
            else
            {
                Utility.hideLoading()
                guard let data = data, error == nil else {
                    print("\(#function) error=\(String(describing: error))")
                    return
                }
                // Code_By: Bhumita - git issue => user/120
                // Code_Function => recalls the invoice api if https status code is zero.
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 0{
                    self.wsGetInvoice()
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
                                self.invoiceResponse = InvoiceResponse.init(fromDictionary: convertedJsonIntoDict)
                                
                                
                                self.startTripListner()
                                if Parser.parseInvoice(tripService: self.invoiceResponse.tripservice, tripDetail: self.invoiceResponse.trip, arrForInvocie: &self.arrForInvoice) {
                                    self.setupInvoice()
                                    self.tblForInvoice?.reloadData()
                                }
                                
                                if self.invoiceResponse.trip.is_show_pay_payment && self.invoiceResponse.trip.payment_url != ""{
                                    self.setupInvoice()
                                    self.showPayPayment(url: "")
                                    self.tblForInvoice?.reloadData()
                                } else{
                                    if self.invoiceResponse.trip.paymentStatus == PAYMENT_STATUS.FAILED {
                                        Utility.hideLoading()
                                        if self.invoiceResponse.trip.paymentMode == PaymentMode.CARD {
                                            if !self.isStripeIntentCalled {
                                                self.isStripeIntentCalled = true
                                                self.wsGetStripeIntent()
                                            }
                                        } else if self.invoiceResponse.trip.paymentMode == PaymentMode.APPLE_PAY {
                                            self.wsGetStripeApplePayIntent()
                                        } else {}
                                    }
                                    else if self.invoiceResponse.trip.paymentStatus == PAYMENT_STATUS.WAITING && self.invoiceResponse.trip.paymentMode == PaymentMode.CARD {
                                        Utility.showLoading(text: "txt_please_wait_your_payment_is_processing".localized)
                                        if self.invoiceResponse.trip.is_show_pay_payment && self.invoiceResponse.trip.payment_url != ""{
                                            self.setupInvoice()
                                            self.showPayPayment(url: "")
                                            self.tblForInvoice?.reloadData()
                                        }
                                    }
                                    else {
                                        Utility.hideLoading()
                                        self.btnSubmit.enable()
                                    }
                                }
                                
                              
                                
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if SEGUE.TRIP_TO_FEEDBACK == segue.identifier
        {
            if let destinationVC:FeedbackVC = segue.destination as? FeedbackVC
            {
                destinationVC.tripDetail = self.invoiceResponse.trip
                destinationVC.providerDetail = self.invoiceResponse.providerDetail
            }
        }
    }
    
    func emitTripNotification()
    {
        /*let dictParam:[String:Any] =
         [PARAMS.USER_ID : preferenceHelper.getUserId(),
         PARAMS.TRIP_ID : CurrentTrip.shared.tripId]*/
        //SocketHelper.shared.socket?.emitWithAck(SocketHelper.shared.tripDetailNotify, dictParam).timingOut(after: 0) {data in}
    }
    
    func openApplePay() {
        Utility.hideLoading()
        
        
        
        /*
         let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
         if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
         let paymentItem = PKPaymentSummaryItem.init(label: "Trip Payment", amount: NSDecimalNumber(value: self.invoiceResponse.trip.total))
         let request = PKPaymentRequest()
         request.currencyCode = "USD" // 1
         request.countryCode = "US"// 2
         request.merchantIdentifier = "merchant.com.elluminati.eber" // 3
         request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
         request.supportedNetworks = paymentNetworks // 5
         request.paymentSummaryItems = [paymentItem] // 6
         guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
         displayDefaultAlert(title: "Error", message: "Unable to present Apple Pay authorization.")
         return
         }
         paymentVC.delegate = self
         self.present(paymentVC, animated: true, completion: nil)
         } else {
         displayDefaultAlert(title: "Error", message: "Unable to make Apple Pay transaction.")
         }*/
    }
    
    func displayDefaultAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func wsGetStripeIntent(isRetry: Bool = false) {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] =  CurrentTrip.shared.tripId
        dictParam[PARAMS.IS_TRIP] =  true
        
        if isRetry {
            dictParam[PARAMS.is_for_retry] = true
        }
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_STRIPE_PAYMENT_INTENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                Utility.hideLoading()
                if Parser.isSuccess(response: response, andErrorToast: false) {
                    if let value = response["payment_gateway_type"] as? Int {
                        PaymentMethod.Payment_gateway_type = "\(value)"
                    }
                    if PaymentMethod.Payment_gateway_type == PaymentMethod.Stripe_ID{
                        //self.emitTripNotification()
                        if let paymentMethod =  response["payment_method"] as? String {
                            if let clientSecret: String = response["client_secret"] as? String {
                                self.openStripePaymentMethod(paymentMethod: paymentMethod, clientSecret: clientSecret)
                            }
                        } else {
                            self.isStripeIntentCalled = false
                        }
                    }else if PaymentMethod.Payment_gateway_type == PaymentMethod.PayU_ID{
                        self.payStackVC.htmlDataString = response["html_form"] as? String ?? ""
                        self.navigationController?.pushViewController(self.payStackVC, animated: true)
                    }else if PaymentMethod.Payment_gateway_type == PaymentMethod.Paypal_ID{
                        let amount = self.invoiceResponse.trip.remainingPayment > 0 ? self.invoiceResponse.trip.remainingPayment : (self.invoiceResponse.trip.total ?? 0)
                        self.paypal = PaypalHelper.init(currrencyCode: self.invoiceResponse.trip.currencycode, amount: "\(amount ?? 0)")
                        self.paypal!.delegate = self
                    }else if PaymentMethod.Payment_gateway_type == PaymentMethod.PayTabs{
                        self.payStackVC.htmlDataString = response["authorization_url"] as? String ?? ""
                        self.navigationController?.pushViewController(self.payStackVC, animated: true)
                    }else if PaymentMethod.Payment_gateway_type == PaymentMethod.RazorPay{
                        self.payStackVC.htmlDataString = response["html_form"] as? String ?? ""
                        self.navigationController?.pushViewController(self.payStackVC, animated: true)
                    }else{
                        self.isStripeIntentCalled = false
                    }
                } else {
                    if PaymentMethod.Payment_gateway_type == PaymentMethod.PayStack_ID && (response[PARAMS.REQUIRED_PARAM] as? String)?.count ?? "".count > 0{
                        self.openPaystackPinVerificationDialog(requiredParam: response[PARAMS.REQUIRED_PARAM] as? String ?? "", reference: response["reference"] as? String ?? "")
                    }else{
                        self.isStripeIntentCalled = false
                        self.openRetryPaymentDialog(message: (response["error"] as? String) ?? "")
                    }
                    
                }
            }
        }
    }
    
    func wsGetStripeIntentApplePay(paymentMethod:String, handler: @escaping (_ success:Bool, _ clientSecret:String, _ paymentMethod:String, _ errorMsg:String) -> (Void))
    {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TYPE] = CONSTANT.TYPE_USER
        dictParam[PARAMS.PAYMENT_METHOD] = paymentMethod
        dictParam[PARAMS.TRIP_ID] = CurrentTrip.shared.tripId
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_STRIPE_PAYMENT_INTENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response:response, andErrorToast:false) {
                    //self.emitTripNotification()
                    if let value = response["payment_gateway_type"] as? Int {
                        PaymentMethod.Payment_gateway_type = "\(value)"
                    }
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
                self.isStripeIntentCalled = false
                self.openRetryPaymentDialog(message: (error?.localizedDescription) ?? "")
                //self.wsFailPayment()
                break
            case .canceled:
                self.isStripeIntentCalled = false
                self.openRetryPaymentDialog(message: (error?.localizedDescription) ?? "")
                //self.wsFailPayment()
                break
            case .succeeded:
                self.isStripeIntentCalled = false
                self.wsPayStripeIntentPayment() { (success) -> (Void) in}
                break
            @unknown default:
                fatalError()
                break
            }
        }
    }
    
    func wsPayStripeIntentPayment(handler: @escaping (_ success:Bool) -> (Void)) {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] =  CurrentTrip.shared.tripId
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.PAY_STRIPE_INTENT_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if (error != nil) {
            } else {
                if Parser.isSuccess(response: response) {
                    self.wsGetInvoice()
                    self.btnSubmit.enable()
                    handler(true)
                    return;
                } else {
                    self.btnSubmit.disable()
                    handler(false)
                }
            }
        }
    }
    
    func wsPaypalPayTrip(orderID: String, payerId: String) {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] =  CurrentTrip.shared.tripId
        dictParam[PARAMS.PAYMENT_GATEWAY_TYPE] = PaymentMethod.Paypal_ID
        dictParam[PARAMS.PAYMENT_INTENT_ID] = orderID
        dictParam[PARAMS.CARD_ID] = payerId
        dictParam[PARAMS.last_four] = "paypal"
        
        let amount = self.invoiceResponse.trip.remainingPayment > 0 ? self.invoiceResponse.trip.remainingPayment : (self.invoiceResponse.trip.total ?? 0)
        dictParam[PARAMS.AMOUNT] = amount
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.PAY_STRIPE_INTENT_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if (error != nil) {
            } else {
                if Parser.isSuccess(response: response) {
                    self.wsGetInvoice()
                    self.btnSubmit.enable()
                    return;
                } else {
                    self.btnSubmit.disable()
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
         PARAMS.TRIP_ID : CurrentTrip.shared.tripId,
         PARAMS.TYPE : CONSTANT.TYPE_USER]
        
        let alamoFire:AlamofireHelper = AlamofireHelper();
        
        alamoFire.getResponseFromURL(url: WebService.WS_TRIP_REMANING_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        {
            (response, error) -> (Void) in
            Utility.hideLoading()
            if Parser.isSuccess(response: response) {
                if let client_secret = response["client_secret"] as? String {
                    let amount = self.invoiceResponse.trip.remainingPayment > 0 ? (self.invoiceResponse.trip.remainingPayment ?? 0) : (self.invoiceResponse.trip.total ?? 0)
                    if let country = response["country_code"] as? String {
                        if let currency_code = response["currency_code"] as? String {
                            let model = ApplePayHelperModel(amount: amount.clean, currencyCode: currency_code, country: country, applePayClientSecret: client_secret)
                            self.applePay = StripeApplePayHelper(model: model)
                            self.applePay?.delegate = self
                            self.applePay?.openApplePayDialog()
                        }
                    }
                }
            } else {
                self.openRetryPaymentDialog()
            }
        }
    }
    
    func wsVerifyPayment() {
        Utility.showLoading()
        let dictParam : [String : Any] =
        [PARAMS.USER_ID      : preferenceHelper.getUserId()  ,
         PARAMS.TOKEN  : preferenceHelper.getSessionToken(),
         PARAMS.TRIP_ID : CurrentTrip.shared.tripId]
        
        let alamoFire:AlamofireHelper = AlamofireHelper();
        alamoFire.getResponseFromURL(url: WebService.WS_VERIFY_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        {
            (response, error) -> (Void) in
            Utility.hideLoading()
            if let status = response["payment_status"] as? Int {
                if status == PAYMENT_STATUS.FAILED {
                    self.wsGetStripeApplePayIntent()
                } else if status == PAYMENT_STATUS.COMPLETED {
                    self.btnSubmit.isEnabled = true
                }
            }
        }
    }
    
}

class InvoiceCell:UITableViewCell
{
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var lblPrice: UILabel!
    
    deinit {
        printE("\(self) \(#function)")
    }
    
    override func awakeFromNib() {
        lblTitle.font = FontHelper.font(size: FontSize.regular, type: .Regular)
        lblTitle.textColor = UIColor.themeLightTextColor
        lblTitle.text = ""
        
        lblSubTitle.font = FontHelper.font(size: FontSize.small, type: .Light)
        lblSubTitle.textColor = UIColor.themeLightTextColor
        lblSubTitle.text = ""
        
        lblPrice.font = FontHelper.font(size: FontSize.medium, type: .Bold)
        lblPrice.textColor = UIColor.themeTextColor
        lblPrice.text = ""
    }
    
    func setCellData(cellItem:Invoice) {
        lblTitle.text = cellItem.title!
        lblSubTitle.text = cellItem.subTitle!
        lblPrice.text = cellItem.price
    }
}

class InvoiceSection:UITableViewCell
{
    @IBOutlet var lblSection: UILabel!
    
    deinit {
        printE("\(self) \(#function)")
    }
    
    override func awakeFromNib() {
        lblSection.textColor = UIColor.themeSelectionColor
        lblSection.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
    }
    
    func setData(title: String) {
        lblSection.text =  title
    }
}

//MARK: - Web Service
extension InvoiceVC
{
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
                print("Socket Response Invoice Trip Updated \(data)")
                self.wsGetInvoice()
            }
        }
    }
    
    func stopTripListner() {
        let myTripid = "'\(CurrentTrip.shared.tripId)'"
        self.socketHelper.socket?.off(myTripid)
    }
    
    func wsSubmitInvoice()
    {
        if !CurrentTrip.shared.tripStaus.trip.id.isEmpty()
        {
            Utility.showLoading()
            var  dictParam : [String : Any] = [:]
            dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
            dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
            dictParam[PARAMS.TRIP_ID] = CurrentTrip.shared.tripStaus.trip.id
            
            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.SUBMIT_INVOICE, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
                if (error != nil)
                {Utility.hideLoading()}
                else
                {
                    if Parser.isSuccess(response: response)
                    {
                        Utility.hideLoading()
                        self.stopTripListner()
                        self.socketHelper.disConnectSocket()
                        self.emitTripNotification()
                        APPDELEGATE.gotoFeedback()
                    }
                    else
                    {
                        Utility.hideLoading()
                    }
                }
            }
        }
        else
        {}
    }
}

extension InvoiceVC: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}

extension InvoiceVC: PaypalHelperDelegate {
    func paymentSucess(capture: PaypalCaptureResponse) {
        self.wsPaypalPayTrip(orderID: capture.paymentId, payerId: capture.payerId)
    }
    func paymentCancel() {
        self.paypal = nil
        if let vc = self.presentedViewController {
            vc.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                Utility.showLoading()
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    Utility.hideLoading()
                    self.openRetryPaymentDialog()
                }
            }
        }
    }
}

extension InvoiceVC: StripeApplePayHelperDelegate {
    func didComplete() {
        btnSubmit.enable()
    }
    
    func didFailed(err: String) {
        openRetryPaymentDialog()
    }
}
