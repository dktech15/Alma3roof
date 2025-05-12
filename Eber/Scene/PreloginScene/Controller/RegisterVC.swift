//
//  RegisterVC.swift
//  Eber
//
//  Created by Elluminati on 30/08/18.
//  Copyright © 2018 Elluminati. All rights reserved.
//

import UIKit
import Sentry

class RegisterVC: BaseVC,OtpDelegate
{
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var txtFirstName: ACFloatingTextfield!
    @IBOutlet weak var txtLastName: ACFloatingTextfield!
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var vwPassword: UIView!
    @IBOutlet weak var txtPassword: ACFloatingTextfield!
    @IBOutlet weak var txtNumber: ACFloatingTextfield!
    @IBOutlet weak var lblConfirmationTermsAndCondition: UILabel!
    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet weak var lblAnd: UILabel!
    @IBOutlet weak var btnPrivacyPolicy: UIButton!
    @IBOutlet weak var phoneNumberView: UIStackView!
    @IBOutlet weak var btnCountryPhoneCode: UIButton!
    @IBOutlet weak var vwTermsCondition: UIView!
    @IBOutlet weak var btnCheckTC: UIButton!
    @IBOutlet weak var btnHideShowPassword: UIButton!

    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    
    var strForCountryPhoneCode:String = CurrentTrip.shared.arrForCountries[0].code
    var strForCountrycode:String = CurrentTrip.shared.arrForCountries[0].alpha2
    var strForPhoneNumber:String =  ""
    var strForCountry = ""
    var strLoginBy = ""
    var strForSocialId = ""
    var strForFirstName = ""
    var strForLastName = ""
    var strForEmail = ""
    var isSignInWithApple:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()

        if (strForCountryPhoneCode.isEmpty()) {
            strForCountryPhoneCode = CurrentTrip.shared.arrForCountries[0].code
        }

        txtEmail.isEnabled = strForEmail.isEmpty()

        if isSignInWithApple {
            txtFirstName.isEnabled = strForFirstName.isEmpty()
            txtLastName.isEnabled = strForLastName.isEmpty()
        }

        if (strLoginBy == CONSTANT.MANUAL) {
            vwPassword.isHidden = false
            phoneNumberView.isUserInteractionEnabled = false
            txtNumber.isUserInteractionEnabled = false
            btnCountryPhoneCode.isUserInteractionEnabled = false
        } else {
            vwPassword.isHidden = true
            phoneNumberView.isUserInteractionEnabled = true
            txtNumber.isUserInteractionEnabled = true
            btnCountryPhoneCode.isUserInteractionEnabled = true
            strForCountry = CurrentTrip.shared.currentCountry
            strForCountryPhoneCode = CurrentTrip.shared.currentCountryPhoneCode
        }
        setUserData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initialViewSetup() {
        lblMessage.text = "TXT_REGISTER_MSG".localized
        lblMessage.textColor = UIColor.themeTextColor
        lblMessage.font = FontHelper.font(size: FontSize.large, type: FontType.Regular)
        txtFirstName.placeholder = "TXT_FIRST_NAME".localized
        txtLastName.placeholder = "TXT_LAST_NAME".localized
        txtPassword.placeholder = "TXT_PASSWORD".localized
        txtEmail.placeholder = "TXT_EMAIL".localized
        txtNumber.placeholder = "TXT_PHONE_NO".localized
        lblConfirmationTermsAndCondition.text = "TXT_CONDITIONING_TEXT".localized
        lblConfirmationTermsAndCondition.textColor = UIColor.themeTextColor
        lblConfirmationTermsAndCondition.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        lblAnd.text = "TXT_AND".localized
        lblAnd.textColor = UIColor.themeTextColor
        lblAnd.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        btnTerms.setTitle("TXT_TERMS_CONDITIONS".localized, for: .normal)
        btnTerms.setTitleColor(UIColor.themeButtonBackgroundColor, for: .normal)
        btnTerms.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        btnPrivacyPolicy.setTitle("TXT_PRIVACY_POLICY".localized, for: .normal)
        btnPrivacyPolicy.setTitleColor(UIColor.themeButtonBackgroundColor, for: .normal)
        btnPrivacyPolicy.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        btnCountryPhoneCode.setTitle(strForCountryPhoneCode, for: .normal)
        btnCountryPhoneCode.setTitleColor(UIColor.themeButtonBackgroundColor, for: .normal)
        btnCountryPhoneCode.titleLabel?.font  = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
//        btnBack.setupBackButton()
        setTextFieldSetup(txtFirstName)
        setTextFieldSetup(txtLastName)
        setTextFieldSetup(txtPassword)
        setTextFieldSetup(txtEmail)
        setTextFieldSetup(txtNumber)
//        btnDone.setTitle(FontAsset.icon_forward_arrow, for: .normal)
//        btnDone.setRoundIconButton()
        btnDone.setTitleColor(UIColor.white,for:.normal)
        btnDone.titleLabel?.font = FontHelper.assetFont(size: 30)
        btnDone.setTitleColor(UIColor.white,for:.normal)
        //asset-password-hide_u
        //asset-password-show_u
        btnHideShowPassword.setImage(UIImage(named: "asset-password-hide_u") , for: .normal)
        btnHideShowPassword.setImage(UIImage(named: "asset-password-show_u"), for: .selected)
        btnHideShowPassword.tintColor = UIColor.themeImageColor
//        btnHideShowPassword.setTitle(FontAsset.icon_hide_password, for: .normal)
//        btnHideShowPassword.setTitle(FontAsset.icon_show_password, for: .selected)
//        btnHideShowPassword.setSimpleIconButton()
//        btnHideShowPassword.titleLabel?.font = FontHelper.assetFont(size: 25)
        btnDone.isEnabled = false
        btnDone.alpha = 0.5
        
        btnMale.setImage(UIImage(named: "asset-radio-normal"), for: .normal)
        btnMale.setImage(UIImage(named: "asset-radio-selected"), for: .selected)
        btnMale.tintColor = UIColor.themeImageColor
        btnFemale.setImage(UIImage(named: "asset-radio-normal"), for: .normal)
        btnFemale.setImage(UIImage(named: "asset-radio-selected"), for: .selected)
        btnFemale.tintColor = UIColor.themeImageColor
    }

