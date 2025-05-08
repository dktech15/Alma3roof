//
//  CustomPhotoDialog.swift
//  Eber
//
//  Created by Elluminati on 22/02/17.
//  Copyright © 2017 Elluminati. All rights reserved.
//

import Foundation
import UIKit


public class CustomDialogSplitPaymentReq: CustomDialog
{
   //MARK: - OUTLETS
    @IBOutlet weak var stkDialog: UIStackView!
    @IBOutlet weak var stkBtns: UIStackView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblContactNumber: UILabel!
    
    @IBOutlet weak var btnPaymentMode: UIControl!
    @IBOutlet weak var txtPaymentMode: UITextField!
    
    @IBOutlet weak var imgDropDown: UIImageView!
    @IBOutlet weak var btnAddNewCard: UIButton!
    
    //MARK:Variables
    var onClickRightButton : (() -> Void)? = nil
    var onClickLeftButton : (() -> Void)? = nil
    var onClickAddNewCard : (() -> Void)? = nil
    static let verificationDialog = "CustomDialogSplitPaymentReq"
    var paymentMode = PaymentMode.CASH
    
    var paymentPicker = UIPickerView()
    var arrPayment = [PaymentGateway(name: "TXT_CASH".localized, type: PaymentMode.CASH), PaymentGateway(name: "TXT_CARD".localized, type: PaymentMode.CARD)]
    var isConfirm = false
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        txtPaymentMode.tintColor = .clear
        txtPaymentMode.inputView = paymentPicker
        imgDropDown.isUserInteractionEnabled = true
    }
    
    public static func  showCustomAlertDialog
        (title:String,
         message:String,
         strName: String,
         strPhone: String,
         titleLeftButton:String,
         titleRightButton:String, 
         tag:Int = 479
         ) ->
    CustomDialogSplitPaymentReq {
        var view = UINib(nibName: verificationDialog, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomDialogSplitPaymentReq
        
        let frame = (APPDELEGATE.window?.frame)!;
        view.frame = frame;
        
        if let vw = (APPDELEGATE.window?.viewWithTag(tag)) as? CustomDialogSplitPaymentReq {
            if let window = APPDELEGATE.window {
                window.bringSubviewToFront(vw)
            }
            view = vw
        }
        else {
            view.addViewInWindow(vw: view)
        }
        
        if StripeApplePayHelper.isApplePayAvailable() {
            if let _ = view.arrPayment.firstIndex(where: {$0.name == "TXT_APPLE_PAY".localized}) {
                //find apple pay
            } else {
                view.arrPayment.append(PaymentGateway(name: "TXT_APPLE_PAY".localized, type: PaymentMode.APPLE_PAY))
            }
        }
        
        view.tag = tag
        view.alertView.setShadow()
        view.alertView.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.themeOverlayColor
        
        view.lblTitle.text = title
        view.lblName.text = strName
        view.lblContactNumber.text = strPhone
        view.lblMessage.text = message;
        view.setLocalization()
        view.btnLeft.setTitle(titleLeftButton.capitalized, for: UIControl.State.normal)
        view.btnRight.setTitle(titleRightButton.capitalized, for: UIControl.State.normal)
        
        view.btnLeft.isHidden =  titleLeftButton.isEmpty()
        view.btnRight.isHidden =  titleRightButton.isEmpty()
        view.lblTitle.isHidden = title.isEmpty()
        
        view.setPaymentPicker()
        view.setData()
        
        return view;
    }
    
    func setPaymentPicker() {
        paymentPicker.delegate = self
        paymentPicker.dataSource = self
    }
    
    func addViewInWindow(vw: UIView) {
        if let window = APPDELEGATE.window {
            window.addSubview(self)
            window.bringSubviewToFront(self)
        }
    }
    
    func setLocalization() {
        btnLeft.setTitleColor(UIColor.themeLightTextColor, for: UIControl.State.normal)
        btnRight.setTitleColor(UIColor.themeButtonTitleColor, for: UIControl.State.normal)
        btnAddNewCard.setTitleColor(UIColor.themeLightTextColor, for: UIControl.State.normal)
        btnRight.backgroundColor = UIColor.themeButtonBackgroundColor
        lblTitle.textColor = UIColor.themeTextColor
        lblName.textColor = UIColor.themeTextColor
        lblTitle.textColor = UIColor.themeTextColor
        lblContactNumber.textColor = UIColor.themeTextColor
        
        btnAddNewCard.setTitle("txt_go_to_payment".localized, for: .normal)
        
         btnRight.setupButton()
        /* Set Font */
        btnLeft.titleLabel?.font =  FontHelper.font(type: FontType.Regular)
        btnRight.titleLabel?.font =  FontHelper.font(size: FontSize.medium, type: FontType.Regular)
        btnAddNewCard.titleLabel?.font =  FontHelper.font(type: FontType.Regular)
        lblTitle.font = FontHelper.font(size: FontSize.large, type: FontType.Regular)
        lblMessage.font = FontHelper.font(type: FontType.Regular)
        
        lblName.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        lblContactNumber.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        
        txtPaymentMode.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        
        self.backgroundColor = UIColor.themeOverlayColor
        self.alertView.backgroundColor = UIColor.white
        self.alertView.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 1.0)
    }
    
    func setData() {
        let req = CurrentTrip.shared.splitPaymentReq
        if req._id?.count ?? 0 > 0 {
            if req.status == SplitPaymentStatus.Accept && req.payment_mode == nil {
                isConfirm = true
                btnPaymentMode.isHidden = false
                btnLeft.isHidden = true
                btnRight.setTitle("TXT_CONFIRM".localized, for: .normal)
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClickPaymentMode(_:)))
        imgDropDown.addGestureRecognizer(tap)
    }
    
    func wsAcceptReject(status: Int) {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] = CurrentTrip.shared.splitPaymentReq.trip_id ?? ""
        dictParam[PARAMS.status] = status
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.WS_ACCEPT_REJECT_SPLIT_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
         
            Utility.hideLoading()
            
            let isRemove: Bool = {
                if let code = response["error_code"] as? String {
                    if code == "419" {
                        return true
                    }
                }
                if let code = response["error_code"] as? Int {
                    if code == 419 {
                        return true
                    }
                }
               return false
            }()
            
            if Parser.isSuccess(response: response) {
                if status == 2 {
                    CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: [:])
                    self.removeFromSuperview()
                } else {
                    CurrentTrip.shared.splitPaymentReq.status = .Accept
                    self.setData()
                }
            } else {
                if isRemove {
                    self.removeFromSuperview()
                }
            }
        }
    }
    
    func wsConfirmReq(applePay: Bool = false) {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] = CurrentTrip.shared.splitPaymentReq.trip_id ?? ""
        dictParam[PARAMS.PAYMENT_MODE] = self.paymentMode
        
        if applePay {
            dictParam[PARAMS.PAYMENT_MODE] = PaymentMode.APPLE_PAY
        }
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.WS_UPDATE_SPLIT_PAYMENT_MODE, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
         
            Utility.hideLoading()
            
            if Parser.isSuccess(response: response) {
                CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: [:])
                self.removeFromSuperview()
            } else {
                if let errorCode = response["error_code"] as? Int {
                    if errorCode == 435 {
                        return
                    }
                } else if let errorCode = response["error_code"] as? String {
                    if errorCode == "435" {
                        return
                    }
                }
                CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: [:])
                self.removeFromSuperview()
            }
        }
    }
    
    //ActionMethods
    @IBAction func onClickBtnLeft(_ sender: Any) {
        if self.onClickLeftButton != nil {
            //self.onClickLeftButton!();
            wsAcceptReject(status: 2) //Reject
        }
    }
    
    @IBAction func onClickBtnRight(_ sender: Any) {
        if self.onClickRightButton != nil {
            //self.onClickRightButton!()
            if isConfirm {
                if paymentMode == PaymentMode.APPLE_PAY {
                    self.wsConfirmReq(applePay: true)
                } else {
                    wsConfirmReq()
                }
            } else {
                wsAcceptReject(status: 1) //Accept
            }
        }
    }
    
    @IBAction func onClickPaymentMode(_ sender: Any) {
        if !txtPaymentMode.isFirstResponder {
            txtPaymentMode.becomeFirstResponder()
        }
    }
    
    @IBAction func onClickAddNewCard(_ sender: Any) {
        if self.onClickAddNewCard != nil {
            self.onClickAddNewCard!();
        }
    }
}

extension CustomDialogSplitPaymentReq: UIPickerViewDelegate, UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrPayment.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrPayment[row].name
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let obj = arrPayment[row]
        self.paymentMode = obj.type
        if self.paymentMode == PaymentMode.CARD {
            btnAddNewCard.isHidden = false
        } else {
            btnAddNewCard.isHidden = true
        }
        txtPaymentMode.text = obj.name
    }
}
