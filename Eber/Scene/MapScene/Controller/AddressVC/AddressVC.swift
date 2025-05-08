//
//  MapVC.swift
//  Eber Provider
//
//  Created by Elluminati iMac on 19/04/17.
//  Copyright © 2017 Elluminati iMac. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation


protocol AddressDelegate: AnyObject
{
    func pickupAddressSet()
    func destinationAddressSet()
    func checkRoute()
}

class AddressVC: BaseVC, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var heightForRecentAddTableView: NSLayoutConstraint!
    @IBOutlet weak var tableViewRecentAddress: UITableView!
    @IBOutlet weak var autoCompleteHeight: NSLayoutConstraint!
    @IBOutlet weak var autoCompleteTop: NSLayoutConstraint!
    
    @IBOutlet weak var tblForAutoComplete: UITableView!
    weak var delegate: AddressDelegate?
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet var lblTitle: UILabel!
    
    @IBOutlet weak var viewForPickupAddress: UIView!
    @IBOutlet weak var btnClearPickupAddress: UIButton!
    @IBOutlet weak var txtPickupAddress: UITextField!
    
    @IBOutlet weak var viewForDestinationAddress: UIView!
    @IBOutlet weak var btnClearDestinaitonAddress: UIButton!
    @IBOutlet weak var txtDestinationAddress: UITextField!
    
    @IBOutlet weak var viewForHomeAddress: UIView!
    @IBOutlet weak var btnAddHomeAddress: UIButton!
    @IBOutlet weak var lblHomeAddress: UILabel!
    
    @IBOutlet weak var viewForWorkAddress: UIView!
    @IBOutlet weak var btnAddWorkAddress: UIButton!
    @IBOutlet weak var lblWorkAddress: UILabel!
    
    @IBOutlet weak var viewForSetLocationOnMap: UIView!
    @IBOutlet weak var lblSetLocationOnMap: UILabel!
    @IBOutlet weak var btnSetLocationOnMap: UIButton!
    
    @IBOutlet weak var viewForAddDestinationLater: UIView!
    @IBOutlet weak var lblAddDestinationLater: UILabel!
    @IBOutlet weak var btnAddDestinationLater: UIButton!
    
    @IBOutlet weak var lblIconHomeLocation: UILabel!
    @IBOutlet weak var lblIconWorkAddress: UILabel!
    
    @IBOutlet weak var lblIconSetLocationMap: UILabel!
    @IBOutlet weak var lblIconAddDestinationLatter: UILabel!
    
    @IBOutlet weak var btnAddStops: UIButton!

    @IBOutlet weak var viewForStop1Address: UIView!
    @IBOutlet weak var btnClearStop1Address: UIButton!
    @IBOutlet weak var txtStop1Address: UITextField!
    
    @IBOutlet weak var viewForStop2Address: UIView!
    @IBOutlet weak var btnClearStop2Address: UIButton!
    @IBOutlet weak var txtStop2Address: UITextField!
    
    @IBOutlet weak var viewForStop3Address: UIView!
    @IBOutlet weak var btnClearStop3Address: UIButton!
    @IBOutlet weak var txtStop3Address: UITextField!
    
    @IBOutlet weak var viewForStop4Address: UIView!
    @IBOutlet weak var btnClearStop4Address: UIButton!
    @IBOutlet weak var txtStop4Address: UITextField!
    
    @IBOutlet weak var viewForStop5Address: UIView!
    @IBOutlet weak var btnClearStop5Address: UIButton!
    @IBOutlet weak var txtStop5Address: UITextField!
        
    @IBOutlet weak var tblDestinations: UITableView!
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnConfirm: UIButton!


    
    var maxAllowedStops = 0
    var isMultipleStopsAllowed = false
    
    var tripStops = 0
    var arrLocations = [StopLocationAddress]()
    
    var picUpAddress: StopLocationAddress?
    var destinationAddres: StopLocationAddress?
    
    var arrForAutoCompleteAddress:[(title:String,subTitle:String,address:String,placeid:String)] = []
    
    var flag = AddressType.pickupAddress;
    
    //MARK:
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.txtPickupAddress.isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector((longPressFunctin(_:))))
        self.txtPickupAddress.addGestureRecognizer(longPress)
        
        self.tblDestinations.delegate = self
        self.tblDestinations.dataSource = self
        self.tblDestinations.tableFooterView = UIView()
        self.tblDestinations.register(UINib(nibName: AddLocationTVC.className, bundle: nil), forCellReuseIdentifier: AddLocationTVC.className)
        
        tblForAutoComplete.delegate = self
        tblForAutoComplete.dataSource = self
        
        let homeTapGesutre:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.onClickBtnHomeAddress(_:)))
        lblHomeAddress.addGestureRecognizer(homeTapGesutre)
        lblHomeAddress.isUserInteractionEnabled = true
        
        let workTapGesutre:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.onClickBtnWorkAddress(_:)))
        lblWorkAddress.addGestureRecognizer(workTapGesutre)
        lblWorkAddress.isUserInteractionEnabled = true
        
        self.txtPickupAddress.placeholder = "TXT_PICKUP_ADDRESS_PLACE_HOLDER".localized
        self.txtDestinationAddress.placeholder = "TXT_DESTINATION_ADDRESS_PLACE_HOLDER".localized
        
        txtPickupAddress.delegate = self
        txtDestinationAddress.delegate = self
        
        self.viewForStop1Address.isHidden = true
        self.viewForStop2Address.isHidden = true
        self.viewForStop3Address.isHidden = true
        self.viewForStop4Address.isHidden = true
        self.viewForStop5Address.isHidden = true
        
        lblTitle.text = "TXT_WHERE_TO_GO".localizedCapitalized
        lblTitle.font = FontHelper.font(size: FontSize.medium
            , type: FontType.Bold)
        lblTitle.textColor = UIColor.themeTextColor
        
        self.isMultipleStopsAllowed = preferenceHelper.getIsAllowMultipleStop()
        if self.isMultipleStopsAllowed {
            self.btnAddStops.isHidden = false
            self.maxAllowedStops = preferenceHelper.getMultipleStopCount()
        }
        else {
            self.btnAddStops.isHidden = true
        }
        
        self.setLocalization()
        
        txtPickupAddress.text = CurrentTrip.shared.pickupAddress
        txtDestinationAddress.text = CurrentTrip.shared.destinationtAddress
        self.setPickUpAddress(address: CurrentTrip.shared.pickupAddress, lat: CurrentTrip.shared.pickupCoordinate.latitude, long: CurrentTrip.shared.pickupCoordinate.longitude)
        self.setDestinationAddress(address: CurrentTrip.shared.destinationtAddress, lat: CurrentTrip.shared.destinationCoordinate.latitude, long: CurrentTrip.shared.destinationCoordinate.longitude)
    }
    
    //Write these all functions outside the viewDidLoad()
    @objc func longPressFunctin(_ gestureRecognizer: UILongPressGestureRecognizer) {
        txtPickupAddress.becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(CGRect(x: self.txtPickupAddress.center.x, y: self.txtPickupAddress.center.y, width: 0.0, height: 0.0), in: view)
            menu.setMenuVisible(true, animated: true)
        }
    }

