//
//  File.swift
//  Eber
//
//  Created by Mayur on 08/06/23.
//  Copyright © 2023 Elluminati. All rights reserved.
//

import UIKit

public class SearchDriversDialog: CustomDialog {
    
    public static func  showCustomAlertDialog(inVC: UIViewController) -> SearchDriversDialog {
        var view = UINib(nibName: "SearchDriversDialog", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SearchDriversDialog
        let frame = (APPDELEGATE.window?.frame)!;
        view.frame = frame;
        
        for vw in inVC.view.subviews {
            if vw is SearchDriversDialog {
                vw.removeFromSuperview()
            }
        }
        inVC.view.addSubview(view)
        view.isHidden = true
        return view
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
}
