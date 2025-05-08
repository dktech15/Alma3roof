//
//  HistoryVC.swift
//  Edelivery
//
//  Created by Elluminati on 25/04/17.
//  Copyright © 2017 Elluminati iMac. All rights reserved.
//

import UIKit
import GoogleMaps

class HistoryDetailVC: BaseVC
{
    @IBOutlet var stackView: UIStackView!

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnInvoice: UIButton!
   
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var roundedView: UIView!

    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTripNo: UILabel!

    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var lblDistanceValue: UILabel!

    @IBOutlet weak var lblEtaValue: UILabel!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var lblPickupAddress: UILabel!
    @IBOutlet weak var lblDestinationAddress: UILabel!
    
    @IBOutlet weak var tblMultipleStops: UITableView!
    @IBOutlet weak var heightTable: NSLayoutConstraint!
    
    
    /*FeedbackView*/
    @IBOutlet weak var viewForFeedback: UIView!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblDriver: UILabel!
    /*Feedback Dialog*/
    @IBOutlet weak var feedbackOverlay: UIView!
    @IBOutlet weak var feedbackAlertView: UIView!
    
    @IBOutlet weak var lblProvidername: UILabel!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var txtComment: UITextView!
    @IBOutlet weak var commentView: UIView!

    var rate:Float =  0.0
    let toolBar = UIToolbar()
    
    var hasMultipleStopPoints = false
    var arrLocations = [DestinationAddresses]()
    var historydetailResponse:HistoryDetailResponse = HistoryDetailResponse.init(fromDictionary: [:])
    var tripID:String = ""
    
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var viewForComment: UIView!
    @IBOutlet var btnExpandMap: UIButton!
    @IBOutlet var imgExpandMap: UIImageView!
    
    @IBOutlet weak var lblIconDistance: UILabel!
    @IBOutlet weak var imgIconDistance: UIImageView!
    @IBOutlet weak var lblIconETA: UILabel!
    @IBOutlet weak var imgIconETA: UIImageView!
    @IBOutlet weak var lblIconRate: UILabel!
    @IBOutlet weak var imgIconRate: UIImageView!


    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewForFeedback.isHidden = true
        
        self.tblMultipleStops.delegate = self
        self.tblMultipleStops.dataSource = self
        self.tblMultipleStops.register(UINib(nibName: StopLocationTVC.className, bundle: nil), forCellReuseIdentifier: StopLocationTVC.className)
        self.heightTable.constant = CGFloat(self.arrLocations.count * 30)
        
