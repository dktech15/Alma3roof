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

class MapVC: BaseVC, GMSMapViewDelegate,AddressDelegate,UIGestureRecognizerDelegate, PaymentSelectionDelegate {
   
    
    
    @IBOutlet weak var viewWhereToGO: UIView!
    @IBOutlet weak var stkPaymentMethodTitle: UIStackView!
    @IBOutlet weak var paymentSelectionSheet: UIView!
    @IBOutlet var lblIconNoServiceAvailable: UILabel!
    @IBOutlet var imgIconNoServiceAvailable: UIImageView!
    @IBOutlet var btnPromoCode: UIButton!
    @IBOutlet var lblIconRentCar: UILabel!
    
    @IBOutlet var btnAddStop: UIButton!
    
    @IBOutlet weak var seperatorView: UIView!
    
    let socketHelper:SocketHelper = SocketHelper.shared
    /*Bottom View Animation*/
    
    @IBOutlet weak var scrFilterView: UIScrollView!
    @IBOutlet weak var lblIconPinSourceLocation: UILabel!
    @IBOutlet weak var imgIconPinSourceLocation: UIImageView!
    private var animationProgress: CGFloat = 0
    private var currentState: State = .closed
    @IBOutlet weak var heightForFilter: NSLayoutConstraint!
    
    @IBOutlet weak var lblIconETA: UILabel!
    @IBOutlet weak var imgIconETA: UIImageView!
    @IBOutlet weak var lblIconFareEstimate: UILabel!
    @IBOutlet weak var imgIconFareEstimate: UIImageView!
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    @IBOutlet weak var vwDivider: UIView!
    
    private var originalPullUpControllerViewSize: CGSize = .zero
    @IBOutlet weak var viewForRentalPackage: UIView!
    @IBOutlet weak var lblRentalPackSize: UILabel!
    
    @IBOutlet weak var viewForSelectRetalPackage: UIView!
    @IBOutlet weak var btnSelectPackage: UIButton!
    
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    //Ideal View
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var viewForWhereToGo: UIView!
    @IBOutlet weak var lblWhereToGo: UILabel!
    @IBOutlet weak var btnMyLocation: UIButton!
    
    var isViewDidLoad: Bool = false
    var isNearByProviderCalled: Bool = false
    
    var isSourceToDestPathDrawn:Bool = false
    var polyLinePath:GMSPolyline = GMSPolyline.init()
    var previousCity:String = "";
    
    //Provider Filter View
    @IBOutlet weak var viewForProviderFilter: UIView!
    @IBOutlet weak var dialogForProviderFilter: UIView!
    @IBOutlet weak var lblAccessibility: UILabel!
    @IBOutlet weak var btnHotspot: UIButton!
    @IBOutlet weak var btnHandicap: UIButton!
    @IBOutlet weak var btnBabySeat: UIButton!
    @IBOutlet weak var lblSelectLanguage: UILabel!
    @IBOutlet weak var tblProviderLanguage: UITableView!
    @IBOutlet weak var btnApplyFilter: UIButton!
    @IBOutlet weak var btnCancelFilter: UIButton!
    @IBOutlet weak var heightForLanguageTable: NSLayoutConstraint!
    @IBOutlet var lblBabySeat: UILabel!
    @IBOutlet var lblHandicap: UILabel!
    @IBOutlet var lblHotspot: UILabel!
    @IBOutlet weak var lblProviderGenderSelection: UILabel!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnRegular: UIButton!
    @IBOutlet weak var btnRental: UIButton!
    @IBOutlet weak var viewForRideNowLater: UIView!
    
    //Favourite Address View
    @IBOutlet weak var btnHomeAddress: UIButton!
    @IBOutlet weak var imgHomeAddress: UIImageView!
    @IBOutlet weak var viewHomeAddress: UIView!
    @IBOutlet weak var btnWorkAddress: UIButton!
    @IBOutlet weak var imgWorkAddress: UIImageView!
    @IBOutlet weak var viewWorkAddress: UIView!
    @IBOutlet weak var btnAddAddress: UIButton!
    @IBOutlet weak var viewAddAddress: UIView!
    @IBOutlet weak var imgAddAddress: UIImageView!
    @IBOutlet weak var stkFavouriteAddress: UIStackView!
    //Address View
    @IBOutlet weak var viewForAddresses: UIView!
    @IBOutlet weak var viewForPickupAddress: UIView!
    @IBOutlet weak var lblPickupAddress: UILabel!
    @IBOutlet weak var btnPickupAddress: UIButton!
    @IBOutlet weak var viewForDestinationAddress: UIView!
    @IBOutlet weak var lblDestinationAddress: UILabel!
    @IBOutlet weak var btnDestinationAddress: UIButton!
    @IBOutlet weak var btnRideLater: UIButton!
    
    //No Service View
    @IBOutlet weak var viewForNoServiceAvailable: UIView!
    @IBOutlet weak var lblSorry: UILabel!
    @IBOutlet weak var lblNoServiceAvailable: UILabel!
    @IBOutlet weak var btnSelectCountry: UIButton!
    @IBOutlet weak var btnSelectedCountry: UIButton!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var imgMenu: UIImageView!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var imgFilter: UIImageView!
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var imgNotificationBuget: UIView!
    
    //ViewFor Available Service
    @IBOutlet weak var viewForAvailableService: UIView!
    @IBOutlet weak var viewForServices: UIView!
    @IBOutlet weak var collectionViewForServices: UICollectionView!
    @IBOutlet weak var viewForFareEstimate: UIView!
    @IBOutlet weak var btnFareEstimate: UIButton!
    @IBOutlet weak var lblFareEstimate: UILabel!
    @IBOutlet weak var viewForPayment: UIView!
    @IBOutlet weak var imgPayment: UIImageView!
    @IBOutlet weak var lblPaymentIcon: UILabel!
    @IBOutlet weak var lblPayment: UILabel!
    @IBOutlet weak var btnPayment: UIButton!
    @IBOutlet weak var viewForEta: UIView!
    @IBOutlet weak var lblEta: UILabel!
    @IBOutlet weak var btnEta: UIButton!
    @IBOutlet weak var btnRideNow: UIButton!
    @IBOutlet weak var btnScheduleTripTime: UIButton!
    @IBOutlet weak var imgScheduleTripTime: UIImageView!
    @IBOutlet weak var btnCorporatePay: UIButton!
    @IBOutlet weak var btnRideShare: UIButton!
    
    //Dialogs
    var dialogFromDriverDetail: CustomDriverDetailDialog?
    var dialogForSelectRentPackage : CustomRentCarDialog?
    
    var driverMarkerImage:UIImage? = nil
    private var popupOffset: CGFloat = 0
    
    //View For Type Description
    @IBOutlet weak var viewForTypeDescription: UIView!
    @IBOutlet weak var lblTypeName: UILabel!
    @IBOutlet weak var imgType: UIImageView!
    @IBOutlet weak var lblTypeDescription: UILabel!
    @IBOutlet weak var dialogForTypeDescription: UIView!
    @IBOutlet weak var btnHideTypeDescription: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tblMultipleStops: UITableView!
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    @IBOutlet weak var viewAddStops: UIView!
    
    @IBOutlet weak var viewLocationButton: UIView!
    
    @IBOutlet weak var viewCheckBiding: UIStackView!
    @IBOutlet weak var btnCheckBiding: UIButton!
    @IBOutlet weak var lblCheckBiding: UILabel!
    
    @IBOutlet weak var viewCoporate: UIStackView!
    @IBOutlet weak var lblCoporatePay: UILabel!
    
    @IBOutlet weak var txtTripBiding: DoubleTextField!
    
    @IBOutlet weak var viewRecivedNotification: UIImageView!
    @IBOutlet weak var viewPromoCode: UIView!
    var arrLocations = [StopLocationAddress]()
    @IBOutlet weak var heightForPaymentSheet: NSLayoutConstraint!
    
    //Varialbles
    public var str = ""
    var paymentMode = PaymentMode.UNKNOWN
    var currentMarker = GMSMarker()
    var isDoAnimation:Bool = false
    var selectedIndex:Int = 0
    var arrForProviderLanguage:[Language] = []
    var arrFinalForVehicles:[Citytype] = []
    var arrNormalForVehicles:[Citytype] = []
    var arrRentalForVehicles:[Citytype] = []
    var arrForRideShareVehicles:[Citytype] = []
    var arrForSelectedLanguages:[Language] = []
    var isHotSpotSelected:Bool = false,
        isBabySeatSelected:Bool = false,
        isHandicapSelected:Bool = false;
    
    var arrayForProviderMarker:[GMSMarker] = []
    var arrStopMarkers = [GMSMarker]()
    var pickupMarker:GMSMarker = GMSMarker.init()
    var destinationMarker:GMSMarker = GMSMarker.init()
    var isShowActiveView:Bool = false
    var isNoRouteFound: Bool = false
    var strProviderId:String = ""
    var futureTripSelectedDate: Date?
    var previousProviderId:String = ""
    var promoId:String = ""
    var promoText:String = ""
    var timeAndDistance: (time:String, distance:String) = (time: "0", distance: "0")
    var type = 0
    var isBidTrip: Bool {
        return !viewCheckBiding.isHidden && btnCheckBiding.isSelected
    }
    
