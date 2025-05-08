//
//  DoubleExtension.swift
//  Eber
//
//  Created by Mayur on 23/06/23.
//  Copyright © 2023 Elluminati. All rights reserved.
//

import Foundation

extension Double {

    /// Rounds the double to decimal places value
    func roundTo(places:Int = 2) -> Double {
        let divisor = pow(10.00, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var clean: Double {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? (Double(String(format: "%.0f", self)) ?? self) : self
    }

//    func toString(places:Int = 2, isClean: Bool = false) -> String {
//        if isClean {
//            return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
//        }
//        return String(format:"%."+places.description+"f", self)
//    }

//    func toCurrencyString(currencyCode:String = CurrentTrip.shared.user.walletCurrencyCode) -> String {
//        var currencyNewCode = currencyCode
//
//        if currencyNewCode.isEmpty() {
//            currencyNewCode = CurrentTrip.shared.user.walletCurrencyCode
//        }
//
//        var locale = Locale.current
//        if CurrencyHelper.shared.myLocale.currencyCode == currencyNewCode {
//            locale = CurrencyHelper.shared.myLocale
//        } else {
//            for iteratedLocale in Locale.availableIdentifiers {
//                let newLocal = Locale.init(identifier: iteratedLocale)
//                print(newLocal.currencyCode)
//                if newLocal.currencyCode == currencyNewCode {
//                    locale = newLocal
//                    break;
//                }
//            }
//        }
//
//        if locale.identifier.contains("_") {
//            let strings = locale.identifier.components(separatedBy: "_")
//            if strings.count > 0 {
//                let countryCode = strings[strings.count - 1]
//                locale = Locale.init(identifier: "\(arrForLanguages[preferenceHelper.getLanguage()].code)_\(countryCode)")
//            }
//        } else {
//            locale = Locale.init(identifier: "\(arrForLanguages[preferenceHelper.getLanguage()].code)_\(locale.identifier)")
//        }
//
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.locale = locale
//        CurrencyHelper.shared.myLocale = locale
//        return formatter.string(from: NSNumber.init(value: self) ) ?? self.toString(places: 2);
//    }

    func toCurrencyString(currencyCode: String = CurrentTrip.shared.user.walletCurrencyCode) -> String {
        var currencyNewCode = currencyCode

        if currencyNewCode.isEmpty {
            currencyNewCode = CurrentTrip.shared.user.walletCurrencyCode
        }

        var locale = Locale.current
        if CurrencyHelper.shared.myLocale.currencyCode == currencyNewCode {
            locale = CurrencyHelper.shared.myLocale
        } else {
            for iteratedLocale in Locale.availableIdentifiers {
                let newLocal = Locale(identifier: iteratedLocale)
                if newLocal.currencyCode == currencyNewCode {
                    locale = newLocal
                    break
                }
            }
        }

        if locale.identifier.contains("_") {
            let strings = locale.identifier.components(separatedBy: "_")
            if strings.count > 0 {
                let countryCode = strings[strings.count - 1]
                locale = Locale(identifier: "\(arrForLanguages[preferenceHelper.getLanguage()].code)_\(countryCode)")
            }
        } else {
            locale = Locale(identifier: "\(arrForLanguages[preferenceHelper.getLanguage()].code)_\(locale.identifier)")
        }

        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.minimumFractionDigits = 2
//        formatter.maximumFractionDigits = 2
//        formatter.currencyCode = currencyNewCode
//        formatter.currencySymbol = locale.currencySymbol
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = locale
        
            

        CurrencyHelper.shared.myLocale = locale

         return formatter.string(from: NSNumber(value: self))?.replacingOccurrences(of: ",", with: ".") ?? self.toString(places: 2)

    }

    func toString(places: Int = 2, isClean: Bool = false) -> String {
        if isClean {
            return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
        }
        return String(format: "%." + places.description + "f", self)
    }

    func toInt() -> Int {
        if self > Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return 0
        }
    }
}

extension Int {

    func toString() -> String {
        return String(self)
    }
}
