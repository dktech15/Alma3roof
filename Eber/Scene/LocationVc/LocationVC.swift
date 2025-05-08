//
//  LocationVC.swift
//  Elluminati
//
//  Created by Elluminati on 30/01/17.
//  Copyright © 2017 Elluminati. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

@objc protocol LocationHandlerDelegate: AnyObject {
    func finalAddressAndLocation(address:String,latitude:Double,longitude:Double)
}

class LocationVC: BaseVC,UINavigationControllerDelegate,UIScrollViewDelegate,GMSMapViewDelegate {

    weak var delegate:LocationHandlerDelegate?

    //MARK: - Outlets
    @IBOutlet var btnBack: UIButton!
    @IBOutlet weak var tblAutocomplete: UITableView!
    @IBOutlet weak var heightForAutoComplete: NSLayoutConstraint!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lblIconSourceLocation: UILabel!
    @IBOutlet weak var imgIconSourceLocation: UIImageView!
    
    @IBOutlet weak var lblIconSetLocation: UILabel!
    
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var imgForLocation: UIImageView!
    @IBOutlet weak var btnCurrentLocation: UIButton!
    @IBOutlet weak var imgCurrentLocation: UIImageView!
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var viewForSingleAddress: UIView!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var btnClearAddress: UIButton!
    @IBOutlet weak var imgClearAddress: UIImageView!

    //MARK: - Variables
    var focusLocation:CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: 22.30, longitude: 70.80)
    var address:String = "";
    var location:[Double] = [0.0,0.0];
    var flag:Int = AddressType.pickupAddress
    var arrForAdress:[(title:String,subTitle:String,address:String,placeid:String)] = []
    var country:String = "";
    var marker = GMSMarker()

    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad();
        setLocalization()
        self.tblAutocomplete.estimatedRowHeight = UITableView.automaticDimension
        self.mapView.padding = UIEdgeInsets.init(top: viewForSingleAddress.frame.maxY, left: 20, bottom: viewForSingleAddress.frame.maxY, right: 20)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewForSingleAddress.isHidden = false
        if focusLocation.isValidCoordinate() {} else {
            self.onClickBtnCurrentLocation(self.btnCurrentLocation as Any)
        }

        if flag == AddressType.pickupAddress {
            txtAddress.text = CurrentTrip.shared.pickupAddress
            self.animateToLocation(coordinate: focusLocation)
        }
        if flag == AddressType.destinationAddress {
           txtAddress.text = CurrentTrip.shared.destinationtAddress
            self.animateToLocation(coordinate: focusLocation)
        }
        if flag == AddressType.homeAddress {
            txtAddress.text = CurrentTrip.shared.favouriteAddress.homeAddress
            self.animateToLocation(coordinate: focusLocation)
        }
        if flag == AddressType.workAddress {
            txtAddress.text = CurrentTrip.shared.favouriteAddress.workAddress
            self.animateToLocation(coordinate: focusLocation)
        }
        
        if self.flag >= 10 {
            txtAddress.text = CurrentTrip.shared.destinationtAddress
            self.animateToLocation(coordinate: focusLocation)
        }
        
        // txtAddress.becomeFirstResponder()
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                   self.addMarkerAtCurrentLocation()
               }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        setupLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @IBAction func onClickBtnClearAddress(_ sender: Any) {
        txtAddress.text = "";
        tblAutocomplete.isHidden = true
    }

    func setLocalization() {
        //COLORS
        self.view.backgroundColor = UIColor.themeDialogBackgroundColor;
        self.viewForSingleAddress.backgroundColor = UIColor.themeDialogBackgroundColor
        self.txtAddress.placeholder = "TXT_ADDRESS".localizedCapitalized
        self.txtAddress.textColor = UIColor.themeTextColor
        self.txtAddress.delegate = self
        self.txtAddress.backgroundColor = UIColor.white

        self.btnDone.backgroundColor = UIColor.themeButtonBackgroundColor
        self.btnDone.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        self.btnDone.setTitle("TXT_CONFIRM".localizedCapitalized, for: .normal)
        self.btnDone.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)

        self.navigationView.backgroundColor = UIColor.clear

        self.mapView.bringSubviewToFront(self.imgForLocation)
        self.mapView.bringSubviewToFront(self.imgIconSourceLocation)
        self.mapView.delegate = self;
        self.mapView.settings.allowScrollGesturesDuringRotateOrZoom = false;
       

        if Bundle.main.url(forResource: "styleable_map", withExtension: "json") != nil {
           // mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
        } else {
            printE("Unable to find style.json")
        }
        imgIconSourceLocation.tintColor = UIColor.themeImageColor
        
