//
//  TripVC.swift
//  Eber
//
//  Created by Elluminati on 29/09/18.
//  Copyright © 2018 Elluminati. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import AVFoundation
import Stripe

class TripVC: BaseVC, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnProviderRate: UIButton!
    
    //Address View
    @IBOutlet weak var viewForAddresses: UIView!
    @IBOutlet weak var lblPickupAddress: UILabel!
    @IBOutlet weak var btnPickupAddress: UIButton!
    @IBOutlet weak var lblDestinationAddress: UILabel!
    @IBOutlet weak var btnDestinationAddress: UIButton!
    
    @IBOutlet weak var tblMultipleStops: UITableView!
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var viewForDriver: UIView!
    @IBOutlet weak var btnPromoCode: UIButton!
    @IBOutlet weak var viewForDriverContact: UIView!
    @IBOutlet weak var imgDriverPic: UIImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    
    @IBOutlet weak var btnCancelTrip: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnSos: UIButton!
    
    @IBOutlet weak var lblCarIdOrTotalTime: UILabel!
    @IBOutlet weak var lblCarIdOrTotalTimeValue: UILabel!
    @IBOutlet weak var lblPlatNoOrTotalDistance: UILabel!
    @IBOutlet weak var lblPlatNoOrTotalDistanceValue: UILabel!
    @IBOutlet weak var lblTripNo: UILabel!
    @IBOutlet weak var lblVehical: UILabel!
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var lblTripNoValue: UILabel!
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var lblTotalDistance: UILabel!
    var strProviderId:String = ""
    
    @IBOutlet weak var stkWaitTime: UIStackView!
    @IBOutlet weak var lblWaitingTimeValue: UILabel!
    @IBOutlet weak var lblWaitingTime: UILabel!
    
    /*ViewForPayment*/
    @IBOutlet weak var viewForSelectedPayment: UIView!
    @IBOutlet weak var imgSelectedPayment: UIImageView!
    @IBOutlet weak var lblPaymentIcon: UILabel!
    @IBOutlet weak var lblSelectedPayment: UILabel!
    @IBOutlet weak var selectedPaymentBackground: UIView!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var imgChat: UIImageView!
    @IBOutlet weak var imgChatNotification: UIImageView!
    @IBOutlet weak var btnMyLocation: UIButton!
    @IBOutlet weak var imgMyLocation: UIImageView!
    
    @IBOutlet weak var btnSplitPayment: UIButton!
    @IBOutlet weak var viewSplitPayment: UIView!
    
    @IBOutlet weak var stackTripDetail: UIStackView!
    
    @IBOutlet weak var stkViewGetCode: UIStackView!
    @IBOutlet weak var btnGetCode: UIButton!
    @IBOutlet weak var stkViewTotalDistance: UIView!
    @IBOutlet weak var constraintHeightDistamnce: NSLayoutConstraint!
    @IBOutlet weak var constraintXSplitpsayment: NSLayoutConstraint!
    
    @IBOutlet weak var viewMyLocation: UIView!
    @IBOutlet weak var viewPromoCode : UIStackView!
    var providerMarker:GMSMarker!
    var pickupMarker:GMSMarker!
    var destinationMarker:GMSMarker!
    var onGoingTrip:Trip = Trip.init(fromDictionary: [:])
    var provider:Provider = Provider.init(fromDictionary: [:])
    var providerCurrentStatus:TripStatus = TripStatus.Unknown
    var providerNextStatus:TripStatus = TripStatus.Unknown
    var polyLinePath:GMSPolyline!
    var polyLineCurrentProviderPath:GMSPolyline!;
    var currentProviderPath:GMSMutablePath!
    var previousDriverLatLong:CLLocationCoordinate2D = CLLocationCoordinate2D.init()
    var isMapFocus:Bool = false
    var isPathCurrentPathDraw:Bool = false
    var isSourceToDestPathDrawn:Bool = true
    var soundFile: AVAudioPlayer?
    var isCameraBearingChange:Bool = false
    var mapBearing:Double = 0.0
    var currentWaitingTime:Int = 0
    let ChatRef = DBProvider.Instance.dbRef.child(CurrentTrip.shared.tripId).child(CONSTANT.DBPROVIDER.MESSAGES)
    var dialogForTripStatus : CustomStatusDialog? = nil
    var totalTripTime:Double = 0.0
    let socketHelper:SocketHelper = SocketHelper.shared
    var isPaymentSuccess:Bool = false
    var errorMessage:String = ""
    var payStackVC:PayStackVC!
    var isRemoveListner = true
    var isCardWebLoad = false
    var applePay: StripeApplePayHelper?

    var arrLocations = [DestinationAddresses]()
    var arrBid = [Bids]()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setMap()
        socketHelper.connectSocket()
        NotificationCenter.default.addObserver(self, selector: #selector(doSomething), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSocketConnect), name: .applicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateSplitNotification), name: .updateSplitPaymentDialog, object: nil)
        
        self.tblMultipleStops.delegate = self
        self.tblMultipleStops.dataSource = self
        self.tblMultipleStops.register(UINib(nibName: StopLocationTVC.className, bundle: nil), forCellReuseIdentifier: StopLocationTVC.className)
        
        viewForSelectedPayment.isHidden = true
        polyLineCurrentProviderPath = GMSPolyline.init()
        polyLinePath = GMSPolyline.init()
        currentProviderPath = GMSMutablePath.init()
        mapView.padding = UIEdgeInsets.init(top:viewForAddresses.frame.maxY, left: 20, bottom: viewForDriver.frame.height, right: 20)
        self.navigationController?.isNavigationBarHidden = true
        self.revealViewController()?.delegate = self;
        if CurrentTrip.shared.tripStaus.trip != nil {
            onGoingTrip = CurrentTrip.shared.tripStaus.trip
            self.providerCurrentStatus = TripStatus(rawValue: self.onGoingTrip.isProviderStatus!) ?? TripStatus.Unknown
        }
        imgSelectedPayment.backgroundColor = UIColor.themeButtonBackgroundColor
        lblPaymentIcon.backgroundColor = UIColor.themeButtonBackgroundColor
        lblPaymentIcon.setRound()

        mapView.animate(toZoom: 17)
        mapView.animate(toLocation: CurrentTrip.shared.pickupCoordinate)
        self.stkWaitTime.isHidden = true
        self.constraintXSplitpsayment.constant = 0
        setupRevealViewController()
        initialViewSetup()
        wsGetProviderDetail(id: onGoingTrip.providerId)
        setupPaymentView()
        self.imgChatNotification.isHidden = true
        MessageHandler.Instace.removeObserver()
        MessageHandler.Instace.observeMessage()
        
        viewMyLocation.setRound()
        viewMyLocation.applyShadowToView(viewMyLocation.frame.size.height/2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SplitPaymentListner.shared.updateSplitPayment()
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

    func setDriverData() {
        if lblDriverName != nil {
            lblDriverName.text = provider.firstName + " " + provider.lastName
            imgDriverPic.downloadedFrom(link: provider.picture)
            providerMarker.icon = UIImage.init(named: "asset-driver-pin-placeholder")
            let url = CurrentTrip.shared.tripStaus.mapPinImageUrl
            Utility.downloadImageFrom(link: url!, completion: { (image) in
                self.providerMarker.icon = image
            })
            btnProviderRate.setTitle(provider.rate.toString(places: 1), for: .normal)
        }
    }

    @objc private func doSomething() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.socketHelper.isConnected() {
                self.startLocationListner()
            } else {
                self.socketHelper.connectSocket()
            }
            self.wsGetTripStatus()
        }
    }
    
    @objc func handleUpdateSplitNotification() {
        self.updateSplitPayment()
    }
    
    @objc private func handleSocketConnect() {
        self.startLocationListner()
    }

    override func networkEstablishAgain() {
        super.networkEstablishAgain()
        self.wsGetTripStatus()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dialogForTripStatus = nil
        if isRemoveListner {
            self.stopLocationListner()
        } else {
            isRemoveListner = true
        }
        
        self.stopWaitingTripTimer()
    }

    func startLocationListner() {
        self.stopLocationListner()
        let myTripid = "'\(CurrentTrip.shared.tripId)'"
        self.socketHelper.socket?.emit("room", myTripid)
        self.socketHelper.socket?.on(myTripid) {
            [weak self] (data, ack) in
            guard let `self` = self else {
                return
            }
            guard let response = data.first as? [String:Any] else {
                return
            }
            printE("Soket Response\(response)")
            let location = (response["location"] as? [Double]) ?? [0.0,0.0]
            let location_array = (response["location_array"] as? [[String]])
            print(location)
            print(location_array)
            
            let isTripUpdate = (response[PARAMS.IS_TRIP_UPDATED] as? Bool) ?? false
            if isTripUpdate {
                self.wsGetTripStatus()
            } else {
                if let offlineArray = location_array{
                    if location_array!.count > 1{
                        for locationData in location_array!{
                            if locationData.count > 2{
                                let bearing = (response["bearing"] as? Double) ?? 0.0
                                var loc = [Double]()
                                loc.append(Double(locationData[0])!)
                                loc.append(Double(locationData[1])!)
                                if self.providerCurrentStatus != TripStatus.Completed {
                                    self.updateProviderMarker(providerLocation: loc, bearing: bearing)
                                }
                            }
                        }
                    }
                }
                if location[0] != 0.0 && location[1] != 0.0 {
                    self.onGoingTrip.providerLocation = location
                    self.onGoingTrip.totalTime = (response["total_time"] as? Double) ?? 0.0
                    self.onGoingTrip.totalDistance = (response["total_distance"] as? Double) ?? 0.0
                    self.totalTripTime = self.onGoingTrip.totalTime
                    let bearing = (response["bearing"] as? Double) ?? 0.0
                    self.onGoingTrip.bearing = bearing
                    if self.providerCurrentStatus != TripStatus.Completed {
                        self.updateProviderMarker(providerLocation: location, bearing: bearing)
                    }
                    self.updateTripDetail()
                }
            }
        }
    }

    func stopLocationListner() {
        let myTripid = "'\(CurrentTrip.shared.tripId)'"
        self.socketHelper.socket?.off(myTripid)
        self.stopTotalTripTimer()
        self.isPathCurrentPathDraw = false
    }

    func setupPaymentView() {
        viewForSelectedPayment.backgroundColor = UIColor.clear
        selectedPaymentBackground.backgroundColor = UIColor.themeButtonBackgroundColor
        imgSelectedPayment.setRound()
        //self.lblPaymentIcon.setRound()
        selectedPaymentBackground.setRound(withBorderColor: UIColor.clear, andCornerRadious: selectedPaymentBackground.frame.height/2.0, borderWidth: 1.0)
        selectedPaymentBackground.backgroundColor = UIColor.themeButtonBackgroundColor
        lblSelectedPayment.textColor = UIColor.themeButtonTitleColor
    }

    func updatePaymentView(paymentMode:Int) {
        if paymentMode == PaymentMode.CARD {
            lblSelectedPayment.text = "TXT_CARD".localized
            imgSelectedPayment.image = UIImage.init(named: "asset-trip-card")
        }
        else if paymentMode == PaymentMode.CASH {
            lblSelectedPayment.text = "TXT_CASH".localized
            imgSelectedPayment.image = UIImage.init(named: "asset-trip-cash")
        }
        else if paymentMode == PaymentMode.APPLE_PAY {
            lblSelectedPayment.text = "TXT_APPLE_PAY".localized
            imgSelectedPayment.image = UIImage.init(named: "asset-trip-apple-pay")
        }
        else {
            lblSelectedPayment.text = "TXT_ADD_PAYMENT".localized
        }
        viewForSelectedPayment.isHidden = false
        if (paymentMode == PaymentMode.CASH && CurrentTrip.shared.isPromoApplyForCash == FALSE) || (paymentMode == PaymentMode.CARD && CurrentTrip.shared.isPromoApplyForCard == FALSE)
        {
            viewPromoCode.isHidden = true
//            btnPromoCode.isUserInteractionEnabled = true
//            btnPromoCode.setTitle("TXT_PROMO_APPLIED".localizedCapitalized, for: .normal)
        }else{
            viewPromoCode.isHidden = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MessageHandler.Instace.delegate = self
        print("viewWillAppear Called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.wsGetTripStatus()
            self.startLocationListner()
        }
    }

    func initialViewSetup() {
        viewForDriver.backgroundColor = UIColor.themeViewBackgroundColor.withAlphaComponent(0.95)
        topView.backgroundColor = UIColor.themeNavigationBackgroundColor
        lblPickupAddress.text = "TXT_PICKUP_ADDRESS".localized
        lblPickupAddress.textColor = UIColor.themeTextColor
        lblPickupAddress.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        lblDriverName.text = "--".localized
        lblDriverName.textColor = UIColor.themeTextColor
        lblDriverName.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        lblTitle.text = "TXT_TRIP_NO".localized
        lblTitle.font = FontHelper.font(size: FontSize.medium
            , type: FontType.Bold)
        lblTitle.textColor = UIColor.themeTextColor
        lblDestinationAddress.text = "TXT_DESTINATION_ADDRESS".localized
        lblDestinationAddress.textColor = UIColor.themeTextColor
        lblDestinationAddress.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        btnCall.setTitle("", for: .normal)
        btnCall.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        btnCall.backgroundColor = UIColor.themeButtonBackgroundColor
        btnCall.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
//        btnChat.setTitle("", for: .normal)
//        btnChat.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
//        btnChat.backgroundColor = UIColor.themeButtonBackgroundColor
//        btnChat.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
//        btnShare.setTitle("", for: .normal)
//        btnShare.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
//        btnShare.backgroundColor = UIColor.themeButtonBackgroundColor
//        btnShare.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnCancelTrip.setTitle("  " + "TXT_CANCEL_TRIP".localizedCapitalized + "  ", for: .normal)
        btnCancelTrip.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        btnCancelTrip.backgroundColor = UIColor.themeButtonBackgroundColor
        btnCancelTrip.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnSos.setTitle("  " + "TXT_SOS".localized + "  ", for: .normal)
        btnSos.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        btnSos.backgroundColor = UIColor.themeButtonBackgroundColor
        btnSos.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnProviderRate.setTitle("  " + "0.0".localized + "  ", for: .normal)
        btnProviderRate.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        btnProviderRate.setTitleColor(UIColor.themeTextColor, for: .normal)
        btnPromoCode.setTitle("TXT_HAVE_PROMO_CODE".localizedCapitalized, for: .normal)
        btnPromoCode.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnPromoCode.backgroundColor = UIColor.clear
        btnPromoCode.setTitleColor(UIColor.themeLightTextColor, for: .normal)
//        lblCarIdOrTotalTime.text = "TXT_CAR_ID".localized
        lblCarIdOrTotalTime.textColor = UIColor.themeLightTextColor
        lblCarIdOrTotalTime.font = FontHelper.font(size: FontSize.tiny, type: FontType.Regular)
//        lblCarIdOrTotalTimeValue.text = "".localized
//        lblCarIdOrTotalTimeValue.textColor = UIColor.themeTextColor
//        lblCarIdOrTotalTimeValue.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
//        lblPlatNoOrTotalDistance.text = "TXT_PLATE_NO".localized
        lblPlatNoOrTotalDistance.textColor = UIColor.themeLightTextColor
        lblPlatNoOrTotalDistance.font = FontHelper.font(size: FontSize.tiny, type: FontType.Regular)
//
//        lblPlatNoOrTotalDistanceValue.text = "TXT_PLATE_NO".localized
//        lblPlatNoOrTotalDistanceValue.textColor = UIColor.themeTextColor
//        lblPlatNoOrTotalDistanceValue.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        
        btnSplitPayment.backgroundColor = .clear
        btnSplitPayment.setTitleColor(UIColor.themeWalletAddedColor, for: .normal)
        btnSplitPayment.setTitle("txt_split_payment".localized, for: .normal)
        btnSplitPayment.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Bold)
        
        lblTripNo.text = "TXT_TRIP_NO".localized
        lblTripNo.textColor = UIColor.themeLightTextColor
        lblTripNo.font = FontHelper.font(size: FontSize.tiny, type: FontType.Regular)
        
//        lblTotalTime.text = "TXT_TRIP_NO".localized
        
        
        lblTotalTime.textColor = UIColor.themeTextColor
        lblTotalTime.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        
        lblTotalDistance.textColor = UIColor.themeTextColor
        lblTotalDistance.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
      
        
        btnGetCode.setTitle("txt_get_code".localized, for: .normal)
        btnGetCode.setTitleColor(UIColor.themeButtonBackgroundColor, for: .normal)
        btnGetCode.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
                
        lblWaitingTime.text = "TXT_WAITING_TIME_START_AFTER".localized
        lblWaitingTime.text = "TXT_TOTAL_WAITING_TIME".localized
        lblWaitingTime.textColor = UIColor.themeTextColor
        lblWaitingTime.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        
        lblWaitingTimeValue.text = "--".localized
        lblWaitingTimeValue.textColor = UIColor.themeTextColor
        lblWaitingTimeValue.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        
        lblDestinationAddress.text = "TXT_DESTINATION_ADDRESS".localized
        lblDestinationAddress.textColor = UIColor.themeTextColor
        lblDestinationAddress.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        
//        lblTripNoValue.text = "TXT_TRIP_NO".localized
        lblTripNoValue.textColor = UIColor.themeTextColor
        lblTripNoValue.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
//        
//        self.btnMenu.setTitle(FontAsset.icon_menu, for: .normal)
        self.tblMultipleStops.isHidden = true
        self.lblPaymentIcon.setForIcon()
        self.lblPaymentIcon.textColor = UIColor.white
        self.btnMenu.setUpTopBarButton()
//        self.btnShare.setTitle(FontAsset.icon_menu_share, for: .normal)
//        self.btnShare.setRoundIconButton()
        
//        self.btnChat.setTitle(FontAsset.icon_chat, for: .normal)
//        self.btnChat.setRoundIconButton()
        
        imgChat.tintColor = UIColor.themeImageColor
//        self.btnCall.setTitle(FontAsset.icon_call, for: .normal)
//        self.btnCall.setRoundIconButton()
        
//        btnMyLocation.setSimpleIconButton()
//        btnMyLocation.setTitle(FontAsset.icon_btn_current_location, for: .normal)
//        btnMyLocation.titleLabel?.font = FontHelper.assetFont(size: 30)
        imgMyLocation.tintColor = UIColor.themeImageColor
        payStackVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PayStackVC") as? PayStackVC
        payStackVC.gotPayUResopnse = { [weak self] (_ message: String, _ isCallIntentAPI:Bool, _ showPaymentRetryDialog:Bool, _ ispaytab:Bool) -> Void in
            guard let self = self else { return }
            if showPaymentRetryDialog{
                self.openRetryPaymentDialog()
            }else if ispaytab {
                self.wsGetTripStatus()
            }
        }
    }
    
    func setMap() {
        mapView.clear()
        mapView.delegate = self
        mapView.delegate=self;
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = false;
        mapView.settings.rotateGestures = false;
        mapView.settings.myLocationButton=false;
        mapView.isMyLocationEnabled=false;
        providerMarker = GMSMarker.init()
        pickupMarker = GMSMarker.init()
        destinationMarker = GMSMarker.init()
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
    
    func setupLayout() {
        btnCancelTrip.setRound(withBorderColor: UIColor.clear, andCornerRadious: btnCancelTrip.frame.height/2, borderWidth: 1.0)
//        btnSos.setRound(withBorderColor: UIColor.clear, andCornerRadious: 5, borderWidth: 1.0)
        btnSos.setRound(withBorderColor: UIColor.clear, andCornerRadious: btnSos.frame.height/2, borderWidth: 1.0)
        btnCall.setRound(withBorderColor: UIColor.clear, andCornerRadious: btnCall.frame.height/2, borderWidth: 1.0)
        btnChat.setRound(withBorderColor: UIColor.clear, andCornerRadious: btnChat.frame.height/2, borderWidth: 1.0)
        btnShare.setRound(withBorderColor: UIColor.clear, andCornerRadious: btnShare.frame.height/2, borderWidth: 1.0)
        imgDriverPic.setRound()
        topView.navigationShadow()
    }

    @IBAction func onClickBtnSos(_ sender: Any) {
        self.wsGetEmergencyContactList()
    }

    @IBAction func onClickBtnShare(_ sender: Any) {

        if onGoingTrip.destinationAddress.isEmpty() {
            Utility.showToast(message: "VALIDATION_MSG_PLEASE_ENTER_DESTINATION_FIRST".localized)
        } else {

            let providerLocation: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: onGoingTrip.providerLocation[0], longitude: onGoingTrip.providerLocation[1])
            let destinationLocation: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: onGoingTrip.destinationLocation[0], longitude: onGoingTrip.destinationLocation[1])
            
            LocationCenter.default.getTimeAndDistance(sourceCoordinate: providerLocation, destCoordinate: destinationLocation, multipleStops: [], tripMultipleStops: self.onGoingTrip.destinationAddresses, unit: "") { [weak self] (time, distance) in
                guard let self = self else {return}
                let time = (time.toDouble() * 0.0166667).toString(places: 0)
                let myString = String(format: NSLocalizedString("MSG_SHARE_ETA", comment: ""), self.onGoingTrip.destinationAddress,self.onGoingTrip.providerFirstName + " " + self.onGoingTrip.providerLastName,time)
                let textToShare = [ myString ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
                self.navigationController?.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onClickBtnChat(_ sender: Any) {
        if let chatVc:MyCustomChatVC =  AppStoryboard.Trip.instance.instantiateViewController(withIdentifier: "chatVC") as? MyCustomChatVC
        {
            self.imgChatNotification.isHidden = true
            chatVc.deviceToken =   self.provider.deviceToken
            self.navigationController?.pushViewController(chatVc, animated: true)
        }
    }

    @IBAction func onClickBtnCancelTrip(_ sender: Any)
    {
        Utility.getCancellationReasons { [weak self] arrReason in
            self?.openCanceTripDialog(arrReason: arrReason)
        }
    }

    @IBAction func onClickBtnFocusTrip(_ sender: Any) {
        isCameraBearingChange = false
        focusMap()
    }

    @IBAction func onClickBtnPromo(_ sender: Any) {
        if CurrentTrip.shared.tripStaus.isPromoUsed == TRUE {
            self.wsRemovePromo()
        } else {
            openPromoDialog()
        }
    }

    @IBAction func onClickBtnCall(_ sender: Any) {
        if preferenceHelper.getIsTwillioEnable() {
            btnCall.isEnabled = false
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { (time) in
                self.btnCall.isEnabled = true
            }
            self.wsTwilioVoiceCall()
        } else {
            provider.phone.toCall()
        }
    }

    @IBAction func onClickBtnDestinaiton(_ sender: Any) {
        let locationVC : LocationVC = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "locationVC") as!  LocationVC
        locationVC.delegate = self
        locationVC.flag = AddressType.destinationAddress
        locationVC.focusLocation = CLLocationCoordinate2D.init(latitude: CurrentTrip.shared.tripStaus.trip.destinationLocation[0], longitude: CurrentTrip.shared.tripStaus.trip.destinationLocation[1])
        self.navigationController?.pushViewController(locationVC, animated: true)
    }

    @IBAction func onClickBtnChangePayment(_ sender: Any) {
        if (CurrentTrip.shared.isCashModeAvailable == FALSE && CurrentTrip.shared.isCardModeAvailable == FALSE) {
            Utility.showToast(message: "VALIDATION_MSG_NO_OTHER_PAYMENT_MODE_AVAILABLE".localized)
        } else {
            self.openPaymentDialog()
        }
    }
    
    @IBAction func onClickBtnSplitPayment(_ sender: Any) {
        let vc = UIStoryboard(name: "Trip", bundle: nil).instantiateViewController(withIdentifier: "SplitPaymentVC") as! SplitPaymentVC
        vc.delegate = self
        isRemoveListner = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickGetConfirmationCode(_ sender: UIButton) {
        openGetCodeDialog()
    }

    func startWaitingTripTimer() {
        self.wsGetTripStatus()
        CurrentTrip.timerForWaitingTime?.invalidate()
        CurrentTrip.timerForWaitingTime = nil
        CurrentTrip.timerForWaitingTime = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(waitTimeWatcher), userInfo: nil, repeats: true)
    }

    func stopWaitingTripTimer() {
        CurrentTrip.timerForWaitingTime?.invalidate()
    }

    @objc func waitTimeWatcher() {
        currentWaitingTime = currentWaitingTime + 1;
        if(currentWaitingTime < 0) {
            lblWaitingTime?.text = "\("TXT_WAITING_TIME_START_AFTER".localized ) - \(abs(currentWaitingTime).toString() + " s")"
            lblWaitingTimeValue?.text = ""//abs(currentWaitingTime).toString() + " s"
        } else {
            lblWaitingTime?.text = "\("TXT_TOTAL_WAITING_TIME".localized) - \(abs(currentWaitingTime).toString() + " s")"
            lblWaitingTimeValue?.text = ""//abs(currentWaitingTime).toString() + " s"
        }
        if providerCurrentStatus == TripStatus.Arrived {
            stkWaitTime?.isHidden = false
//            self.constraintXSplitpsayment.constant = 5
        } else {
            stkWaitTime?.isHidden = true
            self.constraintXSplitpsayment.constant = 0
            stopWaitingTripTimer()
        }
    }

    func updateAddress() {
        if let trip = CurrentTrip.shared.tripStaus.trip {
            lblPickupAddress.text = trip.sourceAddress
            CurrentTrip.shared.setPickupLocation(latitude: trip.sourceLocation[0], longitude: trip.sourceLocation[1], address: trip.sourceAddress)
            self.lblDestinationAddress.text = trip.destinationAddress
            
            if self.lblDestinationAddress.text == ""{
                lblDestinationAddress.text = "Destination address"
            }
            
            if trip.destinationAddresses.count > 0 {
                self.arrLocations = trip.destinationAddresses
                self.tblMultipleStops.isHidden = false
                self.tblHeight.constant = CGFloat(self.arrLocations.count * 30)
                self.tblMultipleStops.reloadData()
                
                if CurrentTrip.shared.isFixedFareTrip {
                    self.btnDestinationAddress.isUserInteractionEnabled = false
                } else {
                    self.btnDestinationAddress.isUserInteractionEnabled = true
                }
            }
        }
    }

    func updateProviderMarker(providerLocation:[Double],bearing:Double) {
        if providerLocation[0] != 0.0 && providerLocation[1] != 0.0 {
            let providerPrevioustLocation = providerMarker.position
            let providerCoordinate = CLLocationCoordinate2D.init(latitude: providerLocation[0], longitude: providerLocation[1])
            if providerMarker.map == nil {
                providerMarker.map = mapView
                if mapView != nil {
                    mapView.animate(toLocation: providerCoordinate)
                    mapView.animate(toZoom: 17)
                }
            }

            if providerCurrentStatus == TripStatus.Coming || providerCurrentStatus == TripStatus.Accepted ||  providerCurrentStatus == TripStatus.Arrived || providerCurrentStatus == TripStatus.Started {
                isCameraBearingChange = true;
                mapBearing = self.calculateBearing(source: providerPrevioustLocation, to: providerCoordinate)
            } else {
                isCameraBearingChange = false;
            }

            if (isCameraBearingChange) {
                CATransaction.begin()
                CATransaction.setValue(1.3, forKey: kCATransactionAnimationDuration)
                CATransaction.setCompletionBlock {
                    self.drawCurrentPath(driverCoordinate: providerCoordinate)
                }
                if mapView != nil {
                    mapView.animate(toBearing: mapBearing)
                    mapView.animate(toLocation: providerCoordinate)
                    mapView.animate(toZoom: 17)
                }
                providerMarker.position = providerCoordinate
                CATransaction.commit()
            }
            providerMarker.position = providerCoordinate
        }
    }
    
    func updateSorceDestinationMarkers() {
        if !onGoingTrip.destinationLocation.isEmpty {
            if onGoingTrip.destinationLocation[0] != 0.0 && onGoingTrip.destinationLocation[1] != 0.0 {
                destinationMarker.position = CLLocationCoordinate2D.init(latitude: onGoingTrip.destinationLocation[0], longitude: onGoingTrip.destinationLocation[1])
                destinationMarker.icon = Global.imgPinDestination
                if destinationMarker.map == nil {
                    destinationMarker.map = mapView
                }
            }
        }

        if onGoingTrip.destinationAddresses.count > 0 {
            for stopApp in onGoingTrip.destinationAddresses {
                let wLat = stopApp.location[0]
                let wLong = stopApp.location[1]
                let location = CLLocationCoordinate2D(latitude: wLat, longitude: wLong)
                
                print("location: \(location)")
                let marker = GMSMarker()
                marker.icon = Global.imgPinPickup
                marker.position = location
                marker.map = self.mapView
            }
        }
        
        if onGoingTrip.sourceLocation[0] != 0.0 && onGoingTrip.sourceLocation[1] != 0.0 {
            pickupMarker.position = CLLocationCoordinate2D.init(latitude: onGoingTrip.sourceLocation[0], longitude: onGoingTrip.sourceLocation[1])
            pickupMarker.icon = Global.imgPinPickup
            if pickupMarker.map == nil {
                pickupMarker.map = mapView
            }
        }
    }

    func calculateBearing(source:CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = Double.pi * source.latitude / 180.0
        let long1 = Double.pi * source.longitude / 180.0
        let lat2 = Double.pi * destination.latitude / 180.0
        let long2 = Double.pi * destination.longitude / 180.0
        let rads = atan2(
            sin(long2 - long1) * cos(lat2),
            cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(long2 - long1))
        let degrees = rads * 180 / Double.pi
        return (degrees+360).truncatingRemainder(dividingBy: 360)
    }

    func updatePromoView(isPromoUsed: Bool = CurrentTrip.shared.tripStaus.isPromoUsed == TRUE) {
        if isPromoUsed {
            btnPromoCode.isUserInteractionEnabled = true
            btnPromoCode.setTitle("TXT_PROMO_APPLIED".localizedCapitalized, for: .normal)
        } else {
            btnPromoCode.isUserInteractionEnabled = true
            btnPromoCode.setTitle("TXT_HAVE_PROMO_CODE".localizedCapitalized, for: .normal)
        }
    }

    func startTotalTripTimer() {
        CurrentTrip.timerForTotalTripTime?.invalidate()
        CurrentTrip.timerForTotalTripTime = nil
        CurrentTrip.timerForTotalTripTime =    Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(totalTimeWatcher), userInfo: nil, repeats: true)
    }

    func stopTotalTripTimer() {
        CurrentTrip.timerForTotalTripTime?.invalidate()
        
    }
    func stopTripListner() {
        let myTripid = "'\(CurrentTrip.shared.tripId)'"
        self.socketHelper.socket?.off(myTripid)
    }

    @objc func totalTimeWatcher() {
        totalTripTime = totalTripTime + 1;
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.lblCarIdOrTotalTimeValue != nil {
                self.lblTotalTime.text = self.totalTripTime.toString(places: 2) + MeasureUnit.MINUTES
//                self.lblCarIdOrTotalTimeValue.text = self.totalTripTime.toString(places: 2) + MeasureUnit.MINUTES
            } else {
                self.stopTotalTripTimer()
            }
        }
    }

    func showPathFrom(source:CLLocationCoordinate2D, toDestination destination:CLLocationCoordinate2D) {
        if preferenceHelper.getIsPathdraw() {
            let saddr = "\(source.latitude),\(source.longitude)"
            let daddr = "\(destination.latitude),\(destination.longitude)"
            let apiUrlStr = Google.DIRECTION_URL +  "\(saddr)&destination=\(daddr)&key=\(preferenceHelper.getGoogleKey())"
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            guard let url =  URL(string: apiUrlStr) else {
                return
            }
            do {
                print("JD DIRECTION API CALLED")
                DispatchQueue.main.async {  /*[unowned self, unowned session] in*/
                    session.dataTask(with: url) { [weak self, unowned session] (data, response, error) in
                        guard data != nil else {
                            return
                        }
                        guard let self = self else {
                            return
                        }
                        do {
                            let route = try JSONDecoder().decode(MapPath.self, from: data!)
                            if let points = route.routes?.first?.overview_polyline?.points {
                                self.drawPath(with: points)
                            }
                            self.wsSetGooglePathPickupToDestination(route: String.init(data: data!, encoding: .utf8) ?? "")
                        } catch let error {
                            printE(session)
                            printE("Failed to draw ",error.localizedDescription)
                        }
                    }.resume()
                }
            }
        }
    }

    private func drawPath(with points : String) {
        if isSourceToDestPathDrawn {
            isSourceToDestPathDrawn = false
            DispatchQueue.main.async { [weak self] in
                if self?.polyLinePath.map != nil {
                    self?.polyLinePath.map = nil
                }
                if let path = GMSPath(fromEncodedPath: points) {
                    self?.polyLinePath = GMSPolyline(path: path)
                    self?.polyLinePath.strokeColor = UIColor.themeGooglePathColor
                    self?.polyLinePath.strokeWidth = 5.0
                    self?.polyLinePath.geodesic = true
                    self?.polyLinePath.map = self?.mapView
                }
            }
        }
    }

    func drawCurrentPath(driverCoordinate:CLLocationCoordinate2D) {
        print("\(#function) previous Coordinate: \(previousDriverLatLong) and new \(driverCoordinate)")
        if (isPathCurrentPathDraw && providerCurrentStatus == TripStatus.Started) {
            let tempPath:GMSMutablePath = GMSMutablePath.init()
            if (previousDriverLatLong.latitude != 0.0 && previousDriverLatLong.longitude != 0.0) {
                tempPath.add(previousDriverLatLong)
            }
            tempPath.add(driverCoordinate)
            DispatchQueue.main.async { [unowned self] in
                self.polyLineCurrentProviderPath = GMSPolyline.init(path: tempPath)
                self.polyLineCurrentProviderPath.strokeWidth = 5.0;
                self.polyLineCurrentProviderPath.strokeColor = UIColor.themeButtonBackgroundColor
                self.polyLineCurrentProviderPath.map = self.mapView;
                self.previousDriverLatLong = driverCoordinate;
            }
        }
    }

    func updateTripDetail() {
        if lblTripNoValue != nil {
            lblTripNoValue.text = onGoingTrip.uniqueId.toString()
            lblTitle.text = "TXT_TRIP_NO".localized + " " + onGoingTrip.uniqueId.toString()
            if providerCurrentStatus == TripStatus.Arrived || providerCurrentStatus == TripStatus.Accepted || providerCurrentStatus == TripStatus.Coming {
                lblCarIdOrTotalTime.text = "TXT_CAR_ID".localized
                lblPlatNoOrTotalDistance.text = "TXT_PLATE_NO".localized
                lblCarIdOrTotalTimeValue.text = provider.carModel
                lblPlatNoOrTotalDistanceValue.text = provider.carNumber
                lblColor.text = provider.carColor
                lblVehical.text  = provider.carName
                btnSos.isHidden = true
                btnCancelTrip.isHidden = false
                stkViewTotalDistance.isHidden = true
//                constraintHeightDistamnce.constant = 0
            } else {
                self.totalTripTime = self.onGoingTrip.totalTime
                lblCarIdOrTotalTime.text = "TXT_TOTAL_TIME".localized
                lblPlatNoOrTotalDistance.text = "TXT_TOTAL_DISTANCE".localized
//                lblCarIdOrTotalTimeValue.text = totalTripTime.toString(places: 2) + MeasureUnit.MINUTES
            
                self.lblTotalTime.text = totalTripTime.toString(places: 2) + MeasureUnit.MINUTES
                self.lblTotalDistance.text = onGoingTrip.totalDistance.toString(places: 2) + Utility.getDistanceUnit(unit:onGoingTrip.unit)
                self.startTotalTripTimer()
//                lblPlatNoOrTotalDistanceValue.text = onGoingTrip.totalDistance.toString(places: 2) + Utility.getDistanceUnit(unit: onGoingTrip.unit)
                btnSos.isHidden = false
                btnCancelTrip.isHidden = true
                stkViewTotalDistance.isHidden = false
//                constraintHeightDistamnce.constant = 40
                lblCarIdOrTotalTimeValue.text = provider.carModel
                lblPlatNoOrTotalDistanceValue.text = provider.carNumber
                lblColor.text = provider.carColor
                lblVehical.text  = provider.carName
               
            }
            if preferenceHelper.getIsSplitPayment() {
                if CurrentTrip.shared.tripStaus.trip.is_ride_share || CurrentTrip.shared.tripType == TripType.CORPORATE {
                    self.viewSplitPayment.isHidden = true
                    stackTripDetail.alignment = .leading
                } else {
                    self.viewSplitPayment.isHidden = false
                    stackTripDetail.alignment = .fill
                }
            } else {
                self.viewSplitPayment.isHidden = true
                stackTripDetail.alignment = .leading
            }
        }
    }

    func playSound() {
        if (providerCurrentStatus == TripStatus.Arrived) {
            if (preferenceHelper.getIsArivedSoundOn()) {
                let path = Bundle.main.path(forResource: "alertArriveNotification.mp3", ofType:nil)!
                let url = URL(fileURLWithPath: path)
                do {
                    soundFile = try AVAudioPlayer(contentsOf: url)
                    soundFile?.play()
                } catch {
                    // couldn't load file :(
                }
            }
        } else {
            if (preferenceHelper.getIsSoundOn()) {
                let path = Bundle.main.path(forResource: "alertNotification.mp3", ofType:nil)!
                let url = URL(fileURLWithPath: path)
                do {
                    soundFile = try AVAudioPlayer(contentsOf: url)
                    soundFile?.play()
                } catch {
                    // couldn't load file :(
                }
            }
        }
    }
    
    func sendEventToSplitVC() {
        NotificationCenter.default.post(name: NSNotification.splitPaymentNotification, object: nil)
    }
}

