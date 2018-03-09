//
//  SupplierDetailVC.swift
//  FinchCart
//
//  Created by vivek versatile on 06/12/17.
//  Copyright © 2017 Kaira NewMac. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SDWebImage

class SupplierDetailVC: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var txtViewDetails: UITextView!
    @IBOutlet weak var mapGoogle: GMSMapView!
    @IBOutlet weak var btnLike: UIButton!
    
    var locationManager: CLLocationManager!
    var lat : Double = 0.0
    var long : Double = 0.0
    var supplierId : Int = 0
    var isFav: Bool = false
    
    var objResponse : ServiceResponse<SupplierDetailResModel> = ServiceResponse()!
    var objResponseMessage : ServiceResponseMessage = ServiceResponseMessage()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setView()
        self.setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.SupplierDetailCall()
    }
    
    
}
//MARK: - @IBAction Methods
extension SupplierDetailVC {
    @IBAction func btnClickedLike(_ sender: UIButton) {
        sender.isSelected =  !sender.isSelected
        if sender.isSelected {
            sender.backgroundColor = AppColor.AppTheme_Primary
        } else {
            sender.backgroundColor = AppColor.BorderColor_Gray
        }
        self.AddSupplierToFavCall()
    }
}
//MARK: - Serivce Call

extension SupplierDetailVC {
    func SupplierDetailCall() {
        
        let objReqModel : SupplierDetailReqModel  = SupplierDetailReqModel()
        objReqModel.intSupplier = String(self.supplierId)
        objReqModel.intUser = Preference.GetString(key: UserDefaultsKey.UserID)
        
        let productdataprovider: ProductDataProvider = ProductDataProvider()
        
        productdataprovider.SupplierDetail(detailReqModel: objReqModel, IsLoader: true, viewController: self) { (response, IsSuccess) -> Void in
            if IsSuccess! {
                self.objResponse = response!
                self.setData()
                
            } else {
                appDelegate.window?.rootViewController?.view.makeToast(message: AppMessage.RequestFail)
            }
        }
    }
    
    func AddSupplierToFavCall() {
        
        let objReqModel : SupplierDetailReqModel  = SupplierDetailReqModel()
        objReqModel.intSupplier = String(self.supplierId)
        objReqModel.intUser = Preference.GetString(key: UserDefaultsKey.UserID)
        
        let productdataprovider: ProductDataProvider = ProductDataProvider()
        productdataprovider.AddSupplierToFav(addSupFavReqModel: objReqModel, IsLoader: true, viewController: self) { (response, IsSuccess) -> Void in
            if IsSuccess! {
                self.objResponseMessage = response!; appDelegate.window?.rootViewController?.view.makeToast(message: self.objResponseMessage.Message!)
                
            } else {
                appDelegate.window?.rootViewController?.view.makeToast(message: AppMessage.RequestFail)
            }
        }
    }
}

//MARK:- GMSMapViewDelegate

extension SupplierDetailVC: GMSMapViewDelegate {
    func setGoogleMap() {
        let state_marker = PlaceMarker()
        
        state_marker.position = CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
        if let strName = self.objResponse.Data?.varName {
            state_marker.title = strName
        }
    
        let markerView = UIImageView(image: UIImage(named: "icon_pincode"))
        state_marker.iconView = markerView
        state_marker.map = self.mapGoogle
        
        self.mapGoogle.delegate = self
        self.mapGoogle.camera = GMSCameraPosition.camera(withLatitude: self.lat, longitude: self.long, zoom: 15.0)
        self.mapGoogle.isMyLocationEnabled = true
    }
    
    /*func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    
        let url = "http://maps.apple.com/maps?saddr=\(String(describing: locationManager.location?.coordinate.latitude)),\(String(describing: locationManager.location?.coordinate.longitude))&daddr=\((self.lat)),\((self.long))"
        
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(self.lat),\(self.lat)&directionsmode=driving")! as URL as URL)
            
        } else {
            NSLog("Can't use comgooglemaps://");
            UIApplication.shared.openURL(NSURL(string: url)! as URL)
        }
        return true
    }*/
}


//MARK: - Google Map Marker Class
class PlaceMarker: GMSMarker {
    var strImageURL: String = ""
    var strDistance: String = ""
    var strAddress: String = ""
    var strMobile: Int = 0
}

//MARK: - Location methods
extension SupplierDetailVC {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
    }
}

//MARK: - Setup View & Data
extension SupplierDetailVC {
    
    func setView() {
        self.navigationBar.HeaderSet(self, leftBtnSlector: nil, rightBtnSelector:nil, right1BtnSelector: nil,right2BtnSelector:nil)
        if isFav {
            self.btnLike.isSelected = true
            self.btnLike.backgroundColor = AppColor.AppTheme_Primary
        } else {
            self.btnLike.isSelected = false
            self.btnLike.backgroundColor = AppColor.BorderColor_Gray
        }
    }
    
    func setData()
    {
        if let about = self.objResponse.Data?.varAbout {
            self.txtViewDetails.text = about
        }
        if let userLong = self.objResponse.Data?.varLng {
            self.long = Double(userLong)!
        }
        if let userLat = self.objResponse.Data?.varLat {
            self.lat = Double(userLat)!
        }
        self.setGoogleMap()
    }
    
}
