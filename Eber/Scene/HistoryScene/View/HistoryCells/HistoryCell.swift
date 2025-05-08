//
//  HistoryCell.swift
//  Edelivery
//
//   Created by Ellumination 25/04/17.
//  Copyright © 2017 Elluminati iMac. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblOrderNo: UILabel!
    @IBOutlet weak var lblCancelled: UILabel!
    @IBOutlet weak var mainView: UIView!

    deinit {
        printE("\(self) \(#function)")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        /*Set Font*/
        lblName.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        lblName.textColor = UIColor.themeTextColor

        lblPrice.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        lblPrice.textColor = UIColor.themeButtonBackgroundColor

        lblOrderNo.font = FontHelper.font(size: FontSize.regular, type: FontType.Regular)
        lblOrderNo.textColor = UIColor.themeLightTextColor

        lblTime.font = FontHelper.font(size: FontSize.regular, type: FontType.Light)
        lblTime.textColor = UIColor.themeLightTextColor

        lblCancelled.font =  FontHelper.font(size: FontSize.regular, type: FontType.Bold)
        lblCancelled.textColor = UIColor.themeErrorTextColor
        /*Set Color*/

        self.backgroundColor = UIColor.themeViewBackgroundColor
        self.contentView.backgroundColor = UIColor.themeViewBackgroundColor
        self.mainView.backgroundColor = UIColor.themeViewBackgroundColor
        lblCancelled.text = "TXT_CANCELLED_TRIP".localized
        imgProfilePic.setRound()
    }

    func setHistoryData(data: HistoryTrip) {
        lblPrice.text = data.total.toCurrencyString(currencyCode: data.currencycode)
        lblTime.text = Utility.stringToString(strDate: data.userCreateTime!, fromFormat: DateFormat.WEB , toFormat: DateFormat.HISTORY_TIME_FORMAT)
        lblName.text =  (data.firstName == "" && data.lastName == "") ? "No driver" : data.firstName +  " " + data.lastName
        lblOrderNo.text =  ("TXT_TRIP_ID".localized + "\(data.uniqueId!)").uppercased()
        imgProfilePic.downloadedFrom(link:data.picture)
        lblOrderNo.isHidden = true

        if data.isTripCancelled == TRUE {
            lblCancelled.isHidden = false
            if data.isTripCancelledByUser == TRUE {
                lblCancelled.text = "TXT_CANCELLED_TRIP_BY_USER".localized
            } else if data.isTripCancelledByProvider == TRUE {
                lblCancelled.text = "TXT_CANCELLED_TRIP_BY_DRIVER".localized
            } else {
                lblCancelled.text = "TXT_CANCELLED_TRIP_BY_ADMIN".localized
            }
        } else {
            lblCancelled.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        imgProfilePic.setRound()
    }
}
