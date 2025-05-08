//
//  ViewController.swift
//  newt
//
//  Created by Elluminati on 10/07/18.
//  Copyright © 2018 Elluminati. All rights reserved.
//

import UIKit
import CoreLocation

//let font_right_arrow = "→"
//let font_left_arrow = "←"

let color_18556B = UIColor(red: 24.0/255.0, green: 85.0/255.0, blue: 107.0/255.0, alpha: 1.0)
struct MenuSection {
    let title: String
    let items: [String]
    let images: [UIImage]
}

class MenuVC: BaseVC {
    @IBOutlet weak var viewForFooter: UIView!
    @IBOutlet weak var collectionForMenu: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var btnLogout: UIButton!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var imgNotification: UIImageView!
    
    @IBOutlet weak var heightNavigation: NSLayoutConstraint!
    @IBOutlet weak var heightLogout: NSLayoutConstraint!
    
    @IBOutlet weak var viewUserInfo: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var tblMenu: UITableView!
    @IBOutlet weak var lblEmail: UILabel!
    
    var imagesArray = [ #imageLiteral(resourceName: "asset-menu-payments") ,#imageLiteral(resourceName: "asset-redeem"), #imageLiteral(resourceName: "asset-menu-booking") , #imageLiteral(resourceName: "asset-menu-history"), #imageLiteral(resourceName: "asset-menu-document"), #imageLiteral(resourceName: "asset-menu-referral"), #imageLiteral(resourceName: "asset-menu-setting"), #imageLiteral(resourceName: "asset-menu-heart"), #imageLiteral(resourceName: "asset-menu-contact-us")]
    let user = CurrentTrip.shared.user
    var arrForMenu = [
        "TXT_PAYMENTS".localized,
        "TXT_REDEEM".localized,
        "TXT_MY_BOOKINGS".localized,
        "TXT_HISTORY".localized,
        "TXT_DOCUMENTS".localized,
        "TXT_REFERRAL".localized,
        "TXT_SETTINGS".localized,
        "TXT_FAVOURITE_DRIVER".localized,
        "TXT_CONTACT_US".localized
    ]
    
    let menuSections: [MenuSection] = [
        MenuSection(title: "My Account", items: [
            "TXT_PAYMENTS".localized,
            "TXT_DOCUMENTS".localized,
            "TXT_SETTINGS".localized
        ], images: [
            #imageLiteral(resourceName: "asset-menu-payments"),
            #imageLiteral(resourceName: "asset-menu-document"),
            #imageLiteral(resourceName: "asset-menu-setting")
        ]),
        
        MenuSection(title: "Activity", items: [
            "TXT_MY_BOOKINGS".localized,
            "TXT_HISTORY".localized
        ], images: [
            #imageLiteral(resourceName: "asset-menu-booking"),
            #imageLiteral(resourceName: "asset-menu-history")
        ]),
        
        MenuSection(title: "Support", items: [
            "TXT_CONTACT_US".localized,
            "TXT_REFERRAL".localized,
            "TXT_FAVOURITE_DRIVER".localized
        ], images: [
            #imageLiteral(resourceName: "asset-menu-contact-us"),
            #imageLiteral(resourceName: "asset-menu-referral"),
            #imageLiteral(resourceName: "asset-menu-heart")
        ])
    ]

    
    let cellHeight: CGFloat = 85

    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        imgNotification.tintColor  = UIColor.themeImageColor
        imgNotification.isHidden = true
        viewUserInfo.layer.cornerRadius = 15
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleUserInfoTap))
        viewUserInfo.isUserInteractionEnabled = true
        viewUserInfo.addGestureRecognizer(tapGesture)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionForMenu.reloadData()
