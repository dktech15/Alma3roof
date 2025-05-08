//
//  HistoryInvoiceVC.swift
//  Edelivery
//   Created by Ellumination 23/04/17.
//  Copyright © 2017 Elluminati iMac. All rights reserved.
//

import UIKit

class HistoryInvoiceVC: BaseVC
{
    //MARK: - IBOutlet
    @IBOutlet weak var viewForHeader: UIView!
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var imgPayment: UIImageView!
    @IBOutlet weak var lblPaymentIcon: UILabel!
    @IBOutlet weak var imgPaymentIcon: UIImageView!
    @IBOutlet weak var lblPaymentMode: UILabel!
    @IBOutlet weak var lblDistance: UILabel!

    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblTotalValue: UILabel!

    @IBOutlet weak var viewForiInvoiceDialog: UIView!
    @IBOutlet weak var lblTripId: UILabel!

    @IBOutlet weak var lblIconDistane: UILabel!
    @IBOutlet weak var imgIconDistane: UIImageView!
    @IBOutlet weak var tblForInvoice: UITableView!
    
    @IBOutlet weak var tblForSplitUser: UITableView!
    
    @IBOutlet weak var lblIconTime: UILabel!
    @IBOutlet weak var imgIconTime: UIImageView!
    
    @IBOutlet weak var heightInvoice: NSLayoutConstraint!
    @IBOutlet weak var heightSplitUser: NSLayoutConstraint!

    var arrForInvoice:[[Invoice]]  = []
    var arrSplitUser:[SearchUser]  = []
    var historyInvoiceResponse:HistoryDetailResponse = HistoryDetailResponse.init(fromDictionary: [:])

    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        setupInvoice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblForInvoice.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tblForSplitUser.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tblForSplitUser.removeObserver(self, forKeyPath: "contentSize")
        tblForInvoice.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        heightInvoice.constant = tblForInvoice.contentSize.height
        heightSplitUser.constant = tblForSplitUser.contentSize.height
    }

    func initialViewSetup() {
        lblTotalTime.text = ""
        lblTotalTime.textColor = UIColor.themeTextColor
        lblTotalTime.font = FontHelper.font(size: FontSize.small, type: FontType.Bold)

        lblDistance.text = ""
        lblDistance.textColor = UIColor.themeTextColor
        lblDistance.font = FontHelper.font(size: FontSize.small, type: FontType.Bold)

        lblPaymentMode.text = ""
        lblPaymentMode.textColor = UIColor.themeTextColor
        lblPaymentMode.font = FontHelper.font(size: FontSize.small, type: FontType.Bold)

        lblTotal.text = "TXT_TOTAL".localized
        lblTotal.textColor = UIColor.themeLightTextColor
        lblTotal.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)

        lblTotalValue.text = ""
        lblTotalValue.textColor = UIColor.themeSelectionColor
        lblTotalValue.font = FontHelper.font(size: FontSize.doubleExtraLarge, type: FontType.Bold)

        lblTripId.text = ""
        lblTripId.textColor = UIColor.themeLightTextColor
        lblTripId.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)

        self.view.backgroundColor = UIColor.themeOverlayColor
        self.viewForiInvoiceDialog.setShadow()
        self.viewForiInvoiceDialog.setRound(withBorderColor: UIColor.clear, andCornerRadious: 10.0, borderWidth: 1.0)

        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissMe))
        self.view.addGestureRecognizer(tapGesture)

//        lblPaymentIcon.text = FontAsset.icon_payment_card
//        lblIconTime.text = FontAsset.icon_time
//        lblIconDistane.text = FontAsset.icon_distance
        imgIconDistane.tintColor = UIColor.themeImageColor
        imgIconTime.tintColor = UIColor.themeImageColor
