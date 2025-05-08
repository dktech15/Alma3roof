//
//  StringUtility.swift
//  Eber
//
//  Created by Elluminati on 21/02/17.
//  Copyright © 2017 Elluminati. All rights reserved.
//

import Foundation
import UIKit

extension String {

    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }

    var localizedCapitalized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "").capitalized
    }

    var localizedUppercase: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "").uppercased()
    }

    var localizedLowercase: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "").lowercased()
    }

    func localizedCompare(string:String) -> Bool {
        let str1 = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        let str2 = NSLocalizedString(string, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        return str1.caseInsensitiveCompare(str2) == .orderedSame
    }

    func localizedCaseCompare(string:String) -> Bool{
        let str1 = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        let str2 = NSLocalizedString(string, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        return str1.compare(str2) == .orderedSame
    }

    var localizedWithFormat: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "").capitalized
    }
}

//Type Casting Extension
extension String {

    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }

    func toDouble() -> Double {
        return Double(self) ?? 0//NumberFormat.instance.number(from: self)?.doubleValue ?? 0.0
    }
    
    func toEnglishDouble() -> Double? {
        //before you convert any languge double to english you need to ready string with that language and also decimal sperator
        //Ex. if the string is arabic double thent also the decimal must be in the arabic like ","  not "."
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = NSLocale(localeIdentifier: "EN") as Locale
        if let final = formatter.number(from: self) {
            let doubleNumber = Double(truncating: final)
            return doubleNumber
        }
        return nil
    }

    func toInt() -> Int {
        return NumberFormat.instance.number(from: self)?.intValue ?? 0
    }

    func toDate (format: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat=format
        formatter.locale = Locale.init(identifier: preferenceHelper.getLanguageCode())
        return formatter.date(from: self) ?? Date()
    }

    func toCall()  {
        if let url = URL(string: "tel://\(self)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            Utility.showToast(message: "Unable to call")
        }
    }

    static func secondsToMinutesSeconds (seconds : Int) -> String {
        let min = String(format: "%02d",Int((seconds % 3600) / 60))
        let sec = String(format: "%02d", Int((seconds % 3600) % 60))
        return "\(min):\(sec)"
    }
}

//MARK: - Validation Extension
extension String {

    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }

    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    struct NumberFormat {
        static let instance = NumberFormatter()
    }
}

//MARK: - String To Json
extension String {

    func getJsonFromString() -> [String:Any]? {
        do{
            if let json = self.data(using: String.Encoding.utf8){
                if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:Any]{
                    return jsonData
                }
            }
        }catch {
            print("\(self) not converted to JSON : \(error.localizedDescription)")
        }
        return nil
    }
    
    func getJsonArrayFromString() -> [[String:Any]]? {
        do{
            if let json = self.data(using: String.Encoding.utf8){
                if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [[String:Any]] {
                    return jsonData
                }
            }
        }catch {
            print("\(self) not converted to JSON : \(error.localizedDescription)")
        }
        return nil
    }
}




