//
//  HistoryVC.swift
//  Edelivery
//
//  Created by Elluminati on 25/04/17.
//  Copyright © 2017 Elluminati iMac. All rights reserved.
//

import UIKit

class HistoryVC: BaseVC
{
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var imgMenu: UIImageView!
    
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var imgReset: UIImageView!

    @IBOutlet weak var viewForFilter: UIView!
    @IBOutlet weak var viewForFilterBackground: UIView!
    @IBOutlet weak var stackForDate: UIStackView!
    @IBOutlet weak var viewForFrom: UIView!
    @IBOutlet weak var viewForTo: UIView!
    @IBOutlet weak var btnFrom: UIButton!
    @IBOutlet weak var btnTo: UIButton!
    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var imgApply: UIImageView!

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var lblIconCalender: UILabel!
    @IBOutlet var lblIconToCalender: UILabel!
    @IBOutlet var imgIconCalender: UIImageView!
    @IBOutlet var imgIconToCalender: UIImageView!

    //Empty View
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var imgEmpty: UIImageView!
    @IBOutlet weak var lblEmpty: UILabel!
    @IBOutlet weak var lblEmptyMsg: UILabel!

    var strToDate:String = ""
    var strFromDate:String = ""
    var arrForHistory:[HistoryTrip] = []
    var arrForSection = NSMutableArray()
    var arrForCreateAt = NSMutableArray()
    var page: Int = 1
    var isCallApi: Bool = true

    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wsGetHistory(startDate: strFromDate, endDate: strToDate);
        self.setLocalization()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLayout()
    }

    //MARK: - Set localized layout
    func setLocalization() {
        view.backgroundColor = UIColor.themeViewBackgroundColor;
        tableView.backgroundColor = UIColor.themeViewBackgroundColor
        tableView.tableFooterView = UIView()
        updateUI(isUpdate: false)
        tableView.separatorColor = UIColor.themeDividerColor

        self.lblEmptyMsg.textColor = UIColor.themeLightTextColor
        self.lblEmptyMsg.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        self.lblEmptyMsg.text = "TXT_EMPTY_HISTORY_MSG".localized

        self.lblEmpty.textColor = UIColor.themeTextColor
        self.lblEmpty.font = FontHelper.font(size: FontSize.large, type: FontType.Regular)
        self.lblEmpty.text = "TXT_EMPTY_HISTORY".localized

        lblTitle.text = "TXT_HISTORY".localizedCapitalized
        lblTitle.font = FontHelper.font(size: FontSize.medium, type: FontType.Bold)
        lblTitle.textColor = UIColor.themeTextColor

        //LOCALIZED
        btnFrom.setTitle("TXT_FROM".localizedCapitalized, for: UIControl.State.normal)
        btnTo.setTitle("TXT_TO".localizedCapitalized, for: UIControl.State.normal)
        
//        btnApply.setTitle(FontAsset.icon_search, for: .normal)
//        btnApply.setRoundIconButton()

        //COLORS
        emptyView.backgroundColor = UIColor.themeViewBackgroundColor;
        viewForFilterBackground.backgroundColor = UIColor.themeWalletBGColor
        viewForTo.backgroundColor = UIColor.clear
        viewForFrom.backgroundColor = UIColor.clear
        btnFrom.setTitleColor(UIColor.themeLightTextColor, for: UIControl.State.normal)
        btnTo.setTitleColor(UIColor.themeLightTextColor, for: UIControl.State.normal)

        /*Set Font*/
        btnFrom.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Bold)
        btnTo.titleLabel?.font = FontHelper.font(size: FontSize.small, type: FontType.Bold)

//        lblIconCalender.text = FontAsset.icon_calender_blank
//        lblIconToCalender.text = FontAsset.icon_calender_blank
//        lblIconToCalender.setForIcon()
//        lblIconCalender.setForIcon()
        
        imgIconCalender.tintColor = UIColor.themeImageColor
        imgIconToCalender.tintColor = UIColor.themeImageColor
        imgMenu.tintColor = UIColor.themeImageColor
        imgReset.tintColor = UIColor.themeImageColor
        
//        lblIconCalender.font = FontHelper.assetFont(size: 18)
//        lblIconToCalender.font = FontHelper.assetFont(size: 18)

