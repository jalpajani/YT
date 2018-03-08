//
//  SignUpVC.swift
//  SwiftStructure
//
//  Created by  on 07/04/17.
//  Copyright © 2017 9spl. All rights reserved.
//

import UIKit


class SignUpVC: UIViewController,UITextFieldDelegate {
    
    //MARK:- Variable Declaration
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var txtGender: IQDropDownTextField!
    @IBOutlet weak var txtFirstName: ACFloatingTextfield!
    @IBOutlet weak var txtLastName: ACFloatingTextfield!
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var txtPassword: ACFloatingTextfield!
    @IBOutlet weak var txtConfirmPassword: ACFloatingTextfield!
    
    var arrTextfields = [UITextField]()
    var parentVC = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: - SetUp UI
    func setupUI()
    {
        self.navigationBar.HeaderSet(self, leftBtnSlector: #selector(self.navigationBar.btnNavBarDismiss), rightBtnSelector:nil)
        self.arrTextfields = [txtGender]
        setTextFieldIndicator(self.txtGender, image: UIImage(named: "ico_down_drop")!)
        self.txtGender.itemList = arrGenderOptions
        self.txtGender.setSelectedRow(1, animated: true)
    }
    
    //MARK: - @IBActions
    @IBAction func btnClicked(_ sender: UIButton) {
        switch sender.tag
        {
        case 0: //Back Button
            break
        case 1: //Register User
            if validate() {
                registerUser()
                print("Success")
            }
            break
        case 2:
            self.dismiss(animated: false, completion: nil)
            let loginVC = storyBoard_Login.instantiateViewController(withIdentifier:"LoginVC") as! LoginVC
            
            APP_DELEGATE.window?.rootViewController?.present(loginVC, animated: true, completion: nil)
            break
        default: break
        }
    }
    
    //MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Register User
    func registerUser()
    {
        SVProgressHUD.show()
        
        let dicRequestData = ["Email": self.txtEmail.text as AnyObject, "FirstName": self.txtFirstName.text as AnyObject,"LastName" : self.txtLastName.text! as AnyObject,"Title": self.txtGender.selectedItem as AnyObject, "Password": self.txtPassword.text! as AnyObject, "TimeZone" : const_TimeZone as AnyObject, "DeviceId": DeviceToken as AnyObject, "PushNotificationId": "" as AnyObject,"City" : "" as AnyObject,"Country": "" as AnyObject, "State": "" as AnyObject, "Zipcode" : "" as AnyObject, "Address": "" as AnyObject, "Address1": "" as AnyObject,"Phone" : "" as AnyObject,"MiddleName": "" as AnyObject, "Language": "" as AnyObject, "DOB" : "" as AnyObject]
        
        APIManager.callAPIWithoutToken(Method: .post, url: "\(api_Register)", parameters: dicRequestData, headers: const_dictHeader, completion: { (result, headerMessage) in
            
            SVProgressHUD.dismiss()
            let dicJSONResponse = result.dictionaryValue
            
            setToUserDefaultForKey(dicJSONResponse["ProfileData"]?.dictionaryObject as AnyObject, key: key_User_Object)
            showAlertMessage("", message: headerMessage, okTitle: nil, cancelTitle: nil, okCompletion: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }, cancelCompletion: nil)
            
        }) { (httpresponse, errorMessage) in
            SVProgressHUD.dismiss()
        }
    }
    
    //MARK: - Validation
    func validate() -> Bool {
        if self.txtGender.selectedRow == -1 {
            showMessage(title: "", message: msg_SelectGender, VC: self)
            return false
        }
        if txtFirstName.text?.characters.count == 0 {
            showMessage(title: "", message: msg_EnterFirstname, VC: self)
            return false
        }
        if txtLastName.text?.characters.count == 0 {
            showMessage(title: "", message: msg_EnterLastname, VC: self)
            return false
        }
        if txtEmail.text?.characters.count == 0 {
            showMessage(title: "", message: msg_EnterEmail, VC: self)
            return false
        }
        if !(isValidEmail(txtEmail.text!)) {
            showMessage(title: "", message: msg_ValidEmail, VC: self)
            return false
        }
        if txtPassword.text?.characters.count == 0 {
            showMessage(title: "", message: msg_EnterPassword, VC: self)
            return false
        }
        if !(isValidPassword(self.txtPassword.text!)) {
            showMessage(title: "", message: msg_ValidPassword, VC: self)
            return false
        }
        if txtConfirmPassword.text?.characters.count == 0 {
            showMessage(title: "", message: msg_EnterConfirmPassword, VC: self)
            return false
        }
        if txtPassword.text != txtConfirmPassword.text {
            showMessage(title: "", message: msg_PwdConfirmPwdMatch, VC: self)
            return false
        }
        return true
    }
}
