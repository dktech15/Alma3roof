//
//  UIView+Utils.swift
//  BigRed
//
//  Created by Sapana Ranipa on 17/09/16.
//  Copyright © 2016 Elluminati. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

//MARK: - UIVIEW Extension
extension UIView
{
 
    func setupButton(borderColor:UIColor = UIColor.clear, backgroundColor:UIColor = UIColor.themeButtonBackgroundColor)
    {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width:0, height:1)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
        self.layer.masksToBounds = false
        self.layer.cornerRadius = (self.frame.height/2)
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true;
        self.layer.borderColor = borderColor.cgColor
        self.backgroundColor = backgroundColor
   }
    
    func applyShadowToView(_ cornerRadius : CGFloat = 5.0 ) {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width:0, height:0.7)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 1.5
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.clipsToBounds = false
    }
    
    //// for apply two corner Radius
    func navigationShadow()
    {
        for layar in (self.layer.sublayers ?? []) {
            if layar.name == "cornerRadious" || layar.name == "navigationShadow" {
                layar.removeFromSuperlayer()
            }
        }
        let path = UIBezierPath(roundedRect:self.bounds,
                                byRoundingCorners:[.bottomLeft,.bottomRight],
                                cornerRadii: CGSize(width: 10, height:  10))
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = path.cgPath
        shadowLayer.shadowColor = UIColor.themeShadowColor.cgColor
        shadowLayer.shadowOpacity = 0.27
        shadowLayer.shadowRadius = 1.8
        shadowLayer.shadowOffset = CGSize.init(width: 0, height: 2.8)
        shadowLayer.name = "navigationShadow"
        self.layer.addSublayer(shadowLayer)
        
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft , .bottomRight],
                                     cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.name = "cornerRadious"
        maskLayer1.fillColor = UIColor.themeNavigationBackgroundColor.cgColor
        maskLayer1.path = maskPath1.cgPath
        self.layer.addSublayer(maskLayer1)
        for view in self.subviews
        {
            self.bringSubviewToFront(view)
        }
    }
    
    func  setRound(withBorderColor:UIColor=UIColor.clear, andCornerRadious:CGFloat = 0.0, borderWidth:CGFloat = 1.0)
    {
        if andCornerRadious==0.0
        {
            var frame:CGRect = self.frame;
            frame.size.height=min(self.frame.size.width, self.frame.size.height) ;
            frame.size.width=frame.size.height;
            self.frame=frame;
            self.layer.cornerRadius=self.layer.frame.size.width/2;
        }
        else
        {
            self.layer.cornerRadius=andCornerRadious;
        }
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true;
        self.layer.borderColor = withBorderColor.cgColor
        
    }
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    func setShadow(shadowColor: CGColor = UIColor.themeShadowColor.cgColor,
                          shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0),
                          shadowOpacity: Float = 0.7,
                          shadowRadius: CGFloat = 5.0){
        
        self.layer.shadowColor = shadowColor;
        self.layer.shadowOffset = shadowOffset;
        self.layer.shadowOpacity = shadowOpacity;
        self.layer.shadowRadius = shadowRadius;
        self.layer.masksToBounds = false;
    }

    func sectionRound(_ lblSection:UILabel) {
        lblSection.sizeToFit();
        lblSection.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: lblSection.frame.size.width, height: 25))
        lblSection.baselineAdjustment = .alignCenters
        var path:UIBezierPath;
        if UIApplication.isRTL()
        {
            path = UIBezierPath.init(roundedRect: lblSection.bounds, byRoundingCorners: [UIRectCorner.bottomLeft,UIRectCorner.topLeft], cornerRadii: CGSize(width: 5.0, height: 5.0))
        }
        else
        {
            path = UIBezierPath.init(roundedRect: lblSection.bounds, byRoundingCorners: [UIRectCorner.bottomRight,UIRectCorner.topRight], cornerRadii: CGSize(width: 5.0, height: 5.0))
        }
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        lblSection.layer.mask = mask
        lblSection.layer.contentsGravity = CALayerContentsGravity.center
    }
}

