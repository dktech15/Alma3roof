//
//  ViewController.swift
//  Eber
//
//  Created by Elluminati on 30/08/18.
//  Copyright © 2018 Elluminati. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseCore
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

class IntroVC: BaseVC
{
    @IBOutlet weak var viewForAnimation: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblCountryPhoneCode: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var hvwAnimation: NSLayoutConstraint!
    @IBOutlet var btnGoogle: GIDSignInButton!
    @IBOutlet var imgLogo: UIImageView!
    
    @IBOutlet weak var btnGesture: UIButton!
    var socialId:String = "", strForFirstName:String = "", strForLastName:String = "", strEmail:String = ""
    var strLoginBy = ""
    var isSignInWithApple:Bool = false
    var arrForCountryList:[Country] = []
    
    @IBOutlet var socialStackView: UIStackView!
    
    var isLocationGet:Bool = false
    var isCountryListGet:Bool = false
    var city:String = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        wsGetCountries()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        
        LocationCenter.default.addObserver(self, [#selector(self.locationUpdate(_:)), #selector(self.locationFail(_:)), #selector(locationAuthorizationChanged(_:))])
        
        LocationCenter.default.startUpdatingLocation()
        
        let btnFacebook = FBLoginButton()
        btnFacebook.permissions = ["public_profile", "email"]
        btnFacebook.delegate = self
        
        if preferenceHelper.getIsUseSocialLogin() {
            hvwAnimation.constant = 250
            socialStackView.isHidden = false
            socialStackView.addArrangedSubview(btnFacebook)
            let btnAppleID = ASAuthorizationAppleIDButton()
            btnAppleID.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
            socialStackView.addArrangedSubview(btnAppleID)
            
        } else {
            hvwAnimation.constant = 150
            socialStackView.isHidden = true
            btnGoogle.isHidden = true
        }
        
        Utility.hideLoading()
        CurrentTrip.shared.currentCountryPhoneCode = CurrentTrip.shared.arrForCountries[0].code
        CurrentTrip.shared.currentCountryCode = CurrentTrip.shared.arrForCountries[0].alpha2
        CurrentTrip.shared.currentCountry = CurrentTrip.shared.arrForCountries[0].name
        
        if LocationCenter.authorizationStatus == .notDetermined || LocationCenter.authorizationStatus == .authorizedAlways || LocationCenter.authorizationStatus == .authorizedWhenInUse {
            Utility.showLoading()
        }
        
        let bundleID = Bundle.main.bundleIdentifier
        if bundleID == "com.elluminati.eber" {
            addTapOnVersion()
        }
    }
    
    override func locationUpdate(_ ntf: Notification = Common.defaultNtf) {
        guard let userInfo = ntf.userInfo else { return }
        guard let location = userInfo["location"] as? CLLocation else { return }
        LocationCenter.default.fetchCityAndCountry(location: location) { [weak self] (city, country, error) in
            self?.isLocationGet = true
            self?.fillCountry()
            LocationCenter.default.stopUpdatingLocation()
        }
    }
    
    override func locationFail(_ ntf: Notification = Common.defaultNtf) {
        print("Location:- \(ntf.description)")
        self.isLocationGet = true
        self.fillCountry()
    }
    
    override func locationAuthorizationChanged(_ ntf: Notification = Common.defaultNtf) {
        if LocationCenter.isDenied {
            Utility.hideLoading()
            self.btnGesture.isUserInteractionEnabled = true
            CurrentTrip.shared.currentCountryPhoneCode = CurrentTrip.shared.arrForCountries[0].code
            CurrentTrip.shared.currentCountry = CurrentTrip.shared.arrForCountries[0].name
            CurrentTrip.shared.currentCountryCode = CurrentTrip.shared.arrForCountries[0].alpha2
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GIDSignIn.sharedInstance.signOut()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addTapOnVersion() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClickVersionTap(_:)))
        tap.numberOfTapsRequired = 3
        self.imgLogo.addGestureRecognizer(tap)
        self.imgLogo.isUserInteractionEnabled = true
    }
    
