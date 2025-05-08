//
//  SplitPaymentVC.swift
//  Eber
//
//  Created by MacPro3 on 19/07/22.
//  Copyright © 2022 Elluminati. All rights reserved.
//

import UIKit

protocol SplitPaymentVCDelegate: AnyObject {
    func splitPaymentRequestSent()
}

class SplitPaymentVC: BaseVC {
    
    @IBOutlet weak var tblForFriends: UITableView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblEmptyMessage: UILabel!
    @IBOutlet var searchView: UIView!
    
    @IBOutlet var lblIconSearch: UILabel!
    @IBOutlet var imgIconSearch: UIImageView!
    @IBOutlet var txtSearch: UITextField!
    
    @IBOutlet var btnSearch: UIButton!
    
    @IBOutlet weak var lblSearchNote: UILabel!
    @IBOutlet weak var lblMaxUser: UILabel!

    var arrForProvider:[SearchUser] = []
    weak var delegate: SplitPaymentVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let footerView = UIView.init()
        footerView.backgroundColor = UIColor.themeViewBackgroundColor
        tblForFriends.tableFooterView = footerView
        tblForFriends.delegate = self
        tblForFriends.dataSource = self
        addFriends()
        tblForFriends.reloadData()
        showHideTableView()
        
        initialViewSetup()
        
        txtSearch.placeholder = "TXT_SEARCH_DRIVER".localized
        self.tblForFriends.register(UINib.init(nibName: "SplitPaymentUserCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.wsSearchUser), name: NSNotification.splitPaymentNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadList), name: .splitUserListRefresh, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationView.navigationShadow()
        btnSearch.setRound(withBorderColor: UIColor.clear, andCornerRadious: btnSearch.frame.height/2 , borderWidth: 1.0)
    }
    
    func initialViewSetup() {
        self.view.backgroundColor = UIColor.themeViewBackgroundColor
        self.tblForFriends.backgroundColor = UIColor.themeViewBackgroundColor

        lblSearchNote.font = FontHelper.font(size: FontSize.small, type: .Regular)
        lblSearchNote.text = "TXT_SEARCH_USER_NOTE".localized
        lblSearchNote.textColor = UIColor.themeLightTextColor
        
        lblMaxUser.font = FontHelper.font(size: FontSize.small, type: .Regular)
        lblMaxUser.text = "txt_max_split_req".localized.replacingOccurrences(of: "****", with: "\(preferenceHelper.getMaxSplitUser())")
        lblMaxUser.textColor = UIColor.themeLightTextColor

        lblEmptyMessage.text = "txt_no_user_found".localized
        lblEmptyMessage.font = FontHelper.font(size: FontSize.medium, type: FontType.Bold)
        lblEmptyMessage.textColor = UIColor.themeTextColor
        lblEmptyMessage.isHidden = true

//        btnMenu.setupBackButton()
        self.imgIconSearch.tintColor = UIColor.themeImageColor
//        lblIconSearch.text = FontAsset.icon_search
//        lblIconSearch.setForIcon()

        btnSearch.setTitle("TXT_SEARCH".localized, for: .normal)
        btnSearch.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: .Regular)
        btnSearch.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnSearch.backgroundColor = UIColor.themeButtonBackgroundColor
    }
    
    func addFriends() {
        for obj in (CurrentTrip.shared.tripStaus.trip.split_payment_users) {
            arrForProvider.append(obj)
        }
    }
    
    func removeFriend(id: String) {
        CurrentTrip.shared.tripStaus.trip.split_payment_users = CurrentTrip.shared.tripStaus.trip.split_payment_users.filter({$0._id != id})
    }
    
    func showHideTableView() {
        if self.arrForProvider.count > 0 {
            self.tblForFriends.isHidden = false
            self.lblEmptyMessage.isHidden = true
            let count = arrForProvider.filter({$0.status == .Accept || $0.status == SplitPaymentStatus.waiting || $0.status == SplitPaymentStatus.Rejected}).count
            if count >= preferenceHelper.getMaxSplitUser() {
                self.searchView.isHidden = true
                self.lblMaxUser.isHidden = false
            } else {
                self.searchView.isHidden = false
                self.lblMaxUser.isHidden = true
            }
        } else {
            self.tblForFriends.isHidden = true
            self.lblEmptyMessage.isHidden = false
            self.lblMaxUser.isHidden = true
            self.searchView.isHidden = false
            self.lblMaxUser.isHidden = true
        }
    }
    
