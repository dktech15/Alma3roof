//
//  PromoCodeVC.swift
//  Eber
//
//  Created by Rohit on 04/08/23.
//  Copyright © 2023 Elluminati. All rights reserved.
//

import UIKit

class PromoCodeVC: UIViewController {
    @IBOutlet weak var tablePromo : UITableView!
    
    var listPromoCode = [PromoCode]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tablePromo.register(PromoListCell.nib, forCellReuseIdentifier: PromoListCell.identifier)

    }
    @IBAction func actionCancel (_ sender : UIButton){
        self.view.removeFromSuperview()
//        self.dismiss(animated: true)
    }
}

extension PromoCodeVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listPromoCode.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PromoListCell.identifier) as! PromoListCell
        cell.lblPromo.text = listPromoCode[indexPath.row].promocode ?? ""
        return cell
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.dismiss(animated: true)
        return indexPath
    }
    
}
