//
//  Utility.swift
//  tableViewDemo
//
//  Created by Elluminati on 12/01/17.
//  Copyright © 2017 tag. All rights reserved.
//

import UIKit
import SDWebImage

class Utility: ModelNSObj
{
    static func deg2rad(deg:Double) -> Double {
        return deg * Double.pi / 180
    }

    static func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / Double.pi
    }

    static var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    static var overlayView = UIView();
    static var mainView = UIView();

    override init() {}

    static func dateToString(date: Date, withFormat:String, withTimezone:TimeZone = TimeZone.ReferenceType.default, isForceEnglish: Bool = false) -> String{
        let dateFormatter = DateFormatter()
        if isForceEnglish {
            dateFormatter.locale = Locale.init(identifier: "en_GB")
        } else {
            dateFormatter.locale = Locale.init(identifier: preferenceHelper.getLanguageCode())
        }
        dateFormatter.timeZone = withTimezone
        dateFormatter.dateFormat = withFormat
        let currentDate = dateFormatter.string(from: date)
        return currentDate
    }

    static func stringToDate(strDate: String, withFormat:String, timeZone: TimeZone = TimeZone.ReferenceType.default) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = Locale.init(identifier: preferenceHelper.getLanguageCode())
        dateFormatter.dateFormat = withFormat
        return dateFormatter.date(from: strDate) ?? Date()
    }

    static func showLoading(color: UIColor = UIColor.white, text: String? = nil) {
        DispatchQueue.main.async {
            if(!activityIndicator.isAnimating)
            {
                self.mainView = UIView()
                self.mainView.frame = UIScreen.main.bounds
                self.mainView.backgroundColor = UIColor.clear
                self.overlayView = UIView()
                self.activityIndicator = UIActivityIndicatorView()
                
                let maxWidth = UIScreen.main.bounds.width * 0.8

                overlayView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
                overlayView.backgroundColor = UIColor(white: 0, alpha: 0.7)
                overlayView.clipsToBounds = true
                overlayView.layer.cornerRadius = 10
                overlayView.layer.zPosition = 1
                
                activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                activityIndicator.style = .whiteLarge
                overlayView.addSubview(activityIndicator)
                activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
                
                if text != nil {
                    let lblTxt = UILabel(frame: CGRect(x: 10, y: activityIndicator.frame.size.height + activityIndicator.frame.origin.y + CGFloat(8), width: maxWidth - 20, height: 23))
                    overlayView.addSubview(lblTxt)
                    lblTxt.text = text!
                    lblTxt.numberOfLines = 2
                    lblTxt.font = FontHelper.font(type: .Regular)
                    lblTxt.textColor = color
                    lblTxt.sizeToFit()
                    lblTxt.textAlignment = .center
                    if lblTxt.frame.size.width > 80 {
                        overlayView.frame.size.width = lblTxt.frame.size.width + 20
                    } else {
                        overlayView.frame.size.width = 80
                    }
                    overlayView.frame.size.height = lblTxt.frame.size.height + lblTxt.frame.origin.y + CGFloat(20)
                    activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: activityIndicator.center.y)
                }

                
                self.mainView.addSubview(overlayView)
                
                if let vw = APPDELEGATE.window?.viewWithTag(701)
                {
                    APPDELEGATE.window?.bringSubviewToFront(vw)
                }
                else
                {
                    overlayView.center = (UIApplication.shared.keyWindow?.center)!
                    mainView.tag = 701
                    UIApplication.shared.keyWindow?.addSubview(mainView)
                    activityIndicator.startAnimating()
                }
            } else {
                if let vw = APPDELEGATE.window?.viewWithTag(701)
                {
                    APPDELEGATE.window?.bringSubviewToFront(vw)
                }
            }
        }
    }

    static func hideLoading() {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating();
            UIApplication.shared.keyWindow?.viewWithTag(701)?.removeFromSuperview()
        }
    }

    static func showToast( message:String, backgroundColor:UIColor = UIColor.themeButtonBackgroundColor, textColor:UIColor = UIColor.white) {
        if !message.isEmpty {
            DispatchQueue.main.async {
                var window: UIWindow?
                var height: CGFloat = 0
                var msg = ""
                if let keyWindow = UIApplication.shared.keyWindow {
                    window = keyWindow
                } else {
                    window = UIApplication.shared.windows.last
                    
                }
                if window?.safeAreaInsets.bottom ?? 0 > 0 {
                    height += (window?.safeAreaInsets.bottom ?? 0)
                    msg += ""
                }
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate;
                let label = UILabel(frame: CGRect.zero);
                
                let contentView = UIView(frame: CGRect.zero)
                contentView.backgroundColor = backgroundColor
                
                label.textAlignment = .center
                label.text = message;
                //label.adjustsFontSizeToFitWidth = true;
                label.frame = CGRect.init(x: 0, y: 8, width:  UIScreen.main.bounds.size.width, height: label.frame.height);
                label.backgroundColor =  backgroundColor //UIColor.whiteColor()
                label.textColor = textColor; //TEXT COLOR
                label.numberOfLines = 4
                label.alpha = 1
                UIApplication.shared.keyWindow?.endEditing(true)
                UIApplication.shared.windows.last?.endEditing(true)
                contentView.addSubview(label)
                window?.addSubview(contentView)
                
                contentView.layer.shadowColor = UIColor.gray.cgColor;
                contentView.layer.shadowOffset = CGSize.init(width: 4, height: 3)
                contentView.layer.shadowOpacity = 0.3;
                
                label.sizeToFit()
                label.frame.size.width = UIScreen.main.bounds.size.width
                contentView.frame = CGRect(x: 0, y: (appDelegate.window?.frame.maxY)!, width: appDelegate.window!.frame.size.width, height: (height > 0 ? 0 : 16) + label.frame.size.height + height)

                var basketTopFrame: CGRect = contentView.frame;
                basketTopFrame.origin.x = 0;
                basketTopFrame.origin.y = (appDelegate.window?.frame.maxY)! - contentView.frame.height;

                UIView.animate(withDuration: 3.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
                    contentView.frame = basketTopFrame
                },  completion: {
                    (value: Bool) in
                    UIView.animate(withDuration: 3.0, delay: 3.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
                        contentView.alpha = 0
                    },  completion: {
                        (value: Bool) in
                        contentView.removeFromSuperview()
                    })
                })
            }
        }
    }

    static func convertDictToJson(dict:Dictionary<String, Any>) -> Void{
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        print(jsonString)
    }

    //MARK: - Date Handler
    static func stringToString(strDate:String, fromFormat:String, toFormat:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: preferenceHelper.getLanguageCode())
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC") ?? TimeZone(identifier: "UTC") ?? TimeZone.ReferenceType.default
        dateFormatter.dateFormat = fromFormat
        let currentDate = dateFormatter.date(from: strDate) ?? Date()
        dateFormatter.dateFormat =  toFormat
        dateFormatter.timeZone = TimeZone.ReferenceType.default
        let currentDates = dateFormatter.string(from: currentDate)
        return currentDates
        
    }

    static func relativeDateStringForDate(strDate: String) -> NSString{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: preferenceHelper.getLanguageCode())
        dateFormatter.timeZone = TimeZone.ReferenceType.default
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let currentDate = dateFormatter.string(from:NSDate() as Date)
        
        let calender : NSCalendar = NSCalendar.init(identifier:.gregorian)!
        
        let dayComponent = NSDateComponents()
        
        dayComponent.day = -1
        
        let date:Date = calender.date(byAdding:dayComponent as DateComponents, to: NSDate() as Date, options: NSCalendar.Options(rawValue: 0))!
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strYesterdatDate = dateFormatter.string(from:date as Date)
        
        if(strDate == currentDate)
        {
            return "Today"
        }
        else if(strDate == strYesterdatDate)
        {
            return "Yesterday"
        }
        else
        {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.ReferenceType.default
            dateFormatter.locale = Locale.init(identifier: preferenceHelper.getLanguageCode())
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: strDate)
            let myCurrentDate = Utility.convertDateFormate(date: date!)
            return myCurrentDate as NSString
        }
    }

    static func hmsFrom(seconds: Int, completion: @escaping (_ hours:Double, _ minutes:Double, _ seconds:Double)->()) {
        completion(Double(seconds / 3600), Double((seconds % 3600) / 60), Double((seconds % 3600) % 60))
    }

    static func distanceFrom(meters: Double, unit:Int,  completion: @escaping (_ distance: String)->()) {
        if unit == TRUE
        {
            completion((meters * 0.001).toString(places: 2) + " " + MeasureUnit.KM)
        }
        else
        {
            completion((meters * 0.000621371).toString(places: 2) + " " + MeasureUnit.MILE)
        }
    }

    static func convertDateFormate(date : Date) -> String{
        // Day
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.timeZone = TimeZone.ReferenceType.default
        dateFormate.locale = Locale.init(identifier: preferenceHelper.getLanguageCode())
        dateFormate.dateFormat = "MMMM, yyyy"
        let newDate = dateFormate.string(from: date)
        
        var day  = "\(anchorComponents.day!)"
        switch (day) {
        case "1" , "21" , "31":
            day.append("st")
        case "2" , "22":
            day.append("nd")
        case "3" ,"23":
            day.append("rd")
        default:
            day.append("th")
        }
        return day + " " + newDate
    }
    static func convertSelectedDateToMilliSecond(serverDate:Date,strTimeZone:String)-> Int64
    {
        let timezone = TimeZone.init(identifier: strTimeZone) ?? TimeZone.ReferenceType.default
        
        
        let offSetMiliSecond = Int64(timezone.secondsFromGMT() * 1000)
        let timeSince1970 = Int64(serverDate.timeIntervalSince1970)
        let finalSelectedDateMilli =   Int64(  Int64(timeSince1970 * 1000) +  offSetMiliSecond)
        return finalSelectedDateMilli
    }
    
    /// get time interval from current date to future date
    static func timeInterval(date:Date) -> Double {
        let dateFormatter = DateFormatter.init()
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.locale = Locale.init(identifier: preferenceHelper.getLanguageCode())
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strLocalDate = dateFormatter.string(from: Date())

        let startDate = strLocalDate.toDate(format: "yyyy-MM-dd HH:mm:ss")
        return (date.timeIntervalSince(startDate) * 1000)
    }
    
    ///get system local date
    static func getLocalDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}
        
        return localDate
    }

   //MARK:
    //MARK: - Gesture Handler
    static func addGestureForRemoveViewOnTouch(view:UIView)
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideView))
        view.addGestureRecognizer(tap)
    }
   
    @objc static func hideView(sender:UITapGestureRecognizer)
    {
        let view:UIView = sender.view!
        view.removeFromSuperview()
        view.endEditing(true)
    }
    
    static func downloadImageFrom(link:String, placeholder:String = "asset-driver-pin-placeholder", completion: @escaping (_ result: UIImage) -> Void)
    {
        if link.isEmpty()
        {
            return  completion(UIImage.init(named: placeholder)!)
        }
        else
        {
            let urlStr = WebService.BASE_URL +  link
            let shared = SDWebImageDownloader.shared
            guard let url = URL(string: urlStr) else {
                return
            }

            shared.downloadImage(with: url,
                                 options: SDWebImageDownloaderOptions.ignoreCachedResponse,
                                 progress: nil,
                                 completed: { /*[weak self]*/ (image, data, error, result) in
                                    if error != nil {
                                        //debugPrint("\(self ?? UIImageView()) \(err)")
                                    }

                                    if let downloadedImage = image
                                    {
                                        let width = (UIScreen.main.bounds.width * 0.1)
                                        let height = width
                                        let size = CGSize.init(width: width, height: height)
                                        let newImage = downloadedImage.jd_imageAspectScaled(toFit: size)
                                        completion(newImage)
                                    }
            })
        }
    }

    static func getDistanceUnit(unit: Int) -> String{
        if unit == TRUE {
            return MeasureUnit.KM
        }
        return MeasureUnit.MILE
    }
    
    static func currentAppVersion() -> String {
        if let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return currentAppVersion
        }
        return ""
    }
    
    static func getLatestVersion() -> String {
        guard
            let info = Bundle.main.infoDictionary,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            results.count > 0,
            let versionString = results[0]["version"] as? String
        else { return "" }
        print("Latest Version:- \(versionString)")
        return versionString
    }
    
    static func getCancellationReasons(block:@escaping (_ response:[String]) -> ()) {
        
        Utility.showLoading()
        
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.user_type] = 1 //user
        dictParam[PARAMS.lang] = preferenceHelper.getLanguageCode()

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.get_cancellation_reason, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if let arrReason = response["reasons"] as? [String] {
                block(arrReason)
            } else {
                block(["TXT_CANCEL_TRIP_REASON".localized, "TXT_CANCEL_TRIP_REASON1".localized, "TXT_CANCEL_TRIP_REASON2".localized,"TXT_CANCEL_TRIP_REASON3".localized])
            }
        }
    }
    
    static func wsGetSetting(complition: @escaping voidRequestCompletionBlock) {
        let currentAppVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
        let dictParam : [String : Any] =
            [ PARAMS.USER_ID:preferenceHelper.getUserId(),
              PARAMS.TOKEN:preferenceHelper.getSessionToken(),
              PARAMS.DEVICE_TYPE : CONSTANT.IOS,
              PARAMS.DEVICE_TOKEN:preferenceHelper.getDeviceToken(),
              PARAMS.APP_VERSION: currentAppVersion]

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_USER_SETTING_DETAIL, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            complition(response,error)
        }
    }
}

