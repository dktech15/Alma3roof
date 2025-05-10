//
//  ContactUsVC.swift
//  Eber
//
//  Created by Elluminati on 14/02/17.
//  Copyright © 2017 Elluminati. All rights reserved.
//

import UIKit

class ContactUsVC: BaseVC
{
   
    @IBOutlet weak var btnMail: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    
    @IBOutlet var btnBack: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContactUsMessage: UILabel!
    
    @IBOutlet weak var lblIconContact: UILabel!
    @IBOutlet weak var lblEmailAddress: UILabel!
    //@IBOutlet weak var lblAdminCountryPhoneCode: UILabel!
    @IBOutlet weak var lblAdminContact: UILabel!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var lblIconCall: UILabel!
    @IBOutlet weak var lblIconEmail: UILabel!
    
    @IBOutlet weak var imgIconCall: UIImageView!
    @IBOutlet weak var imgIconEmail: UIImageView!
    @IBOutlet weak var imgIconContact: UIImageView!
    
    
//MARK: View life cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        initialViewSetup()
        setupUI()
     }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
     }
   
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
    }
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        navigationView.navigationShadow()
     
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
        
    }
    
    func initialViewSetup()
    {
        view.backgroundColor = UIColor.themeViewBackgroundColor;
      
        
        lblTitle.text = "TXT_CONTACT_US".localizedCapitalized
        lblTitle.font = FontHelper.font(size: FontSize.medium
            , type: FontType.Bold)
        lblTitle.textColor = UIColor.themeTextColor
     
        lblContactUsMessage.font = FontHelper.font(size: FontSize.large
            , type: FontType.Light)
        
        lblContactUsMessage.textColor = UIColor.themeTextColor
        lblContactUsMessage.text = "TXT_CONTACT_US_MSG".localized
        
       
        
        lblEmailAddress.text =  preferenceHelper.getContactEmail()
        lblEmailAddress.font = FontHelper.font(size: FontSize.regular
            , type: FontType.Light)
        lblEmailAddress.textColor = UIColor.themeTextColor
        
        
        lblAdminContact.font = FontHelper.font(size: FontSize.regular
            , type: FontType.Light)
        lblAdminContact.textColor = UIColor.themeTextColor
        
        let adminContact = preferenceHelper.getContactNumber()
            lblAdminContact.text = adminContact
//        lblIconCall.text = FontAsset.icon_call
//        lblIconEmail.text = FontAsset.icon_message
//        lblIconContact.text = FontAsset.icon_contact
        
        imgIconCall.tintColor = UIColor.themeImageColor
        imgIconEmail.tintColor = UIColor.themeImageColor
        imgIconContact.tintColor = UIColor.themeImageColor
        
//        lblIconCall.setForIcon()
//        lblIconEmail.setForIcon()
//        lblIconContact.setForIcon()
        
//        btnBack.setupBackButton()    
   }
    @IBAction func onClickBtnMenu(_ sender: Any)
    {
        
        if  let navigationVC: UINavigationController  = self.revealViewController()?.mainViewController as? UINavigationController
        {
            navigationVC.popToRootViewController(animated: true)
        }
        
    }
    
    @IBAction func onClickBtnTerms(_ sender: UIButton) {
        guard let url = URL(string: preferenceHelper.getTermsAndCondition()) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func onClickBtnPrivacy(_ sender: Any) {
        guard let url = URL(string: preferenceHelper.getPrivacyPolicy()) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    @IBAction func onClickbtnCall(_ sender: Any)
    {
         let adminMobileNumber =  preferenceHelper.getContactNumber()
        if adminMobileNumber.isEmpty
        {
            Utility.showToast(message: "VALIDATION_MSG_UNABLE_TO_CALL".localized)
        }
        else
        {
            if let url = URL(string: "tel://\(adminMobileNumber)"), UIApplication.shared.canOpenURL(url)
            {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                }
                else {
                UIApplication.shared.openURL(url)
                }
            }
            else
            {
                Utility.showToast(message: "VALIDATION_MSG_UNABLE_TO_CALL".localized)
            }
        }
    }
    @IBAction func onClickBtnMail(_ sender: Any) {
        let email = preferenceHelper.getContactEmail()
        if let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else
        {
            Utility.showToast(message: "VALIDATION_MSG_UNABLE_TO_MAIL".localized)
        }
    }
    
    @objc func didTapInsta() {}
    @objc func didTapfacebook() {}
    
    private func setupUI() {
        view.backgroundColor = .white

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 50),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 20
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        // MARK: Header
        let titleLabel = makeLabel("TXT_CONTACT_US_MSG".localized, font: FontHelper.font(size: FontSize.large
                                                                                         , type: FontType.Light))
        let subtitle = makeLabel("Don’t hesitate to contact us whether you have a suggestion on our improvement, a complaint to discuss or an issue to solve.", font: .systemFont(ofSize: 16), color: .darkGray, lines: 0)

        contentView.addArrangedSubview(titleLabel)
        contentView.addArrangedSubview(subtitle)

        // MARK: Call & Email Buttons
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually

        let callButton = makeContactButton(icon: "phone.fill", title: "Call us", subtitle: preferenceHelper.getContactNumber(),subTitleFont: FontHelper.font(size: FontSize.regular, type: FontType.Light))
        let emailButton = makeContactButton(icon: "envelope.fill", title: "Email us", subtitle: preferenceHelper.getContactEmail(),subTitleFont: FontHelper.font(size: FontSize.regular, type: FontType.Light))
        let callTap = UITapGestureRecognizer(target: self, action: #selector(onClickbtnCall))
        callButton.addGestureRecognizer(callTap)
        buttonStack.addArrangedSubview(callButton)
        let emailTap = UITapGestureRecognizer(target: self, action: #selector(onClickBtnMail))
        emailButton.addGestureRecognizer(emailTap)
        buttonStack.addArrangedSubview(emailButton)
        contentView.addArrangedSubview(buttonStack)

        // MARK: Social Label
        contentView.addArrangedSubview(makeLabel("Contact us in Social Media", font: .systemFont(ofSize: 14)))

        // MARK: Social Items
        let instaView = makeSocialRow(icon: .instagram, name: "Instagram", info: "")
        let instaTap = UITapGestureRecognizer(target: self, action: #selector(didTapInsta))
        instaView.addGestureRecognizer(instaTap)
        let facebookView = makeSocialRow(icon: .facebook, name: "Facebook", info: "")
        let facebookTap = UITapGestureRecognizer(target: self, action: #selector(didTapfacebook))
        facebookView.addGestureRecognizer(instaTap)
        contentView.addArrangedSubview(instaView)
        contentView.addArrangedSubview(facebookView)
//        contentView.addArrangedSubview(makeSocialRow(icon: "telegram", name: "Telegram", info: ""))
//        contentView.addArrangedSubview(makeSocialRow(icon: "whatsapp", name: "WhatsUp", info: ""))
    }
    

    // MARK: Helper Views

    private func makeLabel(_ text: String, font: UIFont, color: UIColor = .black, lines: Int = 1) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = lines
        return label
    }

    private func makeContactButton(icon: String, title: String, subtitle: String,subTitleFont: UIFont = .systemFont(ofSize: 12)) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGroupedBackground
        container.layer.cornerRadius = 8
        container.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(systemName: icon))
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let titleLabel = makeLabel(title, font: .systemFont(ofSize: 18, weight: .medium))
        let subtitleLabel = makeLabel(subtitle, font: subTitleFont, color: .darkGray, lines: 2)
        subtitleLabel.textAlignment = .center

        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)

        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])

        return container
    }
  
    private func makeSocialRow(icon: ImageResource, name: String, info: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        container.layer.cornerRadius = 8
        container.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        container.layer.borderWidth = 1
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView()
        iconView.image = UIImage(resource: icon)
        iconView.tintColor = .black
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let nameLabel = makeLabel(name, font: .systemFont(ofSize: 16, weight: .medium))
        let infoLabel = makeLabel(info, font: .systemFont(ofSize: 12), color: .darkGray)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, infoLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let shareIcon = UIImageView(image: UIImage(systemName: "square.and.arrow.up"))
        shareIcon.tintColor = .black
        shareIcon.contentMode = .scaleAspectFit
        shareIcon.widthAnchor.constraint(equalToConstant: 28).isActive = true
        shareIcon.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let hStack = UIStackView(arrangedSubviews: [iconView, textStack, shareIcon])
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            hStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            hStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])

        return container
    }
}
