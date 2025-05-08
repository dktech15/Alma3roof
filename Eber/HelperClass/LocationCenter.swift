//
//  LocationCenter.swift
//  HyrydeDriver
//
//  Created by Mac Pro5 on 01/10/19.
//  Copyright © 2019 KetanMR_Elluminati. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

typealias TimeDistanceAPICompletion = ((_ time: String, _ Distance: String) -> Void)
typealias Completion = () -> Void

class LocationCenter: NSObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    let geocoder = CLGeocoder()
    var jobCompletion: Completion?
    var country: String = ""
    var countryISOcode: String = ""

    class var isServicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled() 
    }
    
    class var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus() 
    }
    
    class var isAlways_OR_WhenInUse: Bool {
        let status = LocationCenter.authorizationStatus
        return (status == CLAuthorizationStatus.authorizedAlways) || 
            (status == CLAuthorizationStatus.authorizedWhenInUse)
    }
    
    class var isDenied: Bool {
        let status = LocationCenter.authorizationStatus
        return status == CLAuthorizationStatus.denied
    }
    
    var lastLocation: CLLocation? { 
        return self.manager.location
    }
    
    static let `default`: LocationCenter = {
        let instance: LocationCenter = LocationCenter()    
        return instance
    }()
    
    // MARK: - 
    
    override init() {
        super.init()
        
        self.manager.delegate = self
        self.manager.activityType = CLActivityType.other
        self.manager.distanceFilter = 10.0
        self.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.manager.pausesLocationUpdatesAutomatically = false
        //self.manager.allowsBackgroundLocationUpdates = true
        if #available(iOS 11.0, *) {
          //  self.manager.showsBackgroundLocationIndicator = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - 
    
    class func allowAlert() {
        OperationQueue.main.addOperation { 
            let msg = String(format: "%@", "\nPlease enable location services from the Settings app.\n\n1. Go to Settings > Privacy > Location Services.\n\n2. Make sure that location services is on.")
            
            let aC = UIAlertController(title: "Allow location", 
                                       message: msg, 
                                       preferredStyle: UIAlertController.Style.alert)
            
            let act = UIAlertAction(title: "OK", 
                                    style: UIAlertAction.Style.default, 
                                    handler: { (act: UIAlertAction) in
                                        Common.openSettingsApp()
            })
            
            aC.addAction(act)
            Common.appDelegate.window?.rootViewController?.present(aC, animated: true, completion: {
                print(#function)
            })
        }
    }
    
    func addObserver(_ observer: Any, _ selectors: [Selector]) {
        Common.nCd.removeObserver(observer, 
                                  name: Common.locationUpdateNtfNm, 
                                  object: LocationCenter.default)
        
        Common.nCd.removeObserver(observer, 
                                  name: Common.locationFailNtfNm, 
                                  object: LocationCenter.default)
        Common.nCd.removeObserver(observer,
                                  name: Common.locationAuthorizationChangedNtfNm,
                                  object: LocationCenter.default)
        
        Common.nCd.addObserver(observer, 
                               selector: selectors[0], 
                               name: Common.locationUpdateNtfNm, 
                               object: LocationCenter.default)
        
        Common.nCd.addObserver(observer, 
                               selector: selectors[1], 
                               name: Common.locationFailNtfNm, 
                               object: LocationCenter.default)
        Common.nCd.addObserver(observer, selector: selectors[2],
                                  name: Common.locationAuthorizationChangedNtfNm,
                                  object: LocationCenter.default)
    }

    func requestAuthorization() {
        if LocationCenter.isServicesEnabled && (!LocationCenter.isDenied) {
            self.manager.requestAlwaysAuthorization()
        } else {
            if APPDELEGATE.is_app_in_review != true
            {
                LocationCenter.allowAlert()
            }
        }
    }

    func requestLocationOnce() {
        if LocationCenter.isAlways_OR_WhenInUse {
            self.manager.requestLocation()
        } else {
            self.requestAuthorization()
            self.jobCompletion = { [weak self] in
                self?.manager.requestLocation()
            }
        }
    }

    func startUpdatingLocation() {
        if LocationCenter.isAlways_OR_WhenInUse {
            self.manager.startUpdatingLocation()
        } else {
            self.requestAuthorization()
            self.jobCompletion = { [weak self] in
                self?.manager.startUpdatingLocation()
            }
        }
    }

    func stopUpdatingLocation() {
        self.manager.stopUpdatingLocation()
    }

    func fetchCityAndCountry(location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {

        if #available(iOS 11.0, *) {
            geocoder.reverseGeocodeLocation(location, preferredLocale: Locale.init(identifier: "en_US_POSIX"))
            { placemarks, error in
                if (error == nil) {
                    //if CurrentTrip.shared.currentCountryCode.isEmpty() {
                        CurrentTrip.shared.currentCountryCode = (placemarks?.first?.isoCountryCode) ?? ""
                        self.country = placemarks?.first?.country ?? ""
                    //}
                    completion(placemarks?.first?.locality, placemarks?.first?.country, error)
                    print("Country Code: \(placemarks?.first?.isoCountryCode ?? "")")
                    
                } else {
                    if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
                        //if CurrentTrip.shared.currentCountryCode.isEmpty() {
                            CurrentTrip.shared.currentCountryCode = countryCode
                       // }
                        completion(placemarks?.first?.locality, Locale.current.countryName(from: countryCode), nil)
                    } else {
                        completion(placemarks?.first?.locality, placemarks?.first?.country, error)
                    }
                }
            }

        } else {
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if CurrentTrip.shared.currentCountryCode.isEmpty() {
                    CurrentTrip.shared.currentCountryCode = (placemarks?.first?.isoCountryCode) ?? ""
                    if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
                        print(countryCode)
                    }
                }
                print("Country Code: \(placemarks?.first?.isoCountryCode ?? "")")
                completion(placemarks?.first?.locality, placemarks?.first?.country, error)
            }
        }
    }

    func getAddressFromLatitudeLongitude(latitude:Double,longitude:Double, completion: @escaping (String,[Double],String)->Void) {
        print("JD GEO CODE API CALLED - location to address")
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        if coordinate.isValidCoordinate() {
            let aGMSGeocoder: GMSGeocoder = GMSGeocoder()
            aGMSGeocoder.reverseGeocodeCoordinate(coordinate) { (gmsReverseGeocodeResponse, error) in
                if error == nil {
                    if let gmsAddress: GMSAddress = gmsReverseGeocodeResponse?.firstResult() {
                        let latitude = gmsAddress.coordinate.latitude
                        let longitude = gmsAddress.coordinate.longitude
                        var address: String = ""
                        for line in  gmsAddress.lines ?? [] {
                            address += line + " "
                        }
                        let country = gmsAddress.country
                        completion(address,[latitude,longitude],country ?? "")

                    } else {
                        completion("",[0.0,0.0],"")

                    }
                }
                else {
                    completion("",[0.0,0.0],"")
                }

            }
        } else {
            completion("",[0.0,0.0],"")
        }
    }

    func googlePlacesResult(input: String, completion: @escaping (_ result: [(title:String,subTitle:String,address:String, placeid:String)]) -> Void) {

        if !input.isEmpty() {
            var token: GMSAutocompleteSessionToken!
            if let currentToken = GoogleAutoCompleteToken.shared.token  {
                if GoogleAutoCompleteToken.shared.isExpired() || GoogleAutoCompleteToken.shared.isTokenExpired {
                    GoogleAutoCompleteToken.shared.token = GMSAutocompleteSessionToken.init()
                    GoogleAutoCompleteToken.shared.milliseconds = Date().millisecondsSince1970
                    token = GoogleAutoCompleteToken.shared.token!
                    GoogleAutoCompleteToken.shared.isTokenExpired = false
                    debugPrint("\(#function) GMS Token Re-Generated - \(String(describing: token)) at \(GoogleAutoCompleteToken.shared.milliseconds)")
                } else {
                    token = currentToken
                    debugPrint("\(#function) GMS Token Re-Used - \(String(describing: token))")
                }

            } else {
                GoogleAutoCompleteToken.shared.token = GMSAutocompleteSessionToken.init()
                GoogleAutoCompleteToken.shared.milliseconds = Date().millisecondsSince1970
                token = GoogleAutoCompleteToken.shared.token!
                GoogleAutoCompleteToken.shared.isTokenExpired = false
                debugPrint("\(#function) GMS Token Generated - \(String(describing: token)) at \(GoogleAutoCompleteToken.shared.milliseconds)")
            }
            
            print(GoogleAutoCompleteToken.shared.token!)

            
            let filter = GMSAutocompleteFilter()
            filter.country = CurrentTrip.shared.currentCountryCode
//            filter.type = .noFilter

            let placeClient = GMSPlacesClient.shared()
            placeClient.findAutocompletePredictions(fromQuery: input, filter: filter, sessionToken: token, callback: { (results, error) in
                var myAddressArray :[(title:String,subTitle:String,address:String,placeid:String)] = []
                if let error = error {
                    print("Autocomplete error: \(error)")
                    completion(myAddressArray)
                    return
                }
                if let results = results {
                    myAddressArray = []
                    for result in results {
                        let mainString = (result.attributedPrimaryText.string)
                        let subString = (result.attributedSecondaryText?.string) ?? ""
                        let detailString = result.attributedFullText.string
                        let placeId = result.placeID
                        let myAddress:(title:String,subTitle:String,address:String,placeid:String) = (mainString,subString,detailString,placeId)
                        myAddressArray.append(myAddress)
                    }
                    completion(myAddressArray)
                }
                completion(myAddressArray)
            })
        }
    }

    //MARK: - LocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.notDetermined:
            print("\(self) \(#function) notDetermined")
            self.requestAuthorization()
        case CLAuthorizationStatus.restricted:
            print("\(self) \(#function) restricted")
        case CLAuthorizationStatus.denied:
            print("\(self) \(#function) denied")
            Common.nCd.post(name: Common.locationAuthorizationChangedNtfNm,
                            object: LocationCenter.default,
                            userInfo: nil)
        case CLAuthorizationStatus.authorizedAlways:
            print("\(self) \(#function) authorizedAlways")
            self.jobCompletion?()
        case CLAuthorizationStatus.authorizedWhenInUse:
            print("\(self) \(#function) authorizedWhenInUse")
            self.jobCompletion?()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let distance = location.distance(from: Common.location)
        let t1 = location.timestamp.timeIntervalSince1970
        let t2 = Common.location.timestamp.timeIntervalSince1970
        let time = t1-t2
        let speed = fabs(distance/time)
        print("Location speed: \(speed) meters/seconds")
        print("location.horizontalAccuracy \(location.horizontalAccuracy)")
        Common.location = location

        if (speed > 166.7) || 
            (location.horizontalAccuracy < 0.0) || 
            (location.horizontalAccuracy > 1000.0) {
            self.stopUpdatingLocation()
            print("Invalid location speed: \(speed/1000.0) kilometers/seconds")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) { [weak self] in 
                guard let self = self else { return }
                self.startUpdatingLocation()
                print("Retry location update due to occurrence of invalid speed")
            }
            return
        }

        if location.coordinate.isValidCoordinate() {
            Common.currentCoordinate = location.coordinate
        }
        Common.nCd.post(name: Common.locationUpdateNtfNm, 
                        object: LocationCenter.default, 
                        userInfo: [Common.locationKey: location])
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Common.nCd.post(name: Common.locationFailNtfNm, 
                        object: LocationCenter.default, 
                        userInfo: [Common.locationErrorKey: error])
    }

    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print("\(self) \(#function)")
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("\(self) \(#function)")
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("\(self) \(#function)")
    }

    func getTimeAndDistance(sourceCoordinate:CLLocationCoordinate2D,destCoordinate:CLLocationCoordinate2D, multipleStops: [StopLocationAddress], tripMultipleStops: [DestinationAddresses], unit:String, _ completion: @escaping TimeDistanceAPICompletion)
    {
        let time: String = "0"
        let distance:String = "0";

        if sourceCoordinate.isValidCoordinate() && destCoordinate.isValidCoordinate() {
            if sourceCoordinate.isEqual(destCoordinate) && multipleStops.count == 0 {
                completion(time,distance)
            } else {
                let pickup_latitude: String = sourceCoordinate.latitude.toString(places: 6)
                let pickup_longitude: String = sourceCoordinate.longitude.toString(places: 6)
                let destination_latitude: String = destCoordinate.latitude.toString(places: 6)
                let destination_longitude: String = destCoordinate.longitude.toString(places: 6)

                var waypoints = ""
                for i in 0..<multipleStops.count {
                    let add = multipleStops[i]
                    if i != 0 {
                        waypoints = waypoints + "|\(add.latitude ?? 0.0),\(add.longitude ?? 0.0)"
                    }
                    else {
                        waypoints = "\(add.latitude ?? 0.0),\(add.longitude ?? 0.0)"
                    }
                }
                
                for i in 0..<tripMultipleStops.count {
                    let add = tripMultipleStops[i]
                    if i != 0 {
                        waypoints = waypoints + "|\(add.location[0]),\(add.location[1] )"
                    }
                    else {
                        waypoints = "\(add.location[0]),\(add.location[1] )"
                    }
                }
                
                /*
                if multipleStops.count > 0 {
                    waypoints = waypoints + "|\(destination_latitude),\(destination_longitude)"
                }
                else {
                    if tripMultipleStops.count > 0 {
                        waypoints = waypoints + "|\(destination_latitude),\(destination_longitude)"
                    }
                    else {
                        waypoints = "\(destination_latitude),\(destination_longitude)"
                    }
                }*/
                
                if WebService.BASE_URL.contains("192.168.0.") {
                    completion("360","2")
                }
                
                //https://eber.elluminatiinc.net/gmapsapi/maps/api/directions/json?origin=22.303894,70.802160&waypoints=22.5617178,70.4223635|22.470702,70.057730&destination=22.470702,22.470702&key=AIzaSyCKxsYn1eXPw8KuBgt2KDi88WKkmIPTnLI
                
                var strUrl = Google.DIRECTION_URL + "\(pickup_latitude),\(pickup_longitude)&destination=\(destination_latitude),\(destination_longitude)&key=\(preferenceHelper.getGoogleKey())" as NSString
                
                if !waypoints.isEmpty {
                    strUrl = Google.DIRECTION_URL + "\(pickup_latitude),\(pickup_longitude)&waypoints=\(waypoints)&destination=\(destination_latitude),\(destination_longitude)&key=\(preferenceHelper.getGoogleKey())" as NSString
                }
                
                //let strUrl = Google.TIME_DISTANCE_URL + "\(pickup_latitude),\(pickup_longitude)&destinations=\(waypoints)&key=\(preferenceHelper.getGoogleKey())" as NSString
                                
                if let urlStr = strUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL.init(string: urlStr) {
                    let parseData = parseJSON(inputData: getJSON(urlToRequest: url))
                    print("Time And Distance \(strUrl) \(parseData)")
                    let googleRsponse: GoogleDistanceMatrixResponse = GoogleDistanceMatrixResponse(dictionary:parseData)!
                    if ((googleRsponse.status?.compare("OK")) == ComparisonResult.orderedSame) {
                        
                        var t: Int = 0
                        var d: Double = 0
                        
                        let routes = parseData["routes"] as? [[String:Any]] ?? []
                        
                        for route in routes {
                            let legs = route["legs"] as? [[String:Any]] ?? []
                            for leg in legs {
                                if let distance = leg["distance"] as? [String:Any] {
                                    if let value = distance["value"] as? Double {
                                        d += value
                                    }
                                }
                                if let duration = leg["duration"] as? [String:Any] {
                                    if let value = duration["value"] as? Int {
                                        t += value
                                    }
                                }
                            }
                        }
                        completion(t.toString(), d.toString())
                        /*
                        if let rows = googleRsponse.rows {
                            for tempS in rows {
                                if let element = tempS.elements {
                                    for tempData in element {
                                        if let tt = tempData.duration?.value, let dd = tempData.distance?.value {
                                            t = t + tt
                                            d = d + dd
                                        }
                                    }
                                }
                            }
                        }*/
                        
                    } else {
                        completion(time,distance)
                    }
                } else {
                    completion(time,distance)
                }
            }
        }
    }

    func getJSON(urlToRequest:URL) -> Data {
        var content:Data?
        do {
            content = try Data(contentsOf:urlToRequest)
        }
        catch let error {
            print(error)
        }
        return content ?? Data.init()
    }

    func parseJSON(inputData:Data) -> NSDictionary{
        var dictData: NSDictionary = NSDictionary.init()
        if inputData.count > 0 {
            do {
                if let data = (try JSONSerialization.jsonObject(with: inputData, options: .mutableContainers)) as? NSDictionary  {
                    dictData = data
                }
            }
            catch {
                print("Response not proper")
            }
        }
        return dictData
    }
    
    func reverseGeocoder(location: CLLocation, _ completion: @escaping Completion) {
        if self.geocoder.isGeocoding {
            self.geocoder.cancelGeocode()
        }

        self.geocoder.reverseGeocodeLocation(location) {
            [weak self] (placemarks: [CLPlacemark]?, error: Error?) in
            guard let self = self else { return }

            if let placemark = placemarks?.first {
                print("\(self) \(#function) \(placemark)")
                self.country = placemark.country ?? ""
                self.countryISOcode = placemark.isoCountryCode ?? ""
                print("LC.default.country: \(LocationCenter.self.default.country)")
                print("LC.default.countryISOcode: \(LocationCenter.self.default.countryISOcode)")
            }
            else {
                print("\(self) \(#function) \(error?.localizedDescription ?? "")")

                let gmsGeocoder: GMSGeocoder = GMSGeocoder()
                gmsGeocoder.reverseGeocodeCoordinate(location.coordinate)
                { [weak self] (response: GMSReverseGeocodeResponse?, error: Error?) in
                    if error == nil {
                        if let r = response {
                            if let first = r.firstResult() {
                                self?.country = first.country ?? ""
                               // self?.countryISOcode = AppDefaults.countries[self?.country ?? ""] ?? ""
                                print("LC.default.country: \(LocationCenter.self.default.country)")
                                print("LC.default.countryISOcode: \(LocationCenter.self.default.countryISOcode)")
                            }
                        }
                    }
                    else {
                        self?.country = ""
                        self?.countryISOcode = ""
                        print("LC.default.country: \(LocationCenter.self.default.country)")
                        print("LC.default.countryISOcode: \(LocationCenter.self.default.countryISOcode)")
                    }
                    completion()
                }
            }
            completion()
        }
    }
}

