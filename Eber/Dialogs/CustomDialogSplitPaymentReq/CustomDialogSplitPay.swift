//
//  CustomPhotoDialog.swift
//  Eber
//
//  Created by Elluminati on 22/02/17.
//  Copyright © 2017 Elluminati. All rights reserved.
//

import Foundation
import UIKit


public class CustomDialogSplitPay: CustomDialog {
   //MARK: - OUTLETS
    @IBOutlet weak var stkDialog: UIStackView!
    @IBOutlet weak var stkBtns: UIStackView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var lblAmount: UILabel!
    
    //MARK:Variables
    var onClickRightButton : (() -> Void)? = nil
    var onClickLeftButton : (() -> Void)? = nil
    static let  verificationDialog = "CustomDialogSplitPay"
    var amount: Double = 0
    var currency: String = ""
    
    public static func  showCustomAlertDialog
        (title:String,
         message:String,
         titleLeftButton:String,
         titleRightButton:String,
         currency: String,
         amount: Double,
         isShowLeftButton:Bool = true,
         tag:Int = 455
         ) ->
    CustomDialogSplitPay {

        var view = UINib(nibName: verificationDialog, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomDialogSplitPay
        
        if let vw = (APPDELEGATE.window?.viewWithTag(tag))
        {
            if let splitVw = vw as? CustomDialogSplitPay {
                view = splitVw
            }
        }
        
        view.tag = tag
        view.alertView.setShadow()
        view.alertView.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.themeOverlayColor
        let frame = (APPDELEGATE.window?.frame)!;
        view.frame = frame;
        view.lblTitle.text = title;
        
        view.lblMessage.text = message;
        view.setLocalization()
        view.btnLeft.setTitle(titleLeftButton.capitalized, for: UIControl.State.normal)
        view.btnRight.setTitle(titleRightButton.capitalized, for: UIControl.State.normal)
        view.btnLeft.isHidden = !isShowLeftButton
        view.amount = amount
        view.currency = currency
        view.lblAmount.text = "\(view.currency)\(view.amount)"
        
        if let view = (APPDELEGATE.window?.viewWithTag(400))
        {
            if let window = APPDELEGATE.window {
                window.bringSubviewToFront(view);
            }
        }
        else
        {
            if let window = APPDELEGATE.window {
                window.addSubview(view)
                window.bringSubviewToFront(view);
            }
        }
        
        view.btnLeft.isHidden =  titleLeftButton.isEmpty()
        view.btnRight.isHidden =  titleRightButton.isEmpty()
        view.lblTitle.isHidden = title.isEmpty()
        
        return view;
    }
    
    public class func disable() {
        if let vw = APPDELEGATE.window?.viewWithTag(DialogTags.splitPaymentPayDailog) as? CustomDialogSplitPay {
            vw.isUserInteractionEnabled = false
        }
    }
    
    public class func enable() {
        if let vw = APPDELEGATE.window?.viewWithTag(DialogTags.splitPaymentPayDailog) as? CustomDialogSplitPay {
            vw.isUserInteractionEnabled = true
        }
    }
    
    func setLocalization() {
        btnLeft.setTitleColor(UIColor.themeLightTextColor, for: UIControl.State.normal)
        btnRight.setTitleColor(UIColor.themeButtonTitleColor, for: UIControl.State.normal)
        btnRight.backgroundColor = UIColor.themeButtonBackgroundColor
        lblTitle.textColor = UIColor.themeTextColor
        lblAmount.textColor = UIColor.themeTextColor
        lblMessage.textColor = UIColor.themeTextColor
         btnRight.setupButton()
        /* Set Font */
        btnLeft.titleLabel?.font =  FontHelper.font(type: FontType.Regular)
        btnRight.titleLabel?.font =  FontHelper.font(size: FontSize.medium, type: FontType.Regular)
        lblTitle.font = FontHelper.font(size: FontSize.large, type: FontType.Regular)
        lblAmount.font = FontHelper.font(size: FontSize.doubleExtraLarge, type: FontType.Regular)
        lblMessage.font = FontHelper.font(type: FontType.Regular)
  
        self.backgroundColor = UIColor.themeOverlayColor
        self.alertView.backgroundColor = UIColor.white
        self.alertView.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 1.0)
    }
    
    //ActionMethods
    @IBAction func onClickBtnLeft(_ sender: Any) {
        if self.onClickLeftButton != nil {
            self.onClickLeftButton!();
        }
    }
    
    @IBAction func onClickBtnRight(_ sender: Any) {
        if self.onClickRightButton != nil {
            self.onClickRightButton!()
        }
    }
}