//MARK: - RevealViewController Delegate Methods
extension TripVC:PBRevealViewControllerDelegate
{
    @IBAction func onClickBtnMenu(_ sender: Any) {}

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

//MARK: - Dialogs
extension TripVC
{
    func openStatusNotificationDialog()
    {
        if dialogForTripStatus == nil
        {
            dialogForTripStatus = CustomStatusDialog.showCustomStatusDialog(message: providerCurrentStatus.text(), titletButton: "TXT_CLOSE".localizedCapitalized)
            dialogForTripStatus?.updateMessage(message: providerCurrentStatus.text())
            dialogForTripStatus?.onClickOkButton =
                { [unowned self, weak dialogForTripStatus = self.dialogForTripStatus] in 
                    self.dialogForTripStatus?.removeFromSuperview();
                    self.dialogForTripStatus = nil                    
                    dialogForTripStatus?.removeFromSuperview()
                    dialogForTripStatus = nil
            }
        }
        else
        {
            dialogForTripStatus?.updateMessage(message: providerCurrentStatus.text())
        }
    }
    
    //Open a dialog which show the confirmation code
    func openGetCodeDialog() {
        let dialog = CustomStatusDialog.showCustomStatusDialog(message: providerCurrentStatus.text(), titletButton: "TXT_CLOSE".localizedCapitalized, tag: DialogTags.confirmaitionCodeDialog)
        dialog.updateMessage(message: "txt_your_confirmation_code".localized.replacingOccurrences(of: "****", with: "\(self.onGoingTrip.confirmation_code)"))
        dialog.onClickOkButton = {
            dialog.removeFromSuperview();
        }
    }
    
