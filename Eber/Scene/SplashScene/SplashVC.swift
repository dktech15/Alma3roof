//
//  SplashVC.swift
//  Store
//
//  Created by Disha Ladani on 18/02/17.
//  Copyright © 2017 Elluminati. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GoogleSignIn
import AVFoundation

class SplashVC: BaseVC {
    
    @IBOutlet weak var splash: UIImageView!
    var player: AVPlayer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        wsGetAppSetting()
        ws_get_all_country_details()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if let videoURL = Bundle.main.url(forResource: "user_splashscreen", withExtension: "mp4") {
            let asset = AVAsset(url: videoURL)
            player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            
            // Add an observer for the AVPlayerItemDidPlayToEndTime notification
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(videoDidFinish),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: player?.currentItem)
            
            // Set up AVPlayerLayer to display video
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = view.bounds
            playerLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(playerLayer)
            
            // Start playing the video
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForground), name: .applicationWillEnterForeground, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        APPDELEGATE.setupIQKeyboard()
        UISwitch.appearance().tintColor = UIColor.themeSwitchTintColor
        UISwitch.appearance().onTintColor = UIColor.themeSwitchTintColor
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            GMSServices.provideAPIKey(Google.MAP_KEY);
            if preferenceHelper.getGooglePlacesAutocompleteKey().isEmpty {
                GMSPlacesClient.provideAPIKey(Google.MAP_KEY)
            } else {
                GMSPlacesClient.provideAPIKey(preferenceHelper.getGooglePlacesAutocompleteKey())
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func appWillEnterForground() {
        //        wsGetAppSetting()
        ws_get_all_country_details()
    }
    
    @objc func videoDidFinish(notification: Notification) {
        self.checkLogin()
    }
    
    
    
    deinit {
        // Remove the observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    func getLatestVersion() -> String {
        guard
            let info = Bundle.main.infoDictionary,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            results.count > 0,
            let versionString = results[0]["version"] as? String
        else {
            return ""
        }
        print("Latest Version:- \(versionString)")
        return versionString
    }
    
    func loadFrames(from asset: AVAsset) {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.requestedTimeToleranceBefore = CMTime.zero
        imageGenerator.requestedTimeToleranceAfter = CMTime.zero
        
        let duration = asset.duration
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        // Set the number of frames you want to extract per second
        let framesPerSecond = 1
        let totalFrames = Int(durationInSeconds) * framesPerSecond
        
        var images: [UIImage] = []
        
        for i in 0..<totalFrames {
            let time = CMTime(seconds: Double(i) / Double(framesPerSecond), preferredTimescale: 600)
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                images.append(uiImage)
            } catch {
                print("Error generating image: \(error.localizedDescription)")
            }
        }
        
        // Display the frames in the image view
        splash.animationImages = images
        splash.animationDuration = durationInSeconds
        splash.animationRepeatCount = 1 // 0 for infinite loop
        splash.startAnimating()
    }
    
    //MARK: - User Define Funtions
    func isUpdateAvailable(_ latestVersion: String) -> Bool {
        if !latestVersion.isEmpty {
            let currentAppVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
            let myCurrentVersion: [String] = currentAppVersion.components(separatedBy: ".")
            let myLatestVersion: [String] = latestVersion.components(separatedBy: ".")
            let legthOfLatestVersion: Int = myLatestVersion.count
            let legthOfCurrentVersion: Int = myCurrentVersion.count
            if legthOfLatestVersion == legthOfCurrentVersion {
                for i in 0..<myLatestVersion.count {
                    if CInt(myCurrentVersion[i])! < CInt(myLatestVersion[i])! {
                        return true
                    } else if CInt(myCurrentVersion[i]) == CInt(myLatestVersion[i]) {
                        continue
                    } else {
                        return false
                    }
                }
                return false
            } else {
                let count: Int = legthOfCurrentVersion > legthOfLatestVersion ? legthOfLatestVersion : legthOfCurrentVersion
                for i in 0..<count {
                    if CInt(myCurrentVersion[i])! < CInt(myLatestVersion[i])! {
                        return true
                    } else if CInt(myCurrentVersion[i])! > CInt(myLatestVersion[i])! {
                        return false
                    } else if CInt(myCurrentVersion[i]) == CInt(myLatestVersion[i]) {
                        continue
                    }
                }
                if legthOfCurrentVersion < legthOfLatestVersion {
                    for i in legthOfCurrentVersion..<legthOfLatestVersion {
                        if CInt(myLatestVersion[i]) != 0 {
                            return true
                        }
                    }
                    return false
                } else {
                    return false
                }
            }
        } else {
            return false
        }
    }
    
    func checkLogin() {
        if preferenceHelper.getSessionToken().isEmpty()
        {
            APPDELEGATE.gotoLogin()
        }
        else
        {
            SplitPaymentListner.shared.startLister()
            if !(CurrentTrip.shared.user.isReferral == TRUE) && CurrentTrip.shared.user.countryDetail.isReferral
            {
                if let referralVC:ReferralVC = AppStoryboard.PreLogin.instance.instantiateViewController(withIdentifier: "ReferralVC") as? ReferralVC
                {
                    self.present(referralVC, animated: true, completion: {
                    });
                }
            }
            else if (CurrentTrip.shared.user.isDocumentUploaded == FALSE)
            {
                APPDELEGATE.gotoDocument()
            }
            else
            {
                CurrentTrip.shared.tripId = CurrentTrip.shared.user.tripId
                if CurrentTrip.shared.user.isProviderAccepted == TRUE
                {
                    if CurrentTrip.shared.user.isUserInvoiceShow == TRUE {
                        APPDELEGATE.gotoFeedback()
                    } else {
                        APPDELEGATE.gotoTrip()
                    }
                }
                else
                {
                    APPDELEGATE.gotoMap()
                }
            }
        }
    }
}

