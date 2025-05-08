//
//  AddLocationTVC.swift
//  Eber
//
//  Created by Maulik Desai on 14/07/22.
//  Copyright © 2022 Elluminati. All rights reserved.
//

import UIKit

protocol AddLocationDelegate: AnyObject {
    func textField(editingDidBeginIn cell:AddLocationTVC)
    func textField(editingChangedInTextField newText: String, in cell: AddLocationTVC)
}

class AddLocationTVC: UITableViewCell, UITextFieldDelegate {

    class var className : String { return "AddLocationTVC" }
    
    var textChanged: ((String) -> Void)?
    weak var delegate: AddLocationDelegate?
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var txtLocation: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.txtLocation.delegate = self
        self.txtLocation.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        self.txtLocation.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didSelectCell))
        addGestureRecognizer(gesture)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setData(address: StopLocationAddress) {
        self.txtLocation.text = address.address ?? ""
    }
    
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
}

extension AddLocationTVC {
    @objc func didSelectCell() { self.txtLocation?.becomeFirstResponder() }
    @objc func editingDidBegin() { delegate?.textField(editingDidBeginIn: self) }
    @objc func textFieldValueChanged(_ sender: UITextField) {
        if let text = sender.text { delegate?.textField(editingChangedInTextField: text, in: self) }
    }
}