//    override func copy(_ sender: Any?) {
//        let board = UIPasteboard.general
//        board.string = txtPickupAddress.text
//    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        return action == #selector(copy(_:)) && action == #selector(copy(_:))
//    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.wsGetRecentAddress()
        if arrLocations.count >= maxAllowedStops {
            btnAddStops.isHidden = true
        }

        self.tblHeight.constant = CGFloat(self.arrLocations.count * 50)
        
        lblHomeAddress.text = CurrentTrip.shared.favouriteAddress.homeAddress
        lblWorkAddress.text = CurrentTrip.shared.favouriteAddress.workAddress

        btnAddWorkAddress.isSelected =  !CurrentTrip.shared.favouriteAddress.workAddress.isEmpty
        btnAddHomeAddress.isSelected =  !CurrentTrip.shared.favouriteAddress.homeAddress.isEmpty
        
        if lblHomeAddress.text!.isEmpty() {
            lblHomeAddress.text = "TXT_TAP_TO_ADD_HOME_ADDRESS".localized
        }
        if lblWorkAddress.text!.isEmpty() {
            lblWorkAddress.text = "TXT_TAP_TO_ADD_WORK_ADDRESS".localized
        }
        self.getCountryCode()
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch self.flag {
        case AddressType.pickupAddress:
            self.txtPickupAddress.becomeFirstResponder()
            break
        case AddressType.destinationAddress:
            self.txtDestinationAddress.becomeFirstResponder()
            break
        case AddressType.homeAddress:
            self.txtDestinationAddress.becomeFirstResponder()
            break
        case AddressType.workAddress:
            self.txtDestinationAddress.becomeFirstResponder()
            break
        default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLayout()
    }
    
    //MARK:
    //MARK: Set localized
    func setLocalization() {
        txtPickupAddress.text = "TXT_PICKUP_ADDRESS".localized
        txtPickupAddress.textColor = UIColor.themeTextColor
        txtPickupAddress.font = FontHelper.font(size: FontSize.regular15, type: FontType.Regular)
        
        txtDestinationAddress.text = "TXT_DESTINATION_ADDRESS".localized
        txtDestinationAddress.textColor = UIColor.themeTextColor
        txtDestinationAddress.font = FontHelper.font(size: FontSize.regular15, type: FontType.Regular)
        
        btnAddHomeAddress.setTitle("+", for: .normal)
        btnAddHomeAddress.setTitle("TXT_DELETE".localizedCapitalized   , for: .selected)
        btnAddHomeAddress.setTitleColor(UIColor.themeButtonBackgroundColor, for: .normal)
        btnAddHomeAddress.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        
        btnAddWorkAddress.setTitle("+", for: .normal)
        btnAddWorkAddress.setTitle("TXT_DELETE".localizedCapitalized   , for: .selected)
        btnAddWorkAddress.setTitleColor(UIColor.themeButtonBackgroundColor, for: .normal)
        
        btnAddWorkAddress.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        
        lblHomeAddress.textColor = UIColor.themeTextColor
        lblHomeAddress.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)

        lblWorkAddress.textColor = UIColor.themeTextColor
        lblWorkAddress.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        
        lblSetLocationOnMap.text = "TXT_SET_LOCATION_ON_MAP".localized
        lblSetLocationOnMap.textColor = UIColor.themeTextColor
        lblSetLocationOnMap.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        
        lblAddDestinationLater.text = "TXT_ADD_DESTINATION_LATER".localized
        lblAddDestinationLater.textColor = UIColor.themeTextColor
        lblAddDestinationLater.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        
