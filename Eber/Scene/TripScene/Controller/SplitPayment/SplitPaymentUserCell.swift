//
//  SplitPaymentUserCell.swift
//  Eber
//
//  Created by MacPro3 on 19/07/22.
//  Copyright © 2022 Elluminati. All rights reserved.
//

import UIKit

protocol SplitPaymentUserCellDelegate: AnyObject {
    func didTapCellButtons( cell: SplitPaymentUserCell, sender: UIButton)
}

class SplitPaymentUserCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var imgUser: UIImageView!
    
    var delegate: SplitPaymentUserCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        btnStatus.backgroundColor = .clear
        imgUser.layer.cornerRadius = imgUser.frame.size.height/2
        imgUser.clipsToBounds = true
    }
    
    func setData(data: SearchUser) {
        lblName.text = (data.first_name ?? "") + " " + (data.last_name ?? "")
        lblPhone.text = (data.country_phone_code ?? "") + " " + (data.phone ?? "")
        imgUser.downloadedFrom(link: data.picture ?? "", placeHolder: "asset-profile-placeholder", isFromCache: false, isIndicator: false, mode: .scaleAspectFill, isAppendBaseUrl: true)
        
        btnAdd.isHidden = true
        btnClose.isHidden = false
        
        switch data.status {
        case .None :
            print("add")
            btnAdd.isHidden = false
            btnClose.isHidden = true
            btnStatus.setTitle("".localized, for: .normal)
        case .Accept :
            print("Accept")
            btnStatus.setTitle("TXT_ACCEPTED".localized, for: .normal)
            btnStatus.setTitleColor(UIColor.themeWalletAddedColor, for: .normal)
        case .waiting :
            print("waiting")
            btnStatus.setTitle("TXT_WAITING".localized, for: .normal)
            btnStatus.setTitleColor(UIColor.themeButtonBackgroundColor, for: .normal)
        case .Rejected:
            print("Rejected")
            btnStatus.setTitle("TXT_Resend".localized, for: .normal)
            btnStatus.setTitleColor(UIColor.red, for: .normal)
        }
    }
    
    @IBAction func onClickButton(_ sender: UIButton) {
        delegate?.didTapCellButtons(cell: self, sender: sender)
    }
}