    func setTextFieldSetup(_ textField:UITextField) {
        let windowFrame :CGRect = APPDELEGATE.window?.frame ?? self.view.bounds
        let toolBarView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: windowFrame.size.width, height: 100))
        let btnDone:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
        btnDone.frame = CGRect.init(x: windowFrame.size.width - 100, y: 10, width: 70, height: 70)
        btnDone.addTarget(self, action: #selector(self.onClickBtnDone(_:)), for: .touchUpInside)
//        btnDone.setTitle(FontAsset.icon_forward_arrow, for: .normal)
//        btnDone.setRoundIconButton()
        btnDone.titleLabel?.font = FontHelper.assetFont(size: 30)
        btnDone.setTitleColor(UIColor.white,for:.normal)
        toolBarView.backgroundColor = UIColor.clear
        toolBarView.addSubview(btnDone)
        textField.inputAccessoryView = toolBarView;
    }

    func setUserData() {
        txtNumber.text = strForPhoneNumber
        txtFirstName.text = strForFirstName
        txtLastName.text = strForLastName
        txtEmail.text = strForEmail
        btnCountryPhoneCode.setTitle(strForCountryPhoneCode, for: .normal)
    }

    //MARK: - Action Methods
    @IBAction func onClickBtnTerms(_ sender: Any) {
        if let termsUrl:URL = URL.init(string: preferenceHelper.getTermsAndCondition()) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(termsUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(termsUrl)
            }
        }
    }

    @IBAction func onClickBtnPrivacy(_ sender: Any) {
        if let privacyUrl:URL = URL.init(string: preferenceHelper.getPrivacyPolicy()) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(privacyUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(privacyUrl)
            }
        }
    }
    
    @IBAction func onClickBtnMale(_ sender: Any) {
        btnMale.isSelected = true
        btnFemale.isSelected = false
    }
    
    @IBAction func onClickBtnFemale(_ sender: Any) {
        btnMale.isSelected = false
        btnFemale.isSelected = true
    }
    
    @IBAction func onClickBtnDone(_ sender: Any) {
        self.view.endEditing(true)
        if checkValidation() {
            if (preferenceHelper.getIsEmailVerification() || preferenceHelper.getIsPhoneNumberVerification()) && phoneNumberView.isUserInteractionEnabled {
                if !strForSocialId.isEmpty {
                    self.wsCheckUserExist()
                } else {
                    self.wsRegister()
                }
            } else {
                self.wsRegister()
            }
        }
    }

    @IBAction func onClickBtnCheckTC(_ sender: Any) {
        if btnCheckTC.isSelected {
            self.btnCheckTC.isSelected = false
            self.btnDone.isEnabled = false
            self.btnDone.alpha = 0.5
        } else {
            self.btnCheckTC.isSelected = true
            self.btnDone.isEnabled = true
            self.btnDone.alpha = 1
        }
    }

    @IBAction func onClickBtnBack(_ sender: Any) {
        let dialogForDataAlert = CustomAlertDialog.showCustomAlertDialog(title: "MSG_ARE_YOU_SURE".localized, message: "msg_not_save".localized, titleLeftButton: "TXT_NO".localized, titleRightButton: "TXT_YES".localized)
        dialogForDataAlert.onClickLeftButton = { [unowned dialogForDataAlert] in
            dialogForDataAlert.removeFromSuperview();
        }
        dialogForDataAlert.onClickRightButton = { [unowned self, unowned dialogForDataAlert] in
            dialogForDataAlert.removeFromSuperview();
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func onClickBtnCountryPhonecode(_ sender: Any) {
        openCountryDialog()
    }

    @IBAction func onClickBtnHideShowPassword(_ sender: Any) {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
        btnHideShowPassword.isSelected.toggle()
    }

    func openCountryDialog() {
        self.view.endEditing(true)
        let dialogForCountry  = CustomCountryDialog.showCustomCountryDialog()
        dialogForCountry.onCountrySelected = { [unowned self, unowned dialogForCountry] (country:Country) in
            self.txtNumber.text = ""
            self.strForCountryPhoneCode = country.code
            self.strForCountrycode = country.alpha2
            self.strForCountry = country.name
            self.btnCountryPhoneCode.setTitle(self.strForCountryPhoneCode, for: .normal)
            dialogForCountry.removeFromSuperview()
        }
    }

    func checkValidation() -> Bool {
        if txtFirstName.text?.isEmpty() ?? true {
            txtFirstName.showErrorWithText(errorText: "VALIDATION_MSG_ENTER_NAME".localized)
            return false
        }

        let validEmail = txtEmail.text!.checkEmailValidation()
        if validEmail.0 == false {
            txtEmail.showErrorWithText(errorText: validEmail.1)
            return false
        }

        let validPhoneNumber = txtNumber.text!.isValidMobileNumber()
        if validPhoneNumber.0 == false {
            txtNumber.showErrorWithText(errorText: validPhoneNumber.1)
            return false
        }

        let validPassword = txtPassword.text!.checkPasswordValidation()
        if validPassword.0 == false && strForSocialId.isEmpty() {
            txtPassword.showErrorWithText(errorText: validPassword.1)
            return false
        }

        if !self.btnCheckTC.isSelected {
            Utility.showToast(message: "MSG_PLEASE_AGREE_TERMS_CONDITON".localized)
            return false
        }
        return true
    }

    func onOtpDone() {
        wsRegister()
    }
}

extension RegisterVC:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtFirstName {
            _ = txtLastName.becomeFirstResponder()
        } else if textField == txtLastName {
            if txtEmail.isEnabled {
                _ = txtEmail.becomeFirstResponder()
            } else if txtNumber.isEnabled {
                _ = txtNumber.becomeFirstResponder()
            } else {
                self.onClickBtnDone(self.btnDone!)
            }
        } else if textField == txtEmail {
            if !txtPassword.isHidden {
                _ = txtPassword.becomeFirstResponder()
            }
        } else {
            self.onClickBtnDone(self.btnDone!)
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtNumber {
            if  (string == "") || string.count < 1 {
                return true
            }
            //Prevent "0" characters as the first characters.
            if textField.text?.count == 0 && string == "0" {
                return false
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtNumber{
            let result = textField.text?.isValidMobileNumber()
            if !result!.0 {
                self.txtNumber.text = ""
                Utility.showToast(message: "VALIDATION_MSG_ENTER_PHONE_NUMBER".localized)
            }
        }
    }
}

//MARK: - Web Service Calls
extension RegisterVC{
    func wsRegister() {
        Utility.showLoading()
        let afh:AlamofireHelper = AlamofireHelper.init()

        var  dictParam : [String : Any] = [:]
        strForPhoneNumber = txtNumber.text?.trim() ?? ""
        strForFirstName = txtFirstName.text?.trim() ?? ""
        strForLastName = txtLastName.text?.trim() ?? ""
        strForEmail = txtEmail.text?.trim() ?? ""

        let currentAppVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)

        dictParam[PARAMS.PHONE] = strForPhoneNumber
        dictParam[PARAMS.COUNTRY_PHONE_CODE] = strForCountryPhoneCode
        dictParam[PARAMS.APP_VERSION] = currentAppVersion
        dictParam[PARAMS.EMAIL] = strForEmail
        dictParam[PARAMS.LAST_NAME] = strForLastName
        dictParam[PARAMS.FIRST_NAME] = strForFirstName
        dictParam[PARAMS.COUNTRY_PHONE_CODE] = strForCountryPhoneCode
        dictParam[PARAMS.DEVICE_TOKEN] = preferenceHelper.getDeviceToken()
        dictParam[PARAMS.DEVICE_TYPE] = CONSTANT.IOS
        dictParam[PARAMS.DEVICE_TIMEZONE] = TimeZone.current.identifier
        dictParam[PARAMS.COUNTRY] = strForCountry
        dictParam[PARAMS.LOGIN_BY] = strLoginBy
        dictParam["gender_type"] = btnMale.isSelected ? 0 : 1
        dictParam["is_otp_verification_start_trip"] = true
        
        if strLoginBy != CONSTANT.MANUAL {
            dictParam[PARAMS.SOCIAL_UNIQUE_ID] = strForSocialId
            dictParam[PARAMS.PASSWORD] = ""
        } else {
            dictParam[PARAMS.SOCIAL_UNIQUE_ID] = ""
            dictParam[PARAMS.PASSWORD] = txtPassword.text ?? ""
        }

        afh.getResponseFromURL(url: WebService.REGISTER_USER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            printE(Utility.convertDictToJson(dict: response))
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.parseUserDetail(response: response) {
                    SentrySDK.setUser(Sentry.User(userId: CurrentTrip.shared.user.userId))

                    if !(CurrentTrip.shared.user.isReferral == TRUE) && CurrentTrip.shared.user.countryDetail.isReferral {
                        Utility.hideLoading()
                        self.performSegue(withIdentifier: SEGUE.REGISTER_TO_REFERRAL, sender: self)
                    } else if (CurrentTrip.shared.user.isDocumentUploaded == FALSE) {
                        APPDELEGATE.gotoDocument()
                    } else {
                        APPDELEGATE.gotoMap()
                    }
                    let authProvider = AuthProvider.Instance
                    authProvider.wsGenerateFirebaseAcessToken()
                } else {
                    Utility.hideLoading()
                }
            }
        }
    }

    func wsCheckUserExist() {
        Utility.showLoading()
        let afh:AlamofireHelper = AlamofireHelper.init()
        strForEmail = txtEmail.text?.trim() ?? ""
        strForPhoneNumber = txtNumber.text?.trim() ?? ""

        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.PHONE] = strForPhoneNumber
        dictParam[PARAMS.COUNTRY_PHONE_CODE] = strForCountryPhoneCode

        afh.getResponseFromURL(url: WebService.CHECK_USER_REGISTER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            printE(Utility.convertDictToJson(dict: response))
            if (error != nil) {
                Utility.hideLoading()
            } else {
                printE(Utility.convertDictToJson(dict: response))
                if Parser.isSuccess(response: response) {
                    let responseModel:ResponseModel = ResponseModel.init(fromDictionary: response)
                    if responseModel.message == MessageCode.USER_REGISTERED {
                        Utility.showToast(message: "error_user_register".localized)
                        Utility.hideLoading()
                    } else {
                        let isSmsOn:Bool = (response[PARAMS.USER_SMS] as? Bool) ?? false
                        preferenceHelper.setIsPhoneNumberVerification(isSmsOn)
                        if (preferenceHelper.getIsPhoneNumberVerification()) {
                            Utility.hideLoading()
                            let smsOtp:String = (response[PARAMS.SMS_OTP] as? String) ?? ""
                            if let otpvc:OtpVC =  AppStoryboard.PreLogin.instance.instantiateViewController(withIdentifier: "OtpVC") as? OtpVC {
                                otpvc.isFromCheckUser = true
                                self.present(otpvc, animated: true, completion: {
                                    otpvc.delegate = self
                                    otpvc.strForCountryPhoneCode = self.strForCountryPhoneCode
                                    otpvc.strForPhoneNumber = self.txtNumber.text?.trim() ?? ""
                                    otpvc.updateOtpUI(otpEmail: "", otpSms: smsOtp, emailOtpOn: false, smsOtpOn: true, isSocialLogin: false)
                                })
                            }
                        } else {
                            Utility.hideLoading()
                            self.wsRegister()
                        }
                    }
                } else {
                    Utility.hideLoading()
                }
            }
        }
    }
}
