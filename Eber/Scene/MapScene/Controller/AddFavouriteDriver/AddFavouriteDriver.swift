//
//  AddFavouriteDriver.swift
//  Eber
//
//  Created by Elluminati on 10/07/18.
//  Copyright © 2018 Elluminati. All rights reserved.
//

import UIKit

class AddFavouriteDriverVC: BaseVC {

    @IBOutlet weak var tblForMyDriver: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var lblEmptyMessage: UILabel!
    @IBOutlet var searchView: UIView!
    
    @IBOutlet var lblIconSearch: UILabel!
    @IBOutlet var imgIconSearch: UIImageView!
    @IBOutlet var txtSearch: UITextField!
    
    @IBOutlet var btnSearch: UIButton!
    
    @IBOutlet weak var lblSearchNote: UILabel!

    var arrForProvider:[Provider] = []

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let footerView = UIView.init()
        footerView.backgroundColor = UIColor.themeViewBackgroundColor
        tblForMyDriver.tableFooterView = footerView
        tblForMyDriver.reloadData()
        initialViewSetup()
        txtSearch.placeholder = "TXT_SEARCH_DRIVER".localized
        self.tblForMyDriver.register(UINib.init(nibName: "CustomDriverDetailCell", bundle: nil), forCellReuseIdentifier: "cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.wsGetDriverList(strSearchValue: "")
    }

    func initialViewSetup() {
        self.view.backgroundColor = UIColor.themeViewBackgroundColor
        self.tblForMyDriver.backgroundColor = UIColor.themeViewBackgroundColor

        lblSearchNote.font = FontHelper.font(size: FontSize.small, type: .Regular)
        lblSearchNote.text = "TXT_SEARCH_DRIVER_NOTE".localized
        lblSearchNote.textColor = UIColor.themeLightTextColor

        lblTitle.text = "TXT_ADD_FAVOURITE_DRIVER".localizedCapitalized
        lblTitle.font = FontHelper.font(size: FontSize.medium, type: FontType.Bold)
        lblTitle.textColor = UIColor.themeTextColor

        lblEmptyMessage.text = "TXT_NO_DRIVER".localized
        lblEmptyMessage.font = FontHelper.font(size: FontSize.medium, type: FontType.Bold)
        lblEmptyMessage.textColor = UIColor.themeTextColor

//        btnMenu.setupBackButton()
        imgIconSearch.tintColor = UIColor.themeImageColor
//        lblIconSearch.text = FontAsset.icon_search
//        lblIconSearch.setForIcon()

        btnSearch.setTitle("TXT_SEARCH".localized, for: .normal)
        btnSearch.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: .Regular)
        btnSearch.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        btnSearch.backgroundColor = UIColor.themeButtonBackgroundColor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationView.navigationShadow()
        btnSearch.setRound(withBorderColor: UIColor.clear, andCornerRadious: btnSearch.frame.height/2 , borderWidth: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - Dialog
    func openConfirmationDialog() {
        let dialogForConfirmation = CustomAlertDialog.showCustomAlertDialog(title: "TXT_REMOVE_PROVIDER".localized, message: "MSG_ARE_YOU_SURE".localized, titleLeftButton: "TXT_CANCEL".localizedUppercase, titleRightButton: "TXT_OK".localizedUppercase)
        dialogForConfirmation.onClickLeftButton = { [/*unowned self,*/ unowned dialogForConfirmation] in
            dialogForConfirmation.removeFromSuperview();
        }
        dialogForConfirmation.onClickRightButton = { [/*unowned self,*/ unowned dialogForConfirmation] in
            dialogForConfirmation.removeFromSuperview();
        }
    }

    //MARK: - Actions
    @IBAction func onClickBtnSearchDriver(_ sender: Any) {
        if txtSearch.text!.isEmpty() {
            Utility.showToast(message: "msg_enter_email_phone".localized)
            return;
        } else if txtSearch.text!.isNumber() {
            let validPhoneNumber = txtSearch.text!.isValidMobileNumber()
            if validPhoneNumber.0 == false {
                Utility.showToast(message: validPhoneNumber.1)
                return;
            }
        } else {
            let validEmail = txtSearch.text!.checkEmailValidation()
            if validEmail.0 == false {
                Utility.showToast(message: validEmail.1)
                return;
            }
        }
        self.wsGetDriverList(strSearchValue: txtSearch.text!)
    }

    @IBAction func onClickBtnMenu(_ sender: Any) {
        if let navigationVC: UINavigationController  = self.revealViewController()?.mainViewController as? UINavigationController {
            navigationVC.popViewController(animated: true)
        }
    }
}

//MARK: - Table View
extension AddFavouriteDriverVC:UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrForProvider.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! CustomDriverDetailCell;
        cell.btnRemoveDriver.tag = indexPath.row
//        cell.btnRemoveDriver.setTitle(FontAsset.icon_add, for: .normal)
        cell.imgCancel.image = UIImage(systemName: "plus")
        cell.imgCancel.tintColor = .black
        cell.btnRemoveDriver.addTarget(self, action: #selector(addProvider(button:)), for: .touchUpInside)
        cell.setData(data: arrForProvider[indexPath.row])
        cell.selectionStyle = UITableViewCell.SelectionStyle.none;
        return cell
    }

    @objc func addProvider(button: UIButton) {
        self.wsAddToFavouriteProvider(index: button.tag)
    }
}

//MARK: - Web Service
extension AddFavouriteDriverVC {

    func wsGetDriverList(strSearchValue: String) {
        self.view.endEditing(true)
        Utility.showLoading()

        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] =  preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        dictParam[PARAMS.SEARCH_VALUE] = strSearchValue

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.GET_ALL_DRIVER_LIST, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in

            self.arrForProvider.removeAll()
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.isSuccess(response: response) {
                    let providerResponse:ProviderListResponse = ProviderListResponse.init(fromDictionary: response)
                    for provider in providerResponse.provider_list {
                        self.arrForProvider.append(provider)
                    }
                    if strSearchValue != ""{
                        if providerResponse.provider_list.count == 0{
                            Utility.showToast(message: "TXT_NO_DRIVER".localized)
                        }
                    }
                    Utility.hideLoading()
                } else {
                    Utility.hideLoading()
                }
            }
            self.updateUIForEmptyProvider()
            self.tblForMyDriver.reloadData()
        }
    }

    func wsAddToFavouriteProvider(index:Int) {
        if let strProviderId = self.arrForProvider[index].id, strProviderId.isEmpty == false {
            Utility.showLoading()
            let dictParam: Dictionary<String,Any> =
                [PARAMS.USER_ID:preferenceHelper.getUserId(),
                 PARAMS.TOKEN:preferenceHelper.getSessionToken(),
                 PARAMS.PROVIDER_ID:strProviderId
            ];

            let afn:AlamofireHelper = AlamofireHelper.init();
            afn.getResponseFromURL(url: WebService.ADD_FAVOURITE_DRIVER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { (response, error) -> (Void) in
                Utility.hideLoading()
                if (Parser.isSuccess(response: response, withSuccessToast: true, andErrorToast: true)) {
                    self.arrForProvider.remove(at: index)
                    self.updateUIForEmptyProvider()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    func updateUIForEmptyProvider() {
        txtSearch.text = ""
        if arrForProvider.count > 0 {
            lblEmptyMessage.isHidden = true
            tblForMyDriver.isHidden = false
        } else {
            lblEmptyMessage.isHidden = false
            tblForMyDriver.isHidden = true
        }
        tblForMyDriver.reloadData()
    }
}