//MARK: - Web Service Calls
extension SplashVC {
    func wsGetAppSetting() {
        
        Utility.wsGetSetting { response, error in
            if (error != nil) {
                self.openServerErrorDialog()
            }
            else {
                if Parser.parseAppSettingDetail(response: response) {
                    if self.isUpdateAvailable(self.getLatestVersion()) {
                        self.openUpdateAppDialog(isForceUpdate: preferenceHelper.getIsRequiredForceUpdate())
                    }
                    else {
                        
                        self.player?.play()
                    }
                }
            }
        }
        
        /*
         let afh:AlamofireHelper = AlamofireHelper()
         let currentAppVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
         let dictParam : [String : Any] =
         [ PARAMS.USER_ID:preferenceHelper.getUserId(),
         PARAMS.TOKEN:preferenceHelper.getSessionToken(),
         PARAMS.DEVICE_TYPE : CONSTANT.IOS,
         PARAMS.DEVICE_TOKEN:preferenceHelper.getDeviceToken(),
         PARAMS.APP_VERSION: currentAppVersion]
         
         afh.getResponseFromURL(url: WebService.GET_USER_SETTING_DETAIL, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
         if (error != nil) {
         self.openServerErrorDialog()
         }
         else {
         if Parser.parseAppSettingDetail(response: response) {
         if self.isUpdateAvailable(self.getLatestVersion()) {
         self.openUpdateAppDialog(isForceUpdate: preferenceHelper.getIsRequiredForceUpdate())
         }
         else {
         self.checkLogin()
         }
         }
         }
         }*/
    }
    
    func ws_get_all_country_details() {
        let afh:AlamofireHelper = AlamofireHelper()
        
        afh.getResponseFromURL(url: WebService.get_all_country_details, methodName: AlamofireHelper.GET_METHOD, paramData: nil) { (response, error) -> (Void) in
            if (error != nil) {
                //                self.openServerErrorDialog()
                self.wsGetAppSetting()
                
            }
            else {
                if Parser.isSuccess(response: response) {
                    let response:CountryListResponse = CountryListResponse.init(fromDictionary: response)
                    print(response)
                    CurrentTrip.shared.arrForCountries = response.countryList
                    self.wsGetAppSetting()
                }else{
                    self.wsGetAppSetting()
                    
                }
            }
        }
    }
}

//MARK: - Dialogs
extension SplashVC
{
    func openUpdateAppDialog(isForceUpdate:Bool)
    {
        if isForceUpdate
        {
            let dialogForUpdateApp = CustomAlertDialog.showCustomAlertDialog(title: "TXT_ATTENTION".localized, message: "MSG_UPDATE_APP".localized, titleLeftButton: "TXT_EXIT".localized, titleRightButton: "TXT_UPDATE".localized)
            dialogForUpdateApp.onClickLeftButton =
            { [unowned dialogForUpdateApp] in
                dialogForUpdateApp.removeFromSuperview();
                exit(0)
            }
            dialogForUpdateApp.onClickRightButton =
            { [unowned dialogForUpdateApp] in
                if let url = URL(string: CONSTANT.UPDATE_URL),
                   UIApplication.shared.canOpenURL(url)
                {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
                dialogForUpdateApp.removeFromSuperview()
            }
        }
        else
        {
            let dialogForUpdateApp = CustomAlertDialog.showCustomAlertDialog(title: "TXT_ATTENTION".localized, message: "MSG_UPDATE_APP".localized, titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_UPDATE".localized)
            dialogForUpdateApp.onClickLeftButton =
            { [unowned self, unowned dialogForUpdateApp] in
                dialogForUpdateApp.removeFromSuperview();
                self.checkLogin()
            }
            dialogForUpdateApp.onClickRightButton =
            { [unowned self, unowned dialogForUpdateApp] in
                if let url = URL(string: CONSTANT.UPDATE_URL), UIApplication.shared.canOpenURL(url)
                {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
                printE(self)
                dialogForUpdateApp.removeFromSuperview()
            }
        }
    }
    
    func openServerErrorDialog() {
        let dialogForServerError = CustomAlertDialog.showCustomAlertDialog(title: "TXT_ATTENTION".localized, message: "MSG_SERVER_ERROR".localized, titleLeftButton: "TXT_EXIT".localized, titleRightButton: "TXT_RETRY".localized)
        dialogForServerError.onClickLeftButton =
        { [unowned dialogForServerError] in
            dialogForServerError.removeFromSuperview();
            exit(0)
        }
        dialogForServerError.onClickRightButton =
        { [unowned self, unowned dialogForServerError] in
            dialogForServerError.removeFromSuperview();
            self.wsGetAppSetting()
            //            ws_get_all_country_details()
        }
    }
    
    func openPushNotificationDialog()
    {
        let dialogForPushNotification = CustomAlertDialog.showCustomAlertDialog(title: "TXT_PUSH_ENABLE".localized.replacingOccurrences(of: "****", with: "TXT_APP_NAME".localized), message: "MSG_PUSH_ENABLE".localized.replacingOccurrences(of: "****", with: "TXT_APP_NAME".localized), titleLeftButton: "TXT_EXIT".localized, titleRightButton: "".localized)
        dialogForPushNotification.onClickLeftButton =
        { [unowned dialogForPushNotification] in
            dialogForPushNotification.removeFromSuperview();
            exit(0)
        }
        dialogForPushNotification.onClickRightButton =
        { [unowned dialogForPushNotification] in
            dialogForPushNotification.removeFromSuperview();
        }
    }
}