//        lblIconSetLocation.text = FontAsset.icon_location
//        lblIconSourceLocation.text = FontAsset.icon_pickup_location
//        btnClearAddress.setTitle(FontAsset.icon_cross_rounded, for: .normal)
//        btnCurrentLocation.setTitle(FontAsset.icon_btn_current_location, for: .normal)

//        lblIconSetLocation.setForIcon()
//        lblIconSourceLocation.setForIcon()
//        btnCurrentLocation.setSimpleIconButton()
//        btnClearAddress.setSimpleIconButton()
        imgCurrentLocation.tintColor = UIColor.themeImageColor
        imgClearAddress.tintColor = UIColor.themeImageColor
        
//        btnBack.setupBackButton()    
    }
    
    func addMarkerAtCurrentLocation() {
        let initialPosition = CLLocationCoordinate2D(
            latitude: CurrentTrip.shared.currentCoordinate.latitude,
            longitude: CurrentTrip.shared.currentCoordinate.longitude
        )
        
        marker.position = initialPosition
        marker.icon = UIImage(named: "Image_pin_marker") // Your custom pin image
        marker.map = mapView
        marker.iconView?.backgroundColor = .white.withAlphaComponent(0.1) // Helps visualize shadow during dev

        // Center map on marker position
        mapView.camera = GMSCameraPosition(target: initialPosition, zoom: 15)

       }

    @IBAction func onClickDismiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func setupLayout() {
        btnDone.setupButton()
        viewForSingleAddress.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 1.0)
        viewForSingleAddress.setShadow()
    }

    //MARK: - Button action methods
    @IBAction func onClickBtnDone(_ sender: UIButton) {
        if !address.isEmpty() && location[0] != 0.0 && location[1] != 0.0 {
            if flag == AddressType.pickupAddress || flag == AddressType.destinationAddress {
                if !self.country.lowercased().isEmpty() {
                    self.delegate?.finalAddressAndLocation(address: address, latitude: location[0], longitude: location[1])
                    self.navigationController?.popViewController(animated: true)
                } else {
                    Utility.showToast(message: "ERROR_CODE_1001".localized)
                }
            }
            else if self.flag >= 10 {
                self.delegate?.finalAddressAndLocation(address: address, latitude: location[0], longitude: location[1])
                self.navigationController?.popViewController(animated: true)
            }
            else {
                wsSetAddress()
            }
        } else {
            Utility.showToast(message: "VALIDATION_MSG_INVALID_LOCATION".localized)
        }
    }

    @IBAction func onClickBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

//    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        let myCoordinate = position.target
//        marker.position = myCoordinate
//        animateMarkerJump(marker: marker, to: myCoordinate)
//        LocationCenter.default.getAddressFromLatitudeLongitude(latitude: myCoordinate.latitude, longitude: myCoordinate.longitude) { [weak self](address, locations, country) in
//            guard let self = self else { return }
//            self.address = address
//            self.country = country.lowercased()
//            self.txtAddress.text = self.address
//            self.txtAddress.resignFirstResponder()
//            self.location = [myCoordinate.latitude, myCoordinate.longitude]
//        }
//    }
    

//------------------------------------------------------------------------------------------------
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let newCoordinate = position.target
         let iconView = marker.iconView 

        // Step 1: Lift and Shrink the Marker
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.marker.groundAnchor = CGPoint(x: 0.5, y: 1.3) // Lift up
            iconView?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7) // Shrink smoothly
        })

        // Step 2: Move the Marker with Smooth Animation
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setCompletionBlock {
            // Step 3: Restore Marker to Original Size & Position
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
                self.marker.groundAnchor = CGPoint(x: 0.5, y: 1.0) // Reset anchor
                iconView?.transform = CGAffineTransform.identity // Restore original size
            })
        }

        marker.position = newCoordinate
        CATransaction.commit()

        // Fetch address asynchronously
        LocationCenter.default.getAddressFromLatitudeLongitude(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude) { [weak self] (address, locations, country) in
            guard let self = self else { return }

            self.address = address
            self.country = country.lowercased()
            self.txtAddress.text = self.address
            self.txtAddress.resignFirstResponder()
            self.location = [newCoordinate.latitude, newCoordinate.longitude]
        }
    }