    //remove a dialog which show the confirmation code after driver enter code and update status. first we check that dialog is open or not if the dialog is open then we remove on TripStatus.Started status.
    func removeGetCodeDialog() {
        if let view = (APPDELEGATE.window?.viewWithTag(DialogTags.confirmaitionCodeDialog)) {
            view.removeFromSuperview()
        }
    }
    
    func openCanceTripDialog(arrReason: [String])
    {
        let dialogForTripStatus = CustomCancelTripDialog.showCustomCancelTripDialog(title: "TXT_CANCEL_TRIP".localized, message: "TXT_CANCELLATION_CHARGE_MESSAGE".localized, cancelationCharge: "0", titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_OK".localized)
        
        dialogForTripStatus.arrReason = arrReason
        
        if onGoingTrip.isProviderStatus! == TripStatus.Arrived.rawValue
        {
            dialogForTripStatus.setCancellationCharge(cancellationCharge: CurrentTrip.shared.tripStaus.cancellationFee)
        }
        dialogForTripStatus.onClickLeftButton =
        { [unowned dialogForTripStatus] in
            dialogForTripStatus.removeFromSuperview();
        }
        dialogForTripStatus.onClickRightButton = { 
            [weak self, unowned dialogForTripStatus] (reason) in
            dialogForTripStatus.removeFromSuperview()
            self?.wsCancelTrip(reason: reason)
        }
    }

    func openSosDialog()
    {
        let dialogForSos = CustomSosDialog.showCustomSosDialog(title: "TXT_SOS".localized, message: "10", titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_SEND".localized)
        dialogForSos.onClickLeftButton =
        { [unowned dialogForSos] in
            dialogForSos.stopTimer()
            dialogForSos.removeFromSuperview();
        }
        dialogForSos.onClickRightButton =
        { [weak self, unowned dialogForSos] in
            dialogForSos.stopTimer()
            self?.wsSos()
            dialogForSos.removeFromSuperview();
        }
    }

    func openPromoDialog()
    {
        self.view.endEditing(true)
        
        let dialogForPromo = CustomVerificationDialog.showCustomVerificationDialog(title: "TXT_APPLY_PROMO".localized, message: "".localized, titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_APPLY".localized, editTextHint: "TXT_ENTER_PROMO".localized,  editTextInputType: false,offerbutton: true,countryId: CurrentTrip.shared.tripStaus.cityDetail.countryid , cityId:CurrentTrip.shared.tripStaus.cityDetail.id)
        dialogForPromo.onClickLeftButton =
            { [unowned dialogForPromo] in
                dialogForPromo.removeFromSuperview();
        }
        dialogForPromo.onClickRightButton =
            { [unowned self, unowned dialogForPromo] (text:String) in
//addrees, gender, profile pic
                
//
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

    func openPaymentDialog()
    {
        print(PaymentMethod.Payment_gateway_type)
        PaymentMethod.Payment_gateway_type = "\(preferenceHelper.getsPaymentGateway())"
        let dialogForPayment = CustomAppleCardDialog.showCustomPaymentSelectionDialog()
        dialogForPayment.onClickPaymentModeSelected  =  { [weak self] (paymentMode) in
            guard let self = self else { return }
            if self.onGoingTrip.paymentMode != paymentMode {
                self.wsUpdatePaymentMode(paymentMode: paymentMode)
            }
        }
    }
}

extension TripVC:LocationHandlerDelegate
{
    func finalAddressAndLocation(address: String, latitude: Double, longitude: Double)
    {
        CurrentTrip.shared.setDestinationLocation(latitude: latitude, longitude: longitude, address: address)
        lblDestinationAddress.text = address
        if self.lblDestinationAddress.text == ""{
            lblDestinationAddress.text = "Destination address"
        }
        self.wsUpdateDestinationAddress(address: address, latitude: latitude, longitude: longitude)
    }
    
    func focusMap()
    {
        let pickupLocation:CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: onGoingTrip.sourceLocation[0], longitude: onGoingTrip.sourceLocation[1])
        let destinationLocation:CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: onGoingTrip.destinationLocation[0], longitude: onGoingTrip.destinationLocation[1])
        let driverLocation:CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: onGoingTrip.providerLocation[0], longitude: onGoingTrip.providerLocation[1])

        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(driverLocation)
        if self.providerCurrentStatus == .Accepted || self.providerCurrentStatus == .Coming {
            bounds = bounds.includingCoordinate(pickupLocation)
            mapBearing = self.calculateBearing(source: driverLocation, to: pickupLocation)
        }
        else {
            if destinationLocation.latitude != 0.0 && destinationLocation.longitude != 0.0 {
                bounds = bounds.includingCoordinate(destinationLocation)
                mapBearing = self.calculateBearing(source: providerMarker.position, to: destinationLocation)
            }
            else {
                mapBearing = self.calculateBearing(source: driverLocation, to: driverLocation)
            }
        }
        isCameraBearingChange = true;
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock
            {
                self.drawCurrentPath(driverCoordinate: driverLocation)
        }
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
        mapView.animate(toBearing: mapBearing)
        isCameraBearingChange = false
        CATransaction.commit()
    }
}

//MARK: - Web Service Calls
extension TripVC
{
    func wsGetGooglePath() {
        //Utility.showLoading()
        print("\(#function)")
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] = onGoingTrip.id

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_GOOGLE_PATH_FROM_SERVER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                Utility.hideLoading()
                if Parser.isSuccess(response: response) {
                    let googleResponse:GooglePathResponse = GooglePathResponse.init(fromDictionary: response)
                    var path = ""
                    let tripLocations = googleResponse.triplocation
                    path = (tripLocations?.googlePickUpLocationToDestinationLocation) ?? ""
                    let data: Data? = path.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                    if self.providerCurrentStatus == TripStatus.Arrived || self.providerCurrentStatus == TripStatus.Started {
                        if data != nil && !path.isEmpty() {
                            do {
                                let route = try JSONDecoder().decode(MapPath.self, from: data!)
                                if let points = route.routes?.first?.overview_polyline?.points {
                                    self.drawPath(with: points)
                                }
                            } catch {
                                printE("error in JSONSerialization")
                            }
                        } else {
                            if !self.onGoingTrip.destinationLocation.isEmpty {
                                if self.onGoingTrip.destinationLocation[0] != 0.0 && self.onGoingTrip.destinationLocation[1] != 0.0 {
                                    self.showPathFrom(source: self.pickupMarker.position, toDestination: self.destinationMarker.position)
                                }
                            }
                        }
                        if (self.providerCurrentStatus == TripStatus.Started) {
                            let startToEndTripLocation = googleResponse.triplocation.startTripToEndTripLocations;
                            if (self.isPathCurrentPathDraw)
                            {} else {
                                if ((startToEndTripLocation?.count ?? 0) > 0) {
                                    self.currentProviderPath = GMSMutablePath.init()
                                    for currentLocation in startToEndTripLocation ?? [] {
                                        if let location = currentLocation as? [Any] {
                                            let currentCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: (location[0] as? Double) ?? 0.0, longitude: (location[1] as? Double) ?? 0.0)
                                            self.currentProviderPath.add(currentCoordinate)
                                            self.previousDriverLatLong = currentCoordinate
                                        }
                                    }
                                    self.updateProviderMarker(providerLocation: [self.previousDriverLatLong.latitude, self.previousDriverLatLong.longitude], bearing: 1.0)
                                    self.polyLineCurrentProviderPath = GMSPolyline.init(path: self.currentProviderPath)
                                    self.polyLineCurrentProviderPath.strokeWidth = 5.0;
                                    self.polyLineCurrentProviderPath.strokeColor = UIColor.themeButtonBackgroundColor;
                                    self.polyLineCurrentProviderPath.map = self.mapView;
                                    self.isPathCurrentPathDraw = true;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func wsSetGooglePathPickupToDestination(route:String = "") {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] = onGoingTrip.id
        dictParam[PARAMS.GOOGLE_PATH_START_LOCATION_TO_PICKUP_LOCATION] = ""
        dictParam[PARAMS.GOOGLE_PICKUP_LOCATION_TO_DESTINATION_LOCATION] = route

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.SET_GOOGLE_PATH_FROM_SERVER, methodName:  AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response: response) {}
                Utility.hideLoading()
            }
        }
    }
    
    func wsGetProviderDetail(id:String) {
        if !id.isEmpty() {
            Utility.showLoading()
            var  dictParam : [String : Any] = [:]
            dictParam[PARAMS.PROVIDER_ID] = id
            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.GET_PROVIDER_DETAIL, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) {[weak self] (response, error) -> (Void) in
                guard let self = self else {return}
                if (error != nil) {
                    Utility.hideLoading()
                } else {
                    if Parser.isSuccess(response: response, withSuccessToast: false, andErrorToast: false) {
                        let providerResponse :ProviderResponse = ProviderResponse.init(fromDictionary: response)
                        self.provider = providerResponse.provider

                        self.updateTripDetail()
                        self.setDriverData()

                        self.onGoingTrip.providerLocation = providerResponse.provider.providerLocation
                        self.onGoingTrip.bearing = providerResponse.provider.bearing

                        if self.providerCurrentStatus != TripStatus.Completed {
                            self.updateProviderMarker(providerLocation: self.provider.providerLocation, bearing: self.provider.bearing)
                        }

                        Utility.hideLoading()
                    }
                }
            }
        }
    }

    func wsApplyPromo(promo:String,dialog:CustomVerificationDialog) {
        if !promo.isEmpty() {
            Utility.showLoading()
            var dictParam : [String : Any] = [:]
            dictParam[PARAMS.PROMO_CODE] = promo
            dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
            dictParam[PARAMS.TOKEN ] = preferenceHelper.getSessionToken()
            dictParam[PARAMS.TRIP_ID] = onGoingTrip.id
            dictParam[PARAMS.CITY] = ""
            dictParam[PARAMS.COUNTRY] = ""

            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.APPLY_PROMO_CODE, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { 
                [unowned self, unowned dialog] (response, error) -> (Void) in
                if (error != nil) {
                    Utility.hideLoading()
                    self.updatePromoView()
                } else {
                    if Parser.isSuccess(response: response) {
                        Utility.hideLoading()
                        self.updatePromoView(isPromoUsed: true)
                        dialog.removeFromSuperview()
                        self.wsGetTripStatus()
                    }
                }
            }
        }
    }

    func wsRemovePromo() {
        if !onGoingTrip.promoId.isEmpty() {
            Utility.showLoading()
            var dictParam : [String : Any] = [:]
            dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
            dictParam[PARAMS.TOKEN ] = preferenceHelper.getSessionToken()
            dictParam[PARAMS.PROMO_ID] = onGoingTrip.promoId
            dictParam[PARAMS.TRIP_ID] = onGoingTrip.id

            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.REMOVE_PROMO_CODE, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) {
                [unowned self] (response, error) -> (Void) in
                if (error != nil) {
                    Utility.hideLoading()
                    self.updatePromoView()
                } else {
                    if Parser.isSuccess(response: response) {
                        Utility.hideLoading()
                        self.updatePromoView(isPromoUsed: false)
                        self.wsGetTripStatus()
                    }
                }
            }
        }
    }
    