//        self.lblIconWorkAddress.text = FontAsset.icon_work_address
//        self.lblIconSetLocationMap.text = FontAsset.icon_location
//        self.lblIconHomeLocation.text = FontAsset.icon_home_address
//        self.lblIconAddDestinationLatter.text = FontAsset.icon_location
        
        btnAddStops.setTitle("txt_add_stop".localized, for: .normal)
        btnAddStops.setTitleColor(UIColor.themeButtonBackgroundColor, for: .normal)
        btnAddStops.titleLabel?.font = FontHelper.font(size: FontSize.regular15, type: .Regular)
        
        btnConfirm.setTitle("TXT_CONFIRM".localized, for: .normal)
        btnConfirm.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnConfirm.backgroundColor = UIColor.themeButtonBackgroundColor
        btnConfirm.titleLabel?.font = FontHelper.font(size: FontSize.regular15, type: .Regular)
        btnConfirm.layer.cornerRadius = btnConfirm.frame.size.height/2
        btnConfirm.clipsToBounds = true
        
        self.lblIconHomeLocation.setForIcon()
        self.lblIconSetLocationMap.setForIcon()
        self.lblIconAddDestinationLatter.setForIcon()
        self.lblIconWorkAddress.setForIcon()
        
//        btnClearPickupAddress.setTitle(FontAsset.icon_cross_rounded, for: .normal)
//        btnClearDestinaitonAddress.setTitle(FontAsset.icon_cross_rounded, for: .normal)
//        self.btnClearStop1Address.setTitle(FontAsset.icon_cross_rounded, for: .normal)
//        self.btnClearStop2Address.setTitle(FontAsset.icon_cross_rounded, for: .normal)
//        self.btnClearStop3Address.setTitle(FontAsset.icon_cross_rounded, for: .normal)
//        self.btnClearStop4Address.setTitle(FontAsset.icon_cross_rounded, for: .normal)
//        self.btnClearStop5Address.setTitle(FontAsset.icon_cross_rounded, for: .normal)
        
        btnClearPickupAddress.setSimpleIconButton()
        btnClearDestinaitonAddress.setSimpleIconButton()