//        lblPaymentIcon.setForIcon()
//        lblIconTime.setForIcon()
        lblIconDistane.setForIcon()
        
        tblForSplitUser.dataSource = self
        tblForSplitUser.delegate = self
        tblForSplitUser.separatorColor = UIColor.clear
        tblForSplitUser.register(UINib(nibName: "SplitPaymentUserInvoiceCell", bundle: nil), forCellReuseIdentifier: "SplitPaymentUserInvoiceCell")
    }

    func setupInvoice() {
        let tripDetail:InvoiceTrip = historyInvoiceResponse.trip
        lblTripId.text = tripDetail.invoiceNumber
        lblTotalValue.text = tripDetail.total.toCurrencyString(currencyCode: tripDetail.currencycode)

        if tripDetail.paymentMode == PaymentMode.CASH {
            imgPayment.image = UIImage.init(named: "asset-cash")
            lblPaymentMode.text = "TXT_PAID_BY_CASH".localized
            imgPaymentIcon.image = UIImage(named: "asset-cash")
//            self.lblPaymentIcon.text = FontAsset.icon_payment_cash
        } else if tripDetail.paymentMode == PaymentMode.CARD {
            imgPayment.image = UIImage.init(named: "asset-card")
            lblPaymentMode.text = "TXT_PAID_BY_CARD".localized
//            self.lblPaymentIcon.text = FontAsset.icon_payment_card
            imgPaymentIcon.image = UIImage(named: "asset-card")
        } else {
            imgPayment.image = UIImage.init(named: "asset-apple-pay")
            lblPaymentMode.text = "TXT_PAID_BY_APPLE_PAY".localized
//            self.lblPaymentIcon.text = FontAsset.icon_payment_card
            imgPaymentIcon.image = UIImage(named: "asset-card")
        }

        lblDistance.text = tripDetail.totalDistance.toString(places: 2) + Utility.getDistanceUnit(unit: tripDetail.unit)
        self.lblTotalTime.text = String(format:"%.2f%@", tripDetail.totalTime, MeasureUnit.MINUTES)

        if Parser.parseInvoice(tripService: historyInvoiceResponse.tripservice, tripDetail: historyInvoiceResponse.trip, arrForInvocie: &arrForInvoice) {
            tblForInvoice.reloadData()
        }
        
        arrSplitUser = historyInvoiceResponse.trip.split_payment_users
        tblForSplitUser.isHidden = historyInvoiceResponse.trip.split_payment_users.count > 0 ? false : true
        tblForSplitUser.reloadData()
    }

    @objc func dismissMe() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension HistoryInvoiceVC :UITableViewDataSource,UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tblForSplitUser {
            return 1
        }
        return arrForInvoice.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblForSplitUser {
            return arrSplitUser.count
        }
        return arrForInvoice[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblForSplitUser {
            let cell:SplitPaymentUserInvoiceCell = tableView.dequeueReusableCell(withIdentifier: "SplitPaymentUserInvoiceCell") as! SplitPaymentUserInvoiceCell
            let obj = arrSplitUser[indexPath.row]
            cell.setData(data: obj)
            cell.selectionStyle = .none
            return cell
        }
        let cell:HistoryInvoiceCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HistoryInvoiceCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let currentInvoiceItem:Invoice = arrForInvoice[indexPath.section][indexPath.row]
        cell.setCellData(cellItem: currentInvoiceItem)
        return cell;
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblForSplitUser {
            return UITableView.automaticDimension
        }
        return 50//UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tblForSplitUser {
            return 0
        }
        if section == 0 {
            return 0
        }
        return 40
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == tblForSplitUser {
            return nil
        }
        let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "section")! as! HistoryInvoiceSection
        sectionHeader.setData(title: arrForInvoice[section][0].sectionTitle)
        return sectionHeader
    }
}

class HistoryInvoiceCell:UITableViewCell
{
    @IBOutlet weak var vwTitle: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!

    deinit {
        printE("\(self) \(#function)")
    }

    override func awakeFromNib() {
        lblTitle.font = FontHelper.font(size: FontSize.regular, type: .Regular)
        lblTitle.textColor = UIColor.themeLightTextColor
        lblTitle.text = ""

        lblSubTitle.font = FontHelper.font(size: FontSize.small, type: .Light)
        lblSubTitle.textColor = UIColor.themeLightTextColor
        lblSubTitle.text = ""
        lblSubTitle.baselineAdjustment = .alignCenters

        lblPrice.font = FontHelper.font(size: FontSize.medium, type: .Bold)
        lblPrice.textColor = UIColor.themeTextColor
        lblPrice.text = ""
    }

    func setCellData(cellItem:Invoice) {
        lblTitle.text = cellItem.title!
        lblSubTitle.text = cellItem.subTitle!
        lblPrice.text = cellItem.price
    }
}

class HistoryInvoiceSection:UITableViewCell
{
    @IBOutlet weak var lblSection: UILabel!

    deinit {
        printE("\(self) \(#function)")
    }

    override func awakeFromNib() {
        lblSection.textColor = UIColor.themeSelectionColor
        lblSection.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
    }

    func setData(title: String) {
        lblSection.text =  title
    }
}