    func wsPaypalPayTrip(orderID: String, payerId: String) {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] =  CurrentTrip.shared.tripId
        dictParam[PARAMS.PAYMENT_GATEWAY_TYPE] = PaymentMethod.Paypal_ID
        dictParam[PARAMS.PAYMENT_INTENT_ID] = orderID
        dictParam[PARAMS.CARD_ID] = payerId
        dictParam[PARAMS.last_four] = "paypal"
        dictParam[PARAMS.AMOUNT] = CurrentTrip.shared.tripStaus.cancellationFee ?? 0

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.PAY_STRIPE_INTENT_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if (error != nil) {
            } else {
                if Parser.isSuccess(response: response) {
                    CurrentTrip.shared.clearTripData()
                    APPDELEGATE.gotoMap()
                }
            }
        }
    }

    @objc func wsGetTripStatus() {
        if preferenceHelper.getUserId().isEmpty {
            self.stopLocationListner()
            APPDELEGATE.gotoLogin()
            return
        } else {
            var dictParam : [String : Any] = [:]
            dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
            dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()

            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.CHECK_TRIP_STATUS, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) {  (response, error) -> (Void) in
                Utility.hideLoading()
                if (error != nil) {
                    Utility.hideLoading()
                } else {
                    DispatchQueue.main.async {
                        if self.view.subviews.count > 0 {
                            if Parser.isSuccess(response: response,withSuccessToast: false, andErrorToast: false) {
                                Utility.hideLoading()
                                CurrentTrip.shared.tripStaus = TripStatusResponse.init(fromDictionary: response)
                                CurrentTrip.shared.tripId = CurrentTrip.shared.tripStaus.trip.id
                                CurrentTrip.shared.tripType = CurrentTrip.shared.tripStaus.trip.tripType
                                CurrentTrip.shared.isFixedFareTrip = CurrentTrip.shared.tripStaus.trip.isFixedFare
                                CurrentTrip.shared.isCardModeAvailable = CurrentTrip.shared.tripStaus.cityDetail.isPaymentModeCard
                                CurrentTrip.shared.isCashModeAvailable = CurrentTrip.shared.tripStaus.cityDetail.isPaymentModeCash
                                CurrentTrip.shared.isPromoApplyForCash = CurrentTrip.shared.tripStaus.cityDetail.isPromoApplyForCash
                                CurrentTrip.shared.isPromoApplyForCard = CurrentTrip.shared.tripStaus.cityDetail.isPromoApplyForCard
                                if CurrentTrip.shared.pickupCountry.isEmpty {
                                    CurrentTrip.shared.pickupCountry = CurrentTrip.shared.tripStaus.cityDetail.countryname.lowercased()
                                }
                                
                                if CurrentTrip.shared.pickupCountry.isEmpty {
                                    CurrentTrip.shared.pickupCountry = CurrentTrip.shared.tripStaus.cityDetail.countryname.lowercased()
                                }

                                PaymentMethod.Payment_gateway_type = "\(CurrentTrip.shared.tripStaus.trip.payment_gateway_type ?? 0)"

                                if CurrentTrip.shared.tripStaus.trip != nil {
                                    self.onGoingTrip = CurrentTrip.shared.tripStaus.trip
                                }
                                self.providerCurrentStatus = TripStatus(rawValue: self.onGoingTrip.isProviderStatus!) ?? TripStatus.Unknown
                                self.updatePromoView()
                                self.updateAddress()
                                self.updatePaymentView(paymentMode: self.onGoingTrip.paymentMode)

                                if self.strProviderId != CurrentTrip.shared.tripStaus.trip.currentProvider {
                                    self.strProviderId = CurrentTrip.shared.tripStaus.trip.currentProvider
                                    self.wsGetProviderDetail(id: CurrentTrip.shared.tripStaus.trip.providerId)
                                    self.providerNextStatus =  self.providerCurrentStatus
                                }
                                self.provider.bearing = self.onGoingTrip.bearing
                                self.updateSorceDestinationMarkers()
                                self.updateTripDetail()
                                self.stkViewGetCode.isHidden = true
                                if CurrentTrip.shared.tripStaus.trip.isTripCancelled == TRUE && CurrentTrip.shared.tripStaus.trip.isTripCancelledByUser == TRUE {
                                    if self.onGoingTrip.paymentMode == PaymentMode.CARD {
                                        self.wsGetStripeIntent()
                                    } else if self.onGoingTrip.paymentMode == PaymentMode.APPLE_PAY {
                                        self.wsGetStripeApplePayIntent()
                                    } else {}
                                } else {
                                    switch (self.providerCurrentStatus)
                                    {
                                    case TripStatus.Accepted:
                                        if self.providerCurrentStatus == self.providerNextStatus {
                                            self.providerNextStatus = TripStatus.Coming
                                            self.playSound()
                                        }
                                        break
                                    case TripStatus.Coming:
                                        if self.providerCurrentStatus == self.providerNextStatus {
                                            self.openStatusNotificationDialog()
                                            self.providerNextStatus = TripStatus.Arrived
                                            self.playSound()
                                        }
                                        break
                                    case TripStatus.Arrived:
                                        if self.providerCurrentStatus == self.providerNextStatus {
                                            self.openStatusNotificationDialog()
                                            self.playSound()
                                            self.providerNextStatus = TripStatus.Started
                                            self.wsGetGooglePath()
                                        }
                                        if CurrentTrip.shared.tripStaus.priceForWaitingTime > 0.0 && !(CurrentTrip.timerForWaitingTime?.isValid ?? false) && (!CurrentTrip.shared.tripStaus.trip.isFixedFare) {
                                            self.currentWaitingTime = CurrentTrip.shared.tripStaus.totalWaitTime
                                            self.stkWaitTime.isHidden = false
                                            self.constraintXSplitpsayment.constant = 5
                                            self.startWaitingTripTimer()
                                        }
                                        self.stkViewGetCode.isHidden = !( !CurrentTrip.shared.tripStaus.trip.is_otp_verification && CurrentTrip.shared.user.is_otp_verification_start_trip )
                                        break
                                    case TripStatus.Started:
                                        self.removeGetCodeDialog()
                                        if self.providerCurrentStatus == self.providerNextStatus {
                                            self.openStatusNotificationDialog()
                                            self.providerNextStatus = TripStatus.End
                                            self.playSound()
                                        }
                                        self.wsGetGooglePath()
                                        break
                                    case TripStatus.Completed:
                                        self.removeGetCodeDialog()
                                        self.stopLocationListner()
                                        self.socketHelper.disConnectSocket()
                                        APPDELEGATE.gotoInvoice()
                                        break
                                    default:
                                        self.removeGetCodeDialog()
                                        printE("BOOM BOOM")
                                    }
                                }
                            } else {
                                let response:ResponseModel = ResponseModel.init(fromDictionary: response)
                                if response.errorCode == TRIP_IS_ALREADY_CANCELLED {}
                                CurrentTrip.shared.clearTripData()
                                self.stopLocationListner()
                                APPDELEGATE.gotoMap()
                            }
                        }
                    }
                }
            }
        }
    }

    func wsTwilioVoiceCall() {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TYPE] = 1
        dictParam[PARAMS.TRIP_ID] = onGoingTrip.id

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.TWILIO_CALL, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if (error != nil) {
            } else {
                if Parser.isSuccess(response: response) {
                    self.openTwillioNotificationDialog()
                }
            }
        }
    }

    func openTwillioNotificationDialog() {
        let dialogForTwillioCall = CustomStatusDialog.showCustomStatusDialog(message: "TXT_CALL_MESSAGE".localized, titletButton: "TXT_CLOSE".localized)
        dialogForTwillioCall.onClickOkButton =
        { [/*unowned self,*/ unowned dialogForTwillioCall] in
            dialogForTwillioCall.removeFromSuperview()
        }
    }

    func wsCancelTrip(reason:String = "") {
        self.stopLocationListner()
        if !CurrentTrip.shared.tripStaus.trip.id.isEmpty() {
            Utility.showLoading()
            var dictParam : [String : Any] = [:]
            dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
            dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
            dictParam[PARAMS.TRIP_ID] = CurrentTrip.shared.tripStaus.trip.id
            dictParam[PARAMS.CANCEL_TRIP_REASON] = reason

            let afh:AlamofireHelper = AlamofireHelper.init()
            afh.getResponseFromURL(url: WebService.CANCEL_TRIP, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
                if (error != nil) {
                    Utility.hideLoading()
                    self.stopTripListner()
                } else {
                    if Parser.isSuccess(response:response, withSuccessToast:false, andErrorToast:false) {
                        if let paymentStatus = response["payment_status"] as? Int {
                            if paymentStatus == PAYMENT_STATUS.COMPLETED  {
                                CurrentTrip.shared.clearTripData()
                                APPDELEGATE.gotoMap()
                                Utility.hideLoading()
                            } else {
                                if self.onGoingTrip.paymentMode == PaymentMode.APPLE_PAY {
                                    self.wsGetStripeApplePayIntent()
                                } else {
                                    self.wsGetStripeIntent()
                                }
                            }
                        }
                    } else {
                        Utility.hideLoading()
                        self.stopLocationListner()
                    }
                }
            }
        } else {
            self.stopTripListner()
            Utility.hideLoading()
            self.stopLocationListner()
        }
    }

    func wsGetEmergencyContactList() {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.DEVICE_TOKEN] = preferenceHelper.getDeviceToken()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_EMERGENCY_CONTACT_LIST, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response: response) {
                    Utility.hideLoading()
                    self.openSosDialog()
                } else {
                    Utility.hideLoading()
                }
            }
        }
    }

    func wsSos() {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        let sosLatitude = Double(providerMarker.position.latitude).toString(places: 6)
        let sosLongitude = Double(providerMarker.position.longitude).toString(places: 6)
        let strUrl = "https://www.google.co.in/maps/place/\(sosLatitude),\(sosLongitude)"
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.DEVICE_TOKEN] = preferenceHelper.getDeviceToken()
        dictParam[PARAMS.MAP_IMAGE] = strUrl

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.SEND_SMS_TO_EMERGENCY_CONTACT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { /*[unowned self]*/ (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response: response,withSuccessToast: true,andErrorToast: true) {
                    Utility.hideLoading()
                } else {
                    Utility.hideLoading()
                }
            }
        }
    }

    func wsUpdateDestinationAddress(address:String,latitude:Double,longitude:Double) {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.DEVICE_TOKEN] = preferenceHelper.getDeviceToken()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] = onGoingTrip.id
        dictParam[PARAMS.TRIP_DESTINATION_ADDRESS] = address
        dictParam[PARAMS.TRIP_DESTINATION_LATITUDE] = latitude
        dictParam[PARAMS.TRIP_DESTINATION_LONGITUDE] = longitude

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.SET_DESTINATION_ADDRESS, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response: response) {
                    let sourceCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: self.onGoingTrip.sourceLocation[0] , longitude: self.onGoingTrip.sourceLocation[1])
                    self.onGoingTrip.destinationLocation = [latitude,longitude]
                    self.onGoingTrip.destinationAddress = address
                    let destination: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
                    self.isSourceToDestPathDrawn = true
                    self.showPathFrom(source: sourceCoordinate, toDestination: destination)
                    self.isCameraBearingChange = false;
                    Utility.hideLoading()
                } else {
                    Utility.hideLoading()
                }
            }
        }
    }

    func wsUpdatePaymentMode(paymentMode:Int) {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.DEVICE_TOKEN] = preferenceHelper.getDeviceToken()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] = onGoingTrip.id
        dictParam[PARAMS.PAYMENT_TYPE] = paymentMode

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.USER_CHANGE_PAYMENT_TYPE, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response: response) {
                    Utility.hideLoading()
                    self.updatePaymentView(paymentMode: paymentMode)
                    if (paymentMode == PaymentMode.CASH && CurrentTrip.shared.isPromoApplyForCash == TRUE) || (paymentMode == PaymentMode.CARD && CurrentTrip.shared.isPromoApplyForCard == TRUE)
                    {} else {
                        self.wsRemovePromo()
                    }
                } else {
                    Utility.hideLoading()    
                }
            }
        }
    }

    /*
    func openApplePay() {
        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            let paymentItem = PKPaymentSummaryItem.init(label: "Cancellation Charge", amount: NSDecimalNumber(value: CurrentTrip.shared.tripStaus.cancellationFee))
            let request = PKPaymentRequest()
            request.currencyCode = "USD" // 1
            request.countryCode = "US"// 2
            request.merchantIdentifier = "merchant.com.elluminati.eber" // 3
            request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
            request.supportedNetworks = paymentNetworks // 5
            request.paymentSummaryItems = [paymentItem] // 6
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
                displayDefaultAlert(title: "Error", message: "Unable to present Apple Pay authorization.")
                return
            }
            paymentVC.delegate = self
            Utility.hideLoading()
            self.present(paymentVC, animated: true, completion: nil)
        } else {
            displayDefaultAlert(title: "Error", message: "Unable to make Apple Pay transaction.")
        }
    }*/

    func displayDefaultAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension TripVC:MessageRecivedDelegate
{
    //MARK: - Message Recived Delegate
    func messageRecived(data: FirebaseMessage)
    {
        imgChatNotification.isHidden = !(data.isRead == false && data.type != CONSTANT.TYPE_USER)
    }

    func messageUpdated(data: FirebaseMessage)
    {
        imgChatNotification.isHidden = !(data.isRead == false && data.type != CONSTANT.TYPE_USER)
    }
}

