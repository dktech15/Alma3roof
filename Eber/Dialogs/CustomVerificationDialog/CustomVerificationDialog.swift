//
//  CustomPhotoDialog.swift
//  Eber
//
//  Created by Elluminati on 22/02/17.
//  Copyright © 2017 Elluminati. All rights reserved.
//

import Foundation
import UIKit

public class CustomVerificationDialog: CustomDialog, UITextFieldDelegate
{
    //MARK: - OUTLETS
    @IBOutlet weak var stkDialog: UIStackView!
    @IBOutlet weak var stkBtns: UIStackView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPromoTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var vwEditText: UIView!
    @IBOutlet weak var btnHideShowPassword: UIButton!
    @IBOutlet weak var editText: ACFloatingTextfield!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var btnOffer: UIButton!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var viewPromoList: UIView!
    @IBOutlet weak var viewPromo: UIView!
    @IBOutlet weak var tablePromo : UITableView!
    @IBOutlet weak var constraintPromoHeight : NSLayoutConstraint!
    @IBOutlet weak var viewApplyButton: UIView!
    @IBOutlet weak var viewPromoText: UIView!
    @IBOutlet weak var txtPromo: UITextField!
    
    //MARK: - Variables
    var onClickRightButton : ((_ text:String ) -> Void)? = nil
    var onClickLeftButton : (() -> Void)? = nil
    var listPromoCode = [PromoCode]()
    var countryId = ""
    var cityId = ""
    var minimumAmount : Double?
    
    static let verificationDialog = "dialogForVerification"
    
    var doubleValidation = false {
        didSet {
            if doubleValidation {
                editText.delegate = self
                editText.keyboardType = .decimalPad
            } else {
                editText.delegate = nil
                editText.keyboardType = .default
            }
        }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
    }

    public static func showCustomVerificationDialog
        (title:String,
         message:String,
         titleLeftButton:String,
         titleRightButton:String,
         editTextHint:String,
         editTextInputType:Bool = false,
         offerbutton:Bool = false,
         countryId:String = "",
         cityId:String = "") -> CustomVerificationDialog {

        let view = UINib(nibName: verificationDialog, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomVerificationDialog
        view.alertView.setShadow()
        view.viewPromo.setShadow()
        let frame = (APPDELEGATE.window?.frame)!;
        view.frame = frame;
        
        view.countryId = countryId
        view.cityId = cityId
        view.lblTitle.text = title;
        
        view.lblMessage.text = message;
        view.lblMessage.isHidden = message.isEmpty()
        view.setLocalization()
        view.btnLeft.setTitle(titleLeftButton.capitalized, for: UIControl.State.normal)
        view.btnRight.setTitle(titleRightButton.capitalized, for: UIControl.State.normal)
        view.editText.isSecureTextEntry = editTextInputType
        if offerbutton{
            view.alertView.isHidden = true
            view.viewPromoList.isHidden = false
            view.lblPromoTitle.text = title;
            view.tablePromo.register(PromoListCell.nib, forCellReuseIdentifier: PromoListCell.identifier)
            view.wsGetPromo()
            view.btnOffer.isHidden = false
            view.viewPromo.setShadow()
        }else{
            view.viewPromoList.isHidden = true
            view.btnOffer.isHidden = true
        }
        view.constraintPromoHeight.constant = 0.0
        if view.editText.isSecureTextEntry {
            view.btnHideShowPassword.isHidden = false
        } else {
            view.btnHideShowPassword.isHidden = true
        }
        view.editText.placeholder = editTextHint;
        
        APPDELEGATE.window?.addSubview(view)
        APPDELEGATE.window?.bringSubviewToFront(view);
        return view;
    }
    
    func setLocalization() {
        /* Set Color */
        
        btnLeft.setTitleColor(UIColor.themeLightTextColor, for: UIControl.State.normal)
        btnRight.setTitleColor(UIColor.themeButtonTitleColor, for: UIControl.State.normal)
        btnRight.backgroundColor = UIColor.themeButtonBackgroundColor
        lblTitle.textColor = UIColor.themeTextColor
        lblPromoTitle.textColor = UIColor.themeTextColor
        viewApplyButton.backgroundColor = UIColor.themeButtonBackgroundColor
        viewApplyButton.sizeToFit()
        viewApplyButton.setRound(withBorderColor: .clear, andCornerRadious: (viewApplyButton.frame.height/2), borderWidth: 0)
        viewPromoText.setRound(withBorderColor: UIColor.themeLightTextColor
                               , andCornerRadious: 5.0, borderWidth: 1.0)
        
        
        lblMessage.textColor = UIColor.themeTextColor
        editText.textColor = UIColor.themeTextColor
        editText.delegate = self

        btnRight.setupButton()

        btnOffer.setTitleColor(UIColor.themeImageColor, for: UIControl.State.normal)
        btnOffer.setTitle("View Offer", for: .normal)
        btnOffer.setupButton(borderColor: UIColor.themeImageColor, backgroundColor: .white)
//        btnOffer.setTitleColor(UIColor.themeButtonTitleColor, for: UIControl.State.normal)
//        btnOffer.backgroundColor = UIColor.themeButtonBackgroundColor
        btnOffer.layer.cornerRadius = 8
        /* Set Font */
        
        btnLeft.titleLabel?.font =  FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnRight.titleLabel?.font =  FontHelper.font(size: FontSize.medium, type: FontType.Bold)

        lblTitle.font = FontHelper.font(size: FontSize.large, type: FontType.Regular)
        lblPromoTitle.font = FontHelper.font(size: FontSize.large, type: FontType.Regular)
        lblMessage.font =  FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        editText.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)

        self.backgroundColor = UIColor.themeOverlayColor
        self.alertView.backgroundColor = UIColor.white
        self.alertView.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 1.0)
        
