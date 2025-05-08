//
//  SplitPaymentUserCell.swift
//  Eber
//
//  Created by MacPro3 on 19/07/22.
//  Copyright © 2022 Elluminati. All rights reserved.
//

import UIKit

class SplitPaymentUserInvoiceCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    
    var delegate: SplitPaymentUserCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        imgUser.layer.cornerRadius = imgUser.frame.size.height/2
        imgUser.clipsToBounds = true
        
        lblName.textColor = UIColor.themeTextColor
        lblName.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        
        lblPhone.textColor = UIColor.themeTextColor
        lblPhone.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        
        lblPrice.textColor = UIColor.themeTextColor
        lblPrice.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
    }
    
    func setData(data: SearchUser) {
        lblName.text = (data.first_name ?? "") + " " + (data.last_name ?? "")
        lblPhone.text = (data.country_phone_code ?? "") + " " + (data.phone ?? "")
        imgUser.downloadedFrom(link: data.picture ?? "", placeHolder: "asset-profile-placeholder", isFromCache: false, isIndicator: false, mode: .scaleAspectFill, isAppendBaseUrl: true)
        lblPrice.text = (data.total ?? 0).toCurrencyString(currencyCode: data.currency ?? "")
    }
}