//        btnReset.setTitle(FontAsset.icon_refresh, for: .normal)
//        btnMenu.setupBackButton()
//        btnReset.setUpTopBarButton()
    }

    func setupLayout() {
        viewForFilterBackground.setRound(withBorderColor: UIColor.clear, andCornerRadious: 20, borderWidth: 1.0)
        tableView.tableFooterView = UIView()
        navigationView.navigationShadow()
    }

    //MARK: - Button action method
    @IBAction func onClickFromTo(_ sender: UIButton) {
        if sender.tag == 10 {
            let datePickerDialog:CustomDatePickerDialog = CustomDatePickerDialog.showCustomDatePickerDialog(title: "TXT_SELECT_FROM_DATE".localized, titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_OK".localized)
            datePickerDialog.setMaxDate(maxdate: Date())
            if !strToDate.isEmpty() {
                let maxDate = strToDate.toDate(format: DateFormat.DATE_MM_DD_YYYY)
                datePickerDialog.setMaxDate(maxdate: maxDate)
            }
            datePickerDialog.onClickLeftButton = { [/*unowned self,*/ unowned datePickerDialog] in
                datePickerDialog.removeFromSuperview()
            }
            datePickerDialog.onClickRightButton = { [unowned self, unowned datePickerDialog] (selectedDate:Date) in
                let localizedDate = selectedDate.toString(withFormat: DateFormat.DATE_MM_DD_YYYY)
                self.strFromDate = selectedDate.toString(withFormat: DateFormat.DATE_MM_DD_YYYY, isForceEnglish: true)
                self.btnFrom.setTitle(String(format: "%@",localizedDate), for: UIControl.State.normal)
                datePickerDialog.removeFromSuperview()
            }
        } else {
            if btnFrom.titleLabel?.text == "TXT_FROM".localized {
                Utility.showToast(message: "MSG_INVALID_DATE_WARNING".localized)
            } else {
                let datePickerDialog:CustomDatePickerDialog = CustomDatePickerDialog.showCustomDatePickerDialog(title: "TXT_SELECT_TO_DATE".localized, titleLeftButton: "TXT_CANCEL".localized, titleRightButton: "TXT_OK".localized)
                let minidate = strFromDate.toDate(format: DateFormat.DATE_MM_DD_YYYY)
                datePickerDialog.setMaxDate(maxdate: Date())
                datePickerDialog.setMinDate(mindate: minidate)
                datePickerDialog.onClickLeftButton = { [/*unowned self,*/ unowned datePickerDialog] in
                    datePickerDialog.removeFromSuperview()
                }
                datePickerDialog.onClickRightButton = { [unowned self, unowned datePickerDialog] (selectedDate:Date) in
                    let localizedDate = selectedDate.toString(withFormat: DateFormat.DATE_MM_DD_YYYY)
                    self.strToDate = selectedDate.toString(withFormat: DateFormat.DATE_MM_DD_YYYY, isForceEnglish: true)
                    self.btnTo.setTitle(String(format: "%@",localizedDate), for: UIControl.State.normal)
                    datePickerDialog.removeFromSuperview()
                }
            }
        }
    }

    @IBAction func onClickBtnResetFilter(_ sender: UIButton) {
        strToDate = "";
        strFromDate = "";
        btnFrom.setTitle("TXT_FROM".localizedCapitalized, for: UIControl.State.normal)
        btnTo.setTitle("TXT_TO".localizedCapitalized, for: UIControl.State.normal)
        self.arrForHistory.removeAll()
        self.arrForSection.removeAllObjects()
        self.page = 1
        self.tableView.reloadData()
        self.wsGetHistory(startDate: strFromDate, endDate: strToDate);
    }

    @IBAction func onClickBtnApplyFilter(_ sender: UIButton) {
        if (strFromDate.isEmpty() || strToDate.isEmpty()) {
            Utility.showToast(message: "VALIDATION_MSG_PLEASE_SELECT_DATE_FIRST".localized);
        } else {
            self.arrForHistory.removeAll()
            self.arrForSection.removeAllObjects()
            self.page = 1
            self.wsGetHistory(startDate: strFromDate, endDate: strToDate);
        }
    }

    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVc = segue.destination as? HistoryDetailVC {
            destinationVc.tripID = sender as! String
        }
    }

    //MARK: - Memory Mngmnt
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - User Define Function
    func updateUI(isUpdate:Bool = false) {
        emptyView.isHidden = isUpdate
        tableView.isHidden = !isUpdate
    }
}