//MARK: - Label Extension
extension UILabel
{
    func addImage(imageName: String, afterLabel bolAfterLabel: Bool = false)
    {
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: imageName)
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        
        if (bolAfterLabel)
        {
            let strLabelText: NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
            strLabelText.append(attachmentString)
            
            self.attributedText = strLabelText
        }
        else{
            let strLabelText: NSAttributedString = NSAttributedString(string: self.text!)
            let mutableAttachmentString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            
            self.attributedText = mutableAttachmentString
        }
    }
    
    func removeImage()
    {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
    
    func setForIcon()
    {
        self.textColor = UIColor.themeImageColor
        self.font = FontHelper.assetFont(size:self.font!.pointSize)
    }
}


//MARK: - Application Extension
extension UIApplication
{
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
    
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}




//MARK: - Scrollview Extension
extension UIScrollView
{
    var currentPage: Int
    {
        let currentOffset = self.contentOffset.x
        let width = self.frame.size.width
        let currentPosition = Int((currentOffset + (0.5 * width)) / width)
        return currentPosition
    }
}

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizer.State.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizer.State.began
    }
}

extension UITextView {
    func addBottomBorderWithColor(color: UIColor, height: CGFloat) {
        let border = UIView()
        border.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        border.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y+self.frame.height-height, width: self.frame.width, height: height)
        border.backgroundColor = color
        self.superview!.insertSubview(border, aboveSubview: self)
    }
}

extension UIButton
{
    func setRoundIconButton()
    {
        self.setImage(nil, for: .normal)
        self.setImage(nil, for: .selected)
        self.setRound()
        self.setTitleColor(UIColor.themeButtonTitleColor, for: .normal)
        self.setTitleColor(UIColor.themeButtonTitleColor, for: .selected)
        self.backgroundColor = UIColor.themeImageColor
        self.titleLabel?.font = FontHelper.assetFont(size: self.titleLabel?.font.pointSize ?? FontSize.regular)
    }
    
    func setSimpleIconButton(color:UIColor = UIColor.themeButtonBackgroundColor)
    {
        self.setImage(nil, for: .normal)
        self.setImage(nil, for: .selected)
        self.setTitleColor(UIColor.themeImageColor, for: .normal)
        self.setTitleColor(UIColor.themeImageColor, for: .selected)
        self.titleLabel?.font = FontHelper.assetFont(size: self.titleLabel?.font.pointSize ?? FontSize.regular)
    }
    
    
    func setUpTopBarButton(color:UIColor = UIColor.themeButtonBackgroundColor)
    {
        self.setImage(nil, for: .normal)
        self.setImage(nil, for: .selected)
        self.setTitleColor(UIColor.themeTitleColor, for: .normal)
        self.setTitleColor(UIColor.themeTitleColor, for: .selected)
        self.titleLabel?.font = FontHelper.assetFont(size: FontSize.extraLarge)
        
    }
    //ROHIT // Unicode back button code (Back image set in storyboard)
//    func setupBackButton()
//    {
//        self.setImage(nil, for:.normal)
//        self.setImage(nil, for: .selected)
//        self.setTitleColor(UIColor.themeTitleColor, for: .normal)
//
//        self.titleLabel?.font = FontHelper.assetFont(size: FontSize.extraLarge)
//
//        if UIApplication.isRTL()
//        {
//            self.setTitle(FontAsset.icon_forward_arrow, for: .normal)
//        }
//        else
//        {
//            self.setTitle(FontAsset.icon_back_arrow, for: .normal)
//        }
//
//    }
    func disable() {
        self.isEnabled = false
        self.alpha = 0.5
    }
    func enable() {
        self.isEnabled = true
        self.alpha = 1.0
    }
}

extension Notification.Name {
    static let applicationWillEnterForeground = Notification.Name.init(rawValue: "applicationWillEnterForeground")
    static let socketConnected = Notification.Name.init(rawValue: "socketConnected")
    static let splitPaymentNotification = Notification.Name.init(rawValue: "splitPaymentNotification")
    static let splitUserListRefresh = Notification.Name.init(rawValue: "splitUserListRefresh")
    static let updateSplitPaymentDialog = Notification.Name.init(rawValue: "updateSplitPaymentDialog")
}

extension UIView {
    var safeAreaTop: CGFloat {
        if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.top
            }
        }
        return 0
    }
    var safeAreaBottom: CGFloat {
        if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.bottom
            }
        }
        return 0
    }
}

extension UIApplication {
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }
}
