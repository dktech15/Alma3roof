//
//  AppDelegate.swift
//  Eber
//
//  Created by Elluminati on 30/08/18.
//  Copyright © 2018 Elluminati. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications
import GooglePlaces
import IQKeyboardManagerSwift
import GoogleSignIn
import FirebaseCrashlytics
import Firebase
import FBSDKLoginKit
import FirebaseDatabase
import FirebaseMessaging
import PayPalCheckout
import Sentry
//ALMA3ROOF

extension UIViewController {
    public func removeFromParentAndNCObserver() {
        for childVC in self.children {
            childVC.removeFromParentAndNCObserver()
        }
        if self.isKind(of: UINavigationController.classForCoder()) {
            (self as! UINavigationController).viewControllers = []
        }
        self.dismiss(animated: false, completion: nil)        
        self.view.removeFromSuperviewAndNCObserver()
        NotificationCenter.default.removeObserver(self)
        self.removeFromParent()
    }
}

extension UIView {
    public func removeFromSuperviewAndNCObserver() {
        for subvw in self.subviews {
            subvw.removeFromSuperviewAndNCObserver()
        }
        NotificationCenter.default.removeObserver(self)
        self.removeFromSuperview()
    }
    
    var globalFrame: CGRect? {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        let safeAreaTop = rootView?.safeAreaTop
        let frame = self.superview?.convert(self.frame, to: rootView)
        if var frame = frame {
            frame.origin.y -= safeAreaTop ?? 0
            return frame
        }
        return nil
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var reachability: Reachability?;
    var dialogForNetwork:CustomAlertDialog?;
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    var is_app_in_review : Bool?

    private struct PUSH {
        static let Approved = "215"
        static let Declined = "216"
        static let ProviderInitTrip = "217"
        static let LoginAtAnother = "220"
        static let ProviderComing = "200"
        static let ProviderAcceptRequest = "203"
        static let ProviderArrived = "204"
        static let ProviderStartTrip = "206"
        static let ProviderEndTrip = "209"
        static let ProviderEndTripWithTip = "240"
        static let ProviderNoProviderTrip = "213"
        static let ProviderCancelTrip = "214"
        static let CorporateRequest = "231"
        static let AdminCancelled = "218"
    }

    fileprivate static let instance = UIApplication.shared.delegate as! AppDelegate
    static func SharedApplication() -> AppDelegate {
        return instance
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.launchOptions = launchOptions
        Localizer.doTheMagic()
        setupNetworkReachability()
        setupTabbar()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        FBSDKCoreKit.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        application.isIdleTimerDisabled = true
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        let lhs = Utility.currentAppVersion()
        let rhs = Utility.getLatestVersion()
        if lhs.compare(rhs, options: .numeric) == .orderedDescending
        {
            is_app_in_review = true
        }
        SentrySDK.start { options in
                    options.dsn = "  https://1223276ae0ae782d3239b0411d7e3cbc@o4509287234273280.ingest.de.sentry.io/4509287263305808"
                    options.debug = true // Useful for development
                    options.tracesSampleRate = 1.0 // 100% performance tracing (adjust in prod)
                }
      
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NotificationCenter.default.post(name: .applicationWillEnterForeground, object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let _:Bool = GIDSignIn.sharedInstance.handle(url)
        let _:Bool = FBSDKCoreKit.ApplicationDelegate.shared.application(app, open: url, options: options)
        return true
    }

    //MARK: - Setup Tabbar
    func setupTabbar() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font:FontHelper.font(type: FontType.Regular), NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal);
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font:FontHelper.font(type: FontType.Regular), NSAttributedString.Key.foregroundColor: UIColor.themeTextColor], for: .selected);
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
    }

    //MARK: - Keyboard Setting
    func setupIQKeyboard() {
        IQKeyboardManager.shared.enableAutoToolbar = false
        UITextField.appearance().tintColor = UIColor.black;
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enable = true
    }

    func gotoLogin() {
        AlamofireHelper.manager.session.cancelTasks {
            Utility.hideLoading()
            CurrentTrip.shared.clear()
            CurrentTrip.shared.clearTripData()
            self.window?.removeFromSuperviewAndNCObserver()
            self.window?.rootViewController?.removeFromParentAndNCObserver()
            self.window?.rootViewController = AppStoryboard.PreLogin.instance.instantiateInitialViewController() as? UINavigationController
            self.window?.makeKeyAndVisible()
        }
    }
    
    func goToSplash() {
        AlamofireHelper.manager.session.cancelTasks {
            Utility.hideLoading()
            CurrentTrip.shared.clear()
            CurrentTrip.shared.clearTripData()
            self.window?.removeFromSuperviewAndNCObserver()
            self.window?.rootViewController?.removeFromParentAndNCObserver()
            self.window?.rootViewController = AppStoryboard.Splash.instance.instantiateInitialViewController()
            self.window?.makeKeyAndVisible()
        }
    }

    func gotoMap() {
        AlamofireHelper.manager.session.cancelTasks {
            Utility.hideLoading()
            SocketHelper.shared.disConnectSocket()
            CurrentTrip.shared.clearTripData()
            let pbrController = AppStoryboard.Map.instance.instantiateInitialViewController() as? PBRevealViewController
            self.window?.removeFromSuperviewAndNCObserver()
            self.window?.rootViewController?.removeFromParentAndNCObserver()
            self.window?.rootViewController = pbrController
            self.window?.makeKeyAndVisible()
            self.registerForPushNotifications()
        }
    }

    func gotoDocument() {
        AlamofireHelper.manager.session.cancelTasks {
            let mainViewController = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "documentVC")
            self.window?.removeFromSuperviewAndNCObserver()
            self.window?.rootViewController?.removeFromParentAndNCObserver()
            self.window?.rootViewController = mainViewController
            self.window?.makeKeyAndVisible()
            self.registerForPushNotifications()
        }
    }

    func gotoTrip() {
        AlamofireHelper.manager.session.cancelTasks {
            let mainViewController = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "MainNavController")
            let leftViewController = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "LeftMenuController")
            let tripViewController = AppStoryboard.Trip.instance.instantiateInitialViewController()!
            (mainViewController as! UINavigationController).viewControllers = [tripViewController]
            let revealViewController:PBRevealViewController = PBRevealViewController.init(sideViewController: leftViewController, mainViewController: mainViewController)
            self.window?.removeFromSuperviewAndNCObserver()
            self.window?.rootViewController?.removeFromParentAndNCObserver()
            self.window?.rootViewController = revealViewController
            self.window?.makeKeyAndVisible()
            self.registerForPushNotifications()
        }
    }

    func gotoInvoice() {
        Utility.hideLoading()
        SocketHelper.shared.disConnectSocket()
        AlamofireHelper.manager.session.cancelTasks { 
            let mainViewController = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "MainNavController")
            let leftViewController = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "LeftMenuController")
            let invoiceVC = AppStoryboard.Trip.instance.instantiateViewController(withIdentifier: "invoiceVC")
            (mainViewController as! UINavigationController).viewControllers = [invoiceVC]
            let revealViewController:PBRevealViewController = PBRevealViewController.init(sideViewController: leftViewController, mainViewController: mainViewController)
            self.window?.removeFromSuperviewAndNCObserver()
            self.window?.rootViewController?.removeFromParentAndNCObserver()
            self.window?.rootViewController = revealViewController
            self.window?.makeKeyAndVisible()
            self.registerForPushNotifications()
        }
    }

    func gotoFeedback() {
        SocketHelper.shared.disConnectSocket()
        AlamofireHelper.manager.session.cancelTasks {
            let mainViewController = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "MainNavController")
            let leftViewController = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "LeftMenuController")
            let feedbackVC = AppStoryboard.Trip.instance.instantiateViewController(withIdentifier: "FeedbackVC")
            (mainViewController as! UINavigationController).viewControllers = [feedbackVC]
            let revealViewController:PBRevealViewController = PBRevealViewController.init(sideViewController: leftViewController, mainViewController: mainViewController)
            self.window?.removeFromSuperviewAndNCObserver()
            self.window?.rootViewController?.removeFromParentAndNCObserver()
            self.window?.rootViewController = revealViewController
            self.window?.makeKeyAndVisible()
        }
    }
    
    func showFriendReqDialog(name: String, contact: String, completion: @escaping (_ isAddNewCard: Bool)->()) {
        if preferenceHelper.getUserId().isEmpty() || preferenceHelper.getUserId().count == 0 {
            return
        }
        let dialogForCorporateRequest = CustomDialogSplitPaymentReq.showCustomAlertDialog(title: "TXT_SPLIT_PAYMENT_REQ".localized, message: "txt_your_friend_send_split_payment_req".localized, strName: name, strPhone: contact, titleLeftButton: "txt_reject".localized, titleRightButton: "txt_accept".localized, tag: DialogTags.splitPaymentReqDailog)
        dialogForCorporateRequest.onClickLeftButton = {
            dialogForCorporateRequest.removeFromSuperview()
        }
        dialogForCorporateRequest.onClickRightButton = {
            dialogForCorporateRequest.removeFromSuperview()
        }
        dialogForCorporateRequest.onClickAddNewCard = {
            completion(true)
            dialogForCorporateRequest.removeFromSuperview()
        }
    }

    func setupNetworkReachability() {
        self.reachability = Reachability.init();
        do {
            try self.reachability?.startNotifier()
        } catch {
            printE(error)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
    }

    func openNetworkDialog() {
        dialogForNetwork = CustomAlertDialog.showCustomAlertDialog(title: "TXT_INTERNET".localized, message: "MSG_INTERNET_ENABLE".localized, titleLeftButton: "TXT_EXIT".localized, titleRightButton: "TXT_OK".localized)
        self.dialogForNetwork!.onClickLeftButton =
        { [unowned self, weak dialogForNetwork = self.dialogForNetwork] in
            self.dialogForNetwork!.removeFromSuperview()
            self.dialogForNetwork = nil
            dialogForNetwork = nil
            printE(dialogForNetwork ?? "")
            exit(0)
        }
        self.dialogForNetwork!.onClickRightButton =
        { [unowned self, weak dialogForNetwork = self.dialogForNetwork] in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                self.dialogForNetwork?.removeFromSuperview()
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    })
                } else {
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
            self.dialogForNetwork?.removeFromSuperview();
            self.dialogForNetwork = nil
            dialogForNetwork = nil
            printE(dialogForNetwork ?? "")
        }
    }

    @objc func reachabilityChanged(note: NSNotification) {
        DispatchQueue.main.async {
            let reachability = note.object as! Reachability
            if reachability.isReachable {
                if (AppDelegate.SharedApplication().window?.viewWithTag(DialogTags.networkDialog)) != nil {
                    self.dialogForNetwork?.removeFromSuperview()
                }
                if reachability.isReachableViaWiFi {
                    printE("Reachable via WiFi")
                } else {
                    printE("Reachable via Cellular")
                }
            } else {
                printE("Network not reachable")
                self.openNetworkDialog()
            }
        }
    }
}
