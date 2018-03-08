//
//  SearchVC.swift
//  MEH
//
//  Created by  on 20/07/17.
//  Copyright © 2017 Nishant Bhindi. All rights reserved.
//

import UIKit
let cell_Height_GlobalSearch =   71.0
struct PropertyInfo {
    var pId: Int!
    var pName: String!
    var pCountry: String!
    var pState: String!
    var pCity: String!
    var pAdd1: String!
    var pAdd2: String!
    
}
class SearchVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate{
    
    //MARK: - Variable Declaration
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var txtSearch: ACFloatingTextfield!
    
    var arrProperties = [String]()
    var dashboardVC = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let _ = self.txtSearch.becomeFirstResponder()
        if self.txtSearch.text == "" {
            setNoDataFoundMsg(tableView: self.tblList, displayMessage: msg_SearchForHotel)
        }
    }
    
    //MARK: - SetUp UI
    func setupUI()
    {
        self.navigationBar.HeaderSet(self, leftBtnSlector: nil, rightBtnSelector:nil)
        self.tblList.estimatedRowHeight = CGFloat(cell_Height_GlobalSearch)
        self.tblList.rowHeight = UITableViewAutomaticDimension
    }
    
    //MARK:- TableView Delegate and DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.txtSearch.text == "" {
            return 0
        } else {
            return self.arrProperties.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        let data = self.arrProperties[indexPath.row].data(using: String.Encoding.utf8, allowLossyConversion: false)
        if data != nil {
            let value = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue) as String?
            cell.lblHotel.text = value
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        (self.dashboardVC as! DashboardVC).txtSearch.text = self.arrProperties[indexPath.row]
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Fetch Country or State data
    func fetchPropertiesData()
    {
        if self.arrProperties.count>0
        {
            self.arrProperties.removeAll()
        }
        if DBManager.sharedDB.openDatabase() {
            let searchText = "\"%\(self.txtSearch.text!)%\""
            let selectQuery = "SELECT 1 as position, \(field_pCountry) as SearchText from \(tblProperty) WHERE \(field_pCountry) like \(searchText) UNION SELECT 2 as position, (\(field_pState) ||\", \"||\(field_pCountry)) as SearchText from \(tblProperty) WHERE (\(field_pState) like \(searchText) OR \(field_pCountry) like \(searchText)) AND (\(field_pState) != NULL OR \(field_pState) != \"\") UNION SELECT 3 as position, (\(field_pCity) ||\", \"||\(field_pState)||\", \"||\(field_pCountry)) as SearchText from \(tblProperty) WHERE (\(field_pCity) like \(searchText) OR \(field_pState) like \(searchText) OR \(field_pCountry) like \(searchText)) AND (\(field_pCity) != NULL OR \(field_pCity) != \"\") UNION SELECT 4 as position, (\(field_pName) ||\", \"|| \(field_pCity) ||\", \"|| \(field_pState) ||\", \"|| \(field_pCountry)) as SearchText from \(tblProperty) WHERE \(field_pName) like \(searchText) OR \(field_pCity) like \(searchText) OR \(field_pState) like \(searchText) OR \(field_pCountry) like \(searchText) AND (\(field_pName) != NULL OR \(field_pName) != \"\")"
            
            print(selectQuery)
            do {
                let results:FMResultSet = try DBManager.sharedDB.database.executeQuery(selectQuery, values: nil)
                while results.next() {
                    var data = results.string(forColumnIndex: 1)
                    if data?.characters.last == "," {
                        data = String (data!.characters.dropLast()) + ""
                    }
                    if data?.characters.first == "," {
                        data =  String(data!.characters.dropFirst()) + ""
                    }
                    if (data?.contains(", ,"))! {
                        data =  data!.replacingOccurrences(of: ", ,", with: ",")
                    }
                    self.arrProperties.append(data!)
                        checkRecordAvailableWithImg(self.arrProperties as [AnyObject], tableView: self.tblList, targetController: self, displayMessage: msg_NoSearchForHotel, vc: self, img: UIImage(named: "ico_failed.png")!)
                }
            } catch {
                print(error.localizedDescription)
            }
            DBManager.sharedDB.database.close()
        }
    }
    
    //MARK: - Redirect to Search
    @IBAction func doSearch(_ sender: Any) {
        if (txtSearch.text?.characters.count)! > 0 {
            fetchPropertiesData()
             checkRecordAvailableWithImg(self.arrProperties as [AnyObject], tableView: self.tblList, targetController: self, displayMessage: msg_NoSearchForHotel, vc: self, img: UIImage(named: "ico_failed.png")!)
        } else {
            arrProperties.removeAll()
             checkRecordAvailableWithImg(self.arrProperties as [AnyObject], tableView: self.tblList, targetController: self, displayMessage: msg_NoSearchForHotel, vc: self, img: UIImage(named: "ico_failed.png")!)
        }
    }
}
