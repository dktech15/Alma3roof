//
//  PhoneVC.swift
//  Eber
//
//  Created by Elluminati on 30/08/18.
//  Copyright © 2018 Elluminati. All rights reserved.
//

import UIKit

class PhoneVC: BaseVC,OtpDelegate
{
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnCountryPhoneCode: UIButton!
    @IBOutlet weak var txtPhoneNumber: ACFloatingTextfield!
    @IBOutlet weak var btnDone: UIButton!

    var strForCountryPhoneCode:String = CurrentTrip.shared.currentCountryPhoneCode
    var strForCountrycode:String = CurrentTrip.shared.currentCountryCode
    var strForCountryFlag:String = CurrentTrip.shared.currentCountryFlag
    var strForCountry:String = CurrentTrip.shared.currentCountry
    var isTappedOnCountryCode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
//        btnDone.setTitle(FontAsset.icon_forward_arrow, for: .normal)
//        btnDone.setRoundIconButton()
        btnDone.setTitleColor(UIColor.white,for:.normal)
        btnDone.titleLabel?.font = FontHelper.assetFont(size: 30)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnCountryPhoneCode.setTitle(strForCountryPhoneCode, for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = txtPhoneNumber.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initialViewSetup() {
        lblMessage.text = "TXT_INTRO_MSG".localized
        lblMessage.textColor = UIColor.themeTextColor
        lblMessage.font = FontHelper.font(size: FontSize.large, type: FontType.Regular)
        btnCountryPhoneCode.setTitle(strForCountryPhoneCode, for: .normal)
        btnCountryPhoneCode.setTitleColor(UIColor.themeButtonBackgroundColor, for: .normal)
        btnCountryPhoneCode.titleLabel?.font  = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        txtPhoneNumber.placeholder = "TXT_MOBILE_MSG".localized
        setTextFieldSetup(txtPhoneNumber)
//        btnBack.setupBackButton()
    }

    func onOtpDone() {
        self.performSegue(withIdentifier: SEGUE.PHONE_TO_REGISTER, sender: self)
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
    func setValueForCountryCode()  {
        self.strForCountrycode = CurrentTrip.shared.currentCountryCode
        print("self.strForCountrycode1", self.strForCountrycode)
    }
    //MARK: - Action Methods
    @IBAction func onClickBtnDone(_ sender: Any) {
        self.view.endEditing(true)
        if checkValidation() {
            wsCheckUserExist()
        }
    }

    @IBAction func onClickBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickBtnCountryPhonecode(_ sender: Any) {
        openCountryDialog()
    }

    func checkValidation() -> Bool {
        let validPhoneNumber = txtPhoneNumber.text!.isValidMobileNumber()
        if validPhoneNumber.0 == false {
            txtPhoneNumber.showErrorWithText(errorText: validPhoneNumber.1)
            return false
        }
        return true
    }

    func openCountryDialog() {
        self.isTappedOnCountryCode = true
        self.view.endEditing(true)
        let dialogForCountry  = CustomCountryDialog.showCustomCountryDialog()
        dialogForCountry.onCountrySelected = { [unowned self, unowned dialogForCountry] (country:Country) in
            printE(country.name!)
            self.strForCountryPhoneCode = country.code
            self.strForCountry = country.name
            self.strForCountrycode = country.alpha2
            self.txtPhoneNumber.text = ""
            self.btnCountryPhoneCode.setTitle(self.strForCountryPhoneCode, for: .normal)
            dialogForCountry.removeFromSuperview()
        }
    }
    func getCountryValue() {
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE.PHONE_TO_PASSWORD {
            if let destinationVc = segue.destination as? PasswordVC {
                destinationVc.strForCountryPhoneCode = strForCountryPhoneCode
                destinationVc.strForPhoneNumber = txtPhoneNumber.text ?? ""
            }
        } else if segue.identifier == SEGUE.PHONE_TO_REGISTER {
            if let destinationVc = segue.destination as? RegisterVC {
                destinationVc.strForCountryPhoneCode = strForCountryPhoneCode
                destinationVc.strForPhoneNumber = txtPhoneNumber.text ?? ""
                destinationVc.strForCountry = strForCountry
                destinationVc.strLoginBy = CONSTANT.MANUAL
            }
        }
    }
}

extension PhoneVC:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onClickBtnDone(self)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtPhoneNumber {
            if (string == "") || string.count < 1 {
                return true
            }
            //Prevent "0" characters as the first characters.
            if textField.text?.count == 0 && string == "0" {
                return false
            }
        }
        return true;
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtPhoneNumber {
            if(!isTappedOnCountryCode) {
                self.strForCountrycode = CurrentTrip.shared.currentCountryCode
            }
            print("self.strForCountrycode",self.strForCountrycode)
            let result = textField.text?.isValidMobileNumber()
            if !result!.0 {
                txtPhoneNumber.showErrorWithText(errorText: "VALIDATION_MSG_INVALID_PHONE_NUMBER".localized)
            }
        }
    }
}

extension PhoneVC
{
    func wsCheckUserExist() {
        Utility.showLoading()
        let dictParam : [String : Any] =
            [ PARAMS.PHONE:txtPhoneNumber.text?.trim() ?? "",
              PARAMS.COUNTRY_PHONE_CODE : strForCountryPhoneCode];

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.CHECK_USER_REGISTER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            printE(Utility.convertDictToJson(dict: response))
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response: response) {
                    let responseModel:ResponseModel = ResponseModel.init(fromDictionary: response)
                    if responseModel.message == MessageCode.USER_REGISTERED {
                        Utility.hideLoading()
                        self.performSegue(withIdentifier: SEGUE.PHONE_TO_PASSWORD, sender: self)
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
                                    otpvc.strForPhoneNumber = self.txtPhoneNumber.text?.trim() ?? ""
                                    otpvc.updateOtpUI(otpEmail: "", otpSms: smsOtp, emailOtpOn: false, smsOtpOn: true, isSocialLogin: false)
                                })
                            }
                        } else {
                            self.performSegue(withIdentifier: SEGUE.PHONE_TO_REGISTER, sender: self)
                            Utility.hideLoading()
                        }
                    }
                } else {
                    Utility.hideLoading()
                }
            }
        }
    }
}