    var vehicleListResponse: VehicleListResponse?
    var bidPrice: Double = 0
    var listPromoCode = [PromoCode]()
    var routString = ""
    var listCountry = [Countres]()
    var selectedCountry = Countres()
    var listCites = [Cites]()
    var imagesArray = [#imageLiteral(resourceName: "asset-menu-payments") , #imageLiteral(resourceName: "asset-menu-payments") ,#imageLiteral(resourceName: "asset-menu-payments"),#imageLiteral(resourceName: "asset-menu-payments"),#imageLiteral(resourceName: "asset-menu-payments"),#imageLiteral(resourceName: "asset-menu-payments")]
    let user = CurrentTrip.shared.user
    var arrForPaymentMethod = [
        "Cash".localized,
        "idfali".localized,
        "Mobi-cash".localized,
        "Sadad".localized,
        "Tadawul".localized,
        "Bank Cards".localized,
    ]
    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isViewDidLoad = true
        setMap()
        self.tblMultipleStops.delegate = self
        self.tblMultipleStops.dataSource = self
        self.tblMultipleStops.tableFooterView = UIView()
        self.tblMultipleStops.register(UINib(nibName: StopLocationTVC.className, bundle: nil), forCellReuseIdentifier: StopLocationTVC.className)
        self.tblHeight.constant = CGFloat(self.arrLocations.count * 30)
        view.addSubview(viewForProviderFilter)
        viewForProviderFilter.backgroundColor = UIColor.themeOverlayColor
        stkFavouriteAddress.isHidden = true
        currentMarker.icon = Global.imgPinPickup
        currentMarker.map = mapView
        currentMarker.groundAnchor = CGPoint.init(x: 0.5, y: 0.5)
        self.navigationController?.isNavigationBarHidden = true
        self.revealViewController()?.delegate = self;
        btnCorporatePay.isSelected = false
        seperatorView.backgroundColor = UIColor.themeLightDividerColor
        Utility.hideLoading()
        
        if preferenceHelper.getUserId().isEmpty {
            self.stopTripStatusTimer()
            self.stopTripNearByProviderTimer()
            return
        } else {
            self.initialViewSetup()
            LocationCenter.default.addObserver(self, [#selector(self.locationUpdate(_:)), #selector(self.locationFail(_:)), #selector(locationAuthorizationChanged(_:))])
            self.startCurrentLocation()
            setCollectionView()
            setupRevealViewController()
            self.arrLocations = []
            idealView()
            self.wsGetLanguage()
            self.wsGetAddress()
        }
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapVC.handleLongPress))
        lpgr.minimumPressDuration = 0.3
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        imgBack.tintColor = UIColor.themeImageColor
        imgMenu.tintColor = UIColor.themeImageColor
        self.collectionViewForServices?.addGestureRecognizer(lpgr)
        self.collectionViewForServices.reloadData()
        self.scrollToSelectService()
        mapView.settings.compassButton = false
        bottomConstraint.constant = -self.viewForAvailableService.frame.height
        //viewForAvailableService.addGestureRecognizer(panRecognizer)
        viewForAvailableService.isHidden = true
        popupOffset = viewForAvailableService.frame.size.height
        self.bottomConstraint.constant = -self.viewForAvailableService.frame.height
        //btnBack.setupBackButton()
        btnPromoCode.setTitle("TXT_HAVE_PROMO_CODE".localizedCapitalized, for: .normal)
        btnPromoCode.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnPromoCode.backgroundColor = UIColor.clear
        btnPromoCode.setTitleColor(UIColor.themeLightTextColor, for: .normal)
        self.updateEtaUI()
        NotificationCenter.default.addObserver(self, selector: #selector(doSomething), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateSplitNotification), name: .updateSplitPaymentDialog, object: nil)
        bottomView.isHidden = true
        btnSelectedCountry.isHidden = true
        viewRecivedNotification.isHidden = true
    }
    
    @objc private func doSomething() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.wsGetTripStatus()
        }
    }
    
    func updateEtaUI() {
        
        if preferenceHelper.getIsShowEta() {
            self.viewForEta.isHidden = false
            self.vwDivider.isHidden = false
        } else{
            self.viewForEta.isHidden = true
            self.vwDivider.isHidden = true
        }
    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        
        let p = gesture.location(in: self.collectionViewForServices)
        
        if /*let indexPath =*/self.collectionViewForServices.indexPathForItem(at: p) != nil {
            // get the cell at indexPath (the one you long pressed)
            openTypeDescriptionDialog()
            // do stuff with the cell
        } else {
            printE("couldn't find index path")
        }
    }
    
    func openTypeDescriptionDialog() {
        self.lblTypeName.text = CurrentTrip.shared.selectedVehicle.typeDetails.typename
        self.imgType.downloadedFrom(link: CurrentTrip.shared.selectedVehicle.typeDetails.typeImageUrl,
                                    placeHolder: "asset-profile-placeholder",
                                    isFromCache:true,
                                    isIndicator:false,
                                    mode:.scaleAspectFit,
                                    isAppendBaseUrl:true)
        self.lblTypeDescription.text = CurrentTrip.shared.selectedVehicle.typeDetails.descriptionField
        self.viewForTypeDescription.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !preferenceHelper.getIsAllowMultipleStop() || arrLocations.count >= preferenceHelper.getMultipleStopCount() || CurrentTrip.shared.destinationtAddress.isEmpty() {
            self.viewAddStops.isHidden = true
        } else {
            self.btnRideShare.isHidden = self.arrLocations.count > 0 ? true : false
        }
        
        socketHelper.connectSocket()
        if preferenceHelper.getUserId().isEmpty {
            self.stopTripStatusTimer()
            self.stopTripNearByProviderTimer()
            APPDELEGATE.gotoLogin()
            return
        }
        
        if !CurrentTrip.shared.user.corporateDetail.id.isEmpty() && CurrentTrip.shared.user.corporateDetail.status == FALSE {
            self.openCorporateRequestDialog()
        }
        
        self.resetTripNearByProviderTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.wsGetTripStatus()
        }
        updateAddressUI()
        
        btnRideLater.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SplitPaymentListner.shared.updateSplitPayment()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTripNearByProviderTimer()
        socketHelper.disConnectSocket()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLayout()
    }
    
    override func locationUpdate(_ ntf: Notification = Common.defaultNtf) {
        guard let userInfo = ntf.userInfo else { return }
        guard let location = userInfo["location"] as? CLLocation else { return }
        CurrentTrip.shared.currentCoordinate = location.coordinate
        LocationCenter.default.stopUpdatingLocation()
        self.handleCurrentLocationResponse(currentLocation: location)
        if CurrentTrip.shared.currentCoordinate.latitude != 0.0 && CurrentTrip.shared.currentCoordinate.longitude != 0.0 {
            self.resetTripNearByProviderTimer()
        }
    }
    
    func startCurrentLocation() {
        LocationCenter.default.stopUpdatingLocation()
        LocationCenter.default.startUpdatingLocation()
    }
    
    func handleCurrentLocationResponse(currentLocation:CLLocation) {
        if currentLocation.coordinate.latitude != 0.0 && currentLocation.coordinate.longitude != 0.0 {
            CurrentTrip.shared.currentCountryCode = ""
            print(currentLocation.coordinate)
            if CurrentTrip.shared.currentCoordinate.isEqual(currentLocation.coordinate) {
                if CurrentTrip.shared.pickupAddress.isEmpty() {
                    LocationCenter.default.getAddressFromLatitudeLongitude(latitude: CurrentTrip.shared.currentCoordinate.latitude, longitude: CurrentTrip.shared.currentCoordinate.longitude, completion: { (address, locations, country) in
                        if CurrentTrip.shared.currentAddress.isEmpty {
                            CurrentTrip.shared.currentAddress = address
                        }
                        CurrentTrip.shared.setPickupLocation(latitude: locations[0], longitude: locations[1], address: address)
                        self.checkForAvailableService()
                    })
                } else {
                    self.checkForAvailableService()
                }
            } else {
                CurrentTrip.shared.currentCoordinate = currentLocation.coordinate
                
                LocationCenter.default.getAddressFromLatitudeLongitude(latitude: CurrentTrip.shared.currentCoordinate.latitude, longitude: CurrentTrip.shared.currentCoordinate.longitude, completion: { (address, locations, country) in
                    CurrentTrip.shared.setPickupLocation(latitude: locations[0], longitude: locations[1], address: address)
                    self.checkForAvailableService()
                })
            }
            self.animateToCurrentLocation()
        }
    }
    
    //MARK: - Socket Listeners
    func registerProviderSocket(id:String) {
        let myProviderId = "'\(id)'"
        self.socketHelper.socket?.emit("room", myProviderId)
        self.socketHelper.socket?.on(myProviderId) {
            [weak self] (data, ack) in
            guard let `self` = self else { return }
            guard let response = data.first as? [String:Any] else
            { return }
            print("Soket Response\(response)")
            let location = (response["location"] as? [Double]) ?? [0.0,0.0]
            let bearing = (response["bearing"] as? Double) ?? 0.0
            let providerid = (response["provider_id"] as? String) ?? ""
            if let marker = self.arrayForProviderMarker.first(where: { (marker) -> Bool in
                marker.accessibilityLabel == providerid
            }) {
                self.animateMarker(marker: marker, coordinate: CLLocationCoordinate2D.init(latitude: location[0], longitude: location[1]), bearing: bearing)
            }
        }
    }
    
    func animateMarker(marker:GMSMarker, coordinate:CLLocationCoordinate2D,bearing:Double) {
        
        if marker.accessibilityLabel == "64a3ded349d1f640518a2516" {
            print("Animation to Angel \(bearing)")
            print(marker.position.bearing(to: coordinate))
        }
        
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setValue(0.5, forKey: kCATransactionAnimationDuration)
            CATransaction.setCompletionBlock {
            }
            marker.rotation = bearing
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            CATransaction.commit()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                CATransaction.begin()
                CATransaction.setValue(1.5, forKey: kCATransactionAnimationDuration)
                CATransaction.setCompletionBlock {
                }
                marker.position = coordinate
                CATransaction.commit()
            }
        }
    }
    
    func unRegisterProviderSocket(id:String) {
        socketHelper.socket?.off(id)
    }
    
    func registerAllProviderSocket(providers:[Provider]) {
        self.setProviderMarker(arrProvider: providers)
    }
    
    func unRegisterProviderSocket() {
        for marker in arrayForProviderMarker {
            if let id = marker.accessibilityLabel {
                let myProviderId = "'\(id)'"
                unRegisterProviderSocket(id: myProviderId)
            }
        }
    }
    
    func startTripListner() {
        print("Socket Response Start Listner")
        let myTripid = "'\(CurrentTrip.shared.tripId)'"
        self.socketHelper.socket?.emit("room", myTripid)
        self.socketHelper.socket?.on(myTripid) {
            [weak self] (data, ack) in
            
            print("Socket Response \(data)")
            guard let `self` = self else { return }
            guard let response = data.first as? [String:Any] else { return }
            let isTripUpdate = (response[PARAMS.IS_TRIP_UPDATED] as? Bool) ?? false
            if isTripUpdate {
                self.stopTripListner()
                self.wsGetTripStatus()
            }
        }
    }
    
    func startMyIdListner() {
        let myid = "\(preferenceHelper.getUserId())"
        print("startMyIdListner \(myid)")
        stopMyIdListner()
        self.socketHelper.socket?.emit("room", myid)
        self.socketHelper.socket?.on(myid) {
            [weak self] (data, ack) in
            
            print("Socket Response MyId \(data)")
            guard let `self` = self else { return }
            guard let response = data.first as? [String:Any] else { return }
            if response["type_id"] != nil {
                
            }
            print(response)
        }
    }
    
    func stopMyIdListner() {
        let myid = "'\(preferenceHelper.getUserId())'"
        self.socketHelper.socket?.off(myid)
    }
    
    func stopTripListner() {
        let myTripid = "'\(CurrentTrip.shared.tripId)'"
        self.socketHelper.socket?.off(myTripid)
    }
    
    //MARK: - Set localized
    func initialViewSetup() {
        lblWhereToGo.text = "TXT_WHERE_TO_GO".localized
        lblWhereToGo.textColor = UIColor.themeLightTextColor
        lblWhereToGo.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        lblAccessibility.text = "TXT_ACCESSIBILITY".localized
        lblAccessibility.textColor = UIColor.themeTextColor
        lblAccessibility.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        lblSelectLanguage.text = "TXT_SELECT_LANGUAGE".localized
        lblSelectLanguage.textColor = UIColor.themeTextColor
        lblSelectLanguage.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        lblProviderGenderSelection.text = "TXT_REQUEST_PROVIDER_GENDER".localized
        lblProviderGenderSelection.textColor = UIColor.themeTextColor
        lblProviderGenderSelection.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        btnMale.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnMale.setTitle(" " + "TXT_MALE".localizedCapitalized, for: .normal)
        btnMale.setTitleColor(UIColor.themeTextColor, for: .normal)
        btnFemale.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnFemale.setTitle(" " + "TXT_FEMALE".localizedCapitalized, for: .normal)
        btnFemale.setTitleColor(UIColor.themeTextColor, for: .normal)
        
        lblCoporatePay.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        lblCoporatePay.text = "TXT_PAY_BY_CORPORATE".localized
        lblCoporatePay.textColor = UIColor.themeTextColor
        
        lblCheckBiding.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        lblCheckBiding.text = "txt_is_allow_biding".localized
        lblCheckBiding.textColor = UIColor.themeTextColor
        
        btnHideTypeDescription.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnHideTypeDescription.setTitle(" " + "TXT_CLOSE".localizedCapitalized, for: .normal)
        btnHideTypeDescription.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnHideTypeDescription.backgroundColor = UIColor.themeButtonBackgroundColor
        
        //        btnHotspot.setTitle(FontAsset.icon_check_box_normal, for: .normal)
        //        btnHotspot.setTitle(FontAsset.icon_check_box_selected, for: .selected)
        
        btnHotspot.setImage(UIImage(named: "asset-checkbox-normal"), for: .normal)
        btnHotspot.setImage(UIImage(named: "asset-checkbox-selected"), for: .selected)
        
        lblHotspot.text = "TXT_HOTSPOT".localizedCapitalized
        lblHotspot.textColor = UIColor.themeTextColor
        lblHotspot.font = FontHelper.font(size: FontSize.regular, type: .Regular)
        
        lblBabySeat.text = "TXT_BABY_SEAT".localizedCapitalized
        lblBabySeat.textColor = UIColor.themeTextColor
        lblBabySeat.font = FontHelper.font(size: FontSize.regular, type: .Regular)
        
        btnBabySeat.setImage(UIImage(named: "asset-checkbox-norma"), for: .normal)
        btnBabySeat.setImage(UIImage(named: "asset-checkbox-selected"), for: .selected)
        
        btnBabySeat.setImage(UIImage(named: "asset-checkbox-normal"), for: .normal)
        btnBabySeat.setImage(UIImage(named: "asset-checkbox-selected"), for: .selected)
        
        //        btnBabySeat.setTitle(FontAsset.icon_check_box_normal, for: .normal)
        //        btnBabySeat.setTitle(FontAsset.icon_check_box_selected, for: .selected)
        
        lblHandicap.text = "TXT_HANDICAP".localizedCapitalized
        lblHandicap.textColor = UIColor.themeTextColor
        lblHandicap.font = FontHelper.font(size: FontSize.regular, type: .Regular)
        
        //        btnHandicap.setTitle(FontAsset.icon_check_box_normal, for: .normal)
        //        btnHandicap.setTitle(FontAsset.icon_check_box_selected, for: .selected)
        
        btnHandicap.setImage(UIImage(named: "asset-checkbox-normal"), for: .normal)
        btnHandicap.setImage(UIImage(named: "asset-checkbox-selected"), for: .selected)
        
        //        btnHandicap.setSimpleIconButton()
        //        btnHotspot.setSimpleIconButton()
        //        btnBabySeat.setSimpleIconButton()
        
        btnAddStop.setTitle("txt_add_stop".localized, for: .normal)
        btnAddStop.setTitleColor(UIColor.themeButtonBackgroundColor, for: .normal)
        btnAddStop.titleLabel?.font = FontHelper.font(size: FontSize.regular15, type: .Regular)
        
        btnApplyFilter.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnApplyFilter.setTitle(" " + "TXT_APPLY".localizedCapitalized, for: .normal)
        btnApplyFilter.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnApplyFilter.backgroundColor = UIColor.themeButtonBackgroundColor
        
        btnSelectPackage.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnSelectPackage.setTitle("TXT_SELECT_PACKAGE".localizedCapitalized, for: .normal)
        btnSelectPackage.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnSelectPackage.backgroundColor = UIColor.themeButtonBackgroundColor
        
        btnSelectCountry.setTitle("TXT_SELECT_COUNTRY".localized, for: .normal)
        btnSelectCountry.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnSelectCountry.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnSelectCountry.backgroundColor = UIColor.themeButtonBackgroundColor
        btnSelectCountry.setRound()
        
        
        btnSelectedCountry.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnSelectedCountry.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnSelectedCountry.backgroundColor = UIColor.themeButtonBackgroundColor
        btnSelectedCountry.setRound()
        
        btnRideNow.setTitle("TXT_RIDE_NOW".localized, for: .normal)
        btnRideNow.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnRideNow.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnRideNow.backgroundColor = UIColor.themeButtonBackgroundColor
        
        btnRideLater.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnRideLater.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnRideLater.backgroundColor = UIColor.themeButtonBackgroundColor
        
        btnCancelFilter.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        btnCancelFilter.setTitle(" " + "TXT_CANCEL".localizedCapitalized, for: .normal)
        btnCancelFilter.setTitleColor(UIColor.themeLightTextColor, for: .normal)
        
        lblSorry.text = "TXT_SORRY".localized
        lblSorry.textColor = UIColor.themeTextColor
        lblSorry.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        
        lblNoServiceAvailable.text = "TXT_NO_SERVICE_AVAILABLE_IN_THIS_AREA".localized
        lblNoServiceAvailable.textColor = UIColor.themeLightTextColor
        lblNoServiceAvailable.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        
        lblPickupAddress.text = "TXT_PICKUP_ADDRESS".localized
        lblPickupAddress.textColor = UIColor.themeTextColor
        lblPickupAddress.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        
        lblDestinationAddress.text = "TXT_DESTINATION_ADDRESS".localized
        lblDestinationAddress.textColor = UIColor.themeTextColor
        lblDestinationAddress.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        
        lblFareEstimate.text = "--"
        lblFareEstimate.textColor = UIColor.themeTextColor
        lblFareEstimate.font = FontHelper.font(size: FontSize.small, type: FontType.Light)
        
        lblEta.text = "TXT_ETA".localized
        lblEta.textColor = UIColor.themeTextColor
        lblEta.font = FontHelper.font(size: FontSize.small, type: FontType.Light)
        
        lblPayment.text = "TXT_ADD_PAYMENT".localized
        lblPayment.textColor = UIColor.themeTextColor
        lblPayment.font = FontHelper.font(size: FontSize.small, type: FontType.Light)
        
        lblRentalPackSize.text = "TXT_DEFAULT".localized
        lblRentalPackSize.textColor = UIColor.themeTextColor
        lblRentalPackSize.font = FontHelper.font(size: FontSize.small, type: FontType.Light)
        
        tblProviderLanguage.tableFooterView = UIView.init()
        
        hideProviderFilter()
        viewForNoServiceAvailable.backgroundColor = UIColor.themeDialogBackgroundColor.withAlphaComponent(0.9)
        viewForAvailableService.backgroundColor = UIColor.themeDialogBackgroundColor.withAlphaComponent(0.9)
        
        self.btnRideLater.titleLabel?.numberOfLines = 2
        self.btnRideLater.titleLabel?.textAlignment = .center
        
        viewForTypeDescription.backgroundColor = UIColor.themeOverlayColor
        dialogForTypeDescription.backgroundColor = UIColor.themeDialogBackgroundColor
        
        lblTypeName.text = "TXT_TYPE_NAME".localized
        lblTypeName.textColor = UIColor.themeTextColor
        lblTypeName.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        
        txtTripBiding.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        txtTripBiding.textColor = .themeTextColor
        
        lblTypeDescription.text = "TXT_DEFAULT".localized
        lblTypeDescription.textColor = UIColor.themeLightTextColor
        lblTypeDescription.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        
        btnRegular.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnRegular.setTitle("TXT_NOW".localizedCapitalized, for: .normal)
        btnRegular.setTitleColor(UIColor.themeLightTextColor, for: .normal)
        btnRegular.setTitleColor(UIColor.themeTextColor, for: .selected)
        
        btnRental.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnRental.setTitle("TXT_RENTAL".localizedCapitalized, for: .normal)
        btnRental.setTitleColor(UIColor.themeTextColor, for: .selected)
        btnRental.setTitleColor(UIColor.themeLightTextColor, for: .normal)
        
        btnRideShare.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnRideShare.setTitle("txt_ride_share".localizedCapitalized, for: .normal)
        btnRideShare.setTitleColor(UIColor.themeTextColor, for: .selected)
        btnRideShare.setTitleColor(UIColor.themeLightTextColor, for: .normal)
        
        viewLocationButton.backgroundColor = .themeViewBackgroundColor
        viewLocationButton.setRound()
        viewLocationButton.setShadow(shadowOffset: CGSize(width: 0, height: 6), shadowRadius: 4)
        
        //        lblIconETA.text = FontAsset.icon_time
        //        lblIconPinSourceLocation.text = FontAsset.icon_pin_dot
        //lblPayment.text = FontAsset.icon_payment_cash
        //        lblIconFareEstimate.text = FontAsset.icon_fare_estimate
        //        lblIconRentCar.text = FontAsset.icon_car_rent
        //        lblIconNoServiceAvailable.text = FontAsset.icon_no_service_available
        //        lblIconNoServiceAvailable.setForIcon()
        
        lblIconRentCar.setForIcon()
        //        lblIconPinSourceLocation.setForIcon()
        lblPaymentIcon.setForIcon()
        //        lblIconETA.setForIcon()
        //        lblIconFareEstimate.setForIcon()
        //        imgIconPinSourceLocation.tintColor = UIColor.themeTextColor
        //        imgIconETA.tintColor = UIColor.themeImageColor
        //        imgIconFareEstimate.tintColor = UIColor.themeImageColor
        
        //        btnAddAddress.setTitle(FontAsset.icon_add, for: .normal)
        //        btnHomeAddress.setTitle(FontAsset.icon_btn_home, for: .normal)
        //        btnWorkAddress.setTitle(FontAsset.icon_btn_work, for: .normal)
        btnMyLocation.setTitle("", for: .normal)
        btnMyLocation.setImage(UIImage(named: "asset-my-location_u"), for: .normal)
        btnMyLocation.tintColor = .themeButtonBackgroundColor
        
        //        btnMenu.setTitle(FontAsset.icon_menu, for: .normal)
        btnMenu.setUpTopBarButton()
        
        //        btnFilter.setTitle(FontAsset.icon_filter, for: .normal)
        //        btnFilter.setUpTopBarButton()
        imgFilter.tintColor = UIColor.themeImageColor
        
        //        btnScheduleTripTime.setTitle(FontAsset.icon_schedule_calender, for: .normal)
        //        btnScheduleTripTime.setRoundIconButton()
        
        //        btnAddAddress.setRoundIconButton()
        //        viewAddAddress.roundCorners(corners: [.bottomLeft,.bottomRight,.topLeft,.topRight], radius: 27.5)
        //        btnHomeAddress.setRoundIconButton()
        //        btnWorkAddress.setRoundIconButton()
        
    }
    
    func setupLayout() {
        viewForProviderFilter.frame = view.bounds
        viewForWhereToGo.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 1.0)
        viewForWhereToGo.setShadow()
        
        self.dialogForTypeDescription.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 1.0)
        btnHideTypeDescription.setRound(withBorderColor: UIColor.clear, andCornerRadious: btnHideTypeDescription.frame.height/2, borderWidth: 1.0)
        
        viewForAddresses.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 1.0)
        viewForAddresses.setShadow()
        
        btnRideNow.setRound(withBorderColor: UIColor.clear, andCornerRadious: btnRideNow.frame.height/2, borderWidth: 1.0)
        btnRideLater.setRound(withBorderColor: UIColor.clear, andCornerRadious: btnRideLater.frame.height/2, borderWidth: 1.0)
        
        btnSelectPackage.setRound(withBorderColor: UIColor.clear, andCornerRadious:btnSelectPackage.frame.height/2, borderWidth: 1.0)
        
        btnApplyFilter.setRound(withBorderColor: UIColor.clear, andCornerRadious: btnApplyFilter.frame.height/2, borderWidth: 1.0)
        self.dialogForProviderFilter.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 1.0)
        dialogForProviderFilter.setShadow()
        
        imgPayment.setImageColor()
        
        self.paymentSelectionSheet.layer.cornerRadius = 20
        self.viewWhereToGO.layer.cornerRadius = 10
        self.viewWhereToGO.layer.borderWidth = 1
        self.viewWhereToGO.layer.borderColor = UIColor.lightGray.cgColor
        self.paymentSelectionSheet.applyShadowToView(20)
        
    }
    
    //MARK: - Get Current Location
    func setMap() {
        mapView.clear()
        mapView.delegate = self
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = false;
        mapView.settings.rotateGestures = false;
        mapView.settings.myLocationButton=false;
        mapView.isMyLocationEnabled=false;
        do {
            // Set the map style by passing the URL of the local file. Make sure style.json is present in your project
            if let styleURL = Bundle.main.url(forResource: "styleable_map", withExtension: "json") {
                //mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                printE("Unable to find style.json")
            }
        } catch {
            printE("The style definition could not be loaded: \(error)")
        }
    }
    
    func animateToCurrentLocation() {
        let camera = GMSCameraPosition.camera(withTarget: CurrentTrip.shared.currentCoordinate, zoom: 17.0, bearing: 45, viewingAngle: 0.0)
        self.mapView?.animate(to: camera)
        self.currentMarker.position = CurrentTrip.shared.currentCoordinate
    }
    
    //MARK: - OBJC Function
    
    //MARK: - Action Methods
    @IBAction func onAddLocationClicked(_ sender: UIButton) {
        if let addressVC = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "AddressVC") as? AddressVC {
            addressVC.delegate = self
            addressVC.flag = AddressType.pickupAddress
            addressVC.arrLocations = self.arrLocations
            self.navigationController?.pushViewController(addressVC, animated: true)
        }
    }
    
    @IBAction func btnSelectPackage(_ sender: Any) {
        openRentPackageDialog()
    }
    
    func openRentPackageDialog()
    {
        if dialogForSelectRentPackage == nil
        {
            dialogForSelectRentPackage = CustomRentCarDialog.showCustomRentCarDialog(title: "TXT_PACKAGES".localized, message: "", titleLeftButton:"TXT_CANCEL".localized , titleRightButton: "TXT_RENT_NOW".localized)
            self.updateRideNowButton()
        }
        
        dialogForSelectRentPackage?.onClickLeftButton = { 
            [unowned self, weak dialogForSelectRentPackage = self.dialogForSelectRentPackage] in 
            printE(dialogForSelectRentPackage!)
            self.dialogForSelectRentPackage?.removeFromSuperview()
            self.dialogForSelectRentPackage = nil
            dialogForSelectRentPackage = nil
        }
        dialogForSelectRentPackage?.onClickRightButton = { 
            [unowned self, weak dialogForSelectRentPackage = self.dialogForSelectRentPackage] in 
            printE(dialogForSelectRentPackage!)
            self.dialogForSelectRentPackage?.removeFromSuperview()
            self.dialogForSelectRentPackage = nil
            dialogForSelectRentPackage = nil
            self.createRentTrip()
        }
    }
    
    func updateRideNowButton()
    {
        if dialogForSelectRentPackage != nil
        {
            dialogForSelectRentPackage?.btnRight.isEnabled = btnRideNow.isEnabled
            if dialogForSelectRentPackage?.btnRight.isEnabled ?? true {
                dialogForSelectRentPackage?.btnRight.alpha = 1.0
                dialogForSelectRentPackage?.viewNoFoundDriver.isHidden = true
            }
            else {
                dialogForSelectRentPackage?.btnRight.alpha = 0.5
                dialogForSelectRentPackage?.viewNoFoundDriver.isHidden = false
            }
        }
    }
    
    @IBAction func btnRegular(_ sender: Any) {
        btnRental.isSelected = false
        btnRegular.isSelected = true
        btnRideShare.isSelected = false
        viewForFareEstimate.isHidden = false
        viewForRentalPackage.isHidden = true
        viewForRideNowLater.isHidden = false
        viewForSelectRetalPackage.isHidden = true
        fillVehicleArrayWith(array: self.arrNormalForVehicles)
        type = 1
        btnRegular.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        btnRental.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnRideShare.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        if CurrentTrip.shared.destinationtAddress.isEmpty() {
            viewCheckBiding.isHidden = true
        } else {
            if let vehicleListResponse = vehicleListResponse {
                setTripBidding(response: vehicleListResponse)
            }
        }
        wsGetNearByProvider()
    }
    
    @IBAction func btnRental(_ sender: Any) {
        btnRental.isSelected = true
        btnRegular.isSelected = false
        btnRideShare.isSelected = false
        viewForFareEstimate.isHidden = true
        viewForRentalPackage.isHidden = false
        viewForRideNowLater.isHidden = true
        viewForSelectRetalPackage.isHidden = false
        fillVehicleArrayWith(array: self.arrRentalForVehicles)
        type = 2
        btnRegular.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnRental.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        btnRideShare.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        wsGetNearByProvider()
        viewCheckBiding.isHidden = true
    }
    
    @IBAction func btnShareRide(_ sender: Any) {
        btnRideShare.isSelected = true
        btnRegular.isSelected = false
        btnRental.isSelected = false
        viewForFareEstimate.isHidden = false
        viewForRentalPackage.isHidden = true
        viewForRideNowLater.isHidden = false
        viewForSelectRetalPackage.isHidden = true
        fillVehicleArrayWith(array: self.arrForRideShareVehicles)
        type = 3
        btnRegular.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnRental.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnRideShare.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        wsGetNearByProvider()
        viewCheckBiding.isHidden = true
    }
    
    @IBAction func onClickBtnMyLocation(_ sender: Any) {
//        let massNotificationVC = MassNotificationVC(nibName: "MassNotificationVC", bundle: nil)
//        massNotificationVC.modalPresentationStyle = .fullScreen
//        self.present(massNotificationVC, animated: true, completion: nil)
        
        self.startCurrentLocation()
    }
    
    @IBAction func onClickBnHideTypeDescription(_ sender: Any) {
        viewForTypeDescription.isHidden = true
    }
    
    @IBAction func onClickBtnPromoCode(_ sender: Any) {
        if self.promoId.isEmpty() {
            self.wsGetPromo()
            openPromoDialog()
        } else {
            self.promoId = ""
            updatePromoView()
        }
    }
    
    @IBAction func onClickBtnWhereToGo(_ sender: Any) {
        self.startCurrentLocation()
//        if let addressVC = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "AddressVC") as? AddressVC {
//            addressVC.delegate = self
//            addressVC.arrLocations = self.arrLocations
//            addressVC.flag = AddressType.destinationAddress
//
//            let transition = CATransition()
//            transition.duration = 0.4
//            transition.type = .moveIn
//            transition.subtype = .fromTop
//            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
//            
//            self.navigationController?.pushViewController(addressVC, animated: false)
//        }
        
//        guard let addressVC = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "AddressVC") as? AddressVC else {
//            return
//        }
//
//        addressVC.delegate = self
//        addressVC.arrLocations = self.arrLocations
//        addressVC.flag = AddressType.destinationAddress
//
//        // 📌 1. Prepare AddressVC View Above Screen
//        if let window = UIApplication.shared.windows.first {
//            addressVC.view.frame = CGRect(x: 0,
//                                          y: -UIScreen.main.bounds.height,
//                                          width: UIScreen.main.bounds.width,
//                                          height: UIScreen.main.bounds.height)
//            window.addSubview(addressVC.view)
//        }
//
//        // 🎯 2. Setup values
//        let screenHeight = UIScreen.main.bounds.height
//        let originalHeight = self.heightForPaymentSheet.constant
//        let targetHeight = screenHeight * 0.8 // 80% of the screen
//
//        // 📌 3. Animate in 2 phases
//        UIView.animateKeyframes(withDuration: 1.2, delay: 0, options: [.calculationModeCubicPaced], animations: {
//            
//            // 🏁 Phase 1 (0% -> 70% time) : Grow Payment Sheet to 80% height
//            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.7) {
//                self.heightForPaymentSheet.constant = targetHeight
//                self.view.layoutIfNeeded()
//            }
//            
//            // 🏁 Phase 2 (70% -> 100% time) : Slide AddressVC Down
//            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
//                addressVC.view.frame = CGRect(x: 0,
//                                              y: 0,
//                                              width: UIScreen.main.bounds.width,
//                                              height: UIScreen.main.bounds.height)
//            }
//            
//        }) { _ in
//            // 📌 4. After animation completed
//            addressVC.view.removeFromSuperview()
//            self.heightForPaymentSheet.constant = originalHeight // Reset back if needed
//            self.view.layoutIfNeeded()
//            self.navigationController?.pushViewController(addressVC, animated: false)
//        }



//        guard let addressVC = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "AddressVC") as? AddressVC else {
//            return
//        }
//
//        addressVC.delegate = self
//        addressVC.arrLocations = self.arrLocations
//        addressVC.flag = AddressType.destinationAddress
//
//        // Prepare AddressVC above the screen
//        if let window = UIApplication.shared.windows.first {
//            addressVC.view.frame = CGRect(x: 0,
//                                          y: -UIScreen.main.bounds.height,
//                                          width: UIScreen.main.bounds.width,
//                                          height: UIScreen.main.bounds.height)
//            window.addSubview(addressVC.view)
//        }
//
//        // Prepare blur effect
//        let blurEffect = UIBlurEffect(style: .light)
//        let blurView = UIVisualEffectView(effect: nil) // No effect at start
//        blurView.frame = self.view.bounds
//        self.view.addSubview(blurView)
//        self.view.bringSubviewToFront(self.paymentSelectionSheet)
//
//        // Setup initial values
//        let screenHeight = UIScreen.main.bounds.height
//        let originalHeight = self.heightForPaymentSheet.constant
//        let targetHeight = screenHeight * 0.8 // 80% height
//
//        // Premium animation
//        UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: [.calculationModeCubic], animations: {
//
//            // Phase 1: Grow Payment Sheet
//            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.6) {
//                self.heightForPaymentSheet.constant = targetHeight
//                self.view.layoutIfNeeded()
//                
//                blurView.effect = blurEffect // Start blur slowly
//            }
//            
//            // Phase 2: Little Bounce (luxury feel)
//            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.1) {
//                self.heightForPaymentSheet.constant = targetHeight + 10 // Overgrow 10px
//                self.view.layoutIfNeeded()
//            }
//            
//            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.1) {
//                self.heightForPaymentSheet.constant = targetHeight // Settle back
//                self.view.layoutIfNeeded()
//            }
//            
//            // Phase 3: AddressVC Slide Down
//            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
//                addressVC.view.frame = CGRect(x: 0,
//                                              y: 0,
//                                              width: UIScreen.main.bounds.width,
//                                              height: UIScreen.main.bounds.height)
//                
//                blurView.effect = nil // Fade out blur
//            }
//            
//        }) { _ in
//            // Cleanup
//            blurView.removeFromSuperview()
//            addressVC.view.removeFromSuperview()
//            self.heightForPaymentSheet.constant = originalHeight
//            self.view.layoutIfNeeded()
//            self.navigationController?.pushViewController(addressVC, animated: false)
//        }

     

        openAddressVC()
    }
    
    func openAddressVC() {
        guard let addressVC = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "AddressVC") as? AddressVC else { return }

        addressVC.delegate = self
        addressVC.arrLocations = self.arrLocations
        addressVC.flag = AddressType.destinationAddress

        // Optional blur effect
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: nil)
        blurView.frame = self.view.bounds
        self.view.addSubview(blurView)
        self.view.bringSubviewToFront(paymentSelectionSheet)

        let screenHeight = UIScreen.main.bounds.height
        let originalHeight = heightForPaymentSheet.constant
        let targetHeight = screenHeight * 0.8

        // Collapse sheet initially
        self.heightForPaymentSheet.constant = 0
        self.view.layoutIfNeeded()

        // Animate the sheet growing and then instantly push
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
            self.heightForPaymentSheet.constant = targetHeight
            self.view.layoutIfNeeded()
            blurView.effect = blurEffect
        }) { _ in
            // Cleanup blur
            blurView.removeFromSuperview()

            // Reset the sheet height to original (in background)
            self.heightForPaymentSheet.constant = originalHeight
            self.view.layoutIfNeeded()

            // Immediately push
            self.navigationController?.pushViewController(addressVC, animated: false)
        }
    }


    @IBAction func onClickBtnPickupAddress(_ sender: Any) {
        if let addressVC = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "AddressVC") as? AddressVC {
            addressVC.delegate = self
            addressVC.flag = AddressType.pickupAddress
            addressVC.arrLocations = self.arrLocations
            self.navigationController?.pushViewController(addressVC, animated: true)
        }
    }
    
    @IBAction func onClickCheckBidding(_ sender: UIButton) {
        btnCheckBiding.isSelected.toggle()
        if btnCheckBiding.isSelected && sender.tag == 1 {
            //show add bid price pop up
            openTripBidPopup(isFromButton: true)
            btnScheduleTripTime.disable()
        } else {
            btnScheduleTripTime.enable()
            txtTripBiding.superview?.isHidden = true
        }
    }

    @IBAction func onClickBtnDestinationAddress(_ sender: Any) {
        if let addressVC = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "AddressVC") as? AddressVC {
            addressVC.delegate = self
            addressVC.arrLocations = self.arrLocations
            addressVC.flag = AddressType.destinationAddress
            self.navigationController?.pushViewController(addressVC, animated: true)
        }
    }

    @IBAction func onClickBtnBack(_ sender: Any){
        self.arrLocations = []
        idealView()
    }

    @IBAction func onClickBtnHideFilterView(_ sender: Any) {
        hideProviderFilter()
    }

    @IBAction func onClickBtnFareEstimate(_ sender: Any) {
        openFareEstimateDialog()
    }
    
    @IBAction func onClickBtnBidPrice(_ sender: Any) {
        openTripBidPopup()
    }

    @IBAction func onClickBtnPayment(_ sender: Any) {
        if (CurrentTrip.shared.isCashModeAvailable == FALSE && CurrentTrip.shared.isCardModeAvailable == FALSE) || (CurrentTrip.shared.isCashModeAvailable == FALSE && !StripeApplePayHelper.isApplePayAvailable()) || (CurrentTrip.shared.isCardModeAvailable == FALSE && !StripeApplePayHelper.isApplePayAvailable()) {
            Utility.showToast(message: "VALIDATION_MSG_NO_OTHER_PAYMENT_MODE_AVAILABLE".localized)
        } else {
            self.openPaymentDialog()
       
        }
    }
    
    
    
    func onClickPayementSelect(paymentMode: Int) {
        self.paymentMode = paymentMode
        self.updatePaymentUI()
        self.updatePromoView()
        
        if paymentMode != PaymentMode.UNKNOWN {
            checkSurgeTime(startHour: CurrentTrip.shared.selectedVehicle.surgeStartHour.toString(), endHour: CurrentTrip.shared.selectedVehicle.surgeEndHour.toString(), serverTime: CurrentTrip.shared.serverTime)
            if CurrentTrip.shared.isSurgeHour && !isBidTrip {
                let dialogForSurgePrice = CustomSurgePriceDialog.showCustomSurgePriceDialog(title: "TXT_SURGE_PRICE".localized, message: "TXT_SURGE_PRICE_MESSAGE".localized, surgePrice: CurrentTrip.shared.selectedVehicle.surgeMultiplier.toString() + "x", titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_CONFIRM".localized)
                dialogForSurgePrice.onClickLeftButton = { [/*unowned self, */unowned dialogForSurgePrice] in
                    dialogForSurgePrice.removeFromSuperview()
                }
                dialogForSurgePrice.onClickRightButton = { [unowned self, unowned dialogForSurgePrice] in
                    dialogForSurgePrice.removeFromSuperview()
                    if self.arrLocations.count > 0 {
                        self.wsCreateRequest()
                    }
                    else {
                        self.openFixedPriceDialog()
                    }
                    
                }
            } else {
                if self.arrLocations.count > 0 {
                    self.wsCreateRequest()
                }
                else {
                    self.openFixedPriceDialog()
                }
            }
        } else {
            if self.arrLocations.count > 0 {
                self.wsCreateRequest()
            }
            else {
                self.openFixedPriceDialog()
            }
        }
    }

    func openPromoAttentionDialog() {
        let dialogForConfirmationDialog = CustomAlertDialog.showCustomAlertDialog(title: "TITLE_PROMO_REMOVE_MESSAGE".localized, message: "MSG_PROMO_REMOVE_MESSAGE".localized, titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_OK".localized)
        dialogForConfirmationDialog.onClickLeftButton =
        { [/*unowned self,*/ unowned dialogForConfirmationDialog] in
            dialogForConfirmationDialog.removeFromSuperview();
        }
        dialogForConfirmationDialog.onClickRightButton =
        { [unowned self,unowned dialogForConfirmationDialog] in
            dialogForConfirmationDialog.removeFromSuperview();
//            self.openPaymentDialog()
        }
    }

    @IBAction func onClickBtnAddAddress(_ sender: Any) {
        if let addressVC = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "AddressVC") as? AddressVC {
            addressVC.delegate = self
            addressVC.flag = AddressType.pickupAddress
            addressVC.arrLocations = self.arrLocations
            self.navigationController?.pushViewController(addressVC, animated: true)
        }
    }

    @IBAction func onClickBtnHomeAddress(_ sender: Any) {
        
        if (CurrentTrip.shared.pickupCoordinate.longitude == CurrentTrip.shared.favouriteAddress.homeLocation[0] && CurrentTrip.shared.pickupCoordinate.latitude == CurrentTrip.shared.favouriteAddress.homeLocation[1] || CurrentTrip.shared.pickupAddress == CurrentTrip.shared.favouriteAddress.homeAddress)
        {
            Utility.showToast(message: "txt_please_enter_valid_address".localized)
        }
        else
        {
            Utility.showLoading()
            CurrentTrip.shared.arrStopLocations.removeAll()
            arrLocations.removeAll()
            tblMultipleStops.reloadData()
            self.tblHeight.constant = 0
            
            if !CurrentTrip.shared.currentAddress.isEmpty {
                CurrentTrip.shared.pickupAddress = CurrentTrip.shared.currentAddress
                CurrentTrip.shared.pickupCoordinate = CurrentTrip.shared.currentCoordinate
                CurrentTrip.shared.pickupCity = CurrentTrip.shared.currentCity
                CurrentTrip.shared.pickupCountry = CurrentTrip.shared.currentCountry
            }
            
            let address = CurrentTrip.shared.favouriteAddress
            CurrentTrip.shared.setDestinationLocation(latitude: address.homeLocation[0], longitude: address.homeLocation[1], address: address.homeAddress)
            destinationMarker.position = CurrentTrip.shared.destinationCoordinate
            lblPickupAddress.text = CurrentTrip.shared.pickupAddress
            lblDestinationAddress.text = CurrentTrip.shared.destinationtAddress
            lblDestinationAddress.textColor = UIColor.themeTextColor
            isShowActiveView = true
            isSourceToDestPathDrawn = false
            
            checkForAvailableService(isShowLoader: true)
            self.getTimeDistance()
            if !preferenceHelper.getIsAllowMultipleStop() || arrLocations.count >= preferenceHelper.getMultipleStopCount() {
                self.viewAddStops.isHidden = true
            } else {
                self.viewAddStops.isHidden = false
            }
        }
    }

    @IBAction func onClickBtnWorkAddress(_ sender: Any) {
        
        if (CurrentTrip.shared.pickupCoordinate.longitude == CurrentTrip.shared.favouriteAddress.workLocation[0] && CurrentTrip.shared.pickupCoordinate.latitude == CurrentTrip.shared.favouriteAddress.workLocation[1] || CurrentTrip.shared.pickupAddress == CurrentTrip.shared.favouriteAddress.workAddress)
        {
            Utility.showToast(message: "txt_please_enter_valid_address".localized)
        }
        else
        {
            Utility.showLoading()
            CurrentTrip.shared.arrStopLocations.removeAll()
            arrLocations.removeAll()
            tblMultipleStops.reloadData()
            self.tblHeight.constant = 0
            
            if !CurrentTrip.shared.currentAddress.isEmpty {
                CurrentTrip.shared.pickupAddress = CurrentTrip.shared.currentAddress
                CurrentTrip.shared.pickupCoordinate = CurrentTrip.shared.currentCoordinate
                CurrentTrip.shared.pickupCity = CurrentTrip.shared.currentCity
                CurrentTrip.shared.pickupCountry = CurrentTrip.shared.currentCountry
            }
            
            let address = CurrentTrip.shared.favouriteAddress
            CurrentTrip.shared.setDestinationLocation(latitude: address.workLocation[0], longitude: address.workLocation[1], address: address.workAddress)
            destinationMarker.position = CurrentTrip.shared.destinationCoordinate
            
            lblPickupAddress.text = CurrentTrip.shared.pickupAddress
            lblDestinationAddress.text = CurrentTrip.shared.destinationtAddress
            lblDestinationAddress.textColor = UIColor.themeTextColor
            isShowActiveView = true
            isSourceToDestPathDrawn = false
            
            
            checkForAvailableService(isShowLoader: true)
            
            self.getTimeDistance()
            if !preferenceHelper.getIsAllowMultipleStop() || arrLocations.count >= preferenceHelper.getMultipleStopCount() {
                self.viewAddStops.isHidden = true
            } else {
                self.viewAddStops.isHidden = false
            }
        }
    }

    @IBAction func onClickBtnHotSpot(_ sender: Any) {
        btnHotspot.isSelected = !btnHotspot.isSelected
    }

    @IBAction func onClickBtnHandicap(_ sender: Any) {
        btnHandicap.isSelected = !btnHandicap.isSelected
    }

    @IBAction func onClickBtnBabySeat(_ sender: Any) {
        btnBabySeat.isSelected = !btnBabySeat.isSelected
    }

    @IBAction func onClickBtnMaleProvider(_ sender: Any) {
        btnMale.isSelected = !btnMale.isSelected
    }

    @IBAction func onClickBtnFemaleProvider(_ sender: Any) {
        btnFemale.isSelected = !btnFemale.isSelected
    }

    @IBAction func onClickBtnFilter(_ sender: Any) {
        btnBabySeat.isSelected = isBabySeatSelected
        btnHotspot.isSelected = isHotSpotSelected
        btnHandicap.isSelected = isHandicapSelected
        if arrForProviderLanguage.isEmpty {
            lblSelectLanguage.isHidden = true
            tblProviderLanguage.isHidden = true
        } else {
            for language in arrForProviderLanguage {
                language.isSelected = false
                for selectedLanguage in arrForSelectedLanguages {
                    if selectedLanguage.id == language.id {
                        language.isSelected = true
                    }
                }
            }
            heightForLanguageTable.constant = tblProviderLanguage.contentSize.height < 120 ? tblProviderLanguage.contentSize.height : 120
            tblProviderLanguage.reloadData()
            heightForLanguageTable.constant = tblProviderLanguage.contentSize.height < 120 ? tblProviderLanguage.contentSize.height : 120
            
            heightForLanguageTable.constant =  CGFloat(arrForProviderLanguage.count * 35)
        }
        showProviderFilter()
    }

    @IBAction func onClickBtnApplyFilter(_ sender: Any) {
        isBabySeatSelected = btnBabySeat.isSelected
        isHotSpotSelected = btnHotspot.isSelected
        isHandicapSelected = btnHandicap.isSelected
        arrForSelectedLanguages.removeAll()
        for language in arrForProviderLanguage {
            if language.isSelected {
                arrForSelectedLanguages.append(language)
            }
        }
        resetTripNearByProviderTimer()
        hideProviderFilter()
    }

    @IBAction func onClickBtnCancelFilter(_ sender: Any) {
        hideProviderFilter()
    }

    @IBAction func onClickBtnRideLater(_ sender: Any) {
        let minDate = Date.init(timeIntervalSinceNow: TimeInterval(60*preferenceHelper.getPreSchedualTripTime()))
        if minDate > (futureTripSelectedDate ?? Date()) {
            Utility.showToast(message: "msg_create_trip_for_onward_time".localized.replacingOccurrences(of: "****", with: "\(preferenceHelper.getPreSchedualTripTime())"))
        } else if paymentMode != PaymentMode.UNKNOWN {
            if self.arrLocations.count > 0 {
                self.wsCreateFutureRequest()
            }
            else {
                self.openFixedPriceDialog(futureTrip: true)
            }
        } else {
            openPaymentDialog()
        }
    }

    func showProviderFilter() {
        if scrFilterView.contentSize.height > (UIScreen.main.bounds.height - 100) {
            heightForFilter.constant = (UIScreen.main.bounds.height - 100)
        } else {
            heightForFilter.constant = (scrFilterView.contentSize.height + 40)
        }
        heightForFilter.constant = (330 + heightForLanguageTable.constant)
        viewForProviderFilter.isHidden = false
    }

    func hideProviderFilter() {
        viewForProviderFilter.isHidden = true
    }

    @IBAction func onClickBtnScheduleTripTime(_ sender: Any) {
        openFutureRequestDate()
    }

    @IBAction func onClickBtnCorporatePay(_ sender: Any) {
        btnCorporatePay.isSelected.toggle()
        if btnCorporatePay.isSelected {
            viewCheckBiding.isHidden = true
        } else {
            if let vehicleListResponse = vehicleListResponse {
                setTripBidding(response: vehicleListResponse)
            }
        }
    }

    func createRentTrip() {
        if paymentMode != PaymentMode.UNKNOWN {
            self.wsCreateRentRequest()
        } else {
            openPaymentDialog()
        }
    }

    @IBAction func onClickBtnRideNow(_ sender: Any) {
//        if paymentMode != PaymentMode.UNKNOWN {
//            checkSurgeTime(startHour: CurrentTrip.shared.selectedVehicle.surgeStartHour.toString(), endHour: CurrentTrip.shared.selectedVehicle.surgeEndHour.toString(), serverTime: CurrentTrip.shared.serverTime)
//            if CurrentTrip.shared.isSurgeHour && !isBidTrip {
//                let dialogForSurgePrice = CustomSurgePriceDialog.showCustomSurgePriceDialog(title: "TXT_SURGE_PRICE".localized, message: "TXT_SURGE_PRICE_MESSAGE".localized, surgePrice: CurrentTrip.shared.selectedVehicle.surgeMultiplier.toString() + "x", titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_CONFIRM".localized)
//                dialogForSurgePrice.onClickLeftButton = { [/*unowned self, */unowned dialogForSurgePrice] in
//                    dialogForSurgePrice.removeFromSuperview()
//                }
//                dialogForSurgePrice.onClickRightButton = { [unowned self, unowned dialogForSurgePrice] in
//                    dialogForSurgePrice.removeFromSuperview()
//                    if self.arrLocations.count > 0 {
//                        self.wsCreateRequest()
//                    }
//                    else {
//                        self.openFixedPriceDialog()
//                    }
//                    
//                }
//            } else {
//                if self.arrLocations.count > 0 {
//                    self.wsCreateRequest()
//                }
//                else {
//                    self.openFixedPriceDialog()
//                }
//            }
//        } else {
//            if self.arrLocations.count > 0 {
//                self.wsCreateRequest()
//            }
//            else {
//                self.openFixedPriceDialog()
//            }
//        }
        
        if let paymentSelectionVC = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "PaymentSelectionPopUPVC") as? PaymentSelectionPopUPVC {
            paymentSelectionVC.deleate = self
            paymentSelectionVC.view.frame = self.view.bounds
            paymentSelectionVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addChild(paymentSelectionVC)
            self.view.addSubview(paymentSelectionVC.view)
            
            paymentSelectionVC.didMove(toParent: self)
        }
    }
    @IBAction func actionSelectCountry(_ sender: Any) {
        if self.btnSelectCountry.titleLabel?.text == "Select City"{
            let dialogCountry = CountryPopup.showCustomAlertDialog(title : "Select City",message : "Search City",countryData: listCountry, cityData: listCites,tag: 1)
            dialogCountry.onClickCancel = { [unowned dialogCountry] in
                dialogCountry.removeFromSuperview();
            }
            dialogCountry.onClickSelectCity = { [unowned dialogCountry ] (city) in
                dialogCountry.removeFromSuperview();
                print(city)
                self.lblPickupAddress.text = city.cityname
                
                CurrentTrip.shared.pickupCountry = self.selectedCountry.countryname ?? ""
                CurrentTrip.shared.pickupCity = city.cityname ?? ""
//                CurrentTrip.shared.pickupCoordinate.latitude.toString(places: 6)
                CurrentTrip.shared.currentCountryCode = self.selectedCountry.currencycode ?? ""
                
                var pickupLATITUDECoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: city.cityLatLong![0], longitude: city.cityLatLong![1])
                CurrentTrip.shared.pickupCoordinate = pickupLATITUDECoordinate
                
//                var pickupLONGITUDECoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: 0.0, longitude: 0.0)

//                    dictParam[PARAMS.COUNTRY]  = CurrentTrip.shared.pickupCountry
//                    dictParam[PARAMS.CITY]  = CurrentTrip.shared.pickupCity
//                    dictParam[PARAMS.LATITUDE] = CurrentTrip.shared.pickupCoordinate.latitude.toString(places: 6)
//                    dictParam[PARAMS.LONGITUDE] = CurrentTrip.shared.pickupCoordinate.longitude.toString(places: 6)
//                    dictParam[PARAMS.COUNTRY_CODE] = CurrentTrip.shared.currentCountryCode
                    
                self.wsGetAvailableVehicleTypes()
                
            }
            dialogCountry.onClickSelect = { [unowned dialogCountry ] (country) in
                self.selectedCountry = country
                //
                self.btnSelectCountry.setTitle("Select City", for: .normal)
                dialogCountry.removeFromSuperview();
            }
        }else{
            self.selectState()
//            let dialogCountry = CountryPopup.showCustomAlertDialog(countryData: listCountry, cityData: listCites)
//            dialogCountry.onClickCancel = { [unowned dialogCountry] in
//                dialogCountry.removeFromSuperview();
//            }
//            dialogCountry.onClickSelect = { [unowned dialogCountry ] (country) in
//                self.selecvtedCountry = country
//                print(self.btnSelectCountry.titleLabel?.text)
//                self.btnSelectedCountry.isHidden = false
//                self.btnSelectCountry.setTitle("Select City", for: .normal)
//                dialogCountry.removeFromSuperview();
//            }
        }
        //
    }
    @IBAction func actionCountry(_ sender: Any) {
        self.selectState()
    }
    func selectState(){
        let dialogCountry = CountryPopup.showCustomAlertDialog(title : "Select Country",message : "Search Country",countryData: listCountry, cityData: listCites)
        dialogCountry.onClickCancel = { [unowned dialogCountry] in
            dialogCountry.removeFromSuperview();
        }
        dialogCountry.onClickSelect = { [unowned dialogCountry ] (country) in
            self.selectedCountry = country
            self.listCites = country.city_list
            print(self.btnSelectCountry.titleLabel?.text)
            self.btnSelectedCountry.isHidden = false
            self.btnSelectedCountry.setTitle("\(self.selectedCountry.countryname ?? "")", for: .normal)
            self.btnSelectCountry.setTitle("Select City", for: .normal)
            dialogCountry.removeFromSuperview();
        }
    }