//        let height = getHeight()
//        if let revealVC = APPDELEGATE.window?.rootViewController as? PBRevealViewController {
//            revealVC.leftViewRevealHeight = height
//        }
        
    }
    
    @objc func handleUserInfoTap() {
        // Handle the tap action here
        print("User Info View Tapped")
        // For example, navigate or show a modal
        self.revealViewController()?.revealLeftView()
        if let navigationVC: UINavigationController  = self.revealViewController()?.mainViewController as? UINavigationController {
            navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_PROFILE, sender: self)
        }
    }

    
    func applyGradient() {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [
                UIColor.systemRed.cgColor,
                UIColor.white.cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Top-center
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // Bottom-center
            viewUserInfo.layer.insertSublayer(gradientLayer, at: 0)
        }

    func initialViewSetup() {
        lblTitle.text = "TXT_MENU".localizedCapitalized
        lblTitle.font = FontHelper.font(size: FontSize.medium, type: FontType.Bold)
        lblTitle.textColor = UIColor.themeTextColor
        btnLogout.titleLabel?.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        btnLogout.setTitleColor(UIColor.themeTextColor, for: .normal)
        btnLogout.setTitle("TXT_LOGOUT".localized, for: .normal)
        imgProfile.layer.cornerRadius = imgProfile.frame.width/2
        imgProfile.layer.borderWidth = 3
        imgProfile.layer.borderColor = UIColor.white.cgColor
//        btnBack.setupBackButton()
        
        if !user.picture.isEmpty {
            imgProfile.downloadedFrom(link: user.picture)
        }
        lblUserName.text = user.firstName + " " + user.lastName
        lblEmail.text = user.email
    }
    
    func getHeight() -> CGFloat {
        let maxHeightColletion = UIScreen.main.bounds.height - self.heightNavigation.constant - self.heightLogout.constant - self.view.safeAreaTop - self.view.safeAreaBottom - 110
        let column: CGFloat = 3
        let row = CGFloat(arrForMenu.count)/column
        var height = row * cellHeight
        if arrForMenu.count.isMultiple(of: 3) {
            if height > maxHeightColletion {
                height = maxHeightColletion
            }
        } else {
            height = CGFloat(Int(row) + 1) * cellHeight
        }
        return height + self.heightNavigation.constant + self.heightLogout.constant + self.view.safeAreaTop
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        viewForFooter.navigationShadow()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func actionNotification(_ sender: Any) {
       self.revealViewController()?.revealLeftView()
                let massNotificationVC = MassNotificationVC(nibName: "MassNotificationVC", bundle: nil)
                massNotificationVC.modalPresentationStyle = .fullScreen
                self.present(massNotificationVC, animated: true, completion: nil)
                
    }
    @IBAction func onClickBtnLogout(_ sender: Any) {
       self.revealViewController()?.revealLeftView()
        openLogoutDialog()
    }

    @IBAction func onClickBtnBack(_ sender: Any) {
        self.revealViewController()?.revealLeftView()
    }

    @IBAction func onClickBtnSetting(_ sender: Any) {
        self.revealViewController()?.revealLeftView()
        if let navigationVC: UINavigationController  = self.revealViewController()?.mainViewController as? UINavigationController {
             navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_SETTING, sender: self)
        }
    }

    func openLogoutDialog() {
        let dialogForLogout = CustomAlertDialog.showCustomAlertDialog(title: "TXT_LOGOUT".localized, 
                                                                      message: "MSG_ARE_YOU_SURE".localized,
                                                                      titleLeftButton: "TXT_NO".localized, 
                                                                      titleRightButton: "TXT_YES".localized)
        
        dialogForLogout.onClickLeftButton = { [/*unowned self,*/ unowned dialogForLogout] in
            dialogForLogout.removeFromSuperview();
        }
        
        dialogForLogout.onClickRightButton = { [unowned self, unowned dialogForLogout,
            weak dataSource = self.collectionForMenu.dataSource, 
            weak delegate = self.collectionForMenu.delegate] in 
            dialogForLogout.removeFromSuperview();
            printE("\(#function) \(String(describing: dataSource)) \(String(describing: delegate)) \(dialogForLogout)")
            self.wsLogout()
        }
    }
}

//extension MenuVC : UITableViewDataSource,UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return arrForMenu.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as? MenuTableViewCell {
//            cell.setData(name: arrForMenu[indexPath.row], icon: arrForMenu[indexPath.row], icons: imagesArray[indexPath.row])
//            cell.selectionStyle = .none
//            return cell
//        }
//        return UITableViewCell.init()
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 48
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.revealViewController()?.revealLeftView()
//        if let navigationVC: UINavigationController  = self.revealViewController()?.mainViewController as? UINavigationController {
//            switch indexPath.row {
//           
//            case 0:
//                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_PAYMENT, sender: self)
//            case 1:
//                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_REDEEM, sender: self)
//            case 2:
//                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_MY_BOOKING, sender: self)
//            case 3:
//                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_HISTORY, sender: self)
//            case 4:
//                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_DOCUMENTS, sender: self)
//            case 5:
//                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_SHARE_REFERRAL, sender: self)
//            case 6:
//                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_SETTING, sender: self)
//            case 7:
//                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_FAVOURITE_DRIVER, sender: self)
//            case 8:
//                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_CONTACT_US, sender: self)
//            default:
//                break
//            }
//        }
//    }
//}

extension MenuVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuSections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menuSections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as? MenuTableViewCell else {
            return UITableViewCell()
        }
        let section = menuSections[indexPath.section]
        cell.setData(name: section.items[indexPath.row], icon: section.items[indexPath.row], icons: section.images[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.revealViewController()?.revealLeftView()
        
        guard let navigationVC = self.revealViewController()?.mainViewController as? UINavigationController else { return }

        // Flatten the 2D structure into a 1D array index to match your segue logic
        let flatIndex = menuSections[..<indexPath.section].flatMap { $0.items }.count + indexPath.row
        
        switch flatIndex {
        case 0:
            navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_PAYMENT, sender: self)
        case 1:
            navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_DOCUMENTS, sender: self)
        case 2:
            navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_SETTING, sender: self)
        case 3:
            navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_MY_BOOKING, sender: self)
        case 4:
            navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_HISTORY, sender: self)
        case 5:
            navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_CONTACT_US, sender: self)
        case 6:
            navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_SHARE_REFERRAL, sender: self)
        case 7:
            navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_FAVOURITE_DRIVER, sender: self)
        default:
            break
        }
    }
}


