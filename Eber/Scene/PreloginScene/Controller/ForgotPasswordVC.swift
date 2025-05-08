//
//  ForgotPasswordVC.swift
//  Eber
//
//  Created by Elluminati on 30/08/18.
//  Copyright © 2018 Elluminati. All rights reserved.
//

import UIKit

class ForgotPasswordVC: BaseVC
{
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var stkEmail: UIStackView!
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var stkPhone: UIStackView!
    @IBOutlet weak var btnPhone: UIButton!
    @IBOutlet weak var txtPhoneNumber: ACFloatingTextfield!

    var strForCountryPhoneCode:String =  CurrentTrip.shared.currentCountryPhoneCode
    var strForCountry:String = CurrentTrip.shared.currentCountry
    var strForPhoneNumber:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        txtPhoneNumber.text = strForCountryPhoneCode + strForPhoneNumber
        stkEmail.isHidden = !preferenceHelper.getIsEmailVerification()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = txtPhoneNumber.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initialViewSetup() {
        lblMessage.text = "TXT_FORGOT_PASSWORD_MSG".localized
        lblMessage.textColor = UIColor.themeTextColor
        lblMessage.font = FontHelper.font(size: FontSize.large, type: FontType.Regular)
        txtPhoneNumber.placeholder = "TXT_MOBILE_MSG".localized
        txtEmail.placeholder = "TXT_EMAIL".localized
        setTextFieldSetup(txtPhoneNumber)
        setTextFieldSetup(txtEmail)
//        btnBack.setupBackButton()
        btnEmail.isSelected = false
        btnPhone.isSelected = true
//        btnPhone.setTitle(FontAsset.icon_radio_box_normal, for: .normal)
//        btnPhone.setTitle(FontAsset.icon_radio_box_selected, for: .selected)
//        btnEmail.setTitle(FontAsset.icon_radio_box_normal, for: .normal)
//        btnEmail.setTitle(FontAsset.icon_radio_box_selected, for: .selected)
//        btnEmail.setSimpleIconButton()
//        btnPhone.setSimpleIconButton()
//        
        btnPhone.setImage(UIImage(named: "asset-radio-normal"), for: .normal)
        btnPhone.setImage(UIImage(named: "asset-radio-selected"), for: .selected)
        btnPhone.tintColor = UIColor.themeImageColor
        btnEmail.setImage(UIImage(named: "asset-radio-normal"), for: .normal)
        btnEmail.setImage(UIImage(named: "asset-radio-selected"), for: .selected)
//        btnEmail.tintColor = UIColor.themeImageColor
        
        
        
//        btnDone.setTitle(FontAsset.icon_forward_arrow, for: .normal)
//        btnDone.setRoundIconButton()
        btnDone.setTitleColor(UIColor.white,for:.normal)
        btnDone.titleLabel?.font = FontHelper.assetFont(size: 30)
    }

    func setTextFieldSetup(_ textField:UITextField) {
        let windowFrame :CGRect = APPDELEGATE.window?.frame ?? self.view.bounds
        let toolBarView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: windowFrame.size.width, height: 100))
        let btnDone:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
        btnDone.frame = CGRect.init(x: windowFrame.size.width - 100, y: 10, width: 70, height: 70)
        btnDone.addTarget(self, action: #selector(self.onClickBtnDone(_:)), for: .touchUpInside)
//        btnDone.setTitle(FontAsset.icon_forward_arrow, for: .normal)
//        btnDone.setRoundIconButton()
        btnDone.setTitleColor(UIColor.white,for:.normal)
        btnDone.titleLabel?.font = FontHelper.assetFont(size: 30)
        toolBarView.backgroundColor = UIColor.clear
        toolBarView.addSubview(btnDone)
        textField.inputAccessoryView = toolBarView;
    }

    //MARK: - Action Methods
    @IBAction func onClickBtnDone(_ sender: Any) {
        self.view.endEditing(true)
        let validEmail = txtEmail.text!.checkEmailValidation()
        let validPhoneNumber = strForPhoneNumber.isValidMobileNumber()
        if validPhoneNumber.0 == false && btnPhone.isSelected {
            Utility.showToast(message: validPhoneNumber.1)
        } else if validEmail.0 == false && btnEmail.isSelected {
            Utility.showToast(message: validEmail.1)
        } else if(btnEmail.isSelected) {
            self.wsForgotPassword()
        } else if(btnPhone.isSelected) {
            wsGetOtp()
        }
    }

    @IBAction func onClickBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickBtnPhone(_ sender: Any) {
        btnEmail.isSelected = false
        btnPhone.isSelected = true
    }

    @IBAction func onClickBtnEmail(_ sender: Any) {
        btnEmail.isSelected = true
        btnPhone.isSelected = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE.FORGOT_PASSWORD_TO_NEW_PASSWORD {
            if let destinationVC = segue.destination as? NewPasswordVC {
                destinationVC.strForCountryPhoneCode = strForCountryPhoneCode;
                destinationVC.strForPhoneNumber = strForPhoneNumber
            }
        }
    }
}

extension ForgotPasswordVC:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onClickBtnDone(self)
        return true
    }
}

extension ForgotPasswordVC
{
    func wsForgotPassword() {
        Utility.showLoading()
        let afh:AlamofireHelper = AlamofireHelper.init()

        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.EMAIL] = txtEmail.text!.trim()
        dictParam[PARAMS.TYPE] = TRUE
        afh.getResponseFromURL(url: WebService.FORGOT_PASSWORD, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if (error != nil) {
            } else {
                if Parser.isSuccess(response: response,withSuccessToast: true,andErrorToast: true) {
                    Utility.hideLoading()
                    APPDELEGATE.gotoLogin()
                } else {
                    Utility.hideLoading()
                }
            }
        }
    }

    func wsGetOtp() {
        Utility.showLoading()
        let afh:AlamofireHelper = AlamofireHelper.init()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.PHONE] = strForPhoneNumber
        dictParam[PARAMS.COUNTRY_PHONE_CODE] = strForCountryPhoneCode
        dictParam[PARAMS.TYPE] = CONSTANT.TYPE_USER
        afh.getResponseFromURL(url: WebService.GET_OTP, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response: response) {
                    Utility.hideLoading()
                    let smsOtp:String = (response[PARAMS.SMS_OTP] as? String) ?? ""
                    if let otpvc:OtpVC =  AppStoryboard.PreLogin.instance.instantiateViewController(withIdentifier: "OtpVC") as? OtpVC {
                        self.present(otpvc, animated: true, completion: {
                            otpvc.delegate = self
                            otpvc.isFromForgetPassword = true
                            otpvc.strForCountryPhoneCode = self.strForCountryPhoneCode
                            otpvc.strForPhoneNumber = self.strForPhoneNumber
                            otpvc.updateOtpUI(otpEmail: "", otpSms: smsOtp, emailOtpOn: false, smsOtpOn: true, isSocialLogin: false)
                        })
                    }
                } else {
                    Utility.hideLoading()
                }
            }
        }
    }
}

extension ForgotPasswordVC: OtpDelegate
{
    func onOtpDone() {
        self.performSegue(withIdentifier: SEGUE.FORGOT_PASSWORD_TO_NEW_PASSWORD, sender: self)
    }
}
