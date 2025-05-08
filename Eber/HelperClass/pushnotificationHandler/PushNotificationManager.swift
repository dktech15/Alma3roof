//
//  PushNotificationManager.swift
//  Eber
//
//  Created by Elluminati on 1/28/19.
//  Copyright © 2019 Elluminati. All rights reserved.
//

import Firebase
import FirebaseMessaging
import UIKit
import Foundation
import UserNotifications

fileprivate struct PUSH {
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
    static let SplitPaymentNewRequest = "239"
    static let SplitPaymentRequestAccept = "236"
    static let SplitPaymentRequestReject = "237"
    static let SplitPaymentRequestRemove = "238"
    static let SplitPaymentRequestEnd = "243"
    static let ReceviedMessage = "244"
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func registerForPushNotifications() {
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                // For iOS 10 display notification (sent via APNS)
                UNUserNotificationCenter.current().delegate = self
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: {_, _ in })
            } else {
                let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
            }

            UIApplication.shared.registerForRemoteNotifications()
        }
        Messaging.messaging().delegate = self
    }

    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            print("FCM token: \(token)")
            preferenceHelper.setDeviceToken(token)
            self.wsUpdateDeviceToken()
        }  
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo:[AnyHashable:Any] =  response.notification.request.content.userInfo
        print("FCM remoteMessage \(userInfo)")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken as Data
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("deviceTokenString \(deviceTokenString)")
        //preferenceHelper.setDeviceToken(deviceTokenString)
        //self.wsUpdateDeviceToken()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("FCM Error\(error.localizedDescription)")
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo:[AnyHashable:Any] =  notification.request.content.userInfo
        print("FCM remoteMessage Will Present \(userInfo)")
        self.manageAllPush(data: userInfo, isClick: false)
        completionHandler([UNNotificationPresentationOptions.alert,UNNotificationPresentationOptions.sound,UNNotificationPresentationOptions.badge])
    }

    func manageAllPush(data:[AnyHashable: Any],isClick: Bool = true) {
        
        let id: String = {
            if let value = data["id"] as? String { return value }
            if let value = data["id"] as? Int { return "\(value)" }
            return ""
        }()
        
        switch id {
        case PUSH.LoginAtAnother:
            preferenceHelper.setSessionToken("")
            preferenceHelper.setUserId("")
            self.gotoLogin()
            break;
        case PUSH.Approved:
            self.gotoMap()
            break;
        case PUSH.CorporateRequest:
            printE("Push Data \(data)")
            printE("push received")
            if let strJson = data["extraParam"] as? String, let corporateDetail = strJson.getJsonFromString()
            {
                CurrentTrip.shared.user.corporateDetail = CorporateDetail.init(fromDictionary: corporateDetail)
                if let wd = self.window
                {
                    var viewController = wd.rootViewController
                    if(viewController is PBRevealViewController)
                    {
                        viewController = (viewController as! PBRevealViewController).mainViewController
                        if(viewController is UINavigationController)
                        {
                            printE("Push Controller Find")
                            viewController = (viewController as! UINavigationController).visibleViewController
                            if(viewController is MapVC)
                            {
                                let mapvc:MapVC = (viewController as! MapVC)
                                mapvc.openCorporateRequestDialog()
                            }
                        }
                    }
                }
            }
            break;
        case PUSH.Declined:
            self.gotoMap()
            break;
        case PUSH.ProviderAcceptRequest:
            if let wd = self.window {
                var viewController = wd.rootViewController
                if(viewController is PBRevealViewController) {
                    viewController = (viewController as! PBRevealViewController).mainViewController
                    if(viewController is UINavigationController)  {
                        viewController = (viewController as! UINavigationController).visibleViewController
                        if(viewController is MapVC) {
                            let mapvc:MapVC = (viewController as! MapVC)
                            mapvc.wsGetTripStatus()
                        }
                    }
                }
            }
            break;
        case PUSH.ProviderComing,PUSH.ProviderArrived,PUSH.ProviderStartTrip,PUSH.ProviderEndTrip,PUSH.ProviderEndTripWithTip,PUSH.ProviderInitTrip:
            if let wd = self.window {
                var viewController = wd.rootViewController
                if(viewController is PBRevealViewController) {
                    viewController = (viewController as! PBRevealViewController).mainViewController
                    if(viewController is UINavigationController) {
                        viewController = (viewController as! UINavigationController).visibleViewController
                        if(viewController is TripVC) {
                            let mapvc:TripVC = (viewController as! TripVC)
                            mapvc.wsGetTripStatus()
                        }
                        if(viewController is MapVC) {
                            let mapvc:MapVC = (viewController as! MapVC)
                            mapvc.startTripStatusTimer()
                        }
                    }
                }
            }
            break;
        case PUSH.ProviderCancelTrip, PUSH.AdminCancelled:
            if let wd = self.window {
                var viewController = wd.rootViewController
                if(viewController is PBRevealViewController) {
                    viewController = (viewController as! PBRevealViewController).mainViewController
                    if(viewController is UINavigationController) {
                        viewController = (viewController as! UINavigationController).visibleViewController
                        if(viewController is MapVC) {
                            let mapvc:MapVC = (viewController as! MapVC)
                            mapvc.wsGetTripStatus()
                        }
                        else if(viewController is TripVC) {
                            let tripVC:TripVC = (viewController as! TripVC)
                            tripVC.wsGetTripStatus()
                        }
                        else {
                            Utility.showToast(message: "TXT_TRIP_CANCELLED_BY_PROVIDER".localized)
                        }
                    }
                }
            }
            break;
        case PUSH.SplitPaymentNewRequest:
            /*
            if let strJson = data["extraParam"] as? String, let splitReq = strJson.getJsonFromString() {
                CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: splitReq)
                //APPDELEGATE.gotoMap()
                
                APPDELEGATE.showFriendReqDialog(name: (CurrentTrip.shared.splitPaymentReq.first_name ?? "") + " " + (CurrentTrip.shared.splitPaymentReq.last_name ?? ""), contact: (CurrentTrip.shared.splitPaymentReq.country_phone_code ?? "")+(CurrentTrip.shared.splitPaymentReq.phone ?? "")) { isAddNewCard in
                    if isAddNewCard {
                        print("top view controller \(UIApplication.getTopViewController()!)")
                        let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentVC")
                        if let topVC = UIApplication.getTopViewController() {
                            if let sideMenu = topVC as? PBRevealViewController {
                                if let mainVC = sideMenu.mainViewController as? UINavigationController {
                                    print("mainvc is \(mainVC)")
                                    mainVC.pushViewController(vc, animated: true)
                                }
                            }
                        } else {
                            UIApplication.getTopViewController()?.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
                
            }*/
            print("SplitPaymentNewRequest")
        case PUSH.SplitPaymentRequestRemove:
            CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: [:])
            if let vw = (APPDELEGATE.window?.viewWithTag(DialogTags.splitPaymentReqDailog)) as? CustomDialogSplitPaymentReq {
                vw.removeFromSuperview()
            }
            //APPDELEGATE.gotoMap()
            print("SplitPaymentRequestRemove")
        case PUSH.SplitPaymentRequestEnd:
            /*if let strJson = data["extraParam"] as? String, let splitReq = strJson.getJsonFromString() {
                CurrentTrip.shared.splitPaymentReq = SearchUser(dictionary: splitReq)
                if let vc = UIApplication.getTopViewController() {
                    SplitPaymentPay.splitPayment(inVc: vc)
                }
            }*/
            print("SplitPaymentRequestRemove")
        case PUSH.ReceviedMessage:
            print("ReceviedMessage")
            break;
        default:
            break;
        }
    }
}

//MARK: - Push notification Handler
extension AppDelegate {
    func wsUpdateDeviceToken() {
        if !preferenceHelper.getUserId().isEmpty {
            let dictParam : [String : Any] =
                [ PARAMS.USER_ID:preferenceHelper.getUserId(),
                  PARAMS.TOKEN : preferenceHelper.getSessionToken(),
                  PARAMS.DEVICE_TOKEN : preferenceHelper.getDeviceToken()];

            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.UPDATE_DEVICE_TOKEN, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) {  (response, error) -> (Void) in
                printE(Utility.convertDictToJson(dict: response))
            }
        }
    }
}

extension NSNotification {
    public static let splitPaymentNotification = NSNotification.Name(rawValue: "splitPaymentNotification")
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("FCM token from delegate: \(fcmToken)")
        preferenceHelper.setDeviceToken(fcmToken)
        self.wsUpdateDeviceToken()
    }
}