        self.initialViewSetup()
        self.wsGetHistoryDetail(id: tripID)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.bringSubviewToFront(btnExpandMap)
    }

    func addBottomBorderWithColor() {
        let border = CALayer()
        border.backgroundColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: txtComment.frame.height - 1, width: txtComment.frame.width, height: 1)
        txtComment.layer.addSublayer(border)
        self.view.layer.masksToBounds = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLayout()
    }

    //MARK: - Set localized layout
    func initialViewSetup() {
        roundedView.backgroundColor = UIColor.themeSelectionColor
        lblTitle.text = "TXT_HISTORY".localized
        lblTitle.font = FontHelper.font(size: FontSize.medium, type: FontType.Bold)
        lblTitle.textColor = UIColor.themeTitleColor

        view.addSubview(feedbackOverlay)
        feedbackOverlay.isHidden = true
        feedbackOverlay.backgroundColor = UIColor.themeOverlayColor

        lblDate.textColor = UIColor.themeButtonTitleColor
        lblDate.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        lblDate.backgroundColor = UIColor.themeSelectionColor
        
        lblName.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        lblName.textColor = UIColor.themeTextColor
        
        lblPrice.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        lblPrice.textColor = UIColor.themeButtonBackgroundColor
        
        lblTripNo.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        lblTripNo.textColor = UIColor.themeLightTextColor
        
        lblTime.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        lblTime.textColor = UIColor.themeLightTextColor

        btnInvoice.setTitle("TXT_INVOICE".localizedCapitalized, for: .normal)
        btnInvoice.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Light)
        btnInvoice.setTitleColor(UIColor.themeTextColor, for: .normal)
        
        lblPickupAddress.text = "TXT_PICKUP_ADDRESS".localized
        lblPickupAddress.textColor = UIColor.themeTextColor
        lblPickupAddress.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        
        lblDestinationAddress.text = "TXT_DESTINATION_ADDRESS".localized
        lblDestinationAddress.textColor = UIColor.themeTextColor
        lblDestinationAddress.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)
        
        lblComment.text = "TXT_COMMENTS".localized
        lblComment.textColor = UIColor.themeLightTextColor
        lblComment.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)

        lblRate.text = "txt_rate_driver".localized
        lblRate.textColor = UIColor.themeTextColor
        lblRate.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)

        lblDriver.text = "TXT_DRIVER".localized
        lblDriver.textColor = UIColor.themeTextColor
        lblDriver.font = FontHelper.font(size: FontSize.small, type: FontType.Regular)

        self.createToolbar(textview: txtComment)
        rate = 0.0
        // Required float rating view params
        
        self.ratingView.delegate = self
        self.ratingView.contentMode = UIView.ContentMode.scaleAspectFit
        self.ratingView.maxRating = 5
        self.ratingView.minRating = 1
        self.ratingView.rating = 0.0
        self.ratingView.editable = true
        self.ratingView.minImageSize = CGSize.init(width: 20, height: 20)
        txtComment.text = ""
        
        txtComment.placeholder = "TXT_COMMENT_PLACEHOLDER".localized
        
        // COLORS
        txtComment.textColor = UIColor.themeTextColor
        lblProvidername.textColor = UIColor.themeTextColor
        txtComment.textColor = UIColor.themeLightTextColor
        txtComment.tintColor = UIColor.themeLightTextColor

        // LOCALIZED
        self.title = "TXT_FEEDBACK".localized

        txtComment.delegate = self
        
        lblEtaValue.font = FontHelper.font(size: FontSize.small, type: .Regular)
        lblDistanceValue.font = FontHelper.font(size: FontSize.small, type: .Regular)

        /*Set Font*/
        lblProvidername.font = FontHelper.font(size: FontSize.large, type: FontType.Bold)
        txtComment.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)

        btnCancel.setTitleColor(UIColor.themeLightTextColor, for: UIControl.State.normal)
        btnCancel.titleLabel?.font = FontHelper.font(size: FontSize.medium, type: FontType.Regular)
        btnCancel.setTitle("TXT_CANCEL".localizedCapitalized, for: .normal)

        btnSubmit.setTitle("TXT_SUBMIT".localized, for: .normal)
        btnSubmit.setTitleColor(UIColor.themeButtonTitleColor, for: UIControl.State.normal)
        btnSubmit.backgroundColor = UIColor.themeButtonBackgroundColor
        btnSubmit.titleLabel?.font = FontHelper.font(size: FontSize.medium, type: FontType.Regular)
        btnSubmit.setRound()

//        btnExpandMap.setTitle(FontAsset.icon_expand, for: .normal)
//        btnExpandMap.setRoundIconButton()
//        btnExpandMap.setTitleColor(UIColor.white, for: .normal)
//        lblIconDistance.text = FontAsset.icon_distance
//        lblIconETA.text = FontAsset.icon_time
//        lblIconRate.text = FontAsset.icon_star
        imgIconRate.tintColor = UIColor.themeImageColor
        imgIconDistance.tintColor = UIColor.themeImageColor
        imgIconETA.tintColor = UIColor.themeImageColor