    @IBAction func onClickBtnMenu(_ sender: Any) {
        if let navigationVC: UINavigationController  = self.revealViewController()?.mainViewController as? UINavigationController {
            navigationVC.popViewController(animated: true)
        }
    }
    
    @IBAction func onClickSearch(_ sender: UIButton) {
        Utility.showLoading()
        wsSearchUser()
    }
    
    @objc func reloadList() {
        self.arrForProvider.removeAll()
        addFriends()
        tblForFriends.reloadData()
        showHideTableView()
    }
    
    @objc func wsSearchUser() {
        
        //Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.search_user] = txtSearch.text!
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.WS_SEARCH_SPLIT_PAYMENT_USER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
         
            Utility.hideLoading()
            self.arrForProvider.removeAll()
            
            if Parser.isSuccess(response: response, withSuccessToast: false, andErrorToast: true) {
                let objUser = response["search_user_detail"] as? [String:Any] ?? [:]
                self.arrForProvider.append(SearchUser(dictionary: objUser))
            }
            
            self.addFriends()
            self.tblForFriends.reloadData()
            self.showHideTableView()
        }
    }
    
    func wsSendReq(user: SearchUser, isReSend: Bool = false) {
        Utility.showLoading()
        
        let id: String = {
            if isReSend {
                return user.user_id ?? ""
            }
            return user._id ?? ""
        }()
        
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.split_request_user_id] = id
        dictParam[PARAMS.TRIP_ID] = CurrentTrip.shared.tripId
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.WS_SEND_SPLIT_REQ, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
         
            Utility.hideLoading()
            
            if Parser.isSuccess(response: response) {
                if let index = self.arrForProvider.firstIndex(where: {$0._id == user._id}) {
                    let user = user
                    user.status = .waiting
                    self.arrForProvider.remove(at: index)
                    self.arrForProvider.insert(user, at: index)
                    self.tblForFriends.reloadData()
                    self.delegate?.splitPaymentRequestSent()
                }
                
            }
        }
    }
    
    func wsRemoveReq(user: SearchUser) {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.split_request_user_id] = user.user_id
        dictParam[PARAMS.TRIP_ID] = user.trip_id
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.WS_REMOVE_SPLIT_REQ, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
         
            Utility.hideLoading()
            
            if Parser.isSuccess(response: response) {
                if let index = self.arrForProvider.firstIndex(where: {$0._id == user._id}) {
                    self.removeFriend(id: user._id ?? "")
                    self.arrForProvider.remove(at: index)
                    self.tblForFriends.reloadData()
                    self.showHideTableView()
                }
            }
        }
    }
    
    func wsResend(user: SearchUser) {
        Utility.showLoading()
        var  dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.split_request_user_id] = user.user_id
        dictParam[PARAMS.TRIP_ID] = user.trip_id
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.WS_REMOVE_SPLIT_REQ, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
         
            Utility.hideLoading()
            
            if Parser.isSuccess(response: response) {
                if let index = self.arrForProvider.firstIndex(where: {$0._id == user._id}) {
                    self.removeFriend(id: user._id ?? "")
                    self.arrForProvider.remove(at: index)
                    self.tblForFriends.reloadData()
                    self.showHideTableView()
                }
            }
        }
    }
}

//MARK: - Table View
extension SplitPaymentVC : UITableViewDelegate,UITableViewDataSource, SplitPaymentUserCellDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrForProvider.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! SplitPaymentUserCell;
        cell.delegate = self
        let obj = arrForProvider[indexPath.row]
        cell.setData(data: obj)
        cell.selectionStyle = .none
        return cell
    }
    
    func didTapCellButtons(cell: SplitPaymentUserCell, sender: UIButton) {
        if let index = tblForFriends.indexPath(for: cell) {
            let obj = arrForProvider[index.row]
            if sender == cell.btnAdd {
                wsSendReq(user: obj)
            } else if sender == cell.btnClose {
                wsRemoveReq(user: obj)
            } else if sender == cell.btnStatus {
                if sender.titleLabel?.text == "TXT_Resend".localized {
                    wsSendReq(user: obj, isReSend: true)
                }
            }
        }
    }
}

extension TripVC: SplitPaymentVCDelegate {
    func splitPaymentRequestSent() {
        Utility.showLoading()
        self.wsGetTripStatus()
    }
}
