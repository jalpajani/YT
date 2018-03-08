//
//  AddCustomerVC.swift
//  PayIt
//
//  Created by vivek versatile on 16/02/18.
//  Copyright © 2018 Kaira NewMac. All rights reserved.
//

import UIKit
import ContactsUI

class AddCustomerVC: UIViewController {

    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var txtSearch: UITextField!
    
    var arrContacts: [CNContact?] = []
    var arrFilterContacts: [CNContact?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getContacts()
    }
}


//MARK: - @IBActions
extension AddCustomerVC
{
    @IBAction func btnClickedBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnClickedAdd(_ sender: UIButton) {
        let vc = AddProductVC (nibName: "AddProductVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Tableview delegate methods
extension AddCustomerVC : UITextFieldDelegate {
    
    @IBAction func doSearch(_ sender: UITextField) {
        if (txtSearch.text?.count)! > 0 {
            arrFilterContacts.removeAll()
            for i:CNContact? in self.arrContacts {
                var fName = ""
                var familyName = ""
                var cPhone = ""
                
                if let firstName = i?.givenName {
                    fName = firstName
                }
                if let lastName = i?.familyName {
                    familyName = lastName
                }
                if let phone = (i?.phoneNumbers[0].value as! CNPhoneNumber).value(forKey: "digits") {
                    cPhone = (phone as? String)!
                }
                
                if fName.lowercased().contains((txtSearch.text?.lowercased())!)  || familyName.lowercased().contains((txtSearch.text?.lowercased())!) || cPhone.lowercased().contains((txtSearch.text?.lowercased())!) {
                    arrFilterContacts.append(i)
                }
                
                
            }
            checkRecordAvailable(self.arrFilterContacts as! [CNContact], tableView: self.tblList, targetController: self, displayMessage: msg_NoContactsAvailable)
            
        } else {
            arrFilterContacts.removeAll()
            checkRecordAvailable(self.arrContacts as! [CNContact], tableView: self.tblList, targetController: self, displayMessage: msg_NoContactsAvailable)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
    }
}
//MARK: - Tableview delegate methods
extension AddCustomerVC : UITableViewDelegate,UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 87
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = AddProductVC (nibName: "AddProductVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if txtSearch.text == "" {
            return arrContacts.count
        } else{
            return arrFilterContacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:AddCustomerCell? = tableView.dequeueReusableCell(withIdentifier: "AddCustomerCell") as? AddCustomerCell
        
        if (cell == nil) {
            let nib: NSArray = Bundle.main.loadNibNamed("AddCustomerCell", owner: self, options: nil)! as NSArray
            cell = nib.object(at: 0) as? AddCustomerCell
        }
        
        var obj: [CNContact?] = []
        if txtSearch.text == "" {
            obj = self.arrContacts
        }
        else {
            obj = self.arrFilterContacts
        }
        
        var fName = ""
        var familyName = ""
    
        if let firstName = obj[indexPath.row]?.givenName {
           fName = firstName
        }
        if let lastName = obj[indexPath.row]?.familyName {
            familyName = lastName
        }
        
        cell?.lblName.text = "\(fName)" + " \(familyName)"
        if let phone = (obj[indexPath.row]?.phoneNumbers[0].value as! CNPhoneNumber).value(forKey: "digits") {
            cell?.lblPhone.text = phone as? String
        }
        if let imgUrl = obj[indexPath.row]?.thumbnailImageData {
            cell?.imgCategory.image = UIImage(data: imgUrl)
        } else {
            cell?.imgCategory.image = UIImage(named: strPlaceHolderImg)
        }
        return cell!
    }
}

//MARK: - Setup View & Data
extension AddCustomerVC {
    
    func setView() {
        self.navigationBar.HeaderSet(self, leftBtnSlector:  #selector(self.btnClickedBack(_:)), rightBtnSelector: nil, right1BtnSelector: nil,right2BtnSelector: nil)
        
        self.tblList.register(UINib(nibName: "AddCustomerCell", bundle: nil), forCellReuseIdentifier: "AddCustomerCell")
    }
    
    func getContacts()
    {
        self.arrContacts = PhoneContacts.getContacts()
    }
}

