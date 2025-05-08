//
//  ProfileVC.swift
//  Eber
//
//  Created by Elluminati on 28/02/17.
//  Copyright © 2017 Elluminati. All rights reserved.
//

import UIKit

class ProfileVC: BaseVC,OtpDelegate {

    //MARK: - Outlets Declaration
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationHeight: NSLayoutConstraint!
    @IBOutlet weak var scrProfile: UIScrollView!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var btnSelectCountry: UIButton!
    @IBOutlet weak var txtFirstName: ACFloatingTextfield!
    @IBOutlet weak var txtLastName: ACFloatingTextfield!
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var txtMobileNumber: ACFloatingTextfield!
    @IBOutlet weak var txtNewPassword: ACFloatingTextfield!
    @IBOutlet weak var btnChangePicuture: UIButton!
    @IBOutlet var btnHideShowPassword: UIButton!
    @IBOutlet var btnHidePassword: UIButton!
    
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet var imgHideShowPassword: UIImageView!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var viewForNewPassword: UIView!
    @IBOutlet weak var btnChangePassword: UIButton!
    @IBOutlet weak var btnDeleteAccount: UIButton!

    //MARK: - Variable Declaration
    var arrForCountryList:[Country] = []
    var selectedCountryObj = Country(fromDictionary: [:])
    var isPicAdded:Bool = false
    var phoneNumberLength = 10
    var dialogForImage:CustomPhotoDialog?;
    var password:String = "";
    var strCountryId:String? = ""
    var strForCountryPhoneCode:String = ""
    var strForCountrycode:String = ""
    let user = CurrentTrip.shared.user

    //MARK: - View LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imgProfilePic.contentMode = .scaleAspectFit
        
//        if CurrentTrip.shared.arrForCountries.isEmpty
//        {
//            wsGetCountries()
//        }
        initialViewSetup()
        