//MARK: - Web Service
extension HistoryVC
{
    func wsGetHistory(startDate: String,endDate: String) {
        Utility.showLoading()
        let dictParam:[String:Any] =
            [PARAMS.TOKEN : preferenceHelper.getSessionToken(),
             PARAMS.USER_ID : preferenceHelper.getUserId(),
             PARAMS.START_DATE : startDate,
             PARAMS.END_DATE : endDate,
             PARAMS.PAGE : page]

        let alamoFire:AlamofireHelper = AlamofireHelper()
        alamoFire.getResponseFromURL(url: WebService.GET_HISTORY_LIST, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { [unowned self] (response, error) -> (Void) in
            if (error != nil) {
                Utility.hideLoading()
            } else {
                Utility.hideLoading()
                if Parser.isSuccess(response: response) {
                    let responseModel:HistoryResponse = HistoryResponse.init(fromDictionary: response)
                    let historyOrderList:[HistoryTrip] = responseModel.trips

                    if historyOrderList.count > 0 {
                        self.isCallApi = true
                        self.page = self.page + 1
                        for data in historyOrderList {
                            self.arrForHistory.append(data)
                        }
                        self.createSection()
                        self.updateUI(isUpdate: true)
                    } else {
                        self.isCallApi = false
                    }
                } else {
                    self.updateUI(isUpdate: false)
                }

                DispatchQueue.main.async { [weak self] in
                    self?.tableView?.reloadData()
                }
            }
        }
    }
}

//MARK: - Table view delegate
extension HistoryVC : UITableViewDataSource,UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrForSection.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (((arrForSection .object(at: section)) as! NSMutableArray).count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryCell
        let dict = ((arrForSection .object(at: indexPath.section)) as! NSMutableArray).object(at: indexPath.row) as! HistoryTrip
        cell.setHistoryData(data: dict )
        let lastSection = tableView.numberOfSections
        if lastSection - 1 == indexPath.section && isCallApi{
            let lastRow = tableView.numberOfRows(inSection: indexPath.section)
            if  lastRow - 1 == indexPath.row {
                self.wsGetHistory(startDate:strFromDate , endDate: strToDate)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "section")! as! HistorySection
        if (arrForSection[section] as! NSMutableArray).count > 0 {
            let dict = ((arrForSection .object(at: section)) as! NSMutableArray).object(at: 0) as! HistoryTrip
            var title = Utility.relativeDateStringForDate(strDate: Utility.stringToString(strDate: dict.userCreateTime!, fromFormat: DateFormat.WEB, toFormat: DateFormat.DATE_FORMAT)) as String
            if title == "Today"{
                title = "TXT_TODAY".localized
            } else if title == "Yesterday"{
                title = "TXT_YESTERDAY".localized
            }
            sectionHeader.setData(title:title)
        }
        return sectionHeader
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dict = ((arrForSection .object(at: indexPath.section)) as! NSMutableArray).object(at: indexPath.row) as! HistoryTrip
        if dict.isTripCompleted == TRUE {
            self.performSegue(withIdentifier:SEGUE.HISTORY_TO_HISTORY_DETAIL, sender: dict.id)
        }
    }

    @IBAction func onClickBtnMenu(_ sender: Any) {
        if let navigationVC: UINavigationController = self.revealViewController()?.mainViewController as? UINavigationController {
            navigationVC.popToRootViewController(animated: true)
        }
    }

    //MARK: - Create for section
    func createSection() {
        arrForSection.removeAllObjects()
        let arrtemp = NSMutableArray()
        arrtemp.addObjects(from: (self.arrForHistory as NSArray) as! [Any])
        for i in 0 ..< arrtemp.count {
            let dict:HistoryTrip = arrtemp .object(at: i) as! HistoryTrip
            let strDate:String = dict.userCreateTime!
            let arr = strDate .components(separatedBy:"T")
            let str:String = (arr as NSArray) .object(at: 0) as! String

            if(!arrForCreateAt.contains(str)) {
                arrForCreateAt.add(str)
            }
        }

        for j in 0 ..< arrForCreateAt.count {
            let strTempDate:String = arrForCreateAt .object(at: j) as! String
            let arr1 = NSMutableArray()

            for i in 0 ..< arrtemp.count {
                let dict:HistoryTrip = arrtemp .object(at: i) as! HistoryTrip
                let strDate:String = dict.userCreateTime!
                let arr = strDate .components(separatedBy:"T")
                let str:String = (arr as NSArray) .object(at: 0) as! String
                if(str == strTempDate) {
                    arr1.add(dict)
                }
            }

            if arr1.count > 0 {
                arrForSection.add(arr1)
            }
        }
    }
}
