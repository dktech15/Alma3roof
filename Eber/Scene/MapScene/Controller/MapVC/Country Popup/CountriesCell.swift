//
//  CountriesCell.swift
//  Eber
//
//  Created by Rohit on 28/08/23.
//  Copyright © 2023 Elluminati. All rights reserved.
//

import UIKit

class CountriesCell: UITableViewCell {
    @IBOutlet weak var lblAlpha2 : UILabel!
    @IBOutlet weak var lblCountryName : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