        if user.socialUniqueId.isEmpty
        {
            viewForNewPassword.isHidden = false
        }
        else
        {
            viewForNewPassword.isHidden = true
        }
       setProfileData();
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews();
    }
    
    @IBAction func onClickBtnHideShowPassword(_ sender: Any) {
        txtNewPassword.isSecureTextEntry = !txtNewPassword.isSecureTextEntry
//        btnHideShowPassword.isSelected.toggle()
        if txtNewPassword.isSecureTextEntry{
            imgHideShowPassword.image = UIImage(named: "asset-password-hide")
        }else{
            imgHideShowPassword.image = UIImage(named: "asset-password-show")
        }
        
    }
    
    override func viewDidLayoutSubviews(){
       super.viewDidLayoutSubviews();
       navigationView.navigationShadow()
       imgProfilePic.setRound()
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
    }
    
    func  initialViewSetup()
    {
        
        view.backgroundColor = UIColor.themeViewBackgroundColor;
        self.scrProfile.backgroundColor = UIColor.themeViewBackgroundColor;
        lblTitle.text = "TXT_PROFILE".localizedCapitalized
        lblTitle.font = FontHelper.font(size: FontSize.medium
            , type: FontType.Bold)
        lblTitle.textColor = UIColor.themeTextColor
        btnDeleteAccount.setTitle("txt_delete_account".localized, for: .normal)
        btnDeleteAccount.setTitleColor(.red, for: .normal)
        btnChangePassword.setTitleColor(UIColor.themeTextColor, for: .normal)
        btnChangePassword.setTitleColor(UIColor.themeTextColor, for: .selected)
        btnChangePassword.setTitle("TXT_CHANGE".localizedCapitalized, for: .normal)
        btnChangePassword.setTitle("TXT_CANCEL".localizedCapitalized, for: .selected)
        txtFirstName.placeholder = "TXT_FIRST_NAME".localized
        txtFirstName.text = "".localized
        txtLastName.placeholder = "TXT_LAST_NAME".localized
        txtLastName.text = "".localized
        txtEmail.placeholder = "TXT_EMAIL".localized
        txtEmail.text = "".localized
        txtNewPassword.placeholder = "TXT_NEW_PASSWORD".localized
        txtNewPassword.text = "".localized
        txtMobileNumber.placeholder = "TXT_PHONE_NO".localized
        txtMobileNumber.text = "".localized
        btnSelectCountry.setTitle("TXT_DEFAULT".localizedCapitalized, for: .normal)
        btnSelectCountry.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnSelectCountry.setTitleColor(UIColor.themeButtonBackgroundColor  , for: .normal)
        btnSave.setImage(UIImage(named: "asset-edit"), for: .normal)
        btnSave.setImage(UIImage(named: "asset-selected"), for: .selected)
        
        btnMale.setImage(UIImage(named: "asset-radio-normal"), for: .normal)
        btnMale.setImage(UIImage(named: "asset-radio-selected"), for: .selected)
        btnMale.tintColor = UIColor.themeImageColor
        btnFemale.setImage(UIImage(named: "asset-radio-normal"), for: .normal)
        btnFemale.setImage(UIImage(named: "asset-radio-selected"), for: .selected)
        btnFemale.tintColor = UIColor.themeImageColor
        
//        btnSave.setTitle(FontAsset.icon_edit, for: .normal)
//        btnSave.setTitle(FontAsset.icon_checked, for: .selected)
//        btnSave.setTitleColor(UIColor.themeTextColor  , for: .normal)
//        btnSave.setUpTopBarButton()
//        btnHideShowPassword.setImage(UIImage(named: "asset-password-hide") , for: .normal)
//        btnHideShowPassword.setImage(UIImage(named: "asset-password-show"), for: .selected)
        imgHideShowPassword.image = UIImage(named: "asset-password-hide")
//        btnHideShowPassword.tintColor = UIColor.themeImageColor
//        btnHideShowPassword.setTitle(FontAsset.icon_hide_password, for: .normal)
//        btnHideShowPassword.setTitle(FontAsset.icon_show_password  , for: .selected)
//        btnHideShowPassword.titleLabel?.font = FontHelper.assetFont(size: 25)
//        btnHideShowPassword.setSimpleIconButton()
//        btnMenu.setupBackButton()
    }

    func onOtpDone() {
        self.openVerifyAccountDialog()
    }

    @IBAction func onClickBtnCountryDialog(_ sender: Any) {
        openCountryDialog()
    }

    //MARK: - Action Methods
    @IBAction func onClickBtnChangePassword(_ sender: Any) {
        self.view.endEditing(true)
        txtNewPassword.text = ""
        btnChangePassword.isSelected = !btnChangePassword.isSelected
        txtNewPassword.isEnabled = !txtNewPassword.isEnabled
        if btnChangePassword.isSelected {
           _ =  txtNewPassword.becomeFirstResponder()
        }
    }

    @IBAction func onClickBtnSave(_ sender: Any) {
        self.view.endEditing(true)
        editProfile()
        btnSave.setImage(UIImage(named: "asset-selected"), for: .normal)
//        btnSave.setTitle(FontAsset.icon_checked, for: .normal)
    }

    @IBAction func btnOnClickFemale(_ sender: Any) {
//        btnMale.isSelected = false
//        btnFemale.isSelected = true
    }
    
    @IBAction func onClickBtnMale(_ sender: Any) {
//        btnMale.isSelected = true
//        btnFemale.isSelected = false
    }
    
    
    @IBAction func onClickBtnEditImage(_ sender: Any) {
        openImageDialog()
    }

    func openImageDialog() {
        self.view.endEditing(true)
        dialogForImage = CustomPhotoDialog.showPhotoDialog("TXT_SELECT_IMAGE".localized, allowEditing: true, andParent: self)
        dialogForImage?.onImageSelected = { [unowned self, weak dialogForImage = self.dialogForImage] (image:UIImage) in
            self.imgProfilePic.image = image
            self.isPicAdded = true
            dialogForImage?.removeFromSuperviewAndNCObserver()
            dialogForImage = nil
        }
    }

    //MARK: - User Define Methods
    func checkValidation() -> Bool {
        let validEmail = txtEmail.text!.checkEmailValidation()
        if validEmail.0 == false {
            txtEmail.showErrorWithText(errorText: validEmail.1)
            scrProfile.scrollRectToVisible(txtEmail.frame, animated: true)
            return false
        }

        let validPhoneNumber = txtMobileNumber.text!.isValidMobileNumber()
        if validPhoneNumber.0 == false {
            txtMobileNumber.showErrorWithText(errorText: validPhoneNumber.1)
            scrProfile.scrollRectToVisible(txtMobileNumber.frame, animated: true)
            return false
        }

        let validPassword = txtNewPassword.text!.checkPasswordValidation()
        if validPassword.0 == false && txtNewPassword.isEnabled {
            txtNewPassword.showErrorWithText(errorText: validPassword.1)
            scrProfile.scrollRectToVisible(txtNewPassword.frame, animated: true)
            return false
        } else {
            return true
        }
    }

    func enableTextFields(enable:Bool) -> Void {
        txtFirstName.isEnabled = enable
        txtLastName.isEnabled = enable
        txtMobileNumber.isEnabled = enable
        txtEmail.isEnabled = enable
        txtNewPassword.isEnabled = false
        btnChangePassword.isEnabled = enable
        btnChangePicuture.isEnabled = enable
        btnHideShowPassword.isEnabled = enable
//        btnHidePassword.isEnabled = enable
    }

    func setProfileData() {
        txtFirstName.text = user.firstName
        txtLastName.text = user.lastName
        txtMobileNumber.text = user.phone;
        btnSelectCountry.setTitle(user.countryPhoneCode, for: .normal)
        btnChangePassword.isSelected = false
        txtEmail.text = user.email
        txtNewPassword.isHidden = false

        if !user.picture.isEmpty {
            imgProfilePic.downloadedFrom(link: user.picture)
        }

        strForCountryPhoneCode = user.countryPhoneCode
        strForCountrycode = CurrentTrip.shared.currentCountryCode
        
        user.gender_type == 0 ? (btnMale.isSelected = true) : (btnMale.isSelected = false)
        user.gender_type == 1 ? (btnFemale.isSelected = true) : (btnFemale.isSelected = false)
        btnFemale.isUserInteractionEnabled = false
        btnMale.isUserInteractionEnabled = false
        enableTextFields(enable: false)
    }

    func editProfile() -> Void {
        if (!txtFirstName.isEnabled) {
            enableTextFields(enable: true)
            _ = txtFirstName.becomeFirstResponder()
        } else {
            if (checkValidation()) {
                switch (self.checkWhichOtpValidationON()) {
                case CONSTANT.SMS_AND_EMAIL_VERIFICATION_ON:
                    wsGetOtp(isEmailOtpOn: true, isSmsOtpOn: true)
                    break;
                case CONSTANT.SMS_VERIFICATION_ON:
                    wsGetOtp(isEmailOtpOn: false, isSmsOtpOn: true)
                    break;
                case CONSTANT.EMAIL_VERIFICATION_ON:
                    wsGetOtp(isEmailOtpOn: true, isSmsOtpOn: false)
                    break;
                default:
                    self.openVerifyAccountDialog();
                    break;
                }
            }
        }
    }

    @IBAction func onClickBtnMenu(_ sender: Any) {
        if let navigationVC: UINavigationController = self.revealViewController()?.mainViewController as? UINavigationController {
            navigationVC.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func onClickDeleteAccount(_ sender: Any) {
        self.view.endEditing(true)
        let dailog = CustomAlertDialog.showCustomAlertDialog(title: "TXT_CONFIRM".localized, message: "txt_are_you_sure_account_delete".localized, titleLeftButton: "TXT_NO".localizedCapitalized, titleRightButton: "TXT_YES".localized)
        dailog.onClickRightButton = { [weak self] in
            dailog.removeFromSuperview()
            guard let self = self else { return }
            self.openVerifyAccountDialog(isDelete: true)
        }
        dailog.onClickLeftButton = {
            dailog.removeFromSuperview()
        }
    }

    //MARK: - Dialog Methods
    func checkWhichOtpValidationON() -> Int {
        if (checkEmailVerification() && checkPhoneNumberVerification()) {
            return CONSTANT.SMS_AND_EMAIL_VERIFICATION_ON;
        } else if (checkPhoneNumberVerification()) {
            return CONSTANT.SMS_VERIFICATION_ON;
        } else if (checkEmailVerification()) {
            return CONSTANT.EMAIL_VERIFICATION_ON;
        }
        return 0;
    }

    func checkEmailVerification() -> Bool {
        return preferenceHelper.getIsEmailVerification() && !(txtEmail.text!.compare(user.email) == ComparisonResult.orderedSame)
    }

    func checkPhoneNumberVerification() -> Bool {
        return preferenceHelper.getIsPhoneNumberVerification() && !(txtMobileNumber.text! == user.phone)
    }

    func openVerifyAccountDialog(isDelete: Bool = false) {
        self.view.endEditing(true)
        if !user.socialUniqueId.isEmpty {
            self.password = ""
            if isDelete {
                self.wsDeleteAccount()
            } else {
                self.wsUpdateProfile()
            }
        } else {
            let dialogForVerification = CustomVerificationDialog.showCustomVerificationDialog(title: "TXT_VERIFY_ACCOUNT".localized, message: "".localized, titleLeftButton: "TXT_NO".localized, titleRightButton: "TXT_YES".localized, editTextHint: "TXT_CURRENT_PASSWORD".localized,  editTextInputType: true)
            dialogForVerification.onClickLeftButton = { [unowned dialogForVerification] in
                dialogForVerification.removeFromSuperview();
            }
            dialogForVerification.onClickRightButton = { [unowned self, unowned dialogForVerification] (text:String) in
                let validPassword = text.checkPasswordValidation()
                if validPassword.0 == false {
                    dialogForVerification.editText.showErrorWithText(errorText: validPassword.1)
                } else {
                    self.password = text
                    if isDelete {
                        self.wsDeleteAccount()
                    } else {
                        self.wsUpdateProfile();
                    }
                    dialogForVerification.removeFromSuperview();
                }
            }
        }
    }

    func openCountryDialog() {
        self.view.endEditing(true)
        self.view.endEditing(true)

        let dialogForCountry  = CustomCountryDialog.showCustomCountryDialog()
        dialogForCountry.onCountrySelected = { [unowned self, unowned dialogForCountry] (country:Country) in
            printE(country.name!)
            if country.code != self.strForCountryPhoneCode {
                self.txtMobileNumber.text = ""
                self.strForCountryPhoneCode = country.code
                self.strForCountrycode = country.alpha2
                self.btnSelectCountry.setTitle(self.strForCountryPhoneCode, for: .normal)
            }
            dialogForCountry.removeFromSuperview()
        }
    }
}

//MARK: - UITextField Delegate Methods
extension ProfileVC :UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtFirstName {
            _ = txtLastName.becomeFirstResponder()
        } else if textField == txtLastName {
            _ = txtEmail.becomeFirstResponder()
        } else if textField == txtEmail {
            _ = txtMobileNumber.becomeFirstResponder()
        } else if textField == txtMobileNumber {
            _ = textField.resignFirstResponder();
        } else {
            _ = textField.resignFirstResponder();
            return true
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtMobileNumber {
            if  (string == "") || string.count < 1 {
                return true
            }
            //Prevent "0" characters as the first characters.
            if textField.text?.count == 0 && string == "0" {
                return false
            }
        }
        return true;
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//MARK: - Web Service Calls
extension ProfileVC
{
    func wsUpdateProfile()
    {
        let name = txtFirstName.text!.trim()
        let lastname = txtLastName.text!.trim()
       
        let dictParam : [String : Any] =
            [PARAMS.FIRST_NAME : name,
             PARAMS.LAST_NAME  : lastname  ,
             PARAMS.EMAIL      : txtEmail.text!  ,
             PARAMS.OLD_PASSWORD: password  ,
             PARAMS.NEW_PASSWORD: txtNewPassword.text ?? "",
             PARAMS.LOGIN_BY   : CONSTANT.MANUAL ,
             PARAMS.COUNTRY_PHONE_CODE  :strForCountryPhoneCode ,
             PARAMS.PHONE : txtMobileNumber.text! ,
             PARAMS.DEVICE_TYPE: CONSTANT.IOS,
             PARAMS.DEVICE_TOKEN:preferenceHelper.getDeviceToken(),
             PARAMS.TOKEN: preferenceHelper.getSessionToken(),
             PARAMS.USER_ID: preferenceHelper.getUserId(),
             PARAMS.SOCIAL_UNIQUE_ID: user.socialUniqueId!,
             "gender_type" : btnMale.isSelected ? 0 : 1
        ]
        let alamoFire:AlamofireHelper = AlamofireHelper();
        Utility.showLoading()
        if isPicAdded
        {
            alamoFire.getResponseFromURL(url: WebService.UPADTE_PROFILE, paramData: dictParam, image: imgProfilePic.image) { [unowned self] (response, error) -> (Void) in
                Utility.hideLoading()
                if Parser.parseUserDetail(response: response)
                {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        else
        {
            alamoFire.getResponseFromURL(url: WebService.UPADTE_PROFILE, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
            { [unowned self] (response, error) -> (Void) in
                Utility.hideLoading()
                if Parser.parseUserDetail(response: response)
                {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
       
    }
    
    func wsDeleteAccount() {
        Utility.showLoading()
        
        let dictParam : [String : Any] =
            [
                PARAMS.USER_ID : preferenceHelper.getUserId(),
                PARAMS.PASSWORD : self.password,
                PARAMS.SOCIAL_ID : CurrentTrip.shared.user.socialUniqueId ?? "",
                PARAMS.TOKEN : preferenceHelper.getSessionToken()
        ]
        
        let alamoFire:AlamofireHelper = AlamofireHelper();
        
        alamoFire.getResponseFromURL(url: WebService.WS_DELETE_USER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) {(response, error) -> (Void) in
            Utility.hideLoading()
            if Parser.isSuccess(response: response) {
                CurrentTrip.shared.clearUserData()
                preferenceHelper.setUserId("")
                preferenceHelper.setSessionToken("")
                preferenceHelper.removeImageBaseUrl()
                UIViewController.clearPBRevealVC()
                APPDELEGATE.gotoLogin()
            }
        }
    }
    
    func wsGetOtp(isEmailOtpOn:Bool,isSmsOtpOn:Bool)
    {
        Utility.showLoading()
        let afh:AlamofireHelper = AlamofireHelper.init()
        let strForEmail = txtEmail.text?.trim() ?? ""
        let strPhoneNumber = txtMobileNumber.text?.trim() ?? ""
        
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.PHONE] = strPhoneNumber
        dictParam[PARAMS.COUNTRY_PHONE_CODE] = strForCountryPhoneCode
        dictParam[PARAMS.EMAIL] = strForEmail
        dictParam[PARAMS.TYPE] = CONSTANT.TYPE_USER
        
        afh.getResponseFromURL(url: WebService.GET_VERIFICATION_OTP, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            printE(Utility.convertDictToJson(dict: response))
            if (error != nil)
            {
                Utility.hideLoading()
            }
            else
            {
                Utility.hideLoading()
                if Parser.isSuccess(response: response)
                {
                    let smsOtp:String = (response[PARAMS.SMS_OTP] as? String) ?? ""
                    let emailOtp:String = (response[PARAMS.EMAIL_OTP] as? String) ?? ""
                    if let otpvc:OtpVC =  AppStoryboard.PreLogin.instance.instantiateViewController(withIdentifier: "OtpVC") as? OtpVC
                    {
                        otpvc.isFromCheckUser = true
                        self.present(otpvc, animated: true, completion: {
                            
                            otpvc.delegate = self
                            otpvc.strForCountryPhoneCode = self.strForCountryPhoneCode
                            otpvc.strForPhoneNumber = strPhoneNumber
                            otpvc.updateOtpUI(otpEmail: emailOtp, otpSms: smsOtp, emailOtpOn: isEmailOtpOn , smsOtpOn: isSmsOtpOn, isSocialLogin: !self.user.socialUniqueId.isEmpty)
                        })
                    }
                    
                }
                else
                {
                    Utility.hideLoading()
                }
            }
        }
    }
}