//MARK: - CollectionView Delegate Methods
extension MenuVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func setCollectionView() {
        collectionForMenu.dataSource = self
        collectionForMenu.delegate = self
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.revealViewController()?.revealLeftView()
        if let navigationVC: UINavigationController  = self.revealViewController()?.mainViewController as? UINavigationController {
            switch indexPath.row {
            case 0:
                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_PROFILE, sender: self)
            case 1:
                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_PAYMENT, sender: self)
            case 2:
                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_REDEEM, sender: self)
            case 3:
                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_MY_BOOKING, sender: self)
            case 4:
                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_HISTORY, sender: self)
            case 5:
                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_DOCUMENTS, sender: self)
            case 6:
                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_SHARE_REFERRAL, sender: self)
            case 7:
                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_SETTING, sender: self)
            case 8:
                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_FAVOURITE_DRIVER, sender: self)
            case 9:
                navigationVC.performSegue(withIdentifier: SEGUE.HOME_TO_CONTACT_US, sender: self)
            default:
                printE("under development")
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MenuCell
        //cell.setData(name: arrForMenu[indexPath.row].0, imageUrl:  arrForMenu[indexPath.row].1)
        cell.setData(name: arrForMenu[indexPath.row], icon: arrForMenu[indexPath.row], icons: imagesArray[indexPath.row])
        
//        cell.setData(name: arrForMenu[indexPath.row].0, icon: arrForMenu[indexPath.row].1, icons: imagesArray[indexPath.row])
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrForMenu.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width-60)/3, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension MenuVC
{
    func wsLogout()
    {
        self.view.endEditing(true)
        Utility.showLoading()

        var dictParam : [String : Any] = [:]
        let currentAppVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)

        dictParam[PARAMS.APP_VERSION] = currentAppVersion
        dictParam[PARAMS.USER_ID] =  preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()

        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.LOGOUT_USER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { 
            [ weak dataSource = self.collectionForMenu.dataSource,
            weak delegate = self.collectionForMenu.delegate] (response, error) -> (Void) in            

            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.parseLogout(response: response) {
                    dataSource = nil
                    delegate = nil
                    printE("\(#function) \(String(describing: dataSource)) \(String(describing: delegate))")
                    UIViewController.clearPBRevealVC()
                    APPDELEGATE.gotoLogin()
                } else {
                    Utility.hideLoading()
                }
            }
        }
    }
}

class MenuCell:UICollectionViewCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblIcon: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblName.font = FontHelper.font(type: FontType.Regular)
        self.lblName.textColor = UIColor.themeLightTextColor
        
        self.lblIcon.setForIcon()
    }
    
    /*func setData(name: String, imageUrl: String) {
        self.lblName.text = name
        self.imgUser.image = UIImage.init(named: imageUrl)       
    }*/
    
    func setData(name: String, icon: String,icons: UIImage) {
        self.lblName.text = name
//        self.lblIcon.text = icon
        self.imgIcon.image = icons
    }
    
    deinit {
        printE("\(self) \(#function)")
    }
}

public extension UIViewController {
    static func clearPBRevealVC() {
        if let vC = APPDELEGATE.window?.rootViewController {
            if vC.isKind(of: PBRevealViewController.classForCoder()) {
                let pbrVC = vC as! PBRevealViewController
                pbrVC.delegate = nil
                
                pbrVC.tapGestureRecognizer?.delegate = nil
                pbrVC.panGestureRecognizer?.delegate = nil
                pbrVC.tapGestureRecognizer?.view?.removeGestureRecognizer(pbrVC.tapGestureRecognizer ?? UIGestureRecognizer())
                pbrVC.panGestureRecognizer?.view?.removeGestureRecognizer(pbrVC.tapGestureRecognizer ?? UIGestureRecognizer())
                
                pbrVC.mainViewController?.removeFromParent()
                pbrVC.mainViewController?.view.removeFromSuperview()
                pbrVC.leftViewController?.removeFromParent()
                pbrVC.leftViewController?.view.removeFromSuperview()
                
                pbrVC.leftViewController = UIViewController()
                pbrVC.mainViewController = UIViewController()                
            }
        }
    }
}

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblMenuTitle: UILabel!
    @IBOutlet weak var imgMenu: UIImageView!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblMenuTitle.font = FontHelper.font(size: 16, type: FontType.Regular)
        self.lblMenuTitle.textColor = UIColor.themeLightTextColor
        cellView.layer.cornerRadius = 10
    }
    
    func setData(name: String, icon: String,icons: UIImage) {
        self.lblMenuTitle.text = name
        self.imgMenu.image = icons
    }
}
