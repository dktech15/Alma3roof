//
//  WalletHistoryItemViewCell.swift
//  ALMA3ROOF
//
//  Created by mac on 09/05/25.
//  Copyright © 2025 Elluminati. All rights reserved.
//

import UIKit

class WalletHistoryItemViewCell: UITableViewCell {
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblStatusTitle: UILabel!
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblIdTitle: UILabel!
    static let identifier = "WalletHistoryItemViewCell"
    

    override func awakeFromNib() {
        super.awakeFromNib()
        lblIdTitle.text = "TXT_ID".localized
        lblStatusTitle.text = ""
        lblDateTitle.text = ""
        viewBackground.layer.cornerRadius = 8
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
   
    func setWalletHistoryData(walletRequestData: WalletHistoryItem)
    {
        lblId.text =  String(walletRequestData.uniqueId)
                
        lblDateTime.text = Utility.stringToString(strDate: walletRequestData.createdAt, fromFormat: DateFormat.WEB, toFormat: DateFormat.DATE_TIME_FORMAT_AM_PM)
        
        let walletHistoryStatus:WalletHistoryStatus = WalletHistoryStatus(rawValue: walletRequestData.walletCommentId) ?? .Unknown;
        lblStatus.text = walletHistoryStatus.text()
        switch (walletRequestData.walletStatus)
        {
        case WalletStatus.ADD_WALLET_AMOUNT: fallthrough
        case WalletStatus.ORDER_REFUND_AMOUNT: fallthrough
        case WalletStatus.ORDER_PROFIT_AMOUNT:
            lblAmount.textColor = UIColor.themeWalletAddedColor
            lblAmount.text = "+"  +  String(walletRequestData.addedWallet) + " " + walletRequestData.toCurrencyCode
            viewBackground.backgroundColor = UIColor.themeWalletAddedColor.withAlphaComponent(0.1)
            break;
        case WalletStatus.REMOVE_WALLET_AMOUNT:fallthrough
        case WalletStatus.ORDER_CHARGE_AMOUNT:fallthrough
        case WalletStatus.ORDER_CANCELLATION_CHARGE_AMOUNT:fallthrough
        case WalletStatus.REQUEST_CHARGE_AMOUNT:
            
            lblAmount.textColor = UIColor.themeWalletDeductedColor
            lblAmount.text = "-"  +  String(walletRequestData.addedWallet) + " " + walletRequestData.fromCurrencyCode
            
            viewBackground.backgroundColor = UIColor.themeWalletDeductedColor.withAlphaComponent(0.1)
            break;
            
        default:
            break;
        }
    }
    
}
