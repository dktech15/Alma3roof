//
//  NewPasswordVC.swift
//  Eber
//
//  Created by Elluminati on 30/08/18.
//  Copyright © 2018 Elluminati. All rights reserved.
//

import UIKit

class NewPasswordVC: BaseVC
{
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var vwPassword: UIView!
    @IBOutlet weak var txtPassword: ACFloatingTextfield!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnHideShowPassword: UIButton!

    var strForCountryPhoneCode:String =  CurrentTrip.shared.arrForCountries[0].code
    var strForPhoneNumber:String =  ""

    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
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
        lblMessage.text = "TXT_NEW_PASSWORD_MSG".localized
        lblMessage.textColor = UIColor.themeTextColor
        lblMessage.font = FontHelper.font(size: FontSize.large, type: FontType.Regular)
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
    }

    func setTextFieldSetup(_ textField:UITextField) {
        let windowFrame :CGRect = APPDELEGATE.window?.frame ?? self.view.bounds
        let toolBarView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: windowFrame.size.width, height: 100))
        let btnDone:UIButton = UIButton.init(type: UIButton.ButtonType.custom)

        btnDone.frame = CGRect.init(x: windowFrame.size.width - 100, y: 10, width: 70, height: 70)
        btnDone.addTarget(self, action: #selector(self.onClickBtnDone(_:)), for: .touchUpInside)

        toolBarView.backgroundColor = UIColor.clear
        toolBarView.addSubview(btnDone)
        textField.inputAccessoryView = toolBarView;
    }

    //MARK: - Action Methods
    @IBAction func onClickBtnDone(_ sender: Any) {
        self.view.endEditing(true)
        let validPassword = txtPassword.text!.checkPasswordValidation()
        if validPassword.0 == false {
            txtPassword.showErrorWithText(errorText: validPassword.1)
        } else {
            wsChangePassword()
        }
    }

    @IBAction func onClickBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickBtnHideShowPassword(_ sender: Any) {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
        btnHideShowPassword.isSelected.toggle()
    }
}

extension NewPasswordVC:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onClickBtnDone(self)
        return true
    }
}

extension NewPasswordVC
{
    func wsChangePassword() {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.PHONE] = strForPhoneNumber
        dictParam[PARAMS.COUNTRY_PHONE_CODE] = strForCountryPhoneCode
        dictParam[PARAMS.PASSWORD] = txtPassword.text!

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.CHANGE_PASSWORD, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { /*[unowned self]*/ (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response: response, withSuccessToast: true) {
                    Utility.hideLoading()
                    APPDELEGATE.gotoLogin()
                } else {
                    Utility.hideLoading()
                }
            }
        }
    }
}
