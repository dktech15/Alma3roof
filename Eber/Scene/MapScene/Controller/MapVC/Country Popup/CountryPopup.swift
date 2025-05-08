//
//  CountryPopup.swift
//  Eber
//
//  Created by Rohit on 28/08/23.
//  Copyright © 2023 Elluminati. All rights reserved.
//

import UIKit

class CountryPopup: UIView {
    @IBOutlet weak var alertView  : UIView!
    @IBOutlet weak var tableCountry : UITableView!
    @IBOutlet weak var constraintHeight : NSLayoutConstraint!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var txtSearch : UITextField!
    
    var onClickSelect : ((Countres) -> Void)? = nil
    var onClickSelectCity : ((Cites) -> Void)? = nil
    var onClickCancel : (() -> Void)? = nil
    static let  countryPopup = "CountryPopup"
    var listCountry = [Countres]()
    var listCountryAll = [Countres]()
    var listCities = [Cites]()
    var listCitiesAll = [Cites]()
    var isCity = 0
    public static func  showCustomAlertDialog
        (title:String = "",
         message:String = "",
         countryData : [Countres],
         cityData : [Cites],
         tag:Int = 400
         ) -> CountryPopup {
        let view = UINib(nibName: countryPopup, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CountryPopup
        view.tag = tag
        view.alertView.setShadow()
        view.alertView.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.themeOverlayColor
      
        view.isCity = tag
        view.listCountry = countryData
        view.listCountryAll = countryData
        view.listCities = cityData
        view.listCitiesAll = cityData
        view.lblTitle.text = title
        view.txtSearch.placeholder  = message
        view.tableCountry.register(CountriesCell.nib, forCellReuseIdentifier: CountriesCell.identifier)
        view.tableCountry.reloadData()
        let frame = (APPDELEGATE.window?.frame)!;
        view.frame = frame;
        view.setLocalization()
        APPDELEGATE.window?.addSubview(view)
        APPDELEGATE.window?.bringSubviewToFront(view);
        return view;
    }
    func setLocalization() {
        self.backgroundColor = UIColor.themeOverlayColor
        self.alertView.backgroundColor = UIColor.white
        self.alertView.setRound(withBorderColor: .clear, andCornerRadious: 10.0, borderWidth: 1.0)
        
        let fullHeight =  (APPDELEGATE.window?.frame.height)! - 340
        var height = (self.listCountry.count * 44)
        if isCity == 1{
            height = (self.listCities.count * 44)
        }else{
            height = (self.listCountry.count * 44)
        }
        if CGFloat(height) > CGFloat(fullHeight){
            self.constraintHeight.constant = fullHeight
        }else{
            self.constraintHeight.constant = CGFloat(height)
        }
    }
    
    @IBAction func actionCancel(_ sender : UIButton){
        self.onClickCancel!()
        
    }
}

extension CountryPopup : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCity == 1{
            return listCities.count
        }else{
            return listCountry.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountriesCell.identifier) as! CountriesCell
        if isCity == 1{
            cell.lblAlpha2.isHidden = true// = listCountry[indexPath.row].alpha2 ?? ""
            cell.lblCountryName.text = listCities[indexPath.row].cityname ?? ""
        }else{
            cell.lblAlpha2.text = listCountry[indexPath.row].alpha2 ?? ""
            cell.lblCountryName.text = listCountry[indexPath.row].countryname ?? ""
          
        }
         return cell
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if isCity == 1{
            self.onClickSelectCity!(listCities[indexPath.row])
        }else{
            self.onClickSelect!(listCountry[indexPath.row])
        }
        return indexPath
    }
    
}

extension CountryPopup : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            print("Rohit :- \(txtAfterUpdate)")
            self.txtSearch.text = txtAfterUpdate
            if isCity == 1{
                listCities = self.listCitiesAll.filter({$0.cityname!.localizedCaseInsensitiveContains(txtAfterUpdate)})
                self.tableCountry.reloadData()
                if txtAfterUpdate == ""{
                    self.listCities = self.listCitiesAll
                    self.tableCountry.reloadData()
                }
            }else{
                listCountry = self.listCountryAll.filter({$0.countryname!.localizedCaseInsensitiveContains(txtAfterUpdate)})
                self.tableCountry.reloadData()
                if txtAfterUpdate == ""{
                    self.listCountry = self.listCountryAll
                    self.tableCountry.reloadData()
                }
            }
        }
        self.setLocalization()
        return false
    }
}
