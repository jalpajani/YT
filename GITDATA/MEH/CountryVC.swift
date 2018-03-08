//
//  CountryVC.swift
//  MEH
//
//  Created by  on 08/07/17.
//  Copyright © 2017 Nishant Bhindi. All rights reserved.
//

import UIKit

struct CountryInfo {
    var cId: Int!
    var cName: String!
    var cDesc: String!
    var currency: String!
    var cTeleCode: Int!
    var code: String!
    
}
struct StateInfo {
    var cId: Int!
    var sId: Int!
    var sName: String!
}

class CountryVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK: - Variable Declaration
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var navigationBar: NavigationBar!
    
    var arrCountry = [CountryInfo]()
    var arrState = [StateInfo]()
    var editProfileVC = UIViewController()
    var contactInfoVC : ContactInfoVC?
    var isCounry = Int()
    var countryId = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchCountryData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if self.isCounry == 0 {
            navigationBar.lblTitle.text = msg_TitleCountry
        } else {
            navigationBar.lblTitle.text = msg_TitleState
        }
    }
    
    //MARK: - SetUp UI
    func setupUI()
    {
        self.navigationBar.HeaderSet(self, leftBtnSlector: nil, rightBtnSelector:nil)
    }
    
    //MARK:- TableView Delegate and DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isCounry == 0 {
            return arrCountry.count
        } else {
            return arrState.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as! CountryCell
        if self.isCounry == 0 {
            var countryData: CountryInfo!
            countryData = arrCountry[indexPath.row]
            cell.lblCountry.text = countryData.cName
        } else {
            var countryData: StateInfo!
            countryData = arrState[indexPath.row]
            cell.lblCountry.text = countryData.sName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if self.isCounry == 0 {
            var countryData: CountryInfo!
            countryData = arrCountry[indexPath.row]
            
            if self.contactInfoVC != nil {
                self.contactInfoVC!.txtCountry.text = countryData.cName
                self.contactInfoVC!.txtCountryCode.text = "\(countryData!.cTeleCode!)"
                self.navigationController?.popViewController(animated: true)
                return
            }
            if ((self.editProfileVC as! EditProfileVC).txtState.text?.characters.count != 0) && ((self.editProfileVC as! EditProfileVC).countryId != countryData.cId ) {
                (self.editProfileVC as! EditProfileVC).txtState.text? = ""
            }
            (self.editProfileVC as! EditProfileVC).txtCountry.text = countryData.cName
            (self.editProfileVC as! EditProfileVC).countryId = countryData.cId
            (self.editProfileVC as! EditProfileVC).txtCode.text = String(countryData.cTeleCode as Int)
        } else {
            var stateData: StateInfo!
            stateData = arrState[indexPath.row]
            (self.editProfileVC as! EditProfileVC).txtState.text = stateData.sName
            (self.editProfileVC as! EditProfileVC).stateId = stateData.sId
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Fetch Country or State data
    func fetchCountryData()
    {
        if self.isCounry == 0 {//Country
            if DBManager.sharedDB.openDatabase() {
                
                let selectQuery = "select  * from \(tblCountry)"
                do {
                    let results:FMResultSet = try DBManager.sharedDB.database.executeQuery(selectQuery, values: nil)
                    while results.next() {
                        let countries  = CountryInfo(cId: Int(results.int(forColumn: field_countryId)), cName: results.string(forColumn: field_countryName), cDesc: results.string(forColumn: field_countryDesc), currency: results.string(forColumn: field_currency), cTeleCode: Int(results.int(forColumn: field_cTeleCode)), code: results.string(forColumn: field_code))
                        arrCountry.append(countries)
                    }
                } catch {
                    print(error.localizedDescription)
                }
                DBManager.sharedDB.database.close()
            }
        } else {//State
            if DBManager.sharedDB.openDatabase() {
                let selectQuery = "select  * from \(tblState) where \(field_cId) = (\(self.countryId))"
                do {
                    let results:FMResultSet = try DBManager.sharedDB.database.executeQuery(selectQuery, values: nil)
                    while results.next() {
                        let states = StateInfo(cId: Int(results.int(forColumn: field_cId)), sId: Int(results.int(forColumn: field_sId)), sName: results.string(forColumn: field_sName))
                        arrState.append(states)
                    }
                } catch {
                    print(error.localizedDescription)
                }
                DBManager.sharedDB.database.close()
            }
        }
    }
}