//        lblIconDistance.setForIcon()
//        lblIconETA.setForIcon()
//        lblIconRate.setForIcon()
//        btnBack.setupBackButton()    
    }

    @IBAction func onClickBtnExpandMap(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
        }, completion: { (complete) in
            self.headerView.isHidden.toggle()
            self.footerView.isHidden.toggle()
            self.updateViewConstraints();
            self.stackView.layoutIfNeeded()
        })
    }

    func createToolbar(textview : UITextView) {
        toolBar.barStyle = UIBarStyle.black
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.white
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(
            title: "TXT_DONE".localized,
            style: .plain,
            target: self,
            action: #selector(doneTextView(sender:))
        )
        doneButton.tag = textview.tag
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textview.inputAccessoryView = toolBar
    }

    @objc func doneTextView(sender : UIBarButtonItem) {
        txtComment.resignFirstResponder()
    }

    func setupLayout() {
        navigationView.navigationShadow()
        roundedView.sizeToFit()
        roundedView.setRound(withBorderColor: .clear, andCornerRadious: (roundedView.frame.height/2), borderWidth: 0)
        imgProfilePic.setRound()
        feedbackAlertView.setShadow()
        feedbackAlertView.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 1.0)
        commentView.setShadow()
    }

    //MARK: - Button action method
    @IBAction func onClickBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickBtnFeedBack(_ sender: Any) {
        feedbackOverlay.frame = self.view.bounds
        feedbackOverlay.isHidden = false
    }

    @IBAction func onClickBtnInvoice(_ sender: Any) {
        if let invoiceVc = AppStoryboard.History.instance.instantiateViewController(withIdentifier: "HistoryInvoiceVC") as? HistoryInvoiceVC {
            invoiceVc.modalPresentationStyle = .overCurrentContext
            invoiceVc.historyInvoiceResponse = self.historydetailResponse
            present(invoiceVc, animated: true, completion: nil)
        }
    }

    @IBAction func onClickSubmit(_ sender: UIButton) {
        if rate != 0.0 {
            wsRateToProvider()
        } else {
            Utility.showToast(message: "VALIDATION_MSG_RATE_PROVIDER".localized)
        }
    }

    @IBAction func onClickBtnCancel(_ sender: Any) {
        feedbackOverlay.isHidden = true
    }
}

//MARK: - Web Service

extension HistoryDetailVC: RatingViewDelegate, UITextViewDelegate
{
    func wsGetHistoryDetail(id: String) {
        Utility.showLoading()
        let dictParam:[String:String] =
            [PARAMS.TOKEN : preferenceHelper.getSessionToken(),
             PARAMS.USER_ID : preferenceHelper.getUserId(),
             PARAMS.TRIP_ID : id]

        let alamoFire:AlamofireHelper = AlamofireHelper();
        alamoFire.getResponseFromURL(url: WebService.GET_HISTORY_DETAIL, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam)
        { [unowned self] (response, error) -> (Void) in
            if error != nil {
                Utility.hideLoading()
            } else {
                Utility.hideLoading()
                if Parser.isSuccess(response: response) {
                    self.historydetailResponse = HistoryDetailResponse.init(fromDictionary: response)
                    if self.historydetailResponse.trip.destinationAddresses.count > 0 {
                        self.hasMultipleStopPoints = true
                        self.arrLocations = self.historydetailResponse.trip.destinationAddresses
                        self.heightTable.constant = CGFloat(self.arrLocations.count * 30)
                        self.tblMultipleStops.reloadData()
                    }
                    self.setUserDetail()
                    DispatchQueue.main.async { [unowned self] in
                        let tripDetail:InvoiceTrip = self.historydetailResponse.trip
                        self.setupMap(tripDetail: tripDetail)
                    }
                }
            }
        }
    }

    func setUserDetail() {
        let tripDetail = self.historydetailResponse.trip!
        let provider = self.historydetailResponse.provider!
        lblProvidername.text = provider.firstName + " " + provider.lastName
        lblName.text = provider.firstName + " " + provider.lastName
        lblTime.text = Utility.stringToString(strDate: tripDetail.userCreateTime!, fromFormat: DateFormat.WEB , toFormat: DateFormat.HISTORY_TIME_FORMAT)
        lblPrice.text = tripDetail.total.toCurrencyString(currencyCode: tripDetail.currencycode)
        lblTripNo.text =  ("TXT_TRIP_ID".localized + "\(tripDetail.uniqueId!)").uppercased()
        imgProfilePic.downloadedFrom(link:provider.picture)
        lblDistanceValue.text = tripDetail.totalDistance.toString(places: 2) + Utility.getDistanceUnit(unit: tripDetail.unit)

        if self.historydetailResponse.trip.isProviderRated == FALSE && self.historydetailResponse.trip.isTripCancelled == FALSE {
            viewForFeedback.isHidden = false
        } else {
            viewForFeedback.isHidden = true
        }

        var title = Utility.relativeDateStringForDate(strDate: Utility.stringToString(strDate: tripDetail.userCreateTime!, fromFormat: DateFormat.WEB, toFormat: DateFormat.DATE_FORMAT)) as String
        if title == "Today"{
            title = "TXT_TODAY".localized
        } else if title == "Yesterday" {
            title = "TXT_YESTERDAY".localized
        }
        lblDate.text = title
        lblPickupAddress.text = tripDetail.sourceAddress
        lblDestinationAddress.text = tripDetail.destinationAddress
        
        self.lblEtaValue.text = String(format:"%.2f%@", tripDetail.totalTime, MeasureUnit.MINUTES)
    }

