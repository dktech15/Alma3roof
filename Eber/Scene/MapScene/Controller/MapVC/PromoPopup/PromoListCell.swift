//
//  PromoListCell.swift
//  Eber
//
//  Created by Rohit on 04/08/23.
//  Copyright © 2023 Elluminati. All rights reserved.
//

import UIKit

class PromoListCell: UITableViewCell {
    @IBOutlet weak var viewApply : UIView!
    @IBOutlet weak var lblPromo : UILabel!
    @IBOutlet weak var lblSubtitle : UILabel!
    @IBOutlet weak var lblDiscount : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewApply.backgroundColor = UIColor.themeImageColor

        viewApply.sizeToFit()
        viewApply.setRound(withBorderColor: .clear, andCornerRadious: (viewApply.frame.height/2), borderWidth: 0)
        
//        viewApply. .backgroundColor = UIColor.themeSelectionColor
//        lblSection.textColor = UIColor.themeButtonTitleColor
//        lblSection.font = FontHelper.font(size: FontSize.regular, type: FontType.Bold)
//        lblSection.backgroundColor = UIColor.themeSelectionColor
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