//    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        let newCoordinate = position.target
//        let iconView = marker.iconView
//
//        // ✅ Strong dark shadow behind marker
//        if let iconView = iconView {
//            iconView.layer.shadowColor = UIColor.black.cgColor
//            iconView.layer.shadowOpacity = 0.8  // Very dark shadow
//            iconView.layer.shadowOffset = CGSize(width: 0, height: 5) // Drop shadow down
//            iconView.layer.shadowRadius = 6     // Soft edge
//            iconView.layer.masksToBounds = false
//        }
//
//        // ✅ Animate: Lift and Shrink
//        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
//            self.marker.groundAnchor = CGPoint(x: 0.5, y: 1.3)
//            iconView?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//        })
//
//        // ✅ Animate Marker Move
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(0.5)
//        CATransaction.setCompletionBlock {
//            // Restore Size and Ground Anchor
//            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
//                self.marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
//                iconView?.transform = .identity
//            })
//        }
//
//        marker.position = newCoordinate
//        CATransaction.commit()
//
//        // ✅ Fetch address
//        LocationCenter.default.getAddressFromLatitudeLongitude(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude) { [weak self] (address, locations, country) in
//            guard let self = self else { return }
//
//            self.address = address
//            self.country = country.lowercased()
//            self.txtAddress.text = self.address
//            self.txtAddress.resignFirstResponder()
//            self.location = [newCoordinate.latitude, newCoordinate.longitude]
//        }
//    }


    // Ensure marker stays at center visually while the map moves
//    func animateMarkerJump(marker: GMSMarker) {
//        // Store the original position
//        let originalPosition = marker.position
//        let jumpHeight: CLLocationDegrees = 0.005// Small latitude change for the jump effect
//        
//        // Move the marker up
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(0.2)
//        marker.position = CLLocationCoordinate2D(latitude: originalPosition.latitude + jumpHeight,
//                                                 longitude: originalPosition.longitude)
//        
//        CATransaction.setCompletionBlock {
//            // Move the marker back down
//            CATransaction.begin()
//            CATransaction.setAnimationDuration(0.2)
//            marker.position = originalPosition
//            CATransaction.commit()
//        }
//        
//        CATransaction.commit()
//    }


//    func animateMarkerJump(marker: GMSMarker) {
//        let originalPosition = marker.position
//        let jumpHeight: CLLocationDegrees = 0.0008 // Adjust for visible jump effect
//
//        // Move up
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(0.2)
//        CATransaction.setCompletionBlock {
//            
//            // Move down slightly past the original position
//            CATransaction.begin()
//            CATransaction.setAnimationDuration(0.15)
//            marker.position = CLLocationCoordinate2D(latitude: originalPosition.latitude - (jumpHeight / 2),
//                                                     longitude: originalPosition.longitude)
//            
//            CATransaction.setCompletionBlock {
//                
//                // Move back to the original position (bounce effect)
//                CATransaction.begin()
//                CATransaction.setAnimationDuration(0.1)
//                marker.position = originalPosition
//                CATransaction.commit()
//            }
//            CATransaction.commit()
//        }
//        
//        marker.position = CLLocationCoordinate2D(latitude: originalPosition.latitude + jumpHeight,
//                                                 longitude: originalPosition.longitude)
//        CATransaction.commit()
//    }

    func animateMarkerJump(marker: GMSMarker, to newPosition: CLLocationCoordinate2D) {
        guard let iconView = marker.iconView else { return }

        let jumpHeight: CGFloat = 40 // Increase height for a bigger jump
        let jumpDuration: Double = 0.3 // Jump animation speed
        let moveDuration: Double = 0.5 // Smooth movement duration

        // Step 1: Make the marker jump before moving
        UIView.animate(withDuration: jumpDuration, animations: {
            iconView.transform = CGAffineTransform(translationX: 0, y: -jumpHeight)
        }) { _ in
            UIView.animate(withDuration: jumpDuration, animations: {
                iconView.transform = CGAffineTransform.identity
            }) { _ in
                // Step 2: After jump is completed, move the marker smoothly
                CATransaction.begin()
                CATransaction.setAnimationDuration(moveDuration)
                marker.position = newPosition
                CATransaction.commit()
            }
        }
    }


  

    // Set marker at the center initially
    func setupMarker() {
        let initialPosition = CLLocationCoordinate2D(
            latitude: CurrentTrip.shared.currentCoordinate.latitude,
            longitude: CurrentTrip.shared.currentCoordinate.longitude
        )
        
        marker.position = initialPosition
        marker.icon = UIImage(named: "Image_pin_marker") // Your custom pin image
        marker.map = mapView
        
        // Center map on marker position
        mapView.camera = GMSCameraPosition(target: initialPosition, zoom: 15)
    }

    // Keep marker at the center while dragging
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            
        }
    }


    @IBAction func onClickBtnCurrentLocation(_ sender: Any) {
        gettingCurrentLocation()
    }

    override func locationUpdate(_ ntf: Notification = Common.defaultNtf) {
        guard let userInfo = ntf.userInfo else { return }
        guard let location = userInfo["location"] as? CLLocation else { return }
        CurrentTrip.shared.currentCoordinate = location.coordinate
        LocationCenter.default.stopUpdatingLocation()
        self.animateToCurrentLocation()
    }
    func gettingCurrentLocation() {
        LocationCenter.default.addObserver(self, [#selector(self.locationUpdate(_:)), #selector(self.locationFail(_:)),#selector(locationAuthorizationChanged(_:))])
        LocationCenter.default.startUpdatingLocation()
    }

    func animateToCurrentLocation() {
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock {}
        let camera = GMSCameraPosition.camera(withTarget: CurrentTrip.shared.currentCoordinate, zoom: 17.0, bearing: 45, viewingAngle: 0.0)
        self.mapView.animate(to: camera)
        CATransaction.commit()
    }

    func animateToLocation(coordinate:CLLocationCoordinate2D) {
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock {}
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17.0, bearing: 45, viewingAngle: 0.0)
        self.mapView.animate(to: camera)
        CATransaction.commit()
    }

    @IBAction func searching(_ sender: UITextField) {
        if !CurrentTrip.shared.currentCountryCode.isEmpty {
            if (sender.text?.count)! > 2 {
                LocationCenter.default.googlePlacesResult(input: sender.text!, completion: { [unowned self] (array) in
                    self.arrForAdress = array
                    if self.arrForAdress.count > 0 {
                        self.heightForAutoComplete.constant = self.tblAutocomplete.contentSize.height
                        self.tblAutocomplete.reloadData()
                        self.tblAutocomplete.isHidden = false
                    } else {
                        self.tblAutocomplete.isHidden = true
                    }
                })
            }
        } else {
            self.getCountryCode()
        }
    }

    func getCountryCode() {
        if CurrentTrip.shared.pickupCoordinate.latitude != 0.0 && CurrentTrip.shared.pickupCoordinate.longitude != 0.0 {
            LocationCenter.default.fetchCityAndCountry(location: CLLocation.init(latitude: CurrentTrip.shared.pickupCoordinate.latitude, longitude: CurrentTrip.shared.pickupCoordinate.longitude))
            { (city, country, error) in
                if error != nil {
                    Utility.hideLoading()
                } else {
                    CurrentTrip.shared.pickupCity = city ?? ""
                    CurrentTrip.shared.pickupCountry = country?.lowercased() ?? ""
                }
            }
        } else {}
    }
}

