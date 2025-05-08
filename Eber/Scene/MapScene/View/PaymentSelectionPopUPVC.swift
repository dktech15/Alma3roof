//
//  PaymentSelectionPopUPVC.swift
//  ALMA3ROOF
//
//  Created by Dhruv K on 03/04/25.
//  Copyright © 2025 Elluminati. All rights reserved.
//

import Foundation
import UIKit

protocol PaymentSelectionDelegate {
    func onClickPayementSelect(paymentMode: Int)
}

class PaymentSelectionPopUPVC: BaseVC {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tblPaymentSelection: UITableView!
    
    var imagesArray = [#imageLiteral(resourceName: "asset-card_u") , #imageLiteral(resourceName: "asset-cash_u") ]
    var arrForPaymentMethod = [
        "TXT_CARD".localized,
        "TXT_CASH".localized
    ]
    var deleate: PaymentSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.layer.cornerRadius = 16
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
//            tapGesture.cancelsTouchesInView = false
//            view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @objc func dismissView() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

//MARK: - Table View Delegate Methods
extension PaymentSelectionPopUPVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PaymentSelectionCell.className, for: indexPath) as! PaymentSelectionCell
        cell.selectionStyle = .none
        cell.iconCash.image = imagesArray[indexPath.row]
        cell.lblPaymentMethodType.text = arrForPaymentMethod[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.deleate?.onClickPayementSelect(paymentMode: indexPath.row == 0 ? PaymentMode.CARD : PaymentMode.CASH)
            self.dismissView()
        }
    }
    
}