    @objc func onClickVersionTap(_ sender: UITapGestureRecognizer) {
        let dialog = DialogForApplicationMode.showCustomAppModeDialog()
        
        dialog.onClickLeftButton = { [unowned dialog] in
            dialog.removeFromSuperview()
        }
        
        dialog.onClickRightButton = { [unowned dialog] in
            dialog.removeFromSuperview()
        }
    }
    
    func initialViewSetup() {
        lblMessage.text = "TXT_INTRO_MSG".localized
        lblMessage.textColor = UIColor.themeTextColor
        lblMessage.font = FontHelper.font(size: FontSize.large, type: FontType.Regular)
        lblCountryPhoneCode.text = CurrentTrip.shared.arrForCountries[0].code
        lblCountryPhoneCode.textColor = UIColor.themeButtonBackgroundColor
        lblCountryPhoneCode.font  = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        lblMobileNumber.text = "TXT_MOBILE_MSG".localized
        lblMobileNumber.textColor = UIColor.themeTextColor
        lblMobileNumber.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        dividerView.backgroundColor = UIColor.themeDividerColor
        btnGoogle.style = .wide
    }
    
    //MARK: - Action Methods
    
    //update- Code for latest SDK
    @IBAction func onClickBtnGoogle(_ sender: Any) {
        self.socialId = ""
        
        let signInConfig = GIDConfiguration.init(clientID:Google.CLIENT_ID)
        GIDSignIn.sharedInstance.configuration = signInConfig
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { authResult, error in
            guard error == nil else { return }
            guard let user = authResult?.user, error == nil else {
                print(error?.localizedDescription ?? "Error Occured")
                return
            }
            self.socialId = user.userID ?? ""
            self.strForFirstName = user.profile?.givenName ?? ""
            self.strForLastName = user.profile?.familyName ?? ""
            self.strEmail = user.profile?.email ?? ""
            GIDSignIn.sharedInstance.signOut()
            self.wsLogin()
        }
    }
    
    //
    
    @IBAction func onClickBtnFacebook(_ sender: Any) {
        self.socialId = ""
    }
    
