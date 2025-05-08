//
//  PasswordVC.swift
//  Eber
//
//  Created by Elluminati on 30/08/18.
//  Copyright © 2018 Elluminati. All rights reserved.
//

import UIKit

class PasswordVC: BaseVC
{
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var vwPassword: UIView!
    @IBOutlet weak var txtPassword: ACFloatingTextfield!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnHideShowPassword: UIButton!
    @IBOutlet weak var btnLoginOTP: UIButton!

    var strForCountryPhoneCode:String = CurrentTrip.shared.arrForCountries[0].code
    var strForPhoneNumber:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        btnLoginOTP.isHidden = !preferenceHelper.getIsLoginWithOTP()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = txtPassword.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initialViewSetup() {
        lblMessage.text = "TXT_SIGN_IN_MSG".localized
        lblMessage.textColor = UIColor.themeTextColor
        lblMessage.font = FontHelper.font(size: FontSize.large, type: FontType.Regular)
        btnForgotPassword.setTitle("TXT_FORGOT_PASSWORD".localizedCapitalized, for: .normal)
        btnForgotPassword.setTitleColor(UIColor.themeButtonBackgroundColor, for: .normal)
        btnForgotPassword.titleLabel?.font  = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        txtPassword.placeholder = "TXT_PASSWORD".localized
        setTextFieldSetup(txtPassword)
//        btnBack.setupBackButton()
//        btnDone.setTitle(FontAsset.icon_forward_arrow, for: .normal)
//        btnDone.setRoundIconButton()
        btnDone.setTitleColor(UIColor.white,for:.normal)
        btnDone.titleLabel?.font = FontHelper.assetFont(size: 30)
//        btnHideShowPassword.setTitle(FontAsset.icon_hide_password, for: .normal)
//        btnHideShowPassword.setTitle(FontAsset.icon_show_password, for: .selected)
//        btnHideShowPassword.setSimpleIconButton()
//        btnHideShowPassword.titleLabel?.font = FontHelper.assetFont(size: 25)
        btnHideShowPassword.setImage(UIImage(named: "asset-password-hide_u") , for: .normal)
        btnHideShowPassword.setImage(UIImage(named: "asset-password-show_u"), for: .selected)
        btnHideShowPassword.tintColor = UIColor.themeImageColor
        
        btnLoginOTP.setTitle("txt_login_with_otp".localized, for: .normal)
        btnLoginOTP.setTitleColor(.themeButtonBackgroundColor, for: .normal)
        btnLoginOTP.titleLabel?.font = FontHelper.font(type: .Regular)
    }

    func setTextFieldSetup(_ textField:UITextField) {
        let windowFrame :CGRect = APPDELEGATE.window?.frame ?? self.view.bounds
        let toolBarView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: windowFrame.size.width, height: 100))
        let btnDone:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
        btnDone.frame = CGRect.init(x: windowFrame.size.width - 100, y: 10, width: 70, height: 70)
        btnDone.addTarget(self, action: #selector(self.onClickBtnDone(_:)), for: .touchUpInside)
//        btnDone.setTitle(FontAsset.icon_forward_arrow, for: .normal)
//        btnDone.setRoundIconButton()
        btnDone.setImage(UIImage(named: "asset-right_u"), for: .normal)
        btnDone.tintColor = .themeButtonTitleColor
        btnDone.setRound(andCornerRadious: btnDone.frame.size.height/2)
        btnDone.backgroundColor = .themeButtonBackgroundColor
        btnDone.setTitleColor(UIColor.white,for:.normal)
        btnDone.titleLabel?.font = FontHelper.assetFont(size: 30)
        toolBarView.backgroundColor = UIColor.clear
        toolBarView.addSubview(btnDone)
        textField.inputAccessoryView = toolBarView;
    }

    //MARK: - Action Methods
    @IBAction func onClickBtnDone(_ sender: Any) {
        self.view.endEditing(true)
        if checkValidation() {
            self.wsLogin()
        }
    }

    @IBAction func onClickBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickBtnForgotPassword(_ sender: Any) {
        self.performSegue(withIdentifier: SEGUE.PASSWORD_TO_FORGOT_PASSWORD, sender: self)
    }
    
    @IBAction func onClickBtnLoginWithOTP(_ sender: Any) {
        txtPassword.text = ""
        wsGetOtp()
    }

    @IBAction func onClickBtnHideShowPassword(_ sender: Any) {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
        btnHideShowPassword.isSelected.toggle()
    }

    func checkValidation() -> Bool {
        let validPassword = txtPassword.text!.checkPasswordValidation()
        if validPassword.0 == false {
            txtPassword.showErrorWithText(errorText: validPassword.1)
            return false
        } else {
            return true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE.PASSWORD_TO_FORGOT_PASSWORD {
            if let destinationVC = segue.destination as? ForgotPasswordVC {
                destinationVC.strForCountryPhoneCode = strForCountryPhoneCode
                destinationVC.strForPhoneNumber = strForPhoneNumber
            }
        }
    }
}

