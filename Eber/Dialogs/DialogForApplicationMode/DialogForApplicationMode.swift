//
//  DialogForApplicationModw.swift
//  Edelivery Provider
//
//  Created by MacPro3 on 14/02/22.
//  Copyright © 2022 Elluminati iMac. All rights reserved.
//

import UIKit
import SwiftUI

public class DialogForApplicationMode:CustomDialog {
    
    @IBOutlet weak var viewCard: UIView!
    
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var btnDeveloper: UIButton!
    @IBOutlet weak var btnStaging: UIButton!
    
    @IBOutlet weak var lblServer: UILabel!
    @IBOutlet weak var lblLive: UILabel!
    @IBOutlet weak var lblStaging: UILabel!
    @IBOutlet weak var lblDeveloper: UILabel!

    var onClickRightButton : (() -> Void)? = nil
    var onClickLeftButton : (() -> Void)? = nil
    
    var appMode: AppMode = .live
    
    static let  verificationDialog = "DialogForApplicationMode"

    public override func awakeFromNib() {
        super.awakeFromNib()
        btnCancel.setTitleColor(UIColor.themeTitleColor, for: .normal)
        btnCancel.titleLabel?.textColor = UIColor.themeTitleColor
        
        self.btnLive.setImage(UIImage.init(named: "asset-radio-normal")!.imageWithColor(color: .themeTextColor), for: .normal)
        self.btnLive.setImage(UIImage.init(named: "asset-radio-selected")!.imageWithColor(color: .themeTextColor), for: .selected)
        
        self.btnDeveloper.setImage(UIImage.init(named: "asset-radio-normal")!.imageWithColor(color: .themeTextColor), for: .normal)
        self.btnDeveloper.setImage(UIImage.init(named: "asset-radio-selected")!.imageWithColor(color: .themeTextColor), for: .selected)
        
        self.btnStaging.setImage(UIImage.init(named: "asset-radio-normal")!.imageWithColor(color: .themeTextColor), for: .normal)
        self.btnStaging.setImage(UIImage.init(named: "asset-radio-selected")!.imageWithColor(color: .themeTextColor), for: .selected)
        
        switch AppMode.currentMode {
        case .live:
            self.onClickRadio(btnLive)
        case .developer:
            self.onClickRadio(btnDeveloper)
        case .staging:
            self.onClickRadio(btnStaging)
        }
    }

    public static func showCustomAppModeDialog() -> DialogForApplicationMode {
        let view = UINib(nibName: verificationDialog, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DialogForApplicationMode
        view.viewCard.applyShadowToView(12)
        view.btnOk.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        view.btnOk.backgroundColor = UIColor.themeTextColor
        view.btnOk.layer.cornerRadius = view.btnOk.frame.size.height/2
        view.btnOk.clipsToBounds = true
        let frame = (APPDELEGATE.window?.frame)!
        view.frame = frame
        
        DispatchQueue.main.async {
            APPDELEGATE.window?.addSubview(view)
            APPDELEGATE.window?.bringSubviewToFront(view)
        }
        return view
    }
    
    @IBAction func onClickRadio(_ sender: UIButton) {
        
        btnLive.isSelected = false
        btnDeveloper.isSelected = false
        btnStaging.isSelected = false
        
        sender.isSelected = true
        
        if sender == btnLive {
            appMode = .live
        } else if sender == btnDeveloper {
            appMode = .developer
        } else {
            appMode = .staging
        }
    }
    
    @IBAction func onClickBtnLeft(_ sender: Any) {
        self.onClickLeftButton!();
    }
    
    @IBAction func onClickBtnRight(_ sender: Any) {
        if appMode != AppMode.currentMode {
            if preferenceHelper.getUserId() != "" {
                wsLogout()
            } else {
                CurrentTrip.shared.clearUserData()
                preferenceHelper.setUserId("")
                preferenceHelper.setSessionToken("")
                preferenceHelper.removeImageBaseUrl()
                
                UIViewController.clearPBRevealVC()
                AppMode.currentMode = self.appMode
                APPDELEGATE.goToSplash()
            }
        }
        self.onClickRightButton!();
    }
    
    func wsLogout() {
        Utility.showLoading()

        var dictParam : [String : Any] = [:]
        let currentAppVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)

        dictParam[PARAMS.APP_VERSION] = currentAppVersion
        dictParam[PARAMS.USER_ID] =  preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.LOGOUT_USER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in

            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.parseLogout(response: response) {
                    UIViewController.clearPBRevealVC()
                    AppMode.currentMode = self.appMode
                    APPDELEGATE.goToSplash()
                } else {
                    Utility.hideLoading()
                }
            }
        }
    }
}