//        btnBack.setupBackButton()
    }
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        print("345434r432332r \(action)")
//        return false
        if action == #selector(UIResponderStandardEditActions.copy(_:)){
            return false
        }
        if action == #selector(paste(_:)){
            return false
        }
        if action == #selector(UIResponderStandardEditActions.cut(_:)) {
            return false
        }

        return false
    }
    /*
     
     */
    func setPickUpAddress(address:String, lat: Double, long: Double) {
        let addressObj = StopLocationAddress(addres: address, lat: lat, long: long)
        self.picUpAddress = addressObj
        txtPickupAddress.text = address
    }
    
    func setDestinationAddress(address:String, lat: Double, long: Double) {
        let addressObj = StopLocationAddress(addres: address, lat: lat, long: long)
        self.destinationAddres = addressObj
        txtDestinationAddress.text = address
    }
    
    func setStopAddress(index: Int, address:String, lat: Double, long: Double) {
        var arrLocation = [StopLocationAddress]()
        let addressObj = StopLocationAddress(addres: address, lat: lat, long: long)
        self.arrLocations[index] = addressObj
        self.tblDestinations.reloadData()
    }
    
    func isDublicateAddress() -> Bool {
        var arr = [StopLocationAddress]()
        arr.append(picUpAddress!)
        arr.append(contentsOf: arrLocations)
        arr.append(destinationAddres!)
                    
        for i in 0..<arr.count {
            if i == arr.count - 1 {
                break
            }
            let obj = arr[i]
            let nextobj = arr[i + 1]
            if (obj.latitude == nextobj.latitude && obj.longitude == nextobj.longitude) || (obj.address == nextobj.address) {
                Utility.showToast(message: "txt_please_enter_valid_address".localized)
                return true
            }
        }
        return false
    }
    
    func validStopLocation() -> Bool {
        for arrLocation in arrLocations {
            if arrLocation.address.isEmpty || (arrLocation.latitude == 0 && arrLocation.longitude == 0) {
                return false
            }
        }
        return true
    }
    
    func getCountryCode()
    {
        if CurrentTrip.shared.pickupCoordinate.latitude != 0.0 && CurrentTrip.shared.pickupCoordinate.longitude != 0.0
        {
            LocationCenter.default.fetchCityAndCountry(location: CLLocation.init(latitude: CurrentTrip.shared.pickupCoordinate.latitude, longitude: CurrentTrip.shared.pickupCoordinate.longitude))
            { (city, country, error) in
                if error != nil {
                    Utility.hideLoading()
                } else {
                    CurrentTrip.shared.pickupCity = city ?? ""
                    CurrentTrip.shared.pickupCountry = country?.lowercased() ?? ""
                }
            }
        }
    }
    
    func setupLayout() {
        navigationView.navigationShadow()
    }

    //MARK:
    //MARK: Action Methods
    @IBAction func onDeleteStopAddressClicked(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            self.viewForStop1Address.isHidden = true
            self.txtStop1Address.text = ""
            CurrentTrip.shared.clearStop1Address()
            break
        case 2:
            self.viewForStop2Address.isHidden = true
            self.txtStop2Address.text = ""
            CurrentTrip.shared.clearStop2Address()
            break
        case 3:
            self.viewForStop3Address.isHidden = true
            self.txtStop3Address.text = ""
            CurrentTrip.shared.clearStop3Address()
            break
        case 4:
            self.viewForStop4Address.isHidden = true
            self.txtStop4Address.text = ""
            CurrentTrip.shared.clearStop4Address()
            break
        case 5:
            self.viewForStop5Address.isHidden = true
            self.txtStop5Address.text = ""
            CurrentTrip.shared.clearStop5Address()
            break
        default:
            break
        }
    }
    
    
    @IBAction func onAddNewStopClicked(_ sender: UIButton) {
        self.tripStops += 1
        let newStop : StopLocationAddress = StopLocationAddress(fromDictionary: [:])
        self.arrLocations.append(newStop)
        self.tblHeight.constant = CGFloat(self.arrLocations.count * 50)
        self.btnAddStops.isHidden = self.arrLocations.count == self.maxAllowedStops ? true : false
        self.tblDestinations.reloadData()
        DispatchQueue.main.async {
            self.setupLayout()
        }
    }
    
    @IBAction func onClickBtnAddDeleteWorkAddress(_ sender: Any) {
    
        flag = AddressType.workAddress
        if (!btnAddWorkAddress.isSelected)
        {
            let locationVC : LocationVC = storyboard?.instantiateViewController(withIdentifier: "locationVC") as! LocationVC
            locationVC.delegate = self
            locationVC.flag = AddressType.workAddress
            
            locationVC.focusLocation =  CurrentTrip.shared.currentCoordinate
            self.navigationController?.pushViewController(locationVC, animated: true)
            //self.present(locationVC, animated: true, completion: nil)
            //btnAddWorkAddress.isSelected =  !btnAddHomeAddress.isSelected
        }
        else
        {
            self.wsSetAddress()
            btnAddWorkAddress.isSelected =  !btnAddHomeAddress.isSelected
        }
    }
    
    @IBAction func onClickBtnAddDeleteHomeAddress(_ sender: Any)
    {
        
        flag = AddressType.homeAddress
        if (!btnAddHomeAddress.isSelected)
        {
            let locationVC : LocationVC = storyboard?.instantiateViewController(withIdentifier: "locationVC") as! LocationVC
            locationVC.delegate = self
            locationVC.flag = AddressType.homeAddress
            locationVC.focusLocation =  CurrentTrip.shared.currentCoordinate
            self.navigationController?.pushViewController(locationVC, animated: true)
            //self.present(locationVC, animated: true, completion: nil)
            // btnAddHomeAddress.isSelected =  !btnAddHomeAddress.isSelected
        }
        else
        {
            self.wsSetAddress()
              btnAddHomeAddress.isSelected =  !btnAddHomeAddress.isSelected
        }
    }

    @IBAction func onClickBtnHomeAddress(_ sender: Any) {
        let address = CurrentTrip.shared.favouriteAddress
        if flag == AddressType.pickupAddress {
//            let address = CurrentTrip.shared.favouriteAddress
            if !address.homeAddress.isEmpty() {
                self.setPickUpAddress(address: address.homeAddress, lat: address.homeLocation[0], long: address.homeLocation[1])
            } else {
                self.onClickBtnAddDeleteHomeAddress(btnAddHomeAddress as Any)
            }
        }
        else if flag == AddressType.destinationAddress {
            let address = CurrentTrip.shared.favouriteAddress
            if !address.homeAddress.isEmpty() {
                self.setDestinationAddress(address: address.homeAddress, lat: address.homeLocation[0], long: address.homeLocation[1])
            } else {
                self.onClickBtnAddDeleteHomeAddress(btnAddHomeAddress!)
            }
        }
        else if flag == AddressType.stop1Address {
            
            self.setStopAddress(index: 0, address: address.homeAddress, lat: address.homeLocation[0], long: address.homeLocation[1])
        }
        else if flag == AddressType.stop2Address {
            self.setStopAddress(index: 1, address: address.homeAddress, lat: address.homeLocation[0], long: address.homeLocation[1])
        }
        else if flag == AddressType.stop3Address {
            self.setStopAddress(index: 2, address: address.homeAddress, lat: address.homeLocation[0], long: address.homeLocation[1])
        }
        
        /*
         static let stop1Address :Int = 11
         static let stop2Address :Int = 12
         static let stop3Address :Int = 13
         static let stop4Address :Int = 14
         static let stop5Address :Int = 15
         */
    }

    @IBAction func onClickBtnWorkAddress(_ sender: Any) {
        let address = CurrentTrip.shared.favouriteAddress
        if flag == AddressType.pickupAddress {
            let address = CurrentTrip.shared.favouriteAddress
            if !address.workAddress.isEmpty() {
                self.setPickUpAddress(address: address.workAddress, lat: address.workLocation[0], long: address.workLocation[1])
            } else {
                self.onClickBtnAddDeleteWorkAddress(btnAddWorkAddress!)
            }
        } else if flag == AddressType.destinationAddress {
            let address = CurrentTrip.shared.favouriteAddress
            if !address.workAddress.isEmpty() {
                self.setDestinationAddress(address: address.workAddress, lat: address.workLocation[0], long: address.workLocation[1])
            } else{
                self.onClickBtnAddDeleteWorkAddress(btnAddWorkAddress as Any)
            }
        }
        else if flag == AddressType.stop1Address {
            
            self.setStopAddress(index: 0, address: address.workAddress, lat: address.workLocation[0], long: address.workLocation[1])
        }
        else if flag == AddressType.stop2Address {
            self.setStopAddress(index: 1, address: address.workAddress, lat: address.workLocation[0], long: address.workLocation[1])
        }
        else if flag == AddressType.stop3Address {
            self.setStopAddress(index: 2, address: address.workAddress, lat: address.workLocation[0], long: address.workLocation[1])
        }
    }
    
    @IBAction func onClickBtnSetLocationOnMap(_ sender: Any) {
        let locationVC : LocationVC = storyboard?.instantiateViewController(withIdentifier: "locationVC") as! LocationVC
        locationVC.delegate = self
        locationVC.flag = self.flag

        if self.flag == AddressType.pickupAddress {
            if CurrentTrip.shared.pickupCoordinate.latitude != 0.0 &&  CurrentTrip.shared.pickupCoordinate.longitude != 0.0 {
                locationVC.focusLocation =  CurrentTrip.shared.pickupCoordinate
            } else {
                locationVC.focusLocation =  CurrentTrip.shared.currentCoordinate
            }
        } else if self.flag == AddressType.destinationAddress {
            if CurrentTrip.shared.destinationCoordinate.latitude != 0.0 &&  CurrentTrip.shared.destinationCoordinate.longitude != 0.0 {
                locationVC.focusLocation =  CurrentTrip.shared.destinationCoordinate
            } else {
                locationVC.focusLocation =  CurrentTrip.shared.currentCoordinate
            }
        } else {
            locationVC.focusLocation =  CurrentTrip.shared.currentCoordinate
        }
        self.navigationController?.pushViewController(locationVC, animated: true)
    }

    @IBAction func onClickBtnBack(_ sender: Any) {
        GoogleAutoCompleteToken.shared.isTokenExpired = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        
        if txtPickupAddress.text!.isEmpty || picUpAddress == nil || (picUpAddress?.address ?? "").isEmpty() {
            Utility.showToast(message: "txt_please_enter_valid_address".localized)
        } else if !validStopLocation() && arrLocations.count > 0 {
            Utility.showToast(message: "txt_please_enter_valid_address".localized)
        } else if txtDestinationAddress.text!.isEmpty || destinationAddres == nil || (destinationAddres?.address ?? "").isEmpty() {
            Utility.showToast(message: "txt_please_enter_valid_address".localized)
        } else if isDublicateAddress() {
            Utility.showToast(message: "txt_please_enter_valid_address".localized)
        } else {
            CurrentTrip.shared.setPickupLocation(latitude: picUpAddress?.latitude ?? 0, longitude: picUpAddress?.longitude ?? 0, address: picUpAddress?.address ?? "")
            CurrentTrip.shared.setDestinationLocation(latitude: destinationAddres?.latitude ?? 0, longitude: destinationAddres?.longitude ?? 0, address: destinationAddres?.address ?? "")
            CurrentTrip.shared.setAllStopLocations(arrLocations: self.arrLocations)
            
            self.delegate?.destinationAddressSet()
            self.delegate?.pickupAddressSet()
            self.delegate?.checkRoute()
            self.wsSetAddressForRecent()
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func onClickBtnClearDestinationAddress(_ sender: Any) {
        txtDestinationAddress.text = ""
        tblForAutoComplete.isHidden = true
        txtDestinationAddress.becomeFirstResponder()
        CurrentTrip.shared.clearDestinationAddress()
    }

    @IBAction func onClickBtnClearPickupAddress(_ sender: Any) {
        txtPickupAddress.text = ""
        tblForAutoComplete.isHidden = true
        txtPickupAddress.becomeFirstResponder()
        CurrentTrip.shared.clearPickupAddress()
    }

    @IBAction func onClickBtnAddDestinationLater(_ sender: Any) {
        if txtPickupAddress.text!.isEmpty || picUpAddress == nil || (picUpAddress?.address ?? "").isEmpty() {
            Utility.showToast(message: "VALIDATION_MSG_PICKUP_ADDRESS_NOT_AVAILABLE".localized)
        } else {
            CurrentTrip.shared.arrStopLocations.removeAll()
            CurrentTrip.shared.clearDestinationAddress()
            CurrentTrip.shared.setPickupLocation(latitude: picUpAddress?.latitude ?? 0, longitude: picUpAddress?.longitude ?? 0, address: picUpAddress?.address ?? "")
            self.delegate?.destinationAddressSet()
            self.delegate?.pickupAddressSet()
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - RevealViewController Delegate Methods

extension AddressVC: UITextFieldDelegate
{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtPickupAddress {
            flag = 0
            autoCompleteTop.constant = viewForPickupAddress.frame.size.height + (viewForPickupAddress.globalFrame?.origin.y ?? 0)
        }
        if textField == txtDestinationAddress {
            flag = 1
            autoCompleteTop.constant = viewForDestinationAddress.frame.size.height + viewForDestinationAddress.frame.origin.y + 20
        }
        
        if textField.tag >= 10 {
            self.flag = textField.tag
            let temp = (viewForPickupAddress.frame.size.height + viewForPickupAddress.frame.origin.y + 50) + CGFloat((50 * (textField.tag - 10 + 1)))
            self.autoCompleteTop.constant = temp
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func searching(_ sender: UITextField) {
        print("searching")
        if sender == txtPickupAddress {
            tblForAutoComplete.tag = 0
        }
        else if sender == txtDestinationAddress {
            tblForAutoComplete.tag = 1
        }
        
        if (sender.text?.count)! > 2 {
            LocationCenter.default.googlePlacesResult(input: sender.text!, completion: { [unowned self] (array) in
                 self.arrForAutoCompleteAddress.removeAll()
                 if array.count > 0 {
                    self.arrForAutoCompleteAddress = array
                    self.tblForAutoComplete.reloadData()
                    self.autoCompleteHeight.constant = CGFloat(50 * array.count)
                    self.tblForAutoComplete.isHidden = false
                 } else {
                    self.tblForAutoComplete.isHidden = true
                 }
            })
        } else {
          self.arrForAutoCompleteAddress.removeAll()
          self.tblForAutoComplete.reloadData()
          self.tblForAutoComplete.isHidden = true
        }
    }
}

extension AddressVC:LocationHandlerDelegate
{
    func finalAddressAndLocation(address: String, latitude: Double, longitude: Double) {
        if flag == AddressType.pickupAddress
        {
            self.setPickUpAddress(address: address, lat: latitude, long: longitude)
        }
        else if flag == AddressType.destinationAddress
        {
            self.setDestinationAddress(address: address, lat: latitude, long: longitude)
        }
        
        if self.flag >= 10 {
            let newStop : StopLocationAddress = StopLocationAddress(fromDictionary: [:])
            newStop.address = address
            newStop.latitude = latitude
            newStop.longitude = longitude
            
            self.arrLocations[self.flag - 10] = newStop
                        
            self.tblDestinations.reloadData()
            self.setupLayout()
            self.tblForAutoComplete.isHidden = true
        }
        
    }
}

extension AddressVC:UITableViewDelegate,UITableViewDataSource {
    
    @objc func searchAddress(_ sender: UITextField) {
        
    }
    
    @objc func deleteAddress(_ sender: UIButton) {
        self.arrLocations.remove(at: sender.tag)
        self.tblHeight.constant = CGFloat(self.arrLocations.count * 50)
        self.btnAddStops.isHidden = self.arrLocations.count == self.maxAllowedStops ? true : false
        self.tblForAutoComplete.isHidden = true
        self.tblDestinations.reloadData()
        self.setupLayout()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == self.tblForAutoComplete {
            return arrForAutoCompleteAddress.count
        } else if tableView == tableViewRecentAddress {
            return CurrentTrip.shared.recentFiveAddress.count
        }

        return self.arrLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == self.tblForAutoComplete {
            let autoCompleteCell = tableView.dequeueReusableCell(withIdentifier: "autoCompleteCell", for: indexPath) as! AutocompleteCell
            
            if indexPath.row < arrForAutoCompleteAddress.count
            {
                autoCompleteCell.setCellData(place: arrForAutoCompleteAddress[indexPath.row])
            }
            
            return autoCompleteCell
        } else if tableView == tableViewRecentAddress {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentTableCell", for: indexPath) as! RecentTableCell
            cell.lblTitle.text = CurrentTrip.shared.recentFiveAddress[indexPath.row].address
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(deleteRecentAddress), for: .touchUpInside)
            self.heightForRecentAddTableView.constant = self.tableViewRecentAddress.contentSize.height
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddLocationTVC.className, for: indexPath) as! AddLocationTVC
            cell.selectionStyle = .none
            
            cell.btnClose.tag = indexPath.row
            cell.txtLocation.tag = 10 + indexPath.row
            
            cell.txtLocation.delegate = self
            cell.txtLocation.addTarget(self, action: #selector(searchAddress), for: .editingChanged)
            cell.btnClose.addTarget(self, action: #selector(deleteAddress), for: .touchUpInside)
            
            cell.delegate = self
            
            cell.setData(address: self.arrLocations[indexPath.row])
            
            cell.textChanged {[weak tableView] newText in
                DispatchQueue.main.async {
                    tableView?.beginUpdates()
                    tableView?.endUpdates()
                }
            }
            
            return cell
            
        }
        
    }
    
    @objc func deleteRecentAddress(_ sender: UIButton) {
        self.wsDeleteRecentAddress(index: sender.tag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        if tableView == self.tblForAutoComplete {
            if indexPath.row < arrForAutoCompleteAddress.count
            {
                tblForAutoComplete.isHidden = true
                let placeID = arrForAutoCompleteAddress[indexPath.row].placeid
                let address = self.arrForAutoCompleteAddress[indexPath.row].address
                let placeClient = GMSPlacesClient.shared()
                
                let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))
                placeClient.fetchPlace(fromPlaceID: placeID,
                                       placeFields: fields,
                                       sessionToken: GoogleAutoCompleteToken.shared.token, callback: {
                    (place: GMSPlace?, error: Error?) in
                    GoogleAutoCompleteToken.shared.token = nil
                    if let error = error {
                        
                        // TODO: Handle the error.
                        printE("An error occurred: \(error.localizedDescription)")
                        return
                    }
                    
                    if let place = place {
                        
                        GoogleAutoCompleteToken.shared.isTokenExpired = true
                        
                        if self.flag == AddressType.pickupAddress
                        {
                            if place.coordinate.latitude != 0.0 && place.coordinate.longitude != 0.0
                            {
                                self.setPickUpAddress(address: address, lat: place.coordinate.latitude, long: place.coordinate.longitude)
                            }
                            else
                            {
                                Utility.showToast(message: "VALIDATION_MSG_INVALID_LOCATION".localized)
                            }
                            
                        }
                        else if self.flag == AddressType.destinationAddress
                        {
                            if place.coordinate.latitude != 0.0 && place.coordinate.longitude != 0.0
                            {
                                self.setDestinationAddress(address: address, lat: place.coordinate.latitude, long: place.coordinate.longitude)
                            }
                            else
                            {
                                Utility.showToast(message: "VALIDATION_MSG_INVALID_LOCATION".localized)
                            }
                        }
                        
                        if self.flag >= 10 {
                            if place.coordinate.latitude != 0.0 && place.coordinate.longitude != 0.0
                            {
                                let newStop : StopLocationAddress = StopLocationAddress(fromDictionary: [:])
                                newStop.address = address
                                newStop.latitude = place.coordinate.latitude
                                newStop.longitude = place.coordinate.longitude
                               
                                self.arrLocations[self.flag - 10] = newStop
                                
                                self.tblDestinations.reloadData()
                                self.setupLayout()
                                self.tblForAutoComplete.isHidden = true
                            }
                            else
                            {
                                Utility.showToast(message: "VALIDATION_MSG_INVALID_LOCATION".localized)
                            }
                        }
                    }
                })
            }
        }
        else if tableView == tableViewRecentAddress{
            let address = CurrentTrip.shared.recentFiveAddress[indexPath.row]
            if flag == AddressType.pickupAddress {
                let address = CurrentTrip.shared.recentFiveAddress[indexPath.row]
                if !address.address.isEmpty() {
                    self.setPickUpAddress(address: address.address, lat: Double(address.location[0]), long: Double(address.location[1]))
                } else {
                    self.onClickBtnAddDeleteWorkAddress(btnAddWorkAddress!)
                }
            } else if flag == AddressType.destinationAddress {
                let address = CurrentTrip.shared.recentFiveAddress[indexPath.row]
                if !address.address.isEmpty() {
                    self.setDestinationAddress(address: address.address, lat: Double(address.location[0]), long: Double(address.location[1]))
                } else{
                    self.onClickBtnAddDeleteWorkAddress(btnAddWorkAddress as Any)
                }
            }
            else if flag == AddressType.stop1Address {
                
                self.setStopAddress(index: 0, address: address.address, lat: Double(address.location[0]), long: Double(address.location[1]))
            }
            else if flag == AddressType.stop2Address {
                self.setStopAddress(index: 1, address: address.address, lat: Double(address.location[0]), long: Double(address.location[1]))
            }
            else if flag == AddressType.stop3Address {
                self.setStopAddress(index: 2, address: address.address, lat: Double(address.location[0]), long: Double(address.location[1]))
            }
        }
    }
    
    
}

extension AddressVC: AddLocationDelegate {
    func textField(editingDidBeginIn cell: AddLocationTVC) {
        if let indexPath = self.tblDestinations?.indexPath(for: cell) {
            let row = indexPath.row
            self.flag = row
            let temp = (self.viewForPickupAddress.frame.maxY + 60) + CGFloat((50 * (row + 1)))
            self.autoCompleteTop.constant = temp
        }
    }
    
    func textField(editingChangedInTextField newText: String, in cell: AddLocationTVC) {
        
        if let indexPath = self.tblDestinations?.indexPath(for: cell) {
            let row = indexPath.row
            self.tblForAutoComplete.tag = 10 + row
        }
        
        if (newText.count) > 2 {
            LocationCenter.default.googlePlacesResult(input: newText, completion: { [unowned self] (array) in
                 self.arrForAutoCompleteAddress.removeAll()
                 if array.count > 0 {
                    self.arrForAutoCompleteAddress = array
                    self.tblForAutoComplete.reloadData()
                    self.autoCompleteHeight.constant = CGFloat(50 * array.count)
                    self.tblForAutoComplete.isHidden = false
                 } else {
                    self.tblForAutoComplete.isHidden = true
                 }
            })
        } else {
          self.arrForAutoCompleteAddress.removeAll()
          self.tblForAutoComplete.reloadData()
          self.tblForAutoComplete.isHidden = true
        }
        
    }
    
    
}

extension AddressVC
{
    
    func wsDeleteRecentAddress(index: Int)
    {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam["address"] = CurrentTrip.shared.recentFiveAddress[index].address
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.DELETE_RECENT_ADDRESS, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            
            
            if (error != nil)
            {
                Utility.hideLoading()
            }
            else
            {
                if Parser.isSuccess(response: response)
                {
                    self.wsGetAddress()
                    self.wsGetRecentAddress()
                    Utility.hideLoading()
                }
            }
        }
    }
    
    func wsSetAddressForRecent()
    {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
     if flag == AddressType.destinationAddress {
            dictParam["address"] = destinationAddres?.address
         dictParam["latitude"] = destinationAddres?.latitude
            dictParam["longitude"] = destinationAddres?.longitude
        }
       
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.SET_RECENET_FIVE_ADDRESS, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            
            if (error != nil)
            {
                Utility.hideLoading()
            }
            else
            {
                if Parser.isSuccess(response: response)
                {
                    self.wsGetAddress()
                    self.wsGetRecentAddress()
                }
            }
            
        }
    }
    
    func wsSetAddress()
    {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        if flag == AddressType.homeAddress
        {
            dictParam[PARAMS.HOME_ADDRESS] = ""
            dictParam[PARAMS.HOME_LATITUDE] = 0.0
            dictParam[PARAMS.HOME_LONGITUDE] = 0.0
        }
        else
        {
            dictParam[PARAMS.WORK_ADDRESS] = ""
            dictParam[PARAMS.WORK_LATITUDE] = 0.0
            dictParam[PARAMS.WORK_LONGITUDE] = 0.0
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
                    self.wsGetAddress()
                    self.wsGetRecentAddress()
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
            }
            else
            {
                if Parser.isSuccess(response: response)
                {
                    let userDataResponse:UserAddressResponse = UserAddressResponse.init(fromDictionary: response)
                    CurrentTrip.shared.favouriteAddress = userDataResponse.userAddress
                    self.btnAddWorkAddress.isSelected =  !CurrentTrip.shared.favouriteAddress.workAddress.isEmpty
                    self.btnAddHomeAddress.isSelected = !CurrentTrip.shared.favouriteAddress.homeAddress.isEmpty
                    self.lblHomeAddress.text = CurrentTrip.shared.favouriteAddress.homeAddress
                    self.lblWorkAddress.text = CurrentTrip.shared.favouriteAddress.workAddress
                    
                    if self.lblHomeAddress.text!.isEmpty()
                    {
                        self.lblHomeAddress.text = "TXT_TAP_TO_ADD_HOME_ADDRESS".localized
                    }
                    if self.lblWorkAddress.text!.isEmpty() {
                        self.lblWorkAddress.text = "TXT_TAP_TO_ADD_WORK_ADDRESS".localized
                    }
                    
                    Utility.hideLoading()
                }
            }
        }
    }
    
    func wsGetRecentAddress()
    {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_RECENT_FIVE_ADDRESS, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            
            
            if (error != nil)
            {
                Utility.hideLoading()
                self.heightForRecentAddTableView.constant = 0
            }
            else
            {
                if Parser.isSuccess(response: response)
                {
                    let userDataResponse:RecentAddressesResponse = RecentAddressesResponse.init(fromDictionary: response)
                    CurrentTrip.shared.recentFiveAddress = userDataResponse.recentAddresses
                   
                    if CurrentTrip.shared.recentFiveAddress.count == 0 {
                        self.heightForRecentAddTableView.constant = 0
                    }
                    
                    self.tableViewRecentAddress.reloadData()
                    
                    Utility.hideLoading()
                }
            }
        }
    }
}

class RecentTableCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnCross: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
