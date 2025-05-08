//
//  ShareReferralVC.swift
//  Eber
//
//  Created by Elluminati on 30/08/18.
//  Copyright © 2018 Elluminati. All rights reserved.
//

import UIKit

class ShareReferralVC: BaseVC
{
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var viewForReferral: UIView!
    @IBOutlet weak var lblReferralMsg: UILabel!
    @IBOutlet weak var lblYourReferralCode: UILabel!
    @IBOutlet weak var lblReferralCode: UILabel!
    @IBOutlet weak var lblYourReferralCredit: UILabel!
    @IBOutlet weak var lblReferralCredit: UILabel!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblIconShareReferral: UILabel!
    @IBOutlet weak var imgIconShareReferral : UIImageView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        initialViewSetup()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.wsGetReferralCredit()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationView.navigationShadow()
        viewForReferral.setRound(withBorderColor: UIColor.clear, andCornerRadious: 10.0, borderWidth: 1.0)
        viewForReferral.setShadow()
        
        btnShare.setRound(withBorderColor: UIColor.clear, andCornerRadious: 25.0, borderWidth: 1.0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initialViewSetup()
    {
        
        lblTitle.text = "TXT_REFERRAL".localized
        lblTitle.textColor = UIColor.themeTextColor
        lblTitle.font = FontHelper.font(size: FontSize.medium, type: FontType.Bold)
        lblReferralMsg.text = "TXT_SHARE_REFERRAL_MSG".localized
        lblReferralMsg.textColor = UIColor.themeTextColor
        lblReferralMsg.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        lblYourReferralCode.text = "TXT_YOUR_REFERRAL_CODE".localized
        lblYourReferralCode.textColor = UIColor.themeTextColor
        lblYourReferralCode.font = FontHelper.font(size: FontSize.small, type: FontType.Light)
        lblYourReferralCredit.text = "TXT_YOUR_REFERRAL_CREDIT".localized
        lblYourReferralCredit.textColor = UIColor.themeTextColor
        lblYourReferralCredit.font = FontHelper.font(size: FontSize.small, type: FontType.Light)
        lblReferralCode.text = CurrentTrip.shared.user.referralCode.uppercased()
        lblReferralCode.textColor = UIColor.themeTextColor
        lblReferralCode.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        lblReferralCredit.text = " $ 0.0"
        lblReferralCredit.textColor = UIColor.themeTextColor
        lblReferralCredit.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        btnShare.setTitle("   " + "TXT_SHARE_REFERRAL_CODE".localizedCapitalized + "   ", for: .normal)
        btnShare.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnShare.backgroundColor = UIColor.themeButtonBackgroundColor
        btnShare.titleLabel?.font  = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
//        lblIconShareReferral.text = FontAsset.icon_referral
        imgIconShareReferral.tintColor = UIColor.themeImageColor
//        lblIconShareReferral.setForIcon()
//        btnBack.setupBackButton()
        
    }
    
    //MARK: - Action Methods
    
    @IBAction func onClickBtnShare(_ sender: Any) {
        
        let myString = "MSG_SHARE_REFERRAL".localized.replacingOccurrences(of: "****", with: "TXT_APP_NAME".localized) + CurrentTrip.shared.user.referralCode
        let textToShare = [ myString ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.navigationController?.present(activityViewController, animated: true, completion: nil)
     }
    
    @IBAction func onClickBtnMenu(_ sender: Any) {
        if  let navigationVC: UINavigationController  = self.revealViewController()?.mainViewController as? UINavigationController
        {
            navigationVC.popToRootViewController(animated: true)
        }
    }
}


extension ShareReferralVC
{
    func wsGetReferralCredit()
    {
        
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_USER_REFERAL_CREDIT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil)
            {Utility.hideLoading()}
            else
            {
                if Parser.isSuccess(response: response)
                {
                    let referralCredit = ((response["total_referral_credit"] as? Double)?.toString()) ?? "0.0"
                    
                    self.lblReferralCredit.text  = CurrentTrip.shared.user.walletCurrencyCode + " " + referralCredit
                    Utility.hideLoading()
                }
            }
        }
    }
}