        self.viewPromo.backgroundColor = UIColor.white
        self.viewPromo.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 1.0)
        
        btnHideShowPassword.setImage(UIImage(named: "asset-password-hide_u"), for: .normal)
        btnHideShowPassword.setImage(UIImage(named: "asset-password-show_u"), for: .selected)
        btnHideShowPassword.tintColor = UIColor.themeImageColor
        
//        btnHideShowPassword.setTitle(FontAsset.icon_hide_password, for: .normal)
//        btnHideShowPassword.setTitle(FontAsset.icon_show_password, for: .selected)
//        btnHideShowPassword.setSimpleIconButton()
//        btnHideShowPassword.titleLabel?.font = FontHelper.assetFont(size: 25)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.editText {
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder();
        }
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if doubleValidation {
            var updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            
            if let currentInputMode = textField.textInputMode {
                let localeIdentifier = editText.doubleValueLocale != nil ? editText.doubleValueLocale! : (currentInputMode.primaryLanguage ?? "en")
                let decimalSeparator = Locale(identifier: localeIdentifier).decimalSeparator ?? "."
                updatedText = updatedText.replacingOccurrences(of: decimalSeparator, with: ".")
                editText.doubleValueLocale = localeIdentifier
            }
            
            if updatedText.isEmpty {
                editText.doubleValueText = nil
                editText.doubleValueLocale = nil
                return true
            }
            if let value = updatedText.toEnglishDouble() {
                editText.doubleValueText = value
                return true
            }
            return false
        }
        return true
    }

    //MARK: - Action Methods
    @IBAction func onClickBtnOffer(_ sender: Any) {
//        self.viewPromoList.isHidden = false
//        self.alertView.isHidden = true
//        let taxAmountPopupVC = PromoCodeVC(nibName: "PromoCodeVC", bundle: nil)
//        taxAmountPopupVC.listingService = "\(list.charges.commisionFee ?? 0)"
//        taxAmountPopupVC.hst = "\(list.charges.tax ?? 0)"
//        taxAmountPopupVC.payout = "\(list.charges.payout ?? 0)"
//        taxAmountPopupVC.currency = "\(list.charges.currency ?? "")"
//        taxAmountPopupVC.modalPresentationStyle = .overFullScreen
//        self.presentFromBottom(taxAmountPopupVC)
    }
    
    @IBAction func onClickBtnLeft(_ sender: Any) {
        if self.onClickLeftButton != nil {          
            self.onClickLeftButton!();
        }
    }

    @IBAction func onClickBtnRight(_ sender: Any) {
        if self.onClickRightButton != nil {
            if doubleValidation {
                if editText.doubleValueText != nil {
                    self.onClickRightButton!("\(editText.text ?? "0")")
                } else {
                    self.onClickRightButton!(editText.text ?? "")
                }
            } else {
                self.onClickRightButton!(editText.text ?? "")
            }
        }
    }
    @IBAction func actionApply(_ sender: Any) {
        self.onClickRightButton!(txtPromo.text ?? "")
        
//            if doubleValidation {
//                if editText.doubleValueText != nil {
//                    self.onClickRightButton!("\(editText.doubleValueText ?? 0)")
//                } else {
//                    self.onClickRightButton!(editText.text ?? "")
//                }
//            } else {
//                self.onClickRightButton!(editText.text ?? "")
//            }
        
    }
    @IBAction func onClickBtnHideShowPassword(_ sender: Any) {
        editText.isSecureTextEntry = !editText.isSecureTextEntry
        btnHideShowPassword.isSelected.toggle()
    }

    public override func removeFromSuperview() {
        super.removeFromSuperview()
    }
    
    @IBAction func actionCancel(_ sender: UIButton) {
        self.onClickLeftButton!();
//        self.alertView.isHidden = false
//        self.viewPromoList.isHidden = true
    }
    func wsGetPromo() {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.CITY_ID] = self.cityId
        dictParam[PARAMS.COUNTRY_ID] = self.countryId
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_PROMO_CODE_LIST, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) {
            (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response: response) {
                    Utility.hideLoading()
                    self.listPromoCode = [PromoCode]()
                    if let info = response["promo_codes"] as? [JSONType]{
                        self.listPromoCode.append(contentsOf: info.compactMap(PromoCode.init))
                        if CGFloat(self.frame.height - 300) > CGFloat(self.listPromoCode.count * 68){
                            self.constraintPromoHeight.constant = CGFloat(self.listPromoCode.count * (70))
                        }else{
                            self.constraintPromoHeight.constant = CGFloat(self.frame.height - 300) //CGFloat(self.listPromoCode.count * (68))
                        }
                        self.tablePromo.reloadData()
                    }
                }
            }
        }
    }
}

extension CustomVerificationDialog : UITableViewDelegate, UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listPromoCode.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PromoListCell.identifier) as! PromoListCell
        let list = listPromoCode[indexPath.row]
        cell.lblPromo.text = list.promocode ?? ""
        cell.lblSubtitle.text = list.description ?? ""
        var discount = "\(list.code_value!)"
        if list.code_type! == 1{ //Absolute
            discount = "\(Double(list.code_value!).toCurrencyString())"
        }else{//Percentage
            discount = "\(list.code_value!)%"
        }
        cell.lblDiscount.text = discount //"\(Double(list.code_value!).toCurrencyString())"
        return cell
    }
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//      self.alertView.isHidden = false
//      self.viewPromoList.isHidden = true
        self.txtPromo.text = self.listPromoCode[indexPath.row].promocode ?? ""
        self.onClickRightButton!(txtPromo.text ?? "")
        return indexPath
    }
}