    func setupMap(tripDetail:InvoiceTrip) {
        do {
            // Set the map style by passing the URL of the local file. Make sure style.json is present in your project
            if Bundle.main.url(forResource: "styleable_map", withExtension: "json") != nil {
               // mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                printE("Unable to find style.json")
            }
        } catch {
            printE("The style definition could not be loaded: \(error)")
        }
        let sourceLoctions = CLLocationCoordinate2D.init(latitude: tripDetail.sourceLocation[0] , longitude: tripDetail.sourceLocation[1] )
        let destinationLocation = CLLocationCoordinate2D.init(latitude: tripDetail.destinationLocation[0] , longitude: tripDetail.destinationLocation[1] )

        let pickupMarker:GMSMarker = GMSMarker.init(position: sourceLoctions)
        pickupMarker.icon = Global.imgPinPickup
        pickupMarker.map = mapView
        
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(sourceLoctions)

        if destinationLocation.latitude != 0 && destinationLocation.longitude != 0 {
            let destinationMarker:GMSMarker = GMSMarker.init(position: destinationLocation)
            destinationMarker.icon = Global.imgPinDestination
            destinationMarker.map = mapView
            bounds = bounds.includingCoordinate(destinationLocation)
        }
        
        if self.arrLocations.count > 0 {
            for stopApp in self.arrLocations {
                let wLat = stopApp.location[0]
                let wLong = stopApp.location[1]
                let location = CLLocationCoordinate2D(latitude: wLat, longitude: wLong)
                
                print("location: \(location)")
                let marker = GMSMarker()
                marker.icon = Global.imgPinSource
                marker.position = location
                marker.map = self.mapView
                
            }
        }

        let locationArray = (self.historydetailResponse.startTripToEndTripLocations) ?? [tripDetail.sourceLocation]
        let tempPath:GMSMutablePath = GMSMutablePath.init()

        if locationArray.count > 1 {
            for location in locationArray {
                let coordinate = CLLocationCoordinate2D.init(latitude: location[0], longitude: location[1])
                tempPath.add(coordinate)
                bounds = bounds.includingCoordinate(coordinate)
            }
        }

        let polyLinePath:GMSPolyline = GMSPolyline.init(path: tempPath)
        polyLinePath.strokeWidth = 5.0
        polyLinePath.strokeColor = UIColor.themeButtonBackgroundColor
        polyLinePath.map = mapView
        CATransaction.begin()
        CATransaction.setValue(0.5, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock {}
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 80.0))
        CATransaction.commit()
    }

    func RatingView(_ ratingView: RatingView, didUpdate rating: Float) {
        rate = rating
    }

    //MARK: - Web Service Calls
    func wsRateToProvider() {
        Utility.showLoading()
        var review:String = txtComment.text ?? ""
        if review.compare("TXT_COMMENT_PLACEHOLDER".localized) == .orderedSame {
            review = ""
        }

        let dictParam: Dictionary<String,Any> =
            [PARAMS.USER_ID:preferenceHelper.getUserId(),
             PARAMS.TOKEN:preferenceHelper.getSessionToken(),
             PARAMS.TRIP_ID:historydetailResponse.trip.id!,
             PARAMS.REVIEW:review,
             PARAMS.RATING:rate
        ];

        let afn:AlamofireHelper = AlamofireHelper.init();
        afn.getResponseFromURL(url: WebService.RATE_PROVIDER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { [unowned self] (response, error) -> (Void) in
            Utility.hideLoading()
            if (Parser.isSuccess(response: response)) {
                self.feedbackOverlay.frame = self.view.bounds
                self.feedbackOverlay.isHidden = true
                self.viewForFeedback.isHidden = true
            }
        }
    }
}

extension HistoryDetailVC : UITableViewDelegate, UITableViewDataSource
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
    }
    
}