extension PasswordVC:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onClickBtnDone(self)
        return true
    }
}

//MARK: - Web Service Calls
extension PasswordVC
{
    func wsLogin(otp: String? = nil) {
        self.view.endEditing(true)
        Utility.showLoading()
        
        var dictParam : [String : Any] = [:]
        let currentAppVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
        dictParam[PARAMS.APP_VERSION] = currentAppVersion
        dictParam[PARAMS.EMAIL] = strForPhoneNumber
        dictParam[PARAMS.COUNTRY_PHONE_CODE] = strForCountryPhoneCode
        dictParam[PARAMS.DEVICE_TIMEZONE] = TimeZone.current.identifier
        dictParam[PARAMS.DEVICE_TYPE] = CONSTANT.IOS
        dictParam[PARAMS.SOCIAL_UNIQUE_ID] = ""
        dictParam[PARAMS.DEVICE_TOKEN] = preferenceHelper.getDeviceToken()
        dictParam[PARAMS.LOGIN_BY] = CONSTANT.MANUAL
        dictParam[PARAMS.PASSWORD] = txtPassword.text
        dictParam[PARAMS.PHONE] = strForPhoneNumber
        
        if let otp = otp {
            dictParam[PARAMS.otp_sms] = otp
        }

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.LOGIN_USER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.parseUserDetail(response: response) {
                    if !(CurrentTrip.shared.user.isReferral == TRUE) && CurrentTrip.shared.user.countryDetail.isReferral {
                        Utility.hideLoading()
                        self.performSegue(withIdentifier: SEGUE.LOGIN_TO_REFERRAL, sender: self)
                    } else if (CurrentTrip.shared.user.isDocumentUploaded == FALSE) {
                        APPDELEGATE.gotoDocument()
                    } else {
                        self.wsGetTripStatus()
                    }
                    let authProvider = AuthProvider.Instance
                    authProvider.wsGenerateFirebaseAcessToken()
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
        dictParam[PARAMS.TYPE] = 2
        
        afh.getResponseFromURL(url: WebService.GET_OTP, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if Parser.isSuccess(response: response) {
                let smsOtp:String = (response[PARAMS.SMS_OTP] as? String) ?? ""
                if let otpvc:OtpVC =  AppStoryboard.PreLogin.instance.instantiateViewController(withIdentifier: "OtpVC") as? OtpVC {
                    otpvc.delegate = self
                    otpvc.isFromLoginWithOTP = true
                    self.present(otpvc, animated: true, completion: {
                        otpvc.strForCountryPhoneCode = self.strForCountryPhoneCode
                        otpvc.strForPhoneNumber = self.strForPhoneNumber
                        otpvc.updateOtpUI(otpEmail: "", otpSms: smsOtp, emailOtpOn: false, smsOtpOn: true, isSocialLogin: false)
                    })
                }
            }
        }
    }

    func wsGetTripStatus() {
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.CHECK_TRIP_STATUS, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { /*[unowned self]*/ (response, error) -> (Void) in
            if (error != nil) {} else {
                if Parser.isSuccess(response: response,withSuccessToast: false,andErrorToast: false) {
                    CurrentTrip.shared.tripStaus = TripStatusResponse.init(fromDictionary: response)
                    CurrentTrip.shared.tripId = CurrentTrip.shared.tripStaus.trip.id
                    if CurrentTrip.shared.tripStaus.trip.isProviderAccepted == TRUE {
                        APPDELEGATE.gotoTrip()
                    } else {
                        APPDELEGATE.gotoMap()
                    }
                } else {
                    APPDELEGATE.gotoMap()
                }
            }
        }
    }
}

extension PasswordVC: OtpDelegate
{
    func onOtpDone() {
        //
    }
    
    func onOtpDone(otp: String) {
        wsLogin(otp: otp)
    }
}
