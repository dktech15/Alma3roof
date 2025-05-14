//
//  EPContactCell.swift
//  EPContacts
//
//  Created by Prabaharan Elangovan on 13/10/15.
//  Copyright © 2015 Prabaharan Elangovan. All rights reserved.
//

import UIKit

class EmergencyContactCell: UITableViewCell
{

    @IBOutlet weak var viewSettings: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var imgDelete: UIImageView!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var lblShareDetail: UILabel!
    @IBOutlet weak var swForShareDetail: UISwitch!
    
    
    var contact: EPContact?
    
    deinit {
        printE("\(self) \(#function)")
    }
    
    override func awakeFromNib() {
        viewSettings.layer.cornerRadius = 8
        super.awakeFromNib()
        // Initialization code
        selectionStyle = UITableViewCell.SelectionStyle.none
       
        lblName.textColor = UIColor.themeLightTextColor
        lblName.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        
        lblPhoneNumber.textColor = UIColor.themeLightTextColor
        lblPhoneNumber.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        
        lblShareDetail.textColor = UIColor.themeTextColor
        lblShareDetail.font = FontHelper.font(size: FontSize.small, type: FontType.Bold)
        
        lblShareDetail.text = "txt_sharing_ride_details".localized
//        btnDelete.setTitle(FontAsset.icon_cross_rounded, for: .normal)
//        btnDelete.setSimpleIconButton()
        imgDelete.tintColor = UIColor.themeImageColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(data:EmergencyContactData)
    {
        
        lblName.text = data.name
        lblPhoneNumber.text = data.phone
        swForShareDetail.isOn = data.isAlwaysShareRideDetail == TRUE
        
    }
   
}