    @IBAction func onClickBtnLogin(_ sender: Any) {
        self.performSegue(withIdentifier: SEGUE.INTRO_TO_PHONE, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE.INTRO_TO_PHONE {
            if let destinationVc = segue.destination as? PhoneVC {
                destinationVc.strForCountryPhoneCode = CurrentTrip.shared.currentCountryPhoneCode
                destinationVc.strForCountry = CurrentTrip.shared.currentCountry
            }
        }
        
        if segue.identifier == SEGUE.INTRO_TO_REGISTER {
            if let registerVC = segue.destination as? RegisterVC {
                if isSignInWithApple {
                    registerVC.isSignInWithApple = true
                }
                registerVC.strForSocialId = socialId;
                registerVC.strForLastName = strForLastName;
                registerVC.strForFirstName = strForFirstName;
                registerVC.strForEmail = strEmail;
                registerVC.strLoginBy = CONSTANT.SOCIAL;
                registerVC.strForPhoneNumber = "";
                registerVC.strForCountryPhoneCode = CurrentTrip.shared.currentCountryPhoneCode
                registerVC.strForCountry = CurrentTrip.shared.currentCountry
            }
        }
    }
    
    func getFBUserData() {
        if((AccessToken.current) != nil) {
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start { (connection, result, error) in
                Utility.hideLoading()
                if (error == nil) {
                    let dict = result as! [String : AnyObject]
                    let email:String = (dict["email"] as? String) ?? ""
                    Profile.loadCurrentProfile(completion: { (profile, error) in
                        if (error == nil) {
                            self.strForFirstName = profile!.firstName ?? ""
                            self.strForLastName = profile!.lastName ?? ""
                            self.strEmail = email
                            self.socialId = (profile?.userID)!
                            LoginManager.init().logOut()
                            self.wsLogin()
                        } else {
                            Utility.showToast(message: (error?.localizedDescription)!)
                        }
                    })
                }
            }
        }
    }
    
    func fillCountry() {
        if isLocationGet {
            var isCountryMatched:Bool = false
            for countries in CurrentTrip.shared.arrForCountries {
                if countries.name.lowercased() == LocationCenter.default.country.lowercased() {
                    isCountryMatched = true
                    CurrentTrip.shared.currentCity = city
                    CurrentTrip.shared.currentCountry = LocationCenter.default.country
                    CurrentTrip.shared.currentCountryPhoneCode = countries.code
                    CurrentTrip.shared.currentCountryCode = countries.alpha2
                    Utility.hideLoading()
                    self.btnGesture.isUserInteractionEnabled = true
                    break;
                }
            }
            
            if !isCountryMatched {
                CurrentTrip.shared.currentCountryPhoneCode = CurrentTrip.shared.arrForCountries[0].code
                CurrentTrip.shared.currentCountryCode = CurrentTrip.shared.arrForCountries[0].alpha2
                CurrentTrip.shared.currentCountry = CurrentTrip.shared.arrForCountries[0].name
                Utility.hideLoading()
            }
            
            DispatchQueue.main.async {
                self.lblCountryPhoneCode.text = CurrentTrip.shared.currentCountryPhoneCode
                Utility.hideLoading()
            }
        } else {
            Utility.hideLoading()
        }
    }
    
    //MARK: - GOOGLE SIGN METHOD
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Web Service Calls
    func wsLogin() {
        self.view.endEditing(true)
        Utility.showLoading()
        
        var dictParam : [String : Any] = [:]
        let currentAppVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
        dictParam[PARAMS.APP_VERSION] = currentAppVersion
        dictParam[PARAMS.DEVICE_TIMEZONE] = TimeZone.current.identifier
        dictParam[PARAMS.DEVICE_TYPE] = CONSTANT.IOS
        dictParam[PARAMS.EMAIL] = strEmail
        dictParam[PARAMS.SOCIAL_UNIQUE_ID] = socialId
        dictParam[PARAMS.DEVICE_TOKEN] = preferenceHelper.getDeviceToken()
        dictParam[PARAMS.LOGIN_BY] = CONSTANT.SOCIAL
        dictParam[PARAMS.PASSWORD] = ""
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.LOGIN_USER, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { [self] (response, error) -> (Void) in
            
            Utility.hideLoading()
            
            if (error != nil) {
                Utility.hideLoading()
            } else {
                if Parser.parseUserDetail(response: response) {
                    if !(CurrentTrip.shared.user.isReferral == TRUE) && CurrentTrip.shared.user.countryDetail.isReferral {
                        Utility.hideLoading()
                        self.performSegue(withIdentifier: SEGUE.INTRO_TO_REFERRAL, sender: self)
                    } else if (CurrentTrip.shared.user.isDocumentUploaded == FALSE) {
                        APPDELEGATE.gotoDocument()
                    } else {
                        self.wsGetTripStatus()
                    }
                    let authProvider = AuthProvider.Instance
                    authProvider.wsGenerateFirebaseAcessToken()
                } else {
                    let isSuccess:ResponseModel = ResponseModel.init(fromDictionary: response)
                    if !isSuccess.success {
                        self.performSegue(withIdentifier: SEGUE.INTRO_TO_REGISTER, sender: self)
                    }
                    Utility.hideLoading()
                }
            }
        }
    }
    
    func wsGetTripStatus() {
        var dictParam : [String : Any] = [:]
        dictParam[PARAMS.USER_ID] = preferenceHelper.getUserId()
        dictParam[PARAMS.TOKEN] = preferenceHelper.getSessionToken()
        
        let afh:AlamofireHelper = AlamofireHelper.init()
        afh.getResponseFromURL(url: WebService.CHECK_TRIP_STATUS, methodName: AlamofireHelper.POST_METHOD, paramData: dictParam) { /*[unowned self]*/ (response, error) -> (Void) in
            if (error != nil) {} else {
                if Parser.isSuccess(response: response,withSuccessToast: false,andErrorToast: false) {
                    CurrentTrip.shared.tripStaus = TripStatusResponse.init(fromDictionary: response)
                    CurrentTrip.shared.tripId = CurrentTrip.shared.tripStaus.trip.id
                    if CurrentTrip.shared.tripStaus.trip.isProviderAccepted == TRUE {
                        APPDELEGATE.gotoTrip()
                    } else {
                        APPDELEGATE.gotoMap()
                    }
                } else {
                    APPDELEGATE.gotoMap()
                }
            }
        }
    }
    

}

extension IntroVC: FBSDKLoginKit.LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil {
            debugPrint("FB login error \(error!)")
        } else {
            if let finalResult = result {
                if finalResult.isCancelled {
                    debugPrint("Login Cancelled")
                } else {
                    Utility.showLoading()
                    self.getFBUserData()
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Did logout via LoginButton")
    }
}

@available(iOS 13.0, *)
extension IntroVC: ASAuthorizationControllerDelegate {
    
    @objc func handleAppleIdRequest() {
        isSignInWithApple = true
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("User id = \(userIdentifier)\nFull Name = \(String(describing: fullName)) \nEmail id = \(String(describing: email))")
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userIdentifier) {  (credentialState, error) in
                switch credentialState {
                case .authorized:
                    print("The Apple ID credential is valid.")
                    DispatchQueue.main.async {
                        self.strForFirstName = appleIDCredential.fullName?.givenName ?? ""
                        print(appleIDCredential.fullName?.givenName ?? "")
                        self.strEmail = appleIDCredential.email ?? ""
                        self.socialId = appleIDCredential.user
                        
                        if !(appleIDCredential.email ?? "").isEmpty{
                            preferenceHelper.setSigninWithAppleEmail(appleIDCredential.email ?? "")
                        }
                        
                        if !(appleIDCredential.fullName?.givenName ?? "").isEmpty{
                            preferenceHelper.setSigninWithAppleUserName((appleIDCredential.fullName?.givenName ?? "") + " " + (appleIDCredential.fullName?.familyName ?? ""))
                        }
                        
                        DispatchQueue.main.async {
                            if preferenceHelper.getSigninWithAppleEmail().count > 0{
                                self.strEmail = preferenceHelper.getSigninWithAppleEmail()
                            }
                            if preferenceHelper.getSigninWithAppleUserName().count > 0{
                                if preferenceHelper.getSigninWithAppleUserName().components(separatedBy: " ")[0].count > 0{
                                    self.strForFirstName = preferenceHelper.getSigninWithAppleUserName().components(separatedBy: " ")[0]
                                } else {
                                    self.strForFirstName = preferenceHelper.getSigninWithAppleUserName()
                                }
                                
                                if preferenceHelper.getSigninWithAppleUserName().components(separatedBy: " ")[1].count > 0{
                                    self.strForLastName = preferenceHelper.getSigninWithAppleUserName().components(separatedBy: " ")[1]
                                }
                            }
                        }
                        
                        if appleIDCredential.email?.contains("privaterelay.appleid.com") ?? false {
                            self.wsLogin()
                        } else {
                            self.wsLogin()
                        }
                    }
                    break
                case .revoked:
                    print("The Apple ID credential is revoked.")
                    break
                case .notFound:
                    print("No credential was found, so show the sign-in UI.")
                    break
                default:
                    break
                }
            }
        } else {
            if let passwordCredential = authorization.credential as? ASPasswordCredential {
                let _ = passwordCredential.user
                let _ = passwordCredential.password
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("apple signin error = \(error.localizedDescription)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