//    FUNC GET //GET_COUNTRY_CITY_LIST
        func GetCountry() {
                Utility.showLoading()
            var  dictParam : [String : Any] = [:]
                let afh:AlamofireHelper = AlamofireHelper.init()
                afh.getResponseFromURL(url: WebService.GET_COUNTRY_CITY_LIST, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) {
                 (response, error) -> (Void) in
//                    print(response)
                    if (error != nil) {
                        Utility.hideLoading()
                        self.promoId = ""
                    } else {
                        if Parser.isSuccess(response: response) {
                            Utility.hideLoading()
                            self.listCountry = [Countres]()
                            if let data = response["country_list"] as? [JSONType]{
                                self.listCountry.append(contentsOf: data.compactMap(Countres.init))
                                print(self.listCountry)
                            }
//                            let promoResponseModel = PromoResponseModel.init(fromDictionary: response)
//                            self.promoId = promoResponseModel.promo_id
//                            self.promoText = promo
//                            dialog.removeFromSuperview()
                        }
                    }
//                    self.updatePromoView()
                }
            
        }
    //MARK: - User Define Methods
    func openDriverDetailDialog() {
        let name = CurrentTrip.shared.tripStaus.trip.providerFirstName + " " +   CurrentTrip.shared.tripStaus.trip.providerLastName
        
        if dialogFromDriverDetail == nil
        {
            dialogFromDriverDetail = CustomDriverDetailDialog.showCustomDriverDetailDialog(name: name, imageUrl: CurrentTrip.shared.providerPicture,rate: CurrentTrip.shared.tripStaus.trip.providerRate , message: "TXT_CONNECTING_NEAR_BY_DRIVER".localized, cancelButton: "TXT_CANCEL_TRIP".localized)
            self.dialogFromDriverDetail?.onClickCancelTrip = { 
                [unowned self, weak dialogFromDriverDetail = self.dialogFromDriverDetail] in
                self.wsCancelTrip()
                printE(dialogFromDriverDetail!)
            }
        }
    }
    
    func openTripBidList() {
        let dialog = AcceptedBidTrips.showDialog(arrBids: CurrentTrip.shared.tripStaus.trip.bids)
        dialog.onClickRightButton = { [weak self] obj in
            guard let self = self else { return }
            self.wsCancelTrip()
        }
        dialog.relaodTrip = { [weak self] in
            guard let self = self else { return }
            self.wsGetTripStatus()
        }
    }
    
    func openTripBidPopup(isFromButton: Bool = false) {
        var min = 0.0
        let dialog = CustomVerificationDialog.showCustomVerificationDialog(title: "txt_bidding".localized, message: "".localized, titleLeftButton: "TXT_CLOSE".localized, titleRightButton: "TXT_CONFIRM".localized, editTextHint: "txt_enter_bidding_price".localized,  editTextInputType: false)
        if let minBidLimit = self.vehicleListResponse?.user_min_bidding_limit, minBidLimit > 0 {
            let minValue = CurrentTrip.shared.estimateFareTotal * (minBidLimit/100)
            min = minValue
            dialog.minimumAmount = minValue
            dialog.lblMessage.text = "txt_minimum_bidding_price".localized.replacingOccurrences(of: "****", with: minValue.toString())
        } else {
            let minValue = CurrentTrip.shared.estimateFareTotal
            min = minValue
            dialog.minimumAmount = minValue
            dialog.lblMessage.text = "txt_minimum_bidding_price".localized.replacingOccurrences(of: "****", with: minValue.toString())
        }
        dialog.lblMessage.isHidden = true
        dialog.lblMessage.textColor = .themeWalletDeductedColor
        dialog.editText.keyboardType = .decimalPad
        dialog.doubleValidation = true
        dialog.btnLeft.isHidden = false
        
        if self.bidPrice > 0 {
            dialog.editText.text = self.bidPrice.toString(isClean: true)
            dialog.editText.doubleValueText = self.bidPrice
            dialog.editText.doubleValueLocale = "en"
        }
        
        dialog.onClickLeftButton = { [unowned dialog] in
            dialog.removeFromSuperview();
            if isFromButton {
                self.btnCheckBiding.isSelected = false
                self.txtTripBiding.superview?.isHidden = true
                return
            }
            if self.bidPrice == 0 {
                self.btnCheckBiding.isSelected = false
                self.txtTripBiding.superview?.isHidden = true
                
                if let vwBid = self.txtTripBiding.superview {
                    if !vwBid.isHidden {
                        vwBid.isHidden = true
                    }
                }
            }
        }
        dialog.onClickRightButton = { [weak self, unowned dialog] (text:String) in
            guard let self = self else { return }
            self.bidPrice = Double(text) ?? 0
            
            //to update value in textfield
            let _ = self.txtTripBiding.becomeFirstResponder()
            let _ = self.txtTripBiding.resignFirstResponder()
            
            self.txtTripBiding.superview?.isHidden = false
          
            if self.bidPrice == 0 {
                let price = "txt_minimum_bidding_price".localized.replacingOccurrences(of: "****", with: min.toString())
                                Utility.showToast(message: price)
//                Utility.showToast(message: "txt_please_enter_valid_bid_price".localized)
                /*if text.isEmpty {
                    let text = CurrentTrip.shared.estimateFareTotal.toCurrencyString()
                    self.bidPrice = CurrentTrip.shared.estimateFareTotal
                    self.txtTripBiding.text = text
                    dialog.removeFromSuperview()
                } else {
                    Utility.showToast(message: "txt_please_enter_valid_bid_price".localized)
                }*/
            } else {
                var min = CurrentTrip.shared.estimateFareTotal
                if let minBidLimit = self.vehicleListResponse?.user_min_bidding_limit, minBidLimit > 0 {
                    min = CurrentTrip.shared.estimateFareTotal * (minBidLimit/100)
                }
            let minimumBid = (CurrentTrip.shared.estimateFareTotal - min)
                if self.bidPrice < minimumBid {
                    let price = "txt_minimum_bidding_price".localized.replacingOccurrences(of: "****", with: minimumBid.toString())
                                    Utility.showToast(message: price)
    //
//                    Utility.showToast(message: "txt_please_enter_valid_bid_price".localized)
                    return
                }
                dialog.removeFromSuperview()
                let text = self.bidPrice.toCurrencyString()
                self.txtTripBiding.text = text
            }
        }
    }

    func checkForAvailableService(isShowLoader: Bool = false)
    {
        if CurrentTrip.shared.pickupCoordinate.latitude != 0.0 && CurrentTrip.shared.pickupCoordinate.longitude != 0.0
        {
            LocationCenter.default.fetchCityAndCountry(location: CLLocation.init(latitude: CurrentTrip.shared.pickupCoordinate.latitude, longitude: CurrentTrip.shared.pickupCoordinate.longitude))
            { [weak self] (city, country, error) in
                if error != nil
                {
                    Utility.hideLoading()
                    //Utility.showToast(message: "VALIDATION_MSG_INVALID_LOCATION".localized)
                }
                else
                {
                    CurrentTrip.shared.pickupCity = city ?? ""
                    CurrentTrip.shared.pickupCountry = country?.lowercased() ?? ""
                    self?.wsGetAvailableVehicleTypes()
                    if !(self?.arrFinalForVehicles.isEmpty ?? true) && (self?.isShowActiveView ?? false) {
                        self?.resetTripNearByProviderTimer(isShowLoader: isShowLoader)
                    }
                }
            }
        }
    }
    
    func updateSplitPayment() {
        if CurrentTrip.shared.splitPaymentReq._id?.count ?? 0 > 0 {
            if (CurrentTrip.shared.splitPaymentReq.payment_status == PAYMENT_STATUS.WAITING || CurrentTrip.shared.splitPaymentReq.payment_status == PAYMENT_STATUS.FAILED) && (CurrentTrip.shared.splitPaymentReq.payment_mode == PaymentMode.CARD || CurrentTrip.shared.splitPaymentReq.payment_mode == PaymentMode.APPLE_PAY) && CurrentTrip.shared.splitPaymentReq.is_trip_end == 1 {
                //PayDialog
                CurrentTrip.shared.splitPaymentDialogHelper?.splitPayment(inVc: self)
            } else {
                APPDELEGATE.showFriendReqDialog(name: (CurrentTrip.shared.splitPaymentReq.first_name ?? "") + " " + (CurrentTrip.shared.splitPaymentReq.last_name ?? ""), contact: (CurrentTrip.shared.splitPaymentReq.country_phone_code ?? "")+(CurrentTrip.shared.splitPaymentReq.phone ?? "")) { isAddNewCard in
                    if isAddNewCard {
                        let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentVC")
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }

    func idealView()
    {
        hideProviderFilter()
        viewForNoServiceAvailable.isHidden = true
        hideBottomView()
        self.GetCountry()
        viewForAddresses.isHidden = true
        btnBack.isHidden = true
        imgBack.isHidden = true
        btnFilter.isHidden = true
        imgFilter.isHidden = true
        viewFilter.isHidden = true
        viewForWhereToGo.isHidden = true
        paymentSelectionSheet.isHidden = false
        btnMyLocation.isHidden = false
        btnMenu.isHidden = false
        imgMenu.isHidden = false
        pickupMarker.map = nil
        pickupMarker.snippet = "Source Location"
        
        destinationMarker.map = nil
        mapView.clear()
        self.polyLinePath.map = nil
        self.mapView.padding = UIEdgeInsets.init(top: viewForWhereToGo.frame.maxY, left: 20, bottom: 20, right: 20)
        currentMarker.map = mapView
        
        updateAddressUI()
        
        CurrentTrip.shared.clearDestinationAddress()
        isShowActiveView = false
        btnRideLater.isHidden = true
        lblFareEstimate.text = "--"
        isShowActiveView = false

        btnPromoCode.isUserInteractionEnabled = true
        btnPromoCode.setTitle("TXT_HAVE_PROMO_CODE".localizedCapitalized, for: .normal)
        self.promoId = ""

        self.resetTripNearByProviderTimer()
        self.animateToCurrentLocation()
    }

    func isMarkerWithinScreen(marker: GMSMarker) -> Bool {
        let region = self.mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: region)
        return bounds.contains(marker.position)
    }

    func activeView() {
        if isNoRouteFound
        {
            hideBottomView()
            viewLocationButton.isHidden = true
            isShowActiveView = true
        }
        else
        {
            //bottomView.isHidden = true
            stkFavouriteAddress.isHidden = true
            //collectionViewForServices.reloadData()
            self.mapView.padding = UIEdgeInsets.init(top: viewForAddresses.frame.maxY, left: 20, bottom: viewForAvailableService.frame.height, right: 20)
            if self.arrFinalForVehicles.isEmpty
            {
                viewForNoServiceAvailable.isHidden = false
                viewForAvailableService.isHidden = true
                self.GetCountry()
            }
            else
            {
                viewForNoServiceAvailable.isHidden = true
                showBottomView()
                showPathFrom(source: CurrentTrip.shared.pickupCoordinate, toDestination: CurrentTrip.shared.destinationCoordinate)
            }
            viewForAddresses.isHidden = false
            btnBack.isHidden = false
            imgBack.isHidden = false
            btnFilter.isHidden = false
            imgFilter.isHidden = false
            viewFilter.isHidden = false
            viewForWhereToGo.isHidden = true
            paymentSelectionSheet.isHidden = true
            btnMyLocation.isHidden = true
            btnMenu.isHidden = true
            imgMenu.isHidden = true
            btnAddAddress.isHidden = true
            viewAddAddress.isHidden = true
            self.setMarkers()
            Utility.hideLoading()
        }
    }

    func setMarkers() {
        currentMarker.map = nil
        if !CurrentTrip.shared.pickupAddress.isEmpty
        {
            pickupMarker.position =  CurrentTrip.shared.pickupCoordinate
            pickupMarker.icon = Global.imgPinPickup
            pickupMarker.map = mapView
        }
        if !CurrentTrip.shared.destinationtAddress.isEmpty
        {
            destinationMarker.position =  CurrentTrip.shared.destinationCoordinate
            destinationMarker.icon = Global.imgPinDestination
            destinationMarker.map = mapView
        }
        
        for arr in self.arrLocations {
            guard let wLat = arr.latitude, let wLong = arr.longitude  else {
                return
            }
            
            let location = CLLocationCoordinate2D(latitude: wLat, longitude: wLong)
            
            print("location: \(location)")
            let marker = GMSMarker()
            marker.icon = Global.imgPinSource
            marker.position = location
            marker.map = self.mapView
        }
        
    }

    func updateAddressUI() {
        let addressData:UserAddress = CurrentTrip.shared.favouriteAddress
        
        if addressData.workAddress.isEmpty() && addressData.homeAddress.isEmpty()
        {
            btnHomeAddress.isHidden = true
            btnWorkAddress.isHidden = true
            btnAddAddress.isHidden = false
            
            viewHomeAddress.isHidden = true
            viewWorkAddress.isHidden = true
            viewAddAddress.isHidden = false
        }
        else if !addressData.workAddress.isEmpty() && !addressData.homeAddress.isEmpty()
        {
            btnHomeAddress.isHidden = false
            btnWorkAddress.isHidden = false
            btnAddAddress.isHidden = true
            
            viewHomeAddress.isHidden = false
            viewWorkAddress.isHidden = false
            viewAddAddress.isHidden = true
        }
        else if !addressData.workAddress.isEmpty() && addressData.homeAddress.isEmpty()
        {
            btnHomeAddress.isHidden = true
            btnWorkAddress.isHidden = false
            btnAddAddress.isHidden = false
            
            viewHomeAddress.isHidden = true
            viewWorkAddress.isHidden = false
            viewAddAddress.isHidden = false
        }
        else if addressData.workAddress.isEmpty() && !addressData.homeAddress.isEmpty()
        {
            btnHomeAddress.isHidden = false
            btnWorkAddress.isHidden = true
            btnAddAddress.isHidden = false
            
            viewHomeAddress.isHidden = false
            viewWorkAddress.isHidden = true
            viewAddAddress.isHidden = false
        }
        else
        {
            btnHomeAddress.isHidden = true
            btnWorkAddress.isHidden = true
            btnAddAddress.isHidden = true
            
            viewHomeAddress.isHidden = true
            viewWorkAddress.isHidden = true
            viewAddAddress.isHidden = true
        }
        if !CurrentTrip.shared.pickupAddress.isEmpty {
            lblPickupAddress.text = CurrentTrip.shared.pickupAddress
        }
        if !CurrentTrip.shared.destinationtAddress.isEmpty {
            lblDestinationAddress.text = CurrentTrip.shared.destinationtAddress
        }
        
        if !CurrentTrip.shared.pickupAddress.isEmpty && CurrentTrip.shared.destinationtAddress.isEmpty{
            lblDestinationAddress.text = "Destination address"
        }

    }

    func checkSurgeTime(startHour:String,endHour:String,serverTime:String) {
        let currentDate:Date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()
        
        let tempDateFormatter = DateFormatter.init()
        tempDateFormatter.dateFormat = DateFormat.WEB
        tempDateFormatter.locale = Locale.init(identifier: "en_GB")
        tempDateFormatter.timeZone = TimeZone.init(identifier: "UTC")
        let serverDateTime = tempDateFormatter.date(from: serverTime)
        tempDateFormatter.timeZone = TimeZone.init(identifier: CurrentTrip.shared.timeZone)
        let tempStrDate = tempDateFormatter.string(from: serverDateTime ?? Date())
        let tempDate = tempDateFormatter.date(from: tempStrDate)
        let cal:Calendar = Calendar.current

        let serverHour:Int = cal.component(Calendar.Component.hour, from: tempDate!)
        let serverMinut:Int = cal.component(Calendar.Component.minute, from: tempDate!)
        
        var isSurge:Bool = false
        
        for surgeHours in CurrentTrip.shared.selectedVehicle.surgeHours
        {
            if surgeHours.day == serverDateTime?.dayNumberOfWeek().toString()
            {
                for dayTime in surgeHours.dayTime
                {
                    var startHour = 0;
                    var startMinut = 0;
                    var endHour = 0;
                    var endMinut = 0;
                    
                    if dayTime.startTime.contains(":")
                    {
                        let time = dayTime.startTime.components(separatedBy: ":")
                        startHour = time[0].toInt()
                        startMinut = time[1].toInt()
                    }
                    if dayTime.endTime.contains(":")
                    {
                        let time = dayTime.endTime.components(separatedBy: ":")
                        endHour = time[0].toInt()
                        endMinut = time[1].toInt()
                    }
                    let surgeStartDate:Date = Calendar.current.date(bySettingHour: startHour, minute: startMinut, second: 0, of: currentDate)!
                    
                    let surgeEndDate:Date = Calendar.current.date(bySettingHour: endHour, minute: endMinut, second: 0, of: currentDate)!
                    
                    let currentTime:Date = Calendar.current.date(bySettingHour: serverHour, minute: serverMinut, second: 0, of: currentDate)!
                    
                    if ((surgeStartDate <= currentTime) &&
                        (surgeEndDate >= currentTime) &&
                        (CurrentTrip.shared.selectedVehicle.isSurgeHours == TRUE) && surgeHours.isSurge == true)
                    {
                        CurrentTrip.shared.selectedVehicle.surgeMultiplier = dayTime.multiplier.toDouble()
                        isSurge = true
                        break;
                    }
                    else
                    {
                        isSurge = false
                    }
                }
            }
        }

        if (isSurge)
        {
            CurrentTrip.shared.selectedVehicle.surgeMultiplier = CurrentTrip.shared.selectedVehicle.richAreaSurgeMultiplier >  CurrentTrip.shared.selectedVehicle.surgeMultiplier ? CurrentTrip.shared.selectedVehicle.richAreaSurgeMultiplier :CurrentTrip.shared.selectedVehicle.surgeMultiplier
            CurrentTrip.shared.isSurgeHour =  (CurrentTrip.shared.selectedVehicle.surgeMultiplier != 1.0 && CurrentTrip.shared.selectedVehicle.surgeMultiplier > 0.0)
        }
        else if (CurrentTrip.shared.selectedVehicle.richAreaSurgeMultiplier != 1.0 && CurrentTrip.shared.selectedVehicle.richAreaSurgeMultiplier > 0.0)
        {
            CurrentTrip.shared.selectedVehicle.surgeMultiplier =   CurrentTrip.shared.selectedVehicle.richAreaSurgeMultiplier
            CurrentTrip.shared.isSurgeHour = true
        }
        else
        {
            CurrentTrip.shared.isSurgeHour = false
        }
        if (CurrentTrip.shared.tripType == TripType.ZONE || CurrentTrip.shared.tripType == TripType.AIRPORT || CurrentTrip.shared.tripType == TripType.CITY)
        {
            CurrentTrip.shared.isSurgeHour = false
        }
    }

    func checkSurgeTimeForFutureRequest(startHour:String,endHour:String,serverTime:String,bookHours:Int,bookMin:Int,bookDay:Int) -> Bool {
        let currentDate:Date = Calendar.current.date(bySetting: .day, value: bookDay, of: Date()) ?? Date()
        let futureTime:Date = Calendar.current.date( bySettingHour: bookHours, minute: bookMin, second: 0, of: currentDate)!

        var isSurge:Bool = false

        for surgeHours in CurrentTrip.shared.selectedVehicle.surgeHours
        {
            if surgeHours.day == futureTime.dayNumberOfWeek().toString()
            {
                for dayTime in surgeHours.dayTime
                {
                    var startHour = 0;
                    var startMinut = 0;
                    var endHour = 0;
                    var endMinut = 0;
                    
                    if dayTime.startTime.contains(":")
                    {
                        let time = dayTime.startTime.components(separatedBy: ":")
                        startHour = time[0].toInt()
                        startMinut = time[1].toInt()
                    }
                    if dayTime.endTime.contains(":")
                    {
                        let time = dayTime.endTime.components(separatedBy: ":")
                        endHour = time[0].toInt()
                        endMinut = time[1].toInt()
                    }
                    let surgeStartDate:Date = Calendar.current.date(bySettingHour: startHour, minute: startMinut, second: 0, of: currentDate)!
                    
                    let surgeEndDate:Date = Calendar.current.date(bySettingHour: endHour, minute: endMinut, second: 0, of: currentDate)!
                    
                    if ((surgeStartDate <= futureTime) && (surgeEndDate >= futureTime) && (CurrentTrip.shared.selectedVehicle.isSurgeHours == TRUE) && surgeHours.isSurge)
                    {
                        CurrentTrip.shared.selectedVehicle.surgeMultiplier = dayTime.multiplier.toDouble()
                        isSurge = true
                        break;
                    }
                    else
                    {
                        isSurge = false
                    }
                }
            }
        }
        
        if (isSurge)
        {
            CurrentTrip.shared.selectedVehicle.surgeMultiplier = CurrentTrip.shared.selectedVehicle.richAreaSurgeMultiplier >  CurrentTrip.shared.selectedVehicle.surgeMultiplier ? CurrentTrip.shared.selectedVehicle.richAreaSurgeMultiplier :CurrentTrip.shared.selectedVehicle.surgeMultiplier
            CurrentTrip.shared.isSurgeHour =  (CurrentTrip.shared.selectedVehicle.surgeMultiplier != 1.0 && CurrentTrip.shared.selectedVehicle.surgeMultiplier > 0.0)
        }
        else if (CurrentTrip.shared.selectedVehicle.richAreaSurgeMultiplier != 1.0 && CurrentTrip.shared.selectedVehicle.richAreaSurgeMultiplier > 0.0)
        {
            CurrentTrip.shared.selectedVehicle.surgeMultiplier =   CurrentTrip.shared.selectedVehicle.richAreaSurgeMultiplier
            CurrentTrip.shared.isSurgeHour = true
        }
        else
        {
            CurrentTrip.shared.isSurgeHour = false
        }
        
        if (CurrentTrip.shared.tripType == TripType.ZONE || CurrentTrip.shared.tripType == TripType.AIRPORT || CurrentTrip.shared.tripType == TripType.CITY)
        {
            CurrentTrip.shared.isSurgeHour = false
        }
        return CurrentTrip.shared.isSurgeHour
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {}

    func resetTripNearByProviderTimer(isShowLoader: Bool = false)
    {
        if !isShowLoader {
            Utility.hideLoading()
        }
        
        self.stopTripNearByProviderTimer()
        self.wsGetNearByProvider()
        CurrentTrip.timerForNearByProvider =  Timer.scheduledTimer(timeInterval: 180.0, target: self, selector: #selector(self.wsGetNearByProvider), userInfo: nil, repeats: true)
    }

    func stopTripNearByProviderTimer()
    {
        CurrentTrip.timerForNearByProvider?.invalidate()
    }

    func startTripStatusTimer()
    {
        self.stopTripListner()
        self.startTripListner()
    }

    func stopTripStatusTimer()
    {
        CurrentTrip.timeForTripStatus?.invalidate()
        CurrentTrip.timeForTripStatus = nil
        self.stopTripListner()
    }
    
    func setProviderMarker(arrProvider:[Provider])
    {
        arrayForProviderMarker.removeAll()
        for provider in arrProvider
        {
            if provider.providerLocation.count > 1
            {
                if provider.providerLocation[0] != 0.0 && provider.providerLocation[1] != 0.0
                {
                    let marker:GMSMarker = GMSMarker.init(position: CLLocationCoordinate2D.init(latitude: provider.providerLocation[0], longitude: provider.providerLocation[1]))
                    marker.accessibilityLabel = provider.id
                    marker.rotation = provider.bearing;
                    marker.snippet = provider.firstName + provider.lastName
                    marker.map = self.mapView;

                    //marker.icon = UIImage.init(named: "asset-driver-pin-placeholder")
                    if !isShowActiveView
                    {
                        self.driverMarkerImage = UIImage.init(named: "asset-driver-pin-placeholder")
                    }
                    
                    if let image = self.driverMarkerImage
                    {
                        DispatchQueue.main.async {
                            marker.icon = image
                            self.driverMarkerImage = image
                        }
                    }
                    else
                    {
                        let url = CurrentTrip.shared.selectedVehicle.typeDetails.mapPinImageUrl
                        Utility.downloadImageFrom(link: url!, completion: { (image) in
                            marker.icon = image
                            self.driverMarkerImage = image
                        })
                    }
                    self.arrayForProviderMarker.append(marker)
                    self.registerProviderSocket(id: provider.id)
                }
            }
        }
    }

    func setTripBidding(response:VehicleListResponse) {
        viewCheckBiding.isHidden = !(response.is_allow_trip_bidding && !btnCorporatePay.isSelected)
        
        //tag 1 == user can set bidding else user can not set bidding
        btnCheckBiding.tag = response.is_user_can_set_bid_price ? 1 : 0
         
        //tag 1 == user can create trip with bidding else not
        viewCheckBiding.tag = response.is_allow_trip_bidding ? 1 : 0
        if type == 2 || type == 3{
            viewCheckBiding.isHidden = true
        }
    }
    @IBAction func actionNotification(_ sender: Any) {
        let massNotificationVC = MassNotificationVC(nibName: "MassNotificationVC", bundle: nil)
        massNotificationVC.modalPresentationStyle = .fullScreen
        self.present(massNotificationVC, animated: true, completion: nil)
        
    }
}

//MARK: - Dialogs
extension MapVC
{

    func openFutureRequestDate()
    {
        let datePickerDialog:CustomDatePickerDialog = CustomDatePickerDialog.showCustomDatePickerDialog(title: "TXT_SELECT_TO_DATE".localized, titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_OK".localized)
        datePickerDialog.setDatePickerForFutureTrip()
        datePickerDialog.onClickLeftButton =
        { [/*unowned self,*/ unowned datePickerDialog] in
            datePickerDialog.removeFromSuperview()
        }
        datePickerDialog.onClickRightButton =
        { [unowned self, unowned datePickerDialog] (selectedDate:Date) in
            let selectedTime = datePickerDialog.getFutureTripBookingDate()
            self.futureTripSelectedDate = selectedDate

            let calender = Calendar.current
            let dateComponents:DateComponents = calender.dateComponents([.hour,.minute,.day], from: selectedDate)

            let hour = dateComponents.hour ?? 0
            let minut = dateComponents.minute ?? 0
            let day = dateComponents.day ?? 0

            if self.checkSurgeTimeForFutureRequest(startHour: CurrentTrip.shared.selectedVehicle.surgeStartHour.toString(), endHour: CurrentTrip.shared.selectedVehicle.surgeEndHour.toString(), serverTime: CurrentTrip.shared.serverTime, bookHours: hour, bookMin: minut, bookDay:day)
            {
                let dialogForSurgePrice = CustomSurgePriceDialog.showCustomSurgePriceDialog(title: "TXT_SURGE_PRICE".localized, message: "TXT_SURGE_PRICE_MESSAGE".localized, surgePrice: CurrentTrip.shared.selectedVehicle.surgeMultiplier.toString() + "x", titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_CONFIRM".localized)
                dialogForSurgePrice.onClickLeftButton = {
                    [/*unowned self,*/ unowned dialogForSurgePrice] in
                    dialogForSurgePrice.removeFromSuperview()
                }
                dialogForSurgePrice.onClickRightButton = {
                    [unowned self, unowned dialogForSurgePrice] in
                    self.viewCheckBiding.isHidden = true
                    self.btnRideLater.setTitle("TXT_SCHEDULE_TRIP".localized + "\n \(selectedTime)", for: .normal)
                    self.btnRideLater.isHidden = false
                    dialogForSurgePrice.removeFromSuperview()
                }
            }
            else
            {
                self.viewCheckBiding.isHidden = true
                self.btnRideLater.setTitle("TXT_SCHEDULE_TRIP".localized + "\n \(selectedTime)", for: .normal)
                self.btnRideLater.isHidden = false
            }
            datePickerDialog.removeFromSuperview()
        }
    }

    func openFareEstimateDialog()
    {
        self.checkSurgeTime(startHour: CurrentTrip.shared.selectedVehicle.surgeStartHour.toString(), endHour: CurrentTrip.shared.selectedVehicle.surgeEndHour.toString(), serverTime: CurrentTrip.shared.serverTime)
        _ = FareEstimateDialog.showFareEstimateDialog()
    }

    func openPaymentDialog()
    {
        PaymentMethod.Payment_gateway_type = "\(preferenceHelper.getsPaymentGateway())"
        let dialogForPayment = CustomAppleCardDialog.showCustomPaymentSelectionDialog()
        dialogForPayment.onClickPaymentModeSelected  =  { [weak self]  (paymentMode) in
            guard let self = self else { return }
            self.paymentMode = paymentMode
            self.updatePaymentUI()
            self.updatePromoView()
        }
    }

    func openCorporateRequestDialog()
    {
        let dialogForCorporateRequest = CustomCorporateRequestDialog.showCustomCorporateRequestDialog(title: "TXT_CORPORATE_REQUEST".localized, message: "TXT_CORPORATE_REQUEST_MESSAGE".localized, titleLeftButton: "TXT_NO".localized, titleRightButton: "TXT_YES".localized)
        dialogForCorporateRequest.onClickLeftButton = { 
            [unowned self, unowned dialogForCorporateRequest] in
            dialogForCorporateRequest.removeFromSuperview()
            self.wsAcceptRejectCorporateRequest(accept: false)
        }
        dialogForCorporateRequest.onClickRightButton = { 
            [unowned self, unowned dialogForCorporateRequest] in
            dialogForCorporateRequest.removeFromSuperview()
            self.wsAcceptRejectCorporateRequest(accept: true)
        }
    }

    func openFixedPriceDialog(futureTrip:Bool = false)
    {
        if CurrentTrip.shared.isAskUserForFixedFare && !isBidTrip && !CurrentTrip.shared.destinationtAddress.isEmpty() {
            let dialogForFixedTrip = CustomAlertDialog.showCustomAlertDialog(title: "TXT_FIXED_RATE_AVAILABLE".localized, message: "MSG_FIXED_RATE_DIALOG".localized, titleLeftButton: "TXT_NO".localized, titleRightButton: "TXT_YES".localized)
            dialogForFixedTrip.onClickLeftButton =
            { [unowned self, unowned dialogForFixedTrip] in
                dialogForFixedTrip.removeFromSuperview()
                if futureTrip
                {
                    CurrentTrip.shared.isFixedFareTrip = false
                    self.wsCreateFutureRequest()
                }
                else
                {
                    CurrentTrip.shared.isFixedFareTrip = false
                    self.wsCreateRequest()
                }
                return;
            }
            dialogForFixedTrip.onClickRightButton =
            { [unowned self, unowned dialogForFixedTrip] in
                dialogForFixedTrip.removeFromSuperview()
                if CurrentTrip.shared.destinationtAddress.isEmpty()
                {
                    Utility.showToast(message: "VALIDATION_MSG_SELECT_DESTINATION_ADDRESS_FIRST".localized)
                }
                else
                {
                    if futureTrip
                    {
                        CurrentTrip.shared.isFixedFareTrip = true
                        self.wsCreateFutureRequest()
                    }
                    else
                    {
                        CurrentTrip.shared.isFixedFareTrip = true
                        self.wsCreateRequest()
                    }
                }
            }
        }
        else
        {
            if futureTrip
            {
                CurrentTrip.shared.isFixedFareTrip = false
                self.wsCreateFutureRequest()
            }
            else
            {
                CurrentTrip.shared.isFixedFareTrip = false
                self.wsCreateRequest()
            }
        }
    }

    func openPromoDialog()
    {
        self.view.endEditing(true)
        let dialogForPromo = CustomVerificationDialog.showCustomVerificationDialog(title: "TXT_APPLY_PROMO".localized, message: "".localized, titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_APPLY".localized, editTextHint: "TXT_ENTER_PROMO".localized,  editTextInputType: false,offerbutton: true,countryId: arrFinalForVehicles[selectedIndex].countryid , cityId: arrFinalForVehicles[selectedIndex].cityid)
        dialogForPromo.onClickLeftButton =
        { [unowned dialogForPromo] in
            dialogForPromo.removeFromSuperview()
        }
        dialogForPromo.onClickRightButton =
        { [unowned self, unowned dialogForPromo] (text:String) in
            if (text.count <  1)
            {
                dialogForPromo.editText.showErrorWithText(errorText:"MSG_PLEASE_ENTER_VALID_PROMOCODE".localized )
            }
            else
            {
                self.wsApplyPromo(promo: text,dialog: dialogForPromo)
            }
        }
    }
//FUNC GET //GET_COUNTRY_CITY_LIST
    func wsApplyPromo(promo:String,dialog:CustomVerificationDialog) {
        if !promo.isEmpty() {
            Utility.showLoading()
            var  dictParam : [String : Any] = [:]
            dictParam[PARAMS.PROMO_CODE] = promo
            dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
            dictParam[PARAMS.TOKEN ] = preferenceHelper.getSessionToken()
            dictParam[PARAMS.CITY_ID] = arrFinalForVehicles[selectedIndex].cityid
            dictParam[PARAMS.COUNTRY_ID] = arrFinalForVehicles[selectedIndex].countryid
            dictParam[PARAMS.PAYMENT_MODE] = self.paymentMode

            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.APPLY_PROMO_CODE, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) {
                [unowned self, unowned dialog] (response, error) -> (Void) in
                if (error != nil) {
                    Utility.hideLoading()
                    self.promoId = ""
                } else {
                    if Parser.isSuccess(response: response) {
                        Utility.hideLoading()
                        let promoResponseModel = PromoResponseModel.init(fromDictionary: response)
                        self.promoId = promoResponseModel.promo_id
                        self.promoText = promo
                        dialog.removeFromSuperview()
                    }
                }
                self.updatePromoView()
            }
        }
    }
    func wsGetPromo() {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.CITY_ID] = arrFinalForVehicles[selectedIndex].cityid
        dictParam[PARAMS.COUNTRY_ID] = arrFinalForVehicles[selectedIndex].countryid
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_PROMO_CODE_LIST, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) {
            (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
//                self.promoId = ""
            } else {
                if Parser.isSuccess(response: response) {
                    Utility.hideLoading()
                    self.listPromoCode = [PromoCode]()
                    if let info = response["promo_codes"] as? [JSONType]{
                        self.listPromoCode.append(contentsOf: info.compactMap(PromoCode.init))
                    }
                }
            }
//            self.updatePromoView()
        }
    }
    
    func updatePaymentUI() {
        if paymentMode == PaymentMode.CARD {
            lblPayment.text = "TXT_CARD".localized
            imgPayment.image = UIImage.init(named: "asset-card")
            //self.lblPaymentIcon.text = FontAsset.icon_payment_card
        }
        else if paymentMode == PaymentMode.CASH {
            lblPayment.text = "TXT_CASH".localized
            imgPayment.image = UIImage.init(named: "asset-cash")
            //self.lblPaymentIcon.text = FontAsset.icon_payment_cash
        }
        else if paymentMode == PaymentMode.APPLE_PAY {
            lblPayment.text = "TXT_APPLE_PAY".localized
            imgPayment.image = UIImage.init(named: "asset-apple-pay")
            //self.lblPaymentIcon.text = FontAsset.icon_payment_apple_pay
        }
        else {
            lblPayment.text = "TXT_ADD_PAYMENT".localized
        }
        imgPayment.setImageColor()
        if (self.paymentMode == PaymentMode.CASH && CurrentTrip.shared.isPromoApplyForCash == FALSE) || (self.paymentMode == PaymentMode.CARD && CurrentTrip.shared.isPromoApplyForCard == FALSE)
        {
            viewPromoCode.isHidden = true
            btnPromoCode.isUserInteractionEnabled = true
            btnPromoCode.setTitle("TXT_PROMO_APPLIED".localizedCapitalized, for: .normal)
        }else{
            viewPromoCode.isHidden = false
        }
    }

    func updatePromoView()
    {
        if (self.paymentMode == PaymentMode.CASH && CurrentTrip.shared.isPromoApplyForCash == FALSE) || (self.paymentMode == PaymentMode.CARD && CurrentTrip.shared.isPromoApplyForCard == FALSE)
        {
            viewPromoCode.isHidden = true
            btnPromoCode.isUserInteractionEnabled = true
            btnPromoCode.setTitle("TXT_PROMO_APPLIED".localizedCapitalized, for: .normal)
        }else{
            viewPromoCode.isHidden = false
        }
        if self.promoId.isEmpty
        {
            btnPromoCode.isUserInteractionEnabled = true
            btnPromoCode.setTitle("TXT_HAVE_PROMO_CODE".localizedCapitalized, for: .normal)
            self.promoId = ""
        }
        else
        {
            /*
             var isPromoApplyForCash:Int = 0
             var isPromoApplyForCard:Int = 0
             */
//            if (self.paymentMode == PaymentMode.CASH) && isPromoApplyForCash == 0 || (self.paymentMode == PaymentMode.CASH){
//                viewPromoCode.isHidden = true
//            }
            if (self.paymentMode == PaymentMode.CASH && CurrentTrip.shared.isPromoApplyForCash == TRUE) || (self.paymentMode == PaymentMode.CARD && CurrentTrip.shared.isPromoApplyForCard == TRUE)
            {
//                viewPromoCode.isHidden = true
                btnPromoCode.isUserInteractionEnabled = true
                btnPromoCode.setTitle("TXT_PROMO_APPLIED".localizedCapitalized, for: .normal)
            }
            else
            {
                self.openPromoAttentionDialog()
                btnPromoCode.isUserInteractionEnabled = true
                btnPromoCode.setTitle("TXT_HAVE_PROMO_CODE".localizedCapitalized, for: .normal)
                self.promoId = ""
            }
        }
    }

    func openAdminApproveDialog()
    {
        let dialogForAdminApprove = CustomAlertDialog.showCustomAlertDialog(title: "TXT_ADMIN_ALERT".localized, message: "MSG_APPROVE_ERROR".localized, titleLeftButton: "TXT_LOGOUT".localized, titleRightButton: "TXT_EMAIL".localized)
        dialogForAdminApprove.onClickLeftButton =
        { [/*unowned self,*/ unowned dialogForAdminApprove] in
            preferenceHelper.setSessionToken("")
            preferenceHelper.setUserId("")
            dialogForAdminApprove.removeFromSuperview();
            APPDELEGATE.gotoLogin()
            return;
        }
        dialogForAdminApprove.onClickRightButton =
        { [/*unowned self,*/ unowned dialogForAdminApprove] in
            let email = preferenceHelper.getContactEmail()
            if let url = URL(string: "mailto://\(email)"), UIApplication.shared.canOpenURL(url)
            {
                if #available(iOS 10, *) {
                    dialogForAdminApprove.removeFromSuperview();
                    UIApplication.shared.open(url)
                } else {
                    dialogForAdminApprove.removeFromSuperview();
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    func openAddWalletAmountDialog()
    {
        let dialogForAddWalletAmount = CustomAlertDialog.showCustomAlertDialog(title: "TXT_ADD_WALLET_AMOUNT".localized, message: "MSG_LAST_CANCELLATION_PAYMENT".localized, titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_ADD".localized)
        dialogForAddWalletAmount.onClickLeftButton =
        { [/*unowned self,*/ unowned dialogForAddWalletAmount] in
            
            dialogForAddWalletAmount.removeFromSuperview()
        }
        dialogForAddWalletAmount.onClickRightButton =
        { [/*unowned self,*/ unowned dialogForAddWalletAmount] in
            dialogForAddWalletAmount.removeFromSuperview()
            let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentVC")
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

//MARK: - RevealViewController Delegate Methods
extension MapVC:PBRevealViewControllerDelegate
{
    @IBAction func onClickBtnMenu(_ sender: Any)
    {}

    func setupRevealViewController() {
        self.revealViewController()?.panGestureRecognizer?.isEnabled = true
        btnMenu.addTarget(self.revealViewController(), action: #selector(PBRevealViewController.revealLeftView), for: .touchUpInside)
    }

    func revealController(_ revealController: PBRevealViewController, willShowLeft viewController: UIViewController) {
        revealController.mainViewController?.view.isUserInteractionEnabled = false;
    }

    func revealController(_ revealController: PBRevealViewController, willHideLeft viewController: UIViewController) {
        revealController.mainViewController?.view.isUserInteractionEnabled = true;
    }
}

//MARK: - CollectionView Delegate Methods
extension MapVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func setCollectionView()
    {
        let nibName = UINib(nibName: "ServiceTypeCollectionViewCell", bundle:nil)
        collectionViewForServices.register(nibName, forCellWithReuseIdentifier: "cell")
        collectionViewForServices.dataSource = self
        collectionViewForServices.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if selectedIndex == indexPath.row {
            scrollToSelectService()
        }
        else {
            selectedIndex = indexPath.row
            driverMarkerImage = nil

            self.previousProviderId = ""
            CurrentTrip.shared.selectedVehicle = arrFinalForVehicles[indexPath.row]
            self.collectionViewForServices.reloadData()
            self.scrollToSelectService()
            self.resetTripNearByProviderTimer()
            self.wsGetFareEstimate()
            self.bidPrice = 0
            if btnCheckBiding.isSelected {
                onClickCheckBidding(btnCheckBiding)
            }
            if btnRental.isSelected {
                lblRentalPackSize.text = CurrentTrip.shared.selectedVehicle.carRentalList.count.toString()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        if arrFinalForVehicles.count > indexPath.row{
            let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ServiceTypeCollectionViewCell
            
            cell.lblServiceTypeName.text = arrFinalForVehicles[indexPath.row].typeDetails.typename
            cell.imgServiceType.downloadedFrom(link: arrFinalForVehicles[indexPath.row].typeDetails.typeImageUrl, placeHolder: "asset-driver-pin-placeholder", isFromCache: true, isIndicator: true, mode: .scaleAspectFit, isAppendBaseUrl: true)
            
            if indexPath.row == selectedIndex
            {
                cell.selectorView.backgroundColor = UIColor.themeSelectionColor
                cell.lblServiceTypeName.textColor = UIColor.themeTextColor
                cell.lblServiceTypeName.font = FontHelper.font(size: FontSize.medium, type: FontType.Bold)
            }
            else
            {
                cell.selectorView.backgroundColor = UIColor.clear
                cell.lblServiceTypeName.textColor = UIColor.themeLightTextColor
                cell.lblServiceTypeName.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
            }
            return cell
        }
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ServiceTypeCollectionViewCell
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if arrFinalForVehicles.count > 0{
            return 1
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFinalForVehicles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.width/3, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if arrFinalForVehicles.count <= 3
        {
            let totalCellWidth = (collectionView.frame.width/3) * CGFloat(collectionView.numberOfItems(inSection: 0))
            let edgeInsets = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth)) / 2
            return UIEdgeInsets(top: 0, left: edgeInsets, bottom: 0, right: edgeInsets)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func scrollToSelectService() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.selectedIndex < self.arrFinalForVehicles.count {
                self.collectionViewForServices.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
}
//MARK: - Table View Delegate Methods
extension MapVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tblMultipleStops {
            return arrLocations.count
        }
        return arrForProviderLanguage.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tblMultipleStops {
            let cell = tableView.dequeueReusableCell(withIdentifier: StopLocationTVC.className, for: indexPath) as! StopLocationTVC
            cell.setData(address: arrLocations[indexPath.row])
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProviderLanguageCell
            cell.setCellData(data: arrForProviderLanguage[indexPath.row])
            return cell
        }
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.tblMultipleStops {
            if let addressVC = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "AddressVC") as? AddressVC {
                addressVC.delegate = self
                addressVC.flag = AddressType.destinationAddress
                addressVC.arrLocations = self.arrLocations
                self.navigationController?.pushViewController(addressVC, animated: true)
            }
        }
        else {
            arrForProviderLanguage[indexPath.row].isSelected = !arrForProviderLanguage[indexPath.row].isSelected
            tblProviderLanguage.reloadData()
        }
    }
    
}
//MARK: - Web Service Calls
extension MapVC
{
    func wsGetLanguage()
    {
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_LANGUAGE_LIST, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            
            
            if (error != nil)
            {
                
            }
            else
            {
                if Parser.isSuccess(response: response,withSuccessToast: false,andErrorToast: false)
                {
                    self.arrForProviderLanguage.removeAll()
                    let languageResponse:LanguageResponse = LanguageResponse.init(fromDictionary: response)
                    let languages = languageResponse.languages!
                    for language in languages
                    {
                        self.arrForProviderLanguage.append(language)
                    }
                }
            }
            
        }
    }
    func wsGetAddress()
    {

        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_FAVOURITE_ADDRESS_LIST, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            
            
            if (error != nil)
            {
            }
            else
            {
                if Parser.isSuccess(response: response)
                {
                    let userDataResponse:UserAddressResponse = UserAddressResponse.init(fromDictionary: response)
                    CurrentTrip.shared.favouriteAddress = userDataResponse.userAddress
                    self.updateAddressUI()
                }
            }
        }
    }
    
    func wsGetAvailableVehicleTypes()
    {
        if !isNoRouteFound
        {
            Utility.showLoading()
            self.previousCity = CurrentTrip.shared.pickupCity
            var  dictParam : [String : Any] = [:]
            dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
            dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
            dictParam[PARAMS.COUNTRY]  = CurrentTrip.shared.pickupCountry
            dictParam[PARAMS.CITY]  = CurrentTrip.shared.pickupCity
            dictParam[PARAMS.LATITUDE] = CurrentTrip.shared.pickupCoordinate.latitude.toString(places: 6)
            dictParam[PARAMS.LONGITUDE] = CurrentTrip.shared.pickupCoordinate.longitude.toString(places: 6)
            dictParam[PARAMS.COUNTRY_CODE] = CurrentTrip.shared.currentCountryCode
            
            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.GET_AVAILABLE_VEHICLE_TYPES, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { [weak self] (response, error) -> (Void) in
                guard let self = self else { return }
                if (error != nil) {
                    Utility.hideLoading()
                } else {
                    self.arrFinalForVehicles.removeAll()
                    if Parser.isSuccess(response: response) {
                        let vehicleListResponse:VehicleListResponse = VehicleListResponse.init(fromDictionary: response)
                        self.vehicleListResponse = vehicleListResponse
                        if vehicleListResponse.isCorporateRequest
                        {
                            self.viewCoporate.isHidden = false
                        }
                        else
                        {
                            self.viewCoporate.isHidden = true
                        }
                        CurrentTrip.shared.serverTime = vehicleListResponse.serverTime
                        CurrentTrip.shared.timeZone = vehicleListResponse.cityDetail.timezone
                        CurrentTrip.shared.isCardModeAvailable = vehicleListResponse.cityDetail.isPaymentModeCard
                        CurrentTrip.shared.isCashModeAvailable = vehicleListResponse.cityDetail.isPaymentModeCash
                        CurrentTrip.shared.isPromoApplyForCash = vehicleListResponse.cityDetail.isPromoApplyForCash
                        CurrentTrip.shared.isPromoApplyForCard = vehicleListResponse.cityDetail.isPromoApplyForCard
                        
                        CurrentTrip.shared.currencyCode = vehicleListResponse.currencyCode
                        CurrentTrip.shared.distanceUnit = Utility.getDistanceUnit(unit: vehicleListResponse.cityDetail.unit)
                        
                        CurrentTrip.shared.isAskUserForFixedFare = vehicleListResponse.cityDetail.isAskUserForFixedFare
                        
                        if CurrentTrip.shared.isCashModeAvailable == TRUE {
                            self.paymentMode = PaymentMode.CASH
                        } else {
                            if CurrentTrip.shared.isCardModeAvailable == TRUE {
                                self.paymentMode = PaymentMode.CARD
                            } else {
                                if StripeApplePayHelper.isApplePayAvailable() {
                                    self.paymentMode = PaymentMode.APPLE_PAY
                                } else {
                                    self.paymentMode = PaymentMode.CASH
                                }
                            }
                        }
                        
                        self.updatePaymentUI()
                        self.arrRentalForVehicles.removeAll()
                        self.arrNormalForVehicles.removeAll()
                        self.arrFinalForVehicles.removeAll()
                        self.arrForRideShareVehicles.removeAll()
                        for vehicle in vehicleListResponse.citytypes
                        {
                            self.arrNormalForVehicles.append(vehicle)
                            if vehicle.isRentalType
                            {
                                self.arrRentalForVehicles.append(vehicle)
                            }
                        }
                        
                        for vehicle in vehicleListResponse.pooltypes {
                            self.arrForRideShareVehicles.append(vehicle)
                        }
                        
                        if self.arrLocations.count > 0 {
                            self.btnRideShare.isHidden = true
                            self.btnRental.isHidden = true
                        } else {
                            if CurrentTrip.shared.destinationtAddress.isEmpty() {
                                self.btnRideShare.isHidden = true
                            } else {
                                self.btnRideShare.isHidden = self.arrForRideShareVehicles.isEmpty
                            }
                            self.btnRental.isHidden = self.arrRentalForVehicles.isEmpty
                        }
                        
                        self.btnRegular(self.btnRegular!)
                        if self.btnRental.isSelected {
                            self.fillVehicleArrayWith(array: self.arrRentalForVehicles)
                        } else {
                            if self.arrNormalForVehicles.count == 0 && self.arrForRideShareVehicles.count > 0 && !self.btnRideShare.isHidden {
                                self.btnRegular.isHidden = true
                                self.btnShareRide(self.btnRideShare as Any)
                            } else {
                                self.btnRegular.isHidden = false
                                self.fillVehicleArrayWith(array: self.arrNormalForVehicles)
                            }
                        }
                        if !self.arrFinalForVehicles.isEmpty {
                            if self.isShowActiveView {
                                self.activeView()
                            }
                        } else {
                            if self.isShowActiveView {
                                self.activeView()
                            }
                        }
                        
                        //self.setTripBidding(response: vehicleListResponse)
                        
                    } else {
                        let isSuccess:ResponseModel = ResponseModel.init(fromDictionary: response)
                        let errorCode:String = "ERROR_CODE_" + String(isSuccess.errorCode )
                        self.lblNoServiceAvailable.text = errorCode.localized
                        if String(isSuccess.errorCode) == "1002" || String(isSuccess.errorCode ) == "1003" {
                            self.activeView()
                        } else if self.isShowActiveView {
                            self.activeView()
                        }
                    }
                }
            }
        }
    }

    func wsGetFareEstimate() {
        if !CurrentTrip.shared.selectedVehicle.id.isEmpty() && !CurrentTrip.shared.pickupAddress.isEmpty() && !CurrentTrip.shared.destinationtAddress.isEmpty() {
            var dictParam : [String : Any] = [:]
            self.checkSurgeTime(startHour: CurrentTrip.shared.selectedVehicle.surgeStartHour.toString(), endHour: CurrentTrip.shared.selectedVehicle.surgeEndHour.toString(), serverTime: CurrentTrip.shared.serverTime)
            dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
            dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
            dictParam[PARAMS.TIME] = (timeAndDistance.time.toInt()).toString()
            dictParam[PARAMS.DISTANCE] = timeAndDistance.distance
            dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
            dictParam[PARAMS.SERVICE_TYPE_ID] = CurrentTrip.shared.selectedVehicle.id
            dictParam[PARAMS.SURGE_MULTIPLIER] = CurrentTrip.shared.selectedVehicle.surgeMultiplier
            dictParam[PARAMS.DESTINATION_LATITUDE] = CurrentTrip.shared.destinationCoordinate.latitude.toString(places: 6)
            dictParam[PARAMS.DESTINATION_LONGITUDE] = CurrentTrip.shared.destinationCoordinate.longitude.toString(places: 6)
            dictParam[PARAMS.PICKUP_LATITUDE] = CurrentTrip.shared.pickupCoordinate.latitude.toString(places: 6)
            dictParam[PARAMS.PICKUP_LONGITUDE] = CurrentTrip.shared.pickupCoordinate.longitude.toString(places: 6)
            dictParam[PARAMS.IS_SURGE_HOURS] = CurrentTrip.shared.isSurgeHour ? TRUE : FALSE
            dictParam[PARAMS.IS_MULTIPLE_STOP] = self.arrLocations.count > 0 ? TRUE : FALSE
            

            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.GET_FARE_ESTIMATE, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
                if (error != nil)
                {} else {
                    if Parser.isSuccess(response: response) {
                        let fareEstimateResponse:FareEstimateResponse = FareEstimateResponse.init(fromDictionary: response)
                        CurrentTrip.shared.estimateFareTotal = fareEstimateResponse.estimatedFare
                        CurrentTrip.shared.estimateFareTime = fareEstimateResponse.time
                        CurrentTrip.shared.estimateFareDistance = fareEstimateResponse.distance
                        CurrentTrip.shared.tripType = fareEstimateResponse.tripType.toInt()
                        CurrentTrip.shared.is_use_distance_slot_calculation = fareEstimateResponse.is_use_distance_slot_calculation
                        CurrentTrip.shared.selected_slot = fareEstimateResponse.selected_slot
                        if CurrentTrip.shared.is_use_distance_slot_calculation {
                            self.lblFareEstimate.text = CurrentTrip.shared.selected_slot.base_price.toCurrencyString(currencyCode: CurrentTrip.shared.currencyCode)
                        } else {
                            self.lblFareEstimate.text = CurrentTrip.shared.estimateFareTotal.toCurrencyString(currencyCode: CurrentTrip.shared.currencyCode)
                        }
                    }
                }
            }
        }
    }
    
    @objc func handleUpdateSplitNotification() {
        self.updateSplitPayment()
    }

    @objc func wsGetNearByProvider()
    {
        if isNearByProviderCalled {
            //return
        }
        if preferenceHelper.getUserId().isEmpty {
            self.stopTripNearByProviderTimer()
        } else {
            self.isNearByProviderCalled = true
            var dictParam : [String : Any] = [:]
            if isShowActiveView {
                var selectedAccessibility:[String] = []
                var selectedGender:[String] = []
                if btnMale.isSelected
                {
                    selectedGender.append(Gender.MALE)
                }
                if btnFemale.isSelected
                {
                    selectedGender.append(Gender.FEMALE)
                }
                if isHotSpotSelected
                {
                    selectedAccessibility.append(VehicleAccessibity.HOTSPOT)
                }
                if isBabySeatSelected
                {
                    selectedAccessibility.append(VehicleAccessibity.BABY_SEAT)
                }
                if isHandicapSelected
                {
                    selectedAccessibility.append(VehicleAccessibity.HANDICAP)
                }
                dictParam[PARAMS.SERVICE_TYPE_ID] = CurrentTrip.shared.selectedVehicle.id
                
                var arrForSelectedProviderLanguage :[String] = []
                for language in arrForSelectedLanguages
                {
                    arrForSelectedProviderLanguage.append(language.id)
                }
                dictParam[PARAMS.PROVIDER_LANGUAGE] = arrForSelectedProviderLanguage
                dictParam[PARAMS.VEHICLE_ACCESSIBILITY] = selectedAccessibility
                dictParam[PARAMS.PROVIDER_GENDER] = selectedGender
                
                if paymentMode != PaymentMode.UNKNOWN
                {
                    dictParam[PARAMS.PAYMENT_MODE] = paymentMode
                }
                else
                {
                    dictParam[PARAMS.PAYMENT_MODE] = PaymentMode.CASH
                }
            }
            dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
            dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
            dictParam[PARAMS.LATITUDE] = CurrentTrip.shared.pickupCoordinate.latitude.toString(places: 6)
            dictParam[PARAMS.LONGITUDE] = CurrentTrip.shared.pickupCoordinate.longitude.toString(places: 6)
            dictParam[PARAMS.IS_MULTIPLE_STOP] = self.arrLocations.count > 0 ? TRUE : FALSE
            dictParam["is_women_trip"] = CurrentTrip.shared.user.gender_type == 0 ? false : true
            dictParam[PARAMS.is_ride_share] = type == 3 ? true : false
            
            if CurrentTrip.shared.destinationCoordinate.latitude != 0 {
                dictParam[PARAMS.DESTINATION_LATITUDE] = CurrentTrip.shared.destinationCoordinate.latitude.toString(places: 6)
            }
            
            if CurrentTrip.shared.destinationCoordinate.longitude != 0 {
                dictParam[PARAMS.DESTINATION_LONGITUDE] = CurrentTrip.shared.destinationCoordinate.longitude.toString(places: 6)
            }

            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.GET_NEAR_BY_PROVIDER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { [weak self] (response, error) -> (Void) in
                guard let self = self else {return}
                self.isNearByProviderCalled = false
                if (error != nil) {} else {
                    for marker in self.arrayForProviderMarker {
                        marker.map = nil
                    }
                    //self.unRegisterProviderSocket()
                    self.arrayForProviderMarker.removeAll()
                    if Parser.isSuccess(response: response,withSuccessToast:false,andErrorToast: false) {
                        let providerResponse:NearByProviderResponse = NearByProviderResponse.init(fromDictionary: response)
                        if self.isShowActiveView {
                            self.activeView()
                        }
                        if providerResponse.providers.count > 0 {
                            self.btnRideNow.isEnabled = true
                            self.btnRideNow.alpha = 1.0
                            self.updateRideNowButton()
                            self.registerAllProviderSocket(providers: providerResponse.providers)
                            if self.previousProviderId != providerResponse.providers[0].id {
                                self.previousProviderId = providerResponse.providers[0].id
                                if preferenceHelper.getIsShowEta() {
                                    LocationCenter.default.getTimeAndDistance(sourceCoordinate: CurrentTrip.shared.pickupCoordinate, destCoordinate: CLLocationCoordinate2D.init(latitude: providerResponse.providers[0].providerLocation[0], longitude:  providerResponse.providers[0].providerLocation[1]), multipleStops: self.arrLocations, tripMultipleStops: [], unit: "") { [weak self](time, distance) in
                                        guard let self = self else {return}
                                        let etaTime = (time.toInt())/60
                                        self.lblEta.text = "TXT_ETA".localized + " : " + etaTime.toString() + MeasureUnit.MINUTES
                                    }
                                }
                            }
                        } else {
                            self.lblEta.text = "TXT_ETA".localized + " : " + 0.toString() + MeasureUnit.MINUTES
                            self.previousProviderId = "";
                            self.updateRideNowButton()
                            self.btnRideNow.isEnabled = false
                            self.btnRideNow.alpha = 0.5
                        }
                        self.updateEtaUI()
                    } else {
                        self.previousProviderId = "";
                        self.lblEta.text = "TXT_ETA".localized + " : " + 0.toString() + MeasureUnit.MINUTES
                        self.btnRideNow.isEnabled = false
                        self.btnRideNow.alpha = 0.5
                        if self.isShowActiveView {
                            self.activeView()
                        }
                    }
                }
            }
        }
    }

    func wsCreateRequest() {
        
        Utility.showLoading()
        
        var selectedAccessibility:[String] = []
        if isHotSpotSelected {
            selectedAccessibility.append(VehicleAccessibity.HOTSPOT)
        }
        if isBabySeatSelected {
            selectedAccessibility.append(VehicleAccessibity.BABY_SEAT)
        }
        if isHandicapSelected {
            selectedAccessibility.append(VehicleAccessibity.HANDICAP)
        }

        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.SERVICE_TYPE_ID] = CurrentTrip.shared.selectedVehicle.id
        dictParam[PARAMS.LATITUDE] = CurrentTrip.shared.pickupCoordinate.latitude.toString(places: 6)
        dictParam[PARAMS.LONGITUDE] = CurrentTrip.shared.pickupCoordinate.longitude.toString(places: 6)
        dictParam[PARAMS.TRIP_PICKUP_ADDRESS] = CurrentTrip.shared.pickupAddress
        
        if !CurrentTrip.shared.destinationtAddress.isEmpty() {
            dictParam[PARAMS.TRIP_DESTINATION_LATITUDE] = CurrentTrip.shared.destinationCoordinate.latitude.toString(places: 6)
            dictParam[PARAMS.TRIP_DESTINATION_LONGITUDE] = CurrentTrip.shared.destinationCoordinate.longitude.toString(places: 6)
            dictParam[PARAMS.TRIP_DESTINATION_ADDRESS] = CurrentTrip.shared.destinationtAddress
        }

        var destAddress : [[String:Any]] = []
        
        for destAdd in self.arrLocations {
            var tempDict : [String:Any] = [:]
            var tempArr : [String] = []
            tempDict[PARAMS.ADDRESS] = destAdd.address
            tempArr.append(destAdd.latitude.toString(places: 6))
            tempArr.append(destAdd.longitude.toString(places: 6))
            tempDict[PARAMS.TRIP_LOCATION] = tempArr
            destAddress.append(tempDict)
        }
        
        var languageArray: [String] = []
        for newLanguage in arrForSelectedLanguages {
            languageArray.append(newLanguage.id)
        }
        
        dictParam[PARAMS.TRIP_DESTINATION_ADDRESSES] = destAddress
        
        dictParam[PARAMS.PROVIDER_LANGUAGE] = languageArray
        dictParam[PARAMS.VEHICLE_ACCESSIBILITY] = selectedAccessibility
        dictParam[PARAMS.IS_SURGE_HOURS] = CurrentTrip.shared.isSurgeHour ? TRUE :FALSE
        dictParam[PARAMS.SURGE_MULTIPLIER] = CurrentTrip.shared.selectedVehicle.surgeMultiplier
        
        dictParam[PARAMS.IS_FIXED_FARE] = isBidTrip ? true : (CurrentTrip.shared.isFixedFareTrip ? TRUE :FALSE)
        dictParam[PARAMS.TIMEZONE] = CurrentTrip.shared.timeZone
        dictParam["is_women_trip"] = CurrentTrip.shared.user.gender_type == 0 ? false : true

        if CurrentTrip.shared.isFixedFareTrip {
            dictParam[PARAMS.FIXED_PRICE] = CurrentTrip.shared.estimateFareTotal
        } else {
            dictParam[PARAMS.FIXED_PRICE] = 0.0
        }

        if btnCorporatePay.isSelected && viewCoporate.isHidden == false {
            dictParam[PARAMS.TRIP_TYPE] = TripType.CORPORATE
        }

        dictParam[PARAMS.PROVIDER_GENDER] = []
        if paymentMode != PaymentMode.UNKNOWN {
            dictParam[PARAMS.PAYMENT_MODE] = paymentMode
        } else {
            dictParam[PARAMS.PAYMENT_MODE] = PaymentMode.CASH
        }
        dictParam[PARAMS.PROMO_ID] = self.promoId
        
        //trip bidding param sent
        dictParam[PARAMS.is_trip_bidding] = isBidTrip
        dictParam[PARAMS.is_user_can_set_bid_price] = btnCheckBiding.tag == 1 ? true : false
        dictParam[PARAMS.ESTIMATE_TIME] = CurrentTrip.shared.estimateFareTime
        dictParam[PARAMS.ESTIMATE_DISTANCE] = CurrentTrip.shared.estimateFareDistance
        dictParam[PARAMS.GOOGLE_PICKUP_LOCATION_TO_DESTINATION_LOCATION] = routString
        if CurrentTrip.shared.is_use_distance_slot_calculation {
            do {
                // Convert the dictionary to Data
                let jsonData = try JSONSerialization.data(withJSONObject: CurrentTrip.shared.selected_slot.toDictionary(), options: [])

                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                    dictParam["selected_zone_slot"] = jsonString
                } else {
                    dictParam["selected_zone_slot"] = "{}"
                    print("Failed to convert data to JSON string.")
                }
            } catch {
                dictParam["selected_zone_slot"] = ""
                print("Error converting dictionary to JSON string:", error)
            }
        } else {
            dictParam["selected_zone_slot"] = "{}"
        }

        if btnCheckBiding.tag == 1 && bidPrice > 0 {
            dictParam[PARAMS.bid_price] = bidPrice
        } else {
            dictParam[PARAMS.bid_price] = CurrentTrip.shared.estimateFareTotal
        }

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.CREATE_TRIP, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                let responseModel:ResponseModel = ResponseModel.init(fromDictionary: response)
                if Parser.isSuccess(response: response) {
                    let createTripResponse:CreateTripRespose = CreateTripRespose.init(fromDictionary: response)
                    CurrentTrip.shared.tripId = createTripResponse.tripId
                    self.wsGetTripStatus()
                    self.startTripStatusTimer()
                    self.stopTripNearByProviderTimer()
                    self.openDriverDetailDialog()
                } else if responseModel.errorCode == ERROR_PAYMENT_PENDING {
                    self.openAddWalletAmountDialog()
                } else {
                    
                    if responseModel.errorCode == TRIP_IS_ALREADY_RUNNING {
                        self.wsGetTripStatus()
                    }
                    Utility.hideLoading()
                }
            }
        }
    }

    func wsCreateRentRequest() {
        Utility.showLoading()
        var selectedAccessibility:[String] = []
        if isHotSpotSelected
        {
            selectedAccessibility.append(VehicleAccessibity.HOTSPOT)
        }
        if isBabySeatSelected
        {
            selectedAccessibility.append(VehicleAccessibity.BABY_SEAT)
        }
        if isHandicapSelected
        {
            selectedAccessibility.append(VehicleAccessibity.HANDICAP)
        }

        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.SERVICE_TYPE_ID] = CurrentTrip.shared.selectedVehicle.id
        dictParam[PARAMS.CAR_RENTAL_ID] = CurrentTrip.shared.selectedVehicle.selectedCarRentelId
        dictParam[PARAMS.LATITUDE] = CurrentTrip.shared.pickupCoordinate.latitude.toString(places: 6)
        dictParam[PARAMS.LONGITUDE] = CurrentTrip.shared.pickupCoordinate.longitude.toString(places: 6)
        dictParam[PARAMS.TRIP_PICKUP_ADDRESS] = CurrentTrip.shared.pickupAddress
        
        if !CurrentTrip.shared.destinationtAddress.isEmpty() {
            dictParam[PARAMS.TRIP_DESTINATION_LATITUDE] = CurrentTrip.shared.destinationCoordinate.latitude.toString(places: 6)
            dictParam[PARAMS.TRIP_DESTINATION_LONGITUDE] = CurrentTrip.shared.destinationCoordinate.longitude.toString(places: 6)
            dictParam[PARAMS.TRIP_DESTINATION_ADDRESS] = CurrentTrip.shared.destinationtAddress
        }

        var languageArray: [String] = []
        for newLanguage in arrForSelectedLanguages {
            languageArray.append(newLanguage.id)
        }
        dictParam[PARAMS.PROVIDER_LANGUAGE] = languageArray
        dictParam[PARAMS.VEHICLE_ACCESSIBILITY] = selectedAccessibility
        dictParam[PARAMS.IS_SURGE_HOURS] = FALSE
        dictParam[PARAMS.IS_FIXED_FARE] = FALSE
        dictParam[PARAMS.TIMEZONE] = CurrentTrip.shared.timeZone
        dictParam[PARAMS.FIXED_PRICE] = 0.0
        if btnCorporatePay.isSelected && viewCoporate.isHidden == false
        {
            dictParam[PARAMS.TRIP_TYPE] = TripType.CORPORATE
        }
        dictParam[PARAMS.PROVIDER_GENDER] = []
        if paymentMode != PaymentMode.UNKNOWN
        {
            dictParam[PARAMS.PAYMENT_MODE] = paymentMode
        }
        else
        {
            dictParam[PARAMS.PAYMENT_MODE] = PaymentMode.CASH
        }
        dictParam[PARAMS.PROMO_ID] = self.promoId
        dictParam[PARAMS.ESTIMATE_TIME] = CurrentTrip.shared.estimateFareTime
        dictParam[PARAMS.ESTIMATE_DISTANCE] = CurrentTrip.shared.estimateFareDistance
        dictParam[PARAMS.GOOGLE_PICKUP_LOCATION_TO_DESTINATION_LOCATION] = routString
        dictParam["is_women_trip"] = CurrentTrip.shared.user.gender_type == 0 ? false : true
        if CurrentTrip.shared.is_use_distance_slot_calculation {
            do {
                // Convert the dictionary to Data
                let jsonData = try JSONSerialization.data(withJSONObject: CurrentTrip.shared.selected_slot.toDictionary(), options: [])

                // Convert the Data to a JSON string
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    // Use the JSON string as needed
                    print(jsonString)
                    dictParam["selected_zone_slot"] = jsonString
                } else {
                    dictParam["selected_zone_slot"] = ""
                    print("Failed to convert data to JSON string.")
                }
            } catch {
                dictParam["selected_zone_slot"] = ""
                print("Error converting dictionary to JSON string:", error)
            }
        } else {
            dictParam["selected_zone_slot"] = "{}"
        }
        Utility.hideLoading()
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.CREATE_TRIP, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil)
            {
                Utility.hideLoading()
            }
            else
            {
                let responseModel:ResponseModel = ResponseModel.init(fromDictionary: response)
                if Parser.isSuccess(response: response)
                {
                    let createTripResponse:CreateTripRespose = CreateTripRespose.init(fromDictionary: response)
                    
                    CurrentTrip.shared.tripId = createTripResponse.tripId
                    CurrentTrip.shared.tripStaus = TripStatusResponse.init(fromDictionary: [:])
                    
                    CurrentTrip.shared.tripStaus.trip.providerId = createTripResponse.providerId
                    CurrentTrip.shared.tripStaus.trip.providerFirstName = createTripResponse.firstName
                    CurrentTrip.shared.tripStaus.trip.providerLastName = createTripResponse.lastName
                    self.wsGetTripStatus()
                    self.startTripStatusTimer()
                    self.stopTripNearByProviderTimer()
                    self.openDriverDetailDialog()
                } else if responseModel.errorCode == ERROR_PAYMENT_PENDING {
                    self.openAddWalletAmountDialog()
                }
                else
                {
                    
                    if responseModel.errorCode == TRIP_IS_ALREADY_RUNNING
                    {
                        self.wsGetTripStatus()
                    }
                    Utility.hideLoading()
                }
            }
        }
    }

    func wsCreateFutureRequest()
    {
        var selectedAccessibility:[String] = []
        if isHotSpotSelected
        {
            selectedAccessibility.append(VehicleAccessibity.HOTSPOT)
        }
        if isBabySeatSelected
        {
            selectedAccessibility.append(VehicleAccessibity.BABY_SEAT)
        }
        if isHandicapSelected
        {
            selectedAccessibility.append(VehicleAccessibity.HANDICAP)
        }
        
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.SERVICE_TYPE_ID] = CurrentTrip.shared.selectedVehicle.id
        dictParam[PARAMS.LATITUDE] = CurrentTrip.shared.pickupCoordinate.latitude.toString(places: 6)
        dictParam[PARAMS.LONGITUDE] = CurrentTrip.shared.pickupCoordinate.longitude.toString(places: 6)
        dictParam[PARAMS.TRIP_PICKUP_ADDRESS] = CurrentTrip.shared.pickupAddress
        
        if !CurrentTrip.shared.destinationtAddress.isEmpty() {
            dictParam[PARAMS.TRIP_DESTINATION_LATITUDE] = CurrentTrip.shared.destinationCoordinate.latitude.toString(places: 6)
            dictParam[PARAMS.TRIP_DESTINATION_LONGITUDE] = CurrentTrip.shared.destinationCoordinate.longitude.toString(places: 6)
            dictParam[PARAMS.TRIP_DESTINATION_ADDRESS] = CurrentTrip.shared.destinationtAddress
        }

        var destAddress : [[String:Any]] = []
        
        for destAdd in self.arrLocations {
            var tempDict : [String:Any] = [:]
            var tempArr : [String] = []
            tempDict[PARAMS.ADDRESS] = destAdd.address
            tempArr.append(destAdd.latitude.toString(places: 6))
            tempArr.append(destAdd.longitude.toString(places: 6))
            tempDict[PARAMS.TRIP_LOCATION] = tempArr
            destAddress.append(tempDict)
        }
        
        var languageArray: [String] = []
        for newLanguage in arrForSelectedLanguages {
            languageArray.append(newLanguage.id)
        }
        
        dictParam[PARAMS.TRIP_DESTINATION_ADDRESSES] = destAddress
        dictParam[PARAMS.PROVIDER_LANGUAGE] = languageArray
        dictParam[PARAMS.VEHICLE_ACCESSIBILITY] = selectedAccessibility
        dictParam[PARAMS.IS_SURGE_HOURS] = CurrentTrip.shared.isSurgeHour ? TRUE :FALSE
        dictParam[PARAMS.SURGE_MULTIPLIER] = CurrentTrip.shared.selectedVehicle.surgeMultiplier
        dictParam[PARAMS.IS_FIXED_FARE] = CurrentTrip.shared.isFixedFareTrip ? TRUE :FALSE
        dictParam[PARAMS.TIMEZONE] = CurrentTrip.shared.timeZone
        dictParam[PARAMS.START_TIME] = Utility.timeInterval(date: futureTripSelectedDate ?? Date()).toString()
        dictParam[PARAMS.FIXED_PRICE] = CurrentTrip.shared.estimateFareTotal
        dictParam[PARAMS.PROVIDER_GENDER] = []
        
        if btnCorporatePay.isSelected && viewCoporate.isHidden == false
        {
            dictParam[PARAMS.TRIP_TYPE] = TripType.CORPORATE
        }

        if paymentMode != PaymentMode.UNKNOWN
        {
            dictParam[PARAMS.PAYMENT_MODE] = paymentMode
        }
        else
        {
            dictParam[PARAMS.PAYMENT_MODE] = PaymentMode.CASH
        }
        dictParam[PARAMS.PROMO_ID] = self.promoId
        dictParam[PARAMS.ESTIMATE_TIME] = CurrentTrip.shared.estimateFareTime
        dictParam[PARAMS.ESTIMATE_DISTANCE] = CurrentTrip.shared.estimateFareDistance
        dictParam[PARAMS.GOOGLE_PICKUP_LOCATION_TO_DESTINATION_LOCATION] = routString
        dictParam["is_women_trip"] = CurrentTrip.shared.user.gender_type == 0 ? false : true
        if CurrentTrip.shared.is_use_distance_slot_calculation {
            do {
                // Convert the dictionary to Data
                let jsonData = try JSONSerialization.data(withJSONObject: CurrentTrip.shared.selected_slot.toDictionary(), options: [])

                // Convert the Data to a JSON string
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    // Use the JSON string as needed
                    print(jsonString)
                    dictParam["selected_zone_slot"] = jsonString
                } else {
                    dictParam["selected_zone_slot"] = ""
                    print("Failed to convert data to JSON string.")
                }
            } catch {
                dictParam["selected_zone_slot"] = ""
                print("Error converting dictionary to JSON string:", error)
            }
        } else {
            dictParam["selected_zone_slot"] = "{}"
        }
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.CREATE_TRIP, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil)
            {
                Utility.hideLoading()
            }
            else
            {
                let responseModel:ResponseModel = ResponseModel.init(fromDictionary: response)
                if Parser.isSuccess(response: response,withSuccessToast: true,andErrorToast: true)
                {
                    Utility.hideLoading()
                    self.arrLocations = []
                    self.idealView()
                } else if responseModel.errorCode == ERROR_PAYMENT_PENDING {
                    self.openAddWalletAmountDialog()
                } else {
                    
                    if responseModel.errorCode == TRIP_IS_ALREADY_RUNNING
                    {
                        self.wsGetTripStatus()
                    }
                    Utility.hideLoading()
                }
            }
        }
    }

    func wsGetProviderDetail(id:String)
    {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.PROVIDER_ID] = id

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_PROVIDER_DETAIL, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        {  (response, error) -> (Void) in
            if (error != nil)
            {
                Utility.hideLoading()
            }
            else
            {
                if Parser.isSuccess(response: response)
                {
                    let providerResponse :ProviderResponse = ProviderResponse.init(fromDictionary: response)
                    CurrentTrip.shared.tripStaus.trip.providerRate = providerResponse.provider.rate
                    CurrentTrip.shared.providerPicture = providerResponse.provider.picture
                    self.openDriverDetailDialog()
                }
            }
        }
    }

    func fillVehicleArrayWith(array:[Citytype])
    {
        arrFinalForVehicles.removeAll()
        for type in array
        {
            arrFinalForVehicles.append(type)
        }
        if !self.arrFinalForVehicles.isEmpty
        {
            var isDefaultFound:Bool = false
            for index in 0...(self.arrFinalForVehicles.count - 1)
            {
                if self.arrFinalForVehicles[index].typeDetails.isDefaultSelected
                {
                    isDefaultFound = true
                    selectedIndex = index
                    CurrentTrip.shared.selectedVehicle = self.arrFinalForVehicles[index]
                    break
                }
            }
            if isDefaultFound == false
            {
                selectedIndex = Int(Double((arrFinalForVehicles.count)/2).rounded(.down))
                CurrentTrip.shared.selectedVehicle = self.arrFinalForVehicles[selectedIndex]
            }
            self.wsGetFareEstimate()
        }

        if btnRental.isSelected
        {
            lblRentalPackSize.text = CurrentTrip.shared.selectedVehicle.carRentalList.count.toString()
        }
        Utility.hideLoading()
        collectionViewForServices.reloadData()
        self.scrollToSelectService()
    }

    func wsAcceptRejectCorporateRequest(accept:Bool)
    {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.CORPORATE_ID] = CurrentTrip.shared.user.corporateDetail.id
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.IS_ACCEPTED] = accept
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.USER_ACCEPT_REJECT_CORPORATE_REQUEST, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        { /*[unowned self]*/ (response, error) -> (Void) in
            Utility.hideLoading()
            if (error != nil)
            {
                Utility.hideLoading()
            }
            else
            {
                if Parser.isSuccess(response: response)
                {
                    CurrentTrip.shared.user.corporateDetail = CorporateDetail.init(fromDictionary: [:])
                }
            }
        }
    }

    @objc func wsGetTripStatus()
    {
        if !isNoRouteFound{
            var dictParam : [String : Any] = [:]
            dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
            dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
            
            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.CHECK_TRIP_STATUS, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { [weak self] (response, error) -> (Void) in
                guard let self = self else { return }
                if (error != nil) {
                    Utility.hideLoading()
                }
                else {
                    if Parser.isSuccess(response: response,withSuccessToast: false,andErrorToast: false) {
                        CurrentTrip.shared.tripStaus = TripStatusResponse.init(fromDictionary: response)
                        CurrentTrip.shared.tripId = CurrentTrip.shared.tripStaus.trip.id
                        CurrentTrip.shared.isCardModeAvailable = CurrentTrip.shared.tripStaus.cityDetail.isPaymentModeCard
                        CurrentTrip.shared.isCashModeAvailable = CurrentTrip.shared.tripStaus.cityDetail.isPaymentModeCash
                        if CurrentTrip.shared.tripStaus.trip.isProviderAccepted == TRUE {
                            self.stopTripStatusTimer()
                            if self.dialogFromDriverDetail != nil {
                                self.dialogFromDriverDetail?.removeFromSuperview()
                                self.dialogFromDriverDetail = nil
                            }
                            APPDELEGATE.gotoTrip()
                            return
                        }
                        else {
                            if CurrentTrip.shared.tripStaus.trip.bids.count > 0 {
                                self.openTripBidList()
                                self.dialogFromDriverDetail = nil
                                CustomDriverDetailDialog.remove()
                            } else {
                                AcceptedBidTrips.remove()
                                self.openDriverDetailDialog()
                            }
                            self.startTripStatusTimer()
                        }
                        Utility.hideLoading()
                    }
                    else {
                        Utility.hideLoading()
                        self.dialogFromDriverDetail?.removeFromSuperview()
                        self.dialogFromDriverDetail = nil
                        AcceptedBidTrips.remove()
                        if !CurrentTrip.shared.tripId.isEmpty() {
                            self.arrLocations = []
                            self.idealView()
                            self.stopTripStatusTimer()
                            CurrentTrip.shared.clearTripData()
                            self.startCurrentLocation()
                        }
                    }
                }
            }
        }
    }

    func wsCancelTrip()
    {
        if !CurrentTrip.shared.tripStaus.trip.id.isEmpty()
        {
            Utility.showLoading()
            var dictParam : [String : Any] = [:]
            dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
            dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
            dictParam[PARAMS.TRIP_ID] = CurrentTrip.shared.tripStaus.trip.id
            dictParam[PARAMS.CANCEL_TRIP_REASON] = ""

            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.CANCEL_TRIP, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
                Utility.hideLoading()
                if Parser.isSuccess(response: response)
                {
                    self.dialogFromDriverDetail?.removeFromSuperview()
                    self.dialogFromDriverDetail = nil
                    self.arrLocations = []
                    self.idealView()
                    self.stopTripStatusTimer()
                    CurrentTrip.shared.clearTripData()
                    self.arrLocations = []
                    self.startCurrentLocation()
                    Utility.hideLoading()
                    AcceptedBidTrips.remove()
                }
                else
                {
                    self.stopTripStatusTimer()
                }
            }
        }
        else
        {
            self.dialogFromDriverDetail?.removeFromSuperview()
            self.dialogFromDriverDetail = nil
            self.arrLocations = []
            self.idealView()
            self.stopTripStatusTimer()
        }
    }

    func showPathFrom(source:CLLocationCoordinate2D, toDestination destination:CLLocationCoordinate2D)
    {
        pickupMarker.position = source
        destinationMarker.position = destination

        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(self.pickupMarker.position)
        bounds = bounds.includingCoordinate(self.destinationMarker.position)
        
        for obj in arrLocations {
            bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: obj.latitude, longitude: obj.longitude))
        }

        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock {}

        self.mapView.animate(with: GMSCameraUpdate.fit(bounds))
        CATransaction.commit()
        if destination.latitude == 0.0 && destination.longitude == 0.0 {
            let camera = GMSCameraPosition.camera(withTarget: source, zoom: 17.0, bearing: 45, viewingAngle: 0.0)
            self.mapView?.animate(to: camera)
            self.pickupMarker.position = source
        }
        
        if !isSourceToDestPathDrawn && preferenceHelper.getIsPathdraw() {
            isSourceToDestPathDrawn = true
            setPath(source: source, toDestination: destination)
        }
    }
    
    func setPath(source:CLLocationCoordinate2D, toDestination destination:CLLocationCoordinate2D) {
        let saddr = "\(source.latitude),\(source.longitude)"
        let daddr = "\(destination.latitude),\(destination.longitude)"
        
        var waypoints = ""
        for i in 0..<arrLocations.count {
            let add = arrLocations[i]
            if i != 0 {
                waypoints = waypoints + "|\(add.latitude ?? 0.0),\(add.longitude ?? 0.0)"
            }
            else {
                waypoints = "\(add.latitude ?? 0.0),\(add.longitude ?? 0.0)"
            }
        }
        
        var apiUrlStr = Google.DIRECTION_URL +  "\(saddr)&destination=\(daddr)&key=\(preferenceHelper.getGoogleKey())"
        if arrLocations.count > 0 {
            apiUrlStr = Google.DIRECTION_URL +  "\(saddr)&waypoints=\(waypoints)&destination=\(daddr)&key=\(preferenceHelper.getGoogleKey())"
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        guard let url =  URL(string: apiUrlStr) else {
            return
        }
        do {
            print("JD DIRECTION API CALLED")
            DispatchQueue.main.async {
                session.dataTask(with: url) { [weak self] (data, response, error) in
                    guard data != nil else {
                        return
                    }
                    do {
                        let route = try JSONDecoder().decode(MapPath.self, from: data!)
                        let stringRoute = String.init(data: data!, encoding: .utf8) ?? ""
                        self?.routString = stringRoute
                        if let points = route.routes?.first?.overview_polyline?.points {
                            self?.drawPath(with: points)
                        }
                    } catch let error {
                        printE("Failed to draw ",error.localizedDescription)
                    }
                }.resume()
            }
        }
    }

    private func drawPath(with points : String) {
        DispatchQueue.main.async { [unowned self] in
            if self.polyLinePath.map != nil
            {
                self.polyLinePath.map = nil
            }
            let path = GMSPath(fromEncodedPath: points)
            self.polyLinePath = GMSPolyline(path: path)
            self.polyLinePath.strokeColor = UIColor.themeGooglePathColor
            self.polyLinePath.strokeWidth = 5.0
            self.polyLinePath.geodesic = true
            self.polyLinePath.map = self.mapView
        }
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        pickupMarker.infoWindowAnchor = CGPoint(x: 0.0, y: 0.0)
        pickupMarker.appearAnimation = .pop
    }
    
    func pickupAddressSet() {
        lblPickupAddress.text = CurrentTrip.shared.pickupAddress
        lblDestinationAddress.text = CurrentTrip.shared.destinationtAddress
        
        if !preferenceHelper.getIsAllowMultipleStop() || arrLocations.count >= preferenceHelper.getMultipleStopCount() {
            self.viewAddStops.isHidden = true
        } else {
            self.viewAddStops.isHidden = false
        }
        
        self.arrLocations = CurrentTrip.shared.arrStopLocations
        self.btnRental.isHidden = self.arrLocations.count > 0 ? true : false
        self.tblHeight.constant = CGFloat(self.arrLocations.count * 30)
        self.tblMultipleStops.reloadData()
        
        isShowActiveView = true
        self.previousProviderId = ""
        isSourceToDestPathDrawn = false
        
        if CurrentTrip.shared.destinationtAddress.isEmpty() {
            lblFareEstimate.text = "--"
            destinationMarker.map = nil
            polyLinePath.map = nil
            lblDestinationAddress.text = "TXT_DESTINATION_ADDRESS".localized//"TXT_DESTINATION_ADDRESS_PLACE_HOLDER".localized
            lblDestinationAddress.textColor = UIColor.themeLightTextColor
        } else {
            lblDestinationAddress.textColor = UIColor.themeTextColor
        }
        
        if !lblPickupAddress.text!.isEmpty {
            checkForAvailableService()
        }
        
        setMarkers()
        self.getTimeDistance()
    }

    func destinationAddressSet() {
        lblPickupAddress.text = CurrentTrip.shared.pickupAddress
        lblDestinationAddress.text = CurrentTrip.shared.destinationtAddress
        
        if !preferenceHelper.getIsAllowMultipleStop() || arrLocations.count >= preferenceHelper.getMultipleStopCount() || CurrentTrip.shared.destinationtAddress.isEmpty() {
            self.viewAddStops.isHidden = true
        } else {
            self.viewAddStops.isHidden = false
        }
        
        self.arrLocations = CurrentTrip.shared.arrStopLocations
        
        self.btnRental.isHidden = self.arrLocations.count > 0 ? true : false
        
        self.tblHeight.constant = CGFloat(self.arrLocations.count * 30)
        self.tblMultipleStops.reloadData()
        
        isShowActiveView = true
        isSourceToDestPathDrawn = false
        if CurrentTrip.shared.destinationtAddress.isEmpty() {
            lblFareEstimate.text = "--"
            destinationMarker.map = nil
            polyLinePath.map = nil
            lblDestinationAddress.text = "TXT_DESTINATION_ADDRESS".localized//"TXT_DESTINATION_ADDRESS_PLACE_HOLDER".localized
            lblDestinationAddress.textColor = UIColor.themeLightTextColor
            btnRideShare.isHidden = true
        } else {
            if let vehicleListResponse = vehicleListResponse {
                setTripBidding(response: vehicleListResponse)
            }
            lblDestinationAddress.textColor = UIColor.themeTextColor
        }
        checkForAvailableService()
        self.setMarkers()
        self.getTimeDistance()
    }

    func getTimeDistance() {
        LocationCenter.default.getTimeAndDistance(sourceCoordinate: CurrentTrip.shared.pickupCoordinate, destCoordinate: CurrentTrip.shared.destinationCoordinate, multipleStops: self.arrLocations, tripMultipleStops: [], unit: "") { [weak self] (time, distance) in
            guard let self = self else {return}
            self.timeAndDistance = (time,distance)
            if (self.timeAndDistance.time != "0" && self.timeAndDistance.distance != "0")
            {
                self.isNoRouteFound = false
                self.wsGetFareEstimate()
            }
            else if (self.timeAndDistance.time == "0" && self.timeAndDistance.distance == "0")
            {
                self.isNoRouteFound = true
            }
        }
    }
    func checkRoute()
    {
        if (self.timeAndDistance.time == "0" && self.timeAndDistance.distance == "0")
        {
            Utility.showToast(message: "No route could be found between the origin and destination.")
            //activeView()
            //activeView()
            hideBottomView()
            viewLocationButton.isHidden = true
            isShowActiveView = true
        }
    }
}