extension CLLocationCoordinate2D {
    func isValidCoordinate() -> Bool {
        if self.latitude == 0.0 && self.longitude == 0.0 {
            return false
        }
        return CLLocationCoordinate2DIsValid(self)
    }

    func isEqual(_ coord: CLLocationCoordinate2D) -> Bool {
        return self.latitude == coord.latitude && self.longitude == coord.longitude
    }

    func calculateBearing(to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = Double.pi * self.latitude / 180.0
        let long1 = Double.pi * self.longitude / 180.0
        let lat2 = Double.pi * destination.latitude / 180.0
        let long2 = Double.pi * destination.longitude / 180.0
        let rads = atan2(
            sin(long2 - long1) * cos(lat2),
            cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(long2 - long1))
        let degrees = rads * 180 / Double.pi

        return (degrees+360).truncatingRemainder(dividingBy: 360)

    }

    func bearing(to point: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
        
        let fromLatitude = degreesToRadians(latitude)
        let fromLongitude = degreesToRadians(longitude)
        
        let toLatitude = degreesToRadians(point.latitude)
        let toLongitude = degreesToRadians(point.longitude)
        
        let differenceLongitude = toLongitude - fromLongitude
        
        let y = sin(differenceLongitude) * cos(toLatitude)
        let x = cos(fromLatitude) * sin(toLatitude) - sin(fromLatitude) * cos(toLatitude) * cos(differenceLongitude)
        let radiansBearing = atan2(y, x);
        let degree = radiansToDegrees(radiansBearing)
        return (degree >= 0) ? degree : (360 + degree)
    }
}

public class GoogleAutoCompleteToken
{
    static let shared = GoogleAutoCompleteToken()
    var token:GMSAutocompleteSessionToken? = nil
    var milliseconds: Double = 0
    var isTokenExpired : Bool = false
    private init()
    {

    }
    func isExpired() -> Bool{
        let difference = (Date().millisecondsSince1970 - self.milliseconds)
        return difference > (180000)

    }
}
extension Locale {

    func countryName(from countryCode: String) -> String? {
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            // Country name was found
            return name
        } else {
            // Country name cannot be found
            return countryCode
        }
    }

}
