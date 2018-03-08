//
//  ShipmentVC.swift
//  YoTransport
//
//  Created by 9series on 15/09/16.
//  Copyright © 2016 9spl. All rights reserved.
//

import UIKit

class ShipmentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,UITextFieldDelegate {
    
    // MARK:- Variable Declaration -
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblList: UITableView!
    
    var popoverVC : ImagePopUPVC? = nil;
    var arrMain = [AnyObject]()
    var arrMainFilter = [AnyObject]()
    
    var ctrlRefresh: UIRefreshControl? = nil
    var intCurrentPage : Int = 0
    var currentLat:Double = 0
    var currentLong:Double = 0
    var isPagingEnabled: Bool = false
    var arrShipFilter = [AnyObject]()
    var objUser = [String: AnyObject]()
    var userId: AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupUI()
        self.fetchList(ctrlRefresh)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.tblList.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchListForLocation), name: NSNotification.Name(rawValue: "LocationUpdate"), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - SetUp UI -
    func setupUI()
    {
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = const_Color_SearchBar_border.cgColor
        addPullToRefresh(tblList, ctrlRefresh: &ctrlRefresh, targetController: self, refreshMethod: #selector(self.fetchList(_:)))
        navigationBar.HeaderSet(self, leftBtnSlector:nil, middleBtnSelector:#selector (self.addShipmentNavigation), rightBtnSelector: #selector(self.btnClickedFilter))

        self.verifyUser()
    }
    func verifyUser()
    {
        self.objUser = getFromUserDefaultForKey(key_User_Object) as! [String: AnyObject]
        self.userId = objUser["userId"] as! String as AnyObject!
        if self.objUser["userType"] as! String == "Transporter"{
            navigationBar.btnMiddle.isHidden = true
        }
    }
    //MARK: - Fetch List on Update Location -
    func fetchListForLocation()
    {
        self.fetchList(ctrlRefresh)
    }
    
    //MARK: - @IBActions -
    //Filter
    func btnClickedFilter() {
        // It will Display the Filter Page Of ShipmentVC
        let filterTransporter = storyBoard_Filter.instantiateViewController(withIdentifier: "TransporterFilterVC") as! TransporterFilterVC
        self.navigationController?.pushViewController(filterTransporter, animated: true)
    }
    //Close Search
    @IBAction func btnClickedCloseSearch(_ sender: UIButton) {
        searchBar.text = ""
        arrMainFilter.removeAll()
        self.searchBar.endEditing(true)
        self.tblList.reloadData()
    }
    @IBAction func btnClickedDelete(_ sender: AnyObject) {
        let objUser = getFromUserDefaultForKey(key_User_Object)
        if objUser!["userType"] as! String == "Customer"{
            showMessageWithConfirm( "", message: msg_RecordDeleteConfirm, okTitle: "Yes", cancelTitle: "No", okCompletion: { (action) in
                self.deleteShipment(sender.tag)
            }, cancelCompletion: {(action) in })
        }
        else{
            phoneCall(sender as! UIButton)
        }
    }
    //MARK: - TableView Datasource -
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == self.arrMain.count {
            return 54.0
        }
        else {
            return 169.0
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->Int{
        if searchBar.text == ""{
            if self.isPagingEnabled{
                return self.arrMain.count + 1
            }
            else{
                return self.arrMain.count
            }
        }
        else{
            return self.arrMainFilter.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.arrMain.count{
            
            var shipmentData = [String: AnyObject]()
            if searchBar.text == ""{
                shipmentData = self.arrMain[indexPath.row] as! [String: AnyObject]
            }
            else{
                shipmentData = self.arrMainFilter[indexPath.row] as! [String: AnyObject]
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShipmentListCell", for: indexPath) as! ShipmentListCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            let objUser = getFromUserDefaultForKey(key_User_Object)
            if objUser!["userType"] as! String == "Customer"{
                cell.btnCall.setImage(UIImage(named: "icon_delete.png"), for: UIControlState())
                cell.lblDistance.needsUpdateConstraints()
                cell.heightDistanceLbl.constant = 0
                cell.iconLocation.needsUpdateConstraints()
                cell.heightLocationImg.constant = 0
            }
            cell.lblTitle.text = shipmentData["title"] as? String
            let dropCity = shipmentData["dropCity"] as! String
            let dropArea = shipmentData["dropArea"] as! String
            cell.lblDropLocation.text = "\(dropArea)," + "\(dropCity)"
            let distance = shipmentData["distance"] as? String
            if distance != "" {
                cell.lblDistance.text = distance! + "KM"
            }
            else{
                cell.lblDistance.text = "No Location"
            }
            cell.lblPickupDate.text = shipmentData["pickupDate"] as? String
            cell.lblDropDate.text = shipmentData["postDate"] as? String
            let pickCity = shipmentData["pickupCity"] as! String
            let pickArea = shipmentData["pickupArea"] as! String
            cell.lblPickupLocation.text = "\(pickArea),"  + "\(pickCity)"
            cell.btnCall.tag = indexPath.row
            var arrImg = shipmentData["thumbImages"] as! [AnyObject]
            
            if arrImg.count != 0{
                let strProfileImageURL = arrImg[0] as! String
                cell.imgView.image = UIImage(named: "img_no_image")
                if strProfileImageURL != "" {
                    cell.imgView.sd_setImage(with: URL(string: strProfileImageURL), completed: { (image, error, imageCacheType, imageUrl) in
                        if image != nil {
                            cell.imgView.image = image
                        }else {
                            
                        }
                    })
                }
            }
            else{
                arrImg = shipmentData["images"] as! [AnyObject]
                let strProfileImageURL = arrImg[0] as! String
                cell.imgView.image = UIImage(named: "img_no_image")
                if strProfileImageURL != "" {
                    cell.imgView.sd_setImage(with: URL(string: strProfileImageURL), completed: { (image, error, imageCacheType, imageUrl) in
                        if image != nil {
                            cell.imgView.image = image
                        }else {
                            
                        }
                    })
                }
            }
            return cell
        }
        else{
            let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.fetchMoreList()
            }
            return showLoadingCell(UIColor.gray)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        let shipDetailVC = storyBoard_Shipment_Detail.instantiateViewController(withIdentifier: "ShipmentDetailVC") as! ShipmentDetailVC
        var selectedData = [String: AnyObject]()
        if searchBar.text == ""{
            selectedData = self.arrMain[indexPath.row] as! [String : AnyObject]
        }
        else{
            selectedData = self.arrMainFilter[indexPath.row] as! [String : AnyObject]
        }
        shipDetailVC.dicDetailData = selectedData
        self.navigationController?.pushViewController(shipDetailVC, animated: true)
    }
    //MARK: - Fetch Shipment Data -
    func fetchList(_ refreshControl: UIRefreshControl?)
    {
        var userId = ""
        if self.objUser["userType"] as! String == "Customer"{
            userId = self.objUser["userId"] as! String
        }
        self.searchBar.text = ""
        self.currentLat = APP_DELEGATE.location.coordinate.latitude
        self.currentLong = APP_DELEGATE.location.coordinate.longitude
        self.intCurrentPage = 1
        
        // if self.currentLat != 0 && self.currentLong != 0{
        SVProgressHUD.show()
        APIManager.callAPIRequest(Method: .post, url: "\(api_GetShipments)", parameters: ["userId": userId as AnyObject, "userLat": self.currentLat as AnyObject,"userLong":self.currentLong as AnyObject,"page": intCurrentPage as AnyObject], headers: nil, completion: { (result) in
            
            if self.arrMain.count>0{
                self.arrMain.removeAll()
            }
            let dicJSONResponse = result as! [String: AnyObject]
            self.arrMain = dicJSONResponse["shipments"] as! [AnyObject]
            if self.arrMain.count>0{
                let dic = self.arrMain[0] as! [String:AnyObject]
                let pageStatus = dic["nextPage"] as! NSString
                self.isPagingEnabled = pageStatus.boolValue
            }
            checkRecordAvailableWithRefreshControl(self.arrMain, tableView: self.tblList, ctrlRefresh: refreshControl, targetController: self, displayMessage: msg_NoDataAvailableRefresh)
            print(self.intCurrentPage)
            SVProgressHUD.dismiss()
        }) { (httpresponse, errorMessage) in
            
            if httpresponse != nil {
                self.arrMain.removeAll()
            }
            checkRecordAvailableWithRefreshControl(self.arrMain, tableView: self.tblList, ctrlRefresh: refreshControl, targetController: self, displayMessage: msg_NoDataAvailableRefresh)
            SVProgressHUD.dismiss()
        }
        // }
        
    }
    //MARK: - Fetch More Shipment Data -
    func fetchMoreList()
    {
        self.currentLat = APP_DELEGATE.location.coordinate.latitude
        self.currentLong = APP_DELEGATE.location.coordinate.longitude
        SVProgressHUD.show()
        self.intCurrentPage += 1
        
        APIManager.callAPIRequest(Method: .post, url: "\(api_GetShipments)", parameters: ["userLat": self.currentLat as AnyObject,"userLong": self.currentLong as AnyObject,"page": intCurrentPage as AnyObject], headers: nil, completion: { (result) in
            
            let dicMoreJSONResponse = result as! [String: AnyObject]
            let arrAdd =  dicMoreJSONResponse["shipments"] as! [AnyObject]
            if arrAdd != nil{
                let dicData = arrAdd
                let dic = dicData[0] as! [String:AnyObject]
                let pageStatus = dic["nextPage"] as! NSString
                self.isPagingEnabled = pageStatus.boolValue
                for (index,_) in dicData.enumerated() {
                    self.arrMain.append(arrAdd[index] )
                }
                checkRecordAvailableWithRefreshControl(self.arrMain, tableView: self.tblList, ctrlRefresh: self.ctrlRefresh, targetController: self, displayMessage: msg_NoDataAvailableRefresh)
                SVProgressHUD.dismiss()
            }
        }) { (httpresponse, errorMessage) in
            
            checkRecordAvailableWithRefreshControl(self.arrMain, tableView: self.tblList, ctrlRefresh: self.ctrlRefresh, targetController: self, displayMessage: msg_NoDataAvailableRefresh)
            SVProgressHUD.dismiss()
        }
    }
    //MARK: - Searchbar Datasource -
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        arrMainFilter.removeAll()
        for objDataTmp : AnyObject in arrMain{
            let strTitle = objDataTmp["title"] as? String
            if strTitle!.lowercased().contains(searchText.lowercased()) {
                arrMainFilter.append(objDataTmp)
            }
        }
        checkRecordAvailableWithRefreshControl(self.arrMainFilter, tableView: self.tblList, ctrlRefresh: self.ctrlRefresh, targetController: self, displayMessage: msg_NodataFound)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    func dismissKeyboard() {
        self.searchBar.endEditing(true)
    }
    //MARK: - TextField Delegate -
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
        return true
    }
    //MARK: - Redirect to Add Shipment -
    func addShipmentNavigation()
    {
        let addShipment = storyBoard_Add.instantiateViewController(withIdentifier: "AddShipmentVC") as! AddShipmentVC
        self.navigationController?.pushViewController(addShipment, animated: true)
    }
    //MARK: - Phone Call -
    func phoneCall(_ sender: UIButton)
    {
        showMessageWithConfirm("", message: msg_CallConfirm, okTitle:"Yes" , cancelTitle: "No", okCompletion: { (action) in
            
            print("call")
            if self.searchBar.text == ""{
                var dicPhoneData = self.arrMain[sender.tag] as! [String: AnyObject]
                callNumber((dicPhoneData["phone"] as? String)!)
            }
            else{
                var dicPhoneData = self.arrMainFilter[sender.tag] as! [String: AnyObject]
                callNumber((dicPhoneData["phone"] as? String)!)
            }
        }, cancelCompletion: { (action) in
            print("call cancel")
        })
    }
    //MARK: - Delete Shipment -
    func deleteShipment(_ tag: Int)
    {
        let dicShipment = self.arrMain[tag] as! [String: AnyObject]
        let strShipId = dicShipment["shipmentId"] as! String
        SVProgressHUD.show()
        
        APIManager.callAPIRequest(Method: .post, url: "\(api_DeleteShipment)", parameters: ["userId":self.userId,"shipmentId":strShipId as AnyObject], headers: nil, completion:{ (result) in
            
            let dicDeleteResponse = result as! [String: AnyObject]
            let message = dicDeleteResponse["message"] as! String
            self.arrMain.remove(at: tag)
            showMessage("", message: message, VC: self)
            checkRecordAvailableWithRefreshControl(self.arrMain, tableView: self.tblList, ctrlRefresh: self.ctrlRefresh, targetController: self, displayMessage: msg_NoDataAvailableRefresh)
            SVProgressHUD.dismiss()
            
        }) { (httpresponse, errorMessage) in
            
            //if httpresponse.statusCode == 404 {
            checkRecordAvailableWithRefreshControl(self.arrMain, tableView: self.tblList, ctrlRefresh: self.ctrlRefresh, targetController: self, displayMessage: msg_NoDataAvailableRefresh)
            //}
            
            SVProgressHUD.dismiss()
        }
        
    }
    
    
}