//MARK: - Payment Handling
extension TripVC: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }

    func wsGetStripeIntent(isRetry: Bool = false) {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] =  CurrentTrip.shared.tripId
        dictParam[PARAMS.IS_TRIP] =  true
        dictParam[PARAMS.TYPE] =  CONSTANT.TYPE_USER
        dictParam[PARAMS.PAYMENT_GATEWAY_TYPE] =  PaymentMethod.Payment_gateway_type
        
        if isRetry {
            dictParam[PARAMS.is_for_retry] = true
        }

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_STRIPE_PAYMENT_INTENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in

            if (error != nil) {
                Utility.hideLoading()
            }else {
                if let value = response["payment_gateway_type"] as? Int {
                    PaymentMethod.Payment_gateway_type = "\(value)"
                }
                if PaymentMethod.Payment_gateway_type == PaymentMethod.Stripe_ID{//stripe
                    Utility.hideLoading()
                    if Parser.isSuccess(response: response,withSuccessToast: false,andErrorToast:false) {
                        //Send in Invoice if paystack
                        if let paymentMethod =  response["payment_method"] as? String {
                            if let clientSecret: String = response["client_secret"] as? String {
                                self.openStripePaymentMethod(paymentMethod: paymentMethod, clientSecret: clientSecret)
                            }
                        }
                    } else {
                        //put condition for paystack switch case
                        //send trip_id
                        self.openRetryPaymentDialog(message: (response["error"] as? String) ?? "")
                    }
                }else if PaymentMethod.Payment_gateway_type == PaymentMethod.PayStack_ID{
                    if Parser.isSuccess(response: response, withSuccessToast: true, andErrorToast: false){
                        CurrentTrip.shared.clearTripData()
                        APPDELEGATE.gotoMap()
                    } else {
                        Utility.hideLoading()
                        if (response[PARAMS.REQUIRED_PARAM] as? String)?.count ?? "".count > 0{
                            self.openPaystackPinVerificationDialog(requiredParam: response[PARAMS.REQUIRED_PARAM] as? String ?? "", reference: response["reference"] as? String ?? "")
                        }else{
                            Utility.showToast(message: ("ERROR_CODE_\(response["error_code"] as! String)".localizedCapitalized))
                            self.openRetryPaymentDialog()
                        }
                    }
                }else if PaymentMethod.Payment_gateway_type == PaymentMethod.PayU_ID{
                    if let last = self.navigationController?.viewControllers.last {
                        if !(last is PayStackVC) && !self.isCardWebLoad {
                            self.payStackVC.htmlDataString = response["html_form"] as? String ?? ""
                            self.isCardWebLoad = true
                            self.navigationController?.pushViewController(self.payStackVC, animated: true)
                        } else {
                            Utility.hideLoading()
                        }
                    } else {
                        Utility.hideLoading()
                    }
                }else if PaymentMethod.Payment_gateway_type == PaymentMethod.RazorPay{
                    if let last = self.navigationController?.viewControllers.last {
                        if !(last is PayStackVC) && !self.isCardWebLoad {
                            self.payStackVC.htmlDataString = response["html_form"] as? String ?? ""
                            self.isCardWebLoad = true
                            self.navigationController?.pushViewController(self.payStackVC, animated: true)
                        } else {
                            Utility.hideLoading()
                        }
                    } else {
                        Utility.hideLoading()
                    }
                }
                else if PaymentMethod.Payment_gateway_type == PaymentMethod.PayTabs{
                    if Parser.isSuccess(response: response,withSuccessToast: false,andErrorToast:false) {
                        if let last = self.navigationController?.viewControllers.last {
                            if !(last is PayStackVC) && !self.isCardWebLoad {
                                self.payStackVC.htmlDataString = response["authorization_url"] as? String ?? ""
                                self.isCardWebLoad = true
                                self.navigationController?.pushViewController(self.payStackVC, animated: true)
                            } else {
                                Utility.hideLoading()
                            }
                        } else {
                            Utility.hideLoading()
                        }
                    } else {
                        self.openRetryPaymentDialog()
                    }
                } else if PaymentMethod.Payment_gateway_type == PaymentMethod.Paypal_ID {
                    let amount = CurrentTrip.shared.tripStaus.cancellationFee ?? 0
                    let paypal = PaypalHelper.init(currrencyCode: CurrentTrip.shared.tripStaus.trip.currencycode ?? "", amount: "\(amount)")
                    paypal.delegate = self
                }
            }
            
            if let msgCode = response["message"] as? String {
                if msgCode == "109" {
                    CurrentTrip.shared.clearTripData()
                    APPDELEGATE.gotoMap()
                }
            } else if let intMsgCode = response["message"] as? Int {
                if intMsgCode == 109 {
                    CurrentTrip.shared.clearTripData()
                    APPDELEGATE.gotoMap()
                }
            }
        }
    }

    func openPaystackPinVerificationDialog(requiredParam:String,reference:String)
    {
        self.view.endEditing(true)

        switch requiredParam {
            case PaymentMethod.VerificationParameter.SEND_PIN:
                let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_PIN".localized, message: "EG_1234".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_PIN".localized, isHideBackButton: true, isShowBirthdayTextfield: false)

                dialogForPromo.onClickLeftButton =
                    { [unowned dialogForPromo] in
                        dialogForPromo.removeFromSuperview();
                    }

                dialogForPromo.onClickRightButton =
                    { [unowned self, unowned dialogForPromo] (text:String) in

                        if (text.count <  1)
                        {
                            Utility.showToast(message: "PLEASE_ENTER_PIN".localized)
                        }
                        else
                        {
                            wsSendPaystackRequiredDetail(requiredParam: requiredParam, reference: reference,pin: text,otp : "", phone: "", dialog: dialogForPromo)
                        }
                    }
            case PaymentMethod.VerificationParameter.SEND_OTP:
                let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_OTP".localized, message: "EG_123456".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_OTP".localized,isHideBackButton: true, isShowBirthdayTextfield: false)

                dialogForPromo.onClickLeftButton =
                    { [unowned dialogForPromo] in
                        dialogForPromo.removeFromSuperview();
                    }

                dialogForPromo.onClickRightButton =
                    { [unowned self, unowned dialogForPromo] (text:String) in
                        if (text.count <  1)
                        {
                            Utility.showToast(message: "PLEASE_ENTER_OTP".localized)
                        }
                        else
                        {
                            wsSendPaystackRequiredDetail(requiredParam: requiredParam, reference: reference,pin: "",otp : text, phone: "", dialog: dialogForPromo)
                        }
                    }
            case PaymentMethod.VerificationParameter.SEND_PHONE:
                let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_PHONE_NUMBER".localized, message: "MINIMUM_10_DIGITS".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_PHONE_NUMBER".localized,isHideBackButton: true, isShowBirthdayTextfield: false)

                dialogForPromo.onClickLeftButton =
                    { [unowned dialogForPromo] in
                        dialogForPromo.removeFromSuperview();
                    }

                dialogForPromo.onClickRightButton =
                    { [unowned self, unowned dialogForPromo] (text:String) in
                        if (text.count <  1)
                        {
                            Utility.showToast(message: "PLEASE_ENTER_PHONE_NO".localized)
                        }
                        else
                        {
                            wsSendPaystackRequiredDetail(requiredParam: requiredParam, reference: reference,pin: "",otp : "",phone:text, dialog: dialogForPromo)
                        }
                    }

            case PaymentMethod.VerificationParameter.SEND_BIRTHDAY:
                let dialogForPromo = CustomPinVerificationDialog.showCustomAlertDialog(title: "ENTER_BIRTHDATE".localized, message: "EG_DD-MM-YYYY".localized, titleLeftButton: "", titleRightButton: "TXT_APPLY".localized, txtFPlaceholder: "ENTER_BIRTHDATE".localized,isHideBackButton: true, isShowBirthdayTextfield: true)

                dialogForPromo.onClickLeftButton =
                    { [unowned dialogForPromo] in
                        dialogForPromo.removeFromSuperview();
                    }

                dialogForPromo.onClickRightButton =
                    { [unowned self, unowned dialogForPromo] (text:String) in
                        if (text.count <  1)
                        {
                            Utility.showToast(message: "PLEASE_ENTER_BIRTHDATE".localized)
                        }
                        else
                        {
                            wsSendPaystackRequiredDetail(requiredParam: requiredParam, reference: reference,pin: "",otp : "",phone:text, dialog: dialogForPromo)
                        }
                    }
            case PaymentMethod.VerificationParameter.SEND_ADDRESS:
                print(PaymentMethod.VerificationParameter.SEND_ADDRESS)
            default:
                break
        }
    }


    func wsSendPaystackRequiredDetail(requiredParam:String,reference:String,pin:String,otp:String,phone:String,dialog:CustomPinVerificationDialog)
    {
        Utility.showLoading()
        let dictParam : [String : Any] =
            [PARAMS.USER_ID      : preferenceHelper.getUserId(),
             PARAMS.TOKEN  : preferenceHelper.getSessionToken(),
             PARAMS.TYPE : CONSTANT.TYPE_USER,
             PARAMS.PAYMENT_GATEWAY_TYPE : PaymentMethod.Payment_gateway_type,
             PARAMS.REFERENCE : reference,
             PARAMS.REQUIRED_PARAM : requiredParam,
             PARAMS.PIN : pin,
             PARAMS.OTP : otp,
             PARAMS.BIRTHDAY : "",
             PARAMS.ADDRESS : "",
             PARAMS.PHONE : "",
             PARAMS.TRIP_ID : CurrentTrip.shared.tripId]

        let alamoFire:AlamofireHelper = AlamofireHelper();
        alamoFire.getResponseFromURL(url: WebService.SEND_PAYSTACK_REQUIRED_DETAIL, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        { (response, error) -> (Void) in
            Utility.hideLoading()
            if Parser.isSuccess(response: response, withSuccessToast: false, andErrorToast: false)
            {

                dialog.removeFromSuperview()
                CurrentTrip.shared.clearTripData()
                APPDELEGATE.gotoMap()

            }else{
                dialog.removeFromSuperview()

                if (response[PARAMS.REQUIRED_PARAM] as? String)?.count ?? "".count > 0{
                    self.openPaystackPinVerificationDialog(requiredParam: response[PARAMS.REQUIRED_PARAM] as? String ?? "", reference: response["reference"] as? String ?? "")
                }else{

                    if (response["error_code"] as? String)?.count ?? "".count > 0{
                        if (response["error_message"] as? String ?? "").count > 0{
                            Utility.showToast(message: (response["error_message"] as? String ?? "").localized)
                        }else{
                            Utility.showToast(message: "ERROR_CODE_\(response["error_code"] as? String ?? "")".localized)
                        }
                        self.openRetryPaymentDialog()
                    }
                }
            }
        }
    }

    func openStripePaymentMethod(paymentMethod:String, clientSecret: String) {
        StripeAPI.defaultPublishableKey = preferenceHelper.getStripeKey()
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        paymentIntentParams.paymentMethodId = paymentMethod

        //Submit the payment
        let paymentHandler = STPPaymentHandler.shared()
        paymentHandler.confirmPayment(paymentIntentParams, with: self) { [weak self] (status, paymentIntent, error) in
            guard let self = self else { return }
            switch (status) {
                case .failed:
                    print("Payment failed = \(error?.localizedDescription ?? "")")
                    self.openRetryPaymentDialog(message: (error?.localizedDescription) ?? "")
                    //self.wsFailPayment()
                    break
                case .canceled:
                    self.openRetryPaymentDialog(message: (error?.localizedDescription) ?? "")
                    //self.wsFailPayment()
                    break
                case .succeeded:
                    self.wsPayStripeIntentPayment() { (success) -> (Void) in
                        if success {
                            self.stopLocationListner()
                            CurrentTrip.shared.clearTripData()
                            APPDELEGATE.gotoMap()
                            Utility.hideLoading()
                        }
                    }
                    break
                @unknown default:
                    fatalError()
                    break
            }
        }
    }

    func openRetryPaymentDialog(message:String = "", isApplePay: Bool = false)
    {
        if isApplePay {
            let actYes = UIAlertAction(title: "Pay Again", style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                self.wsGetStripeApplePayIntent()
            }
            let card = UIAlertAction(title: "Card", style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                self.wsGetStripeIntent(isRetry: true)
            }
            Common.alert("Payment Failed", message, [actYes,card])
        } else if PaymentMethod.Payment_gateway_type == PaymentMethod.Paypal_ID{
            let actYes = UIAlertAction(title: "Pay Again", style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                self.isCardWebLoad = false
                self.wsGetStripeIntent(isRetry: true)
            }

            Common.alert("Payment Failed", message, [actYes])
        } else if PaymentMethod.Payment_gateway_type != PaymentMethod.PayU_ID{
            let actYes = UIAlertAction(title: "Pay Again", style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                self.isCardWebLoad = false
                self.wsGetStripeIntent(isRetry: true)
            }

            let actNo = UIAlertAction(title: "Add New Card", style: UIAlertAction.Style.cancel) {
                (act: UIAlertAction) in
                if  let navigationVC: UINavigationController  = self.revealViewController()?.mainViewController as? UINavigationController
                {
                    navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_PAYMENT, sender: self)
                }
            }
            Common.alert("Payment Failed", message, [actYes,actNo])
        } else {
            let actYes = UIAlertAction(title: "Pay Again", style: UIAlertAction.Style.destructive) {
                (act: UIAlertAction) in
                self.isCardWebLoad = false
                self.wsGetStripeIntent(isRetry: true)
            }
            Common.alert("Payment Failed", message, [actYes])
        }

    }

    func wsPayStripeIntentPayment(handler: @escaping (_ success:Bool) -> (Void)) {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TRIP_ID] =  CurrentTrip.shared.tripId

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.PAY_STRIPE_INTENT_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            Utility.hideLoading()
            if (error != nil) {
            } else {
                if Parser.isSuccess(response: response) {
                    handler(true)
                    return;
                } else {
                    handler(false)
                }
            }
        }
    }

    //apple pay
    func wsGetStripeIntentApplePay(paymentMethod:String, handler: @escaping (_ success:Bool, _ clientSecret:String, _ paymentMethod:String, _ errorMsg:String) -> (Void))
    {
        Utility.showLoading()
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.TYPE] = CONSTANT.TYPE_USER
        dictParam[PARAMS.PAYMENT_METHOD] = paymentMethod
        dictParam[PARAMS.TRIP_ID] = CurrentTrip.shared.tripId

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_STRIPE_PAYMENT_INTENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response:response, andErrorToast:false) {
                    if let value = response["payment_gateway_type"] as? Int {
                        PaymentMethod.Payment_gateway_type = "\(value)"
                    }
                    if let paymentMethod =  response["payment_method"] as? String {
                        if let clientSecret: String = response["client_secret"] as? String {
                            handler(true, clientSecret, paymentMethod, "")
                        }
                    } else {}
                } else {
                    Utility.hideLoading()
                    handler(false, "", "", response["error"] as? String ?? "")
                }
            }
        }
    }
    
    func wsGetStripeApplePayIntent() {
        Utility.showLoading()
        var dictParam : [String : Any] =
            [PARAMS.USER_ID      : preferenceHelper.getUserId()  ,
             PARAMS.TOKEN  : preferenceHelper.getSessionToken(),
             PARAMS.PAYMENT_GATEWAY_TYPE : PaymentMethod.Stripe_ID,
             PARAMS.TRIP_ID : CurrentTrip.shared.tripId,
             PARAMS.TYPE : CONSTANT.TYPE_USER]
        
        dictParam[PARAMS.is_cancle_trip] = true

        let alamoFire:AlamofireHelper = AlamofireHelper();
        
        alamoFire.getResponseFromURL(url: WebService.WS_TRIP_REMANING_PAYMENT, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        {
            (response, error) -> (Void) in
            Utility.hideLoading()
            if Parser.isSuccess(response: response) {
                if let client_secret = response["client_secret"] as? String, let amount = response["total_amount"] as? Double {
                    if let country = response["country_code"] as? String {
                        if let currency_code = response["currency_code"] as? String {
                            let model = ApplePayHelperModel(amount: amount.clean, currencyCode: currency_code, country: country, applePayClientSecret: client_secret)
                            self.applePay = StripeApplePayHelper(model: model)
                            self.applePay?.delegate = self
                            self.applePay?.openApplePayDialog()
                        }
                    }
                }
            } else {
                self.openRetryPaymentDialog(isApplePay: true)
            }
        }
    }

    /*
    @available(iOS 11.0, *)
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Convert the PKPayment into a PaymentMethod
        StripeAPI.defaultPublishableKey = preferenceHelper.getStripeKey()
        STPAPIClient.shared.createPaymentMethod(with: payment) { (paymentMethod: STPPaymentMethod?, error: Error?) in
            guard let paymentMethod = paymentMethod, error == nil else {
                // Present error to customer...
                return
            }
            self.wsGetStripeIntentApplePay(paymentMethod:paymentMethod.stripeId) {
                (success, clientSecret, paymentMethod, errorMsg) -> (Void) in
                if success {
                    let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                    paymentIntentParams.paymentMethodId = paymentMethod

                    // Confirm the PaymentIntent with the payment method
                    STPPaymentHandler.shared().confirmPayment(paymentIntentParams, with: self) { (status, paymentIntent, error) in
                        switch (status) {
                        case .succeeded:
                            //Save payment success
                            print("success")
                            self.wsPayStripeIntentPayment() { (success) -> (Void) in
                                if success {
                                    self.isPaymentSuccess = true
                                    handler(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.success, errors: []))
                                    self.stopLocationListner()
                                    CurrentTrip.shared.clearTripData()
                                    APPDELEGATE.gotoMap()
                                    Utility.hideLoading()
                                } else {
                                    handler(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: []))
                                }
                                return
                            }
                        case .canceled:
                            self.errorMessage = error?.localizedDescription ?? ""
                            handler(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                            Utility.showToast(message: error?.localizedDescription ?? "")
                        case .failed:
                            // Save/handle error
                            self.errorMessage = error?.localizedDescription ?? ""
                            let errors = [STPAPIClient.pkPaymentError(forStripeError: error)].compactMap({ $0 })
                            handler(PKPaymentAuthorizationResult(status: .failure, errors: errors))
                            Utility.showToast(message: error?.localizedDescription ?? "")
                        @unknown default:
                            handler(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                        }
                    }
                } else {
                    self.errorMessage = errorMsg
                    handler(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                    Utility.showToast(message: errorMsg)
                }
            }
        }
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: {
            if !self.isPaymentSuccess {
                let actYes = UIAlertAction(title: "Pay Again", style: UIAlertAction.Style.cancel) {
                    (act: UIAlertAction) in
                    self.openApplePay()
                }
                Common.alert("Payment Failed", self.errorMessage, [actYes])
            }
        })
    }*/
}

extension TripVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StopLocationTVC.className, for: indexPath) as! StopLocationTVC
        cell.setLocationData(address: arrLocations[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let addressVC = AppStoryboard.Map.instance.instantiateViewController(withIdentifier: "AddressVC") as? AddressVC {
//                addressVC.delegate = self
            addressVC.flag = AddressType.destinationAddress
//                addressVC.arrLocations = self.arrLocations
            self.navigationController?.pushViewController(addressVC, animated: true)
        }
    }
    
}

extension TripVC: PaypalHelperDelegate {
    func paymentSucess(capture: PaypalCaptureResponse) {
        self.wsPaypalPayTrip(orderID: capture.paymentId, payerId: capture.payerId)
    }
    func paymentCancel() {
        self.openRetryPaymentDialog()
    }
}

extension TripVC: StripeApplePayHelperDelegate {
    func didComplete() {
        CurrentTrip.shared.clearTripData()
        APPDELEGATE.gotoMap()
        Utility.hideLoading()
    }
    
    func didFailed(err: String) {
        openRetryPaymentDialog(isApplePay: true)
    }
}