extension LocationVC: UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrForAdress.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let autoCompleteCell = tableView.dequeueReusableCell(withIdentifier: "autoCompleteCell", for: indexPath) as! AutocompleteCell
        autoCompleteCell.setCellData(place: arrForAdress[indexPath.row])
        return autoCompleteCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        tblAutocomplete.isHidden = true
        let placeID = arrForAdress[indexPath.row].placeid
        let address = self.arrForAdress[indexPath.row].address
        let placeClient = GMSPlacesClient.shared()
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))
        placeClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: GoogleAutoCompleteToken.shared.token , callback: { (place: GMSPlace?, error: Error?) in
            GoogleAutoCompleteToken.shared.token = nil
            if let error = error {
                // TODO: Handle the error.
                printE("An error occurred: \(error.localizedDescription)")
                return
            }

            if let place = place {
                self.address = address
                self.location = [place.coordinate.latitude,place.coordinate.longitude]
                self.txtAddress.text = address
                self.animateToLocation(coordinate: place.coordinate)
            }
        })
    }
}

extension LocationVC
{
    func wsSetAddress()
    {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        if flag == AddressType.homeAddress
        {
            dictParam[PARAMS.HOME_ADDRESS] = address
            dictParam[PARAMS.HOME_LATITUDE] = location[0]
            dictParam[PARAMS.HOME_LONGITUDE] = location[1]
        }
        else
        {
            dictParam[PARAMS.WORK_ADDRESS] = address
            dictParam[PARAMS.WORK_LATITUDE] = location[0]
            dictParam[PARAMS.WORK_LONGITUDE] = location[1]
        }
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.SET_FAVOURITE_ADDRESS_LIST, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            
            
            if (error != nil)
            {
                Utility.hideLoading()
            }
            else
            {
                if Parser.isSuccess(response: response)
                {
                    self.wsGetAddress()
                    
                }
            }
            
        }
    }
    
    func wsGetAddress()
    {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_FAVOURITE_ADDRESS_LIST, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            
            
            if (error != nil)
            {
                Utility.hideLoading()
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                if Parser.isSuccess(response: response)
                {
                    
                    let userDataResponse:UserAddressResponse = UserAddressResponse.init(fromDictionary: response)
                    CurrentTrip.shared.favouriteAddress = userDataResponse.userAddress
                    Utility.hideLoading()
                    self.navigationController?.popViewController(animated: true)
               }
                
            }
        }
    }
}