//Bottom Animation

private enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

extension MapVC
{
    func hideBottomView()
    {
        if self.isViewDidLoad {
            self.isViewDidLoad = false            
            self.viewForAvailableService.isHidden = true
            self.stkFavouriteAddress.isHidden = false
            return
        }

        let state = currentState.opposite
        let transitionAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations:
        {
            if self.bottomConstraint.constant != -self.viewForAvailableService.frame.height
            {
                self.bottomConstraint.constant = -self.viewForAvailableService.frame.height
            }
            self.view.layoutIfNeeded()
        })

        transitionAnimator.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            @unknown default:
                printE("")
            }

            if self.bottomConstraint.constant != -self.viewForAvailableService.frame.height
            {
                self.bottomConstraint.constant = -self.viewForAvailableService.frame.height
            }
            
            self.view.layoutIfNeeded()
            self.viewForAvailableService.isHidden = true
            self.stkFavouriteAddress.isHidden = false
        }
        transitionAnimator.startAnimation()
    }

    func showBottomView()
    {
        viewForAvailableService.isHidden = false
        
        let state = currentState.opposite
        let transitionAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations:
        {
            if self.bottomConstraint.constant != 0
            {
                self.bottomConstraint.constant = 0
            }
            
            self.view.layoutIfNeeded()
        })
        
        transitionAnimator.addCompletion { [weak self] position in
            guard let self = self else { return }
            switch position {
            case .start:
                self.currentState = state.opposite
                
            case .end:
                self.currentState = state
            case .current:
                ()
            @unknown default:
                printE("")
            }

            if self.bottomConstraint.constant != 0

            {
                self.bottomConstraint.constant = 0

            }
            
            self.view.layoutIfNeeded()
        }
        transitionAnimator.startAnimation()
    }

    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state
        {
        case .changed:
            let translation = recognizer.translation(in: viewForAvailableService)
            let yVelocity = recognizer.velocity(in: viewForAvailableService).y
            
            if yVelocity > 0 && self.bottomConstraint.constant >= 0
            {
                self.bottomConstraint.constant += translation.y;
            }
            else if yVelocity <= 0 && self.bottomConstraint.constant <= viewForAvailableService.frame.size.height
            {
                self.bottomConstraint.constant += translation.y;
            }

        case .ended:
            let yVelocity = recognizer.velocity(in: viewForAvailableService).y
            let shouldClose = yVelocity > 0
            if shouldClose
            {
                let transitionAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations:
                {
                    if self.bottomConstraint.constant != -self.viewForAvailableService.frame.height
                    {
                        self.bottomConstraint.constant = -self.viewForAvailableService.frame.height
                    }
                    
                    self.view.layoutIfNeeded()
                    
                })
                transitionAnimator.addCompletion { position in
                    self.onClickBtnBack(self.btnBack!)
                }
                transitionAnimator.startAnimation()
            }
            else
            {
                let transitionAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations:
                {
                    if self.bottomConstraint.constant != 0
                    {
                        self.bottomConstraint.constant = 0
                    }
                    self.view.layoutIfNeeded()
                })
                transitionAnimator.startAnimation()
            }

        default:
            ()
        }
    }
}

class PaymentSelectionCell: UITableViewCell {
    
    @IBOutlet weak var lblPaymentMethodType: UILabel!
    @IBOutlet weak var iconCash: UIImageView!
    
    class var className : String { return "PaymentSelectionCell" }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
