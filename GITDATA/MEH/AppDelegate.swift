//
//  AppDelegate.swift
//  MEH
//
//  Created by Nishant Bhindi on 27/06/17.
//  Copyright © 2017 Nishant Bhindi. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration
import CoreLocation
import MapKit
import IQKeyboardManagerSwift
import SVProgressHUD
import Fabric
import Crashlytics
import SideMenu

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    //MARK: - Declaration
    var window: UIWindow?
    var isFromKilledState = true
    
    //Internet Check
    private var reachability:Reachability!
    private var reachabilityWithHost:Reachability!
    var isInitialized : Bool = false
    
    //Location
    var locationManager = CLLocationManager()
    var location = CLLocation(latitude: 0, longitude: 0) as CLLocation
    var locationAllowed : Int = 0
    var locationStatusMessage : NSString = "Not Started"
    var currentState : String = ""
    var currentCity : String = ""
    
    //Selected Menu
    var selectedMenu : Int = 1
    
    //User
    var objUser : [String : JSON]?
    
    //Array Country State And Property
    var arrCountry = [JSON]()
    var arrState = [JSON]()
    var arrProperty = [JSON]()
    var arrMostPopular = [JSON]()
    
    //TimeStamp
    var strRegionTimeStamp = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SVProgressHUD.setDefaultMaskType(.black)
        Fabric.with([Crashlytics.self])
        IQKeyboardManager.sharedManager().enable = true
        
        // Push Notification Register //
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        // Push Notification Receive //
        if let options = launchOptions {
            if let notification = options[UIApplicationLaunchOptionsKey.remoteNotification] as? UILocalNotification {
                if let userInfo = notification.userInfo {
                    self.handlePushNotification(userInfo: userInfo)
                }
            }
        }
        checkInternetConnection()
        initializeAppData()
        return true
    }
    
    //MARK: - Internet Connection Availabity
    func checkInternetConnection()
    {
        self.reachability = Reachability.forInternetConnection()
        self.reachabilityWithHost = Reachability(hostName: "www.google.com")
        //
        self.reachability.reachableOnWWAN = false
        
        // Here we set up a NSNotification observer. The Reachability that caused the notification is passed in the object parameter
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.reachabilityChanged(_:)),name: NSNotification.Name.reachabilityChanged,object: nil)
        
        self.reachability.startNotifier()
        self.reachabilityWithHost.startNotifier()
    }
    func reachabilityChanged(_ notification: Foundation.Notification) {
        //if self.reachability!.isReachableViaWiFi() || self.reachability!.isReachableViaWWAN() || self.reachabilityWithHost!.isReachableViaWiFi() || self.reachabilityWithHost!.isReachableViaWWAN() {
        
        if self.reachabilityWithHost.isReachableViaWiFi() || self.reachabilityWithHost.isReachableViaWWAN() {
            print(msg_ServiceAvailble)
            let lastController = topViewController( (self.window?.rootViewController)!)
            if (lastController).isKind(of: NoConnectionVC.self)
            {
                if !isInitialized {
                    initializeAppData()
                }
                lastController.dismiss(animated: true, completion: nil)
            }
        }
        else {
            let lastController = topViewController( (self.window?.rootViewController)!)
            let noConnectionVC = NoConnectionVC()
            
            if !(lastController.isKind(of: NoConnectionVC.self)) {
                noConnectionVC.showController()
            }
        }
    }
    
    //MARK: - Initialize App Data
    func initializeAppData()
    {
        //setStatusBarStyle()
        //self.selectedMenu = SideMenu.Home.rawValue
        
        if getFromUserDefaultForKey(key_User_Object) == nil {
            objUser = nil
        }
        else {
            objUser = JSON(getFromUserDefaultForKey(key_User_Object)!).dictionaryValue
        }
        if self.reachabilityWithHost.isReachableViaWiFi() || self.reachabilityWithHost.isReachableViaWWAN() {
            self.fetchUserLocation()
            self.isInitialized = true
        }
        else
        {
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.1 * Double(3))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                let lastController = self.topViewController( (self.window?.rootViewController)!)
                let noConnectionVC = NoConnectionVC()
                
                if !(lastController.isKind(of: NoConnectionVC.self)) {
                    noConnectionVC.showController()
                }
            })
        }
        getSyncData()
    }
    
    //MARK: - Push Notification
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        var token: String = deviceToken.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        token = token.replacingOccurrences(of: " ", with: "")
        setToUserDefaultForKey(token as AnyObject?, key: key_DeviceToken)
        logD(token)
        self.updateToken()
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logD(error)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        logD(userInfo)
        
        self.handlePushNotification(userInfo: userInfo)
    }
    
    //MARK: - Handle Push Notification
    func handlePushNotification(userInfo: [AnyHashable: Any])
    {
        let dicNotification = userInfo["aps"] as AnyObject
        //let pushType = dicNotification!["type"] as! String
        let pushMessage = dicNotification["alert"] as! String
        
        let alertController = UIAlertController(title: msg_TitleAppName, message: pushMessage, preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (Action) in
        })
        alertController.addAction(OKAction)
        alertController.show()
    }
    
    //MARK: - Present View Controller (Currently At Top)
    func topViewController(_ rootViewController: UIViewController) -> UIViewController {
        if rootViewController.presentedViewController == nil {
            return rootViewController
        }
        if (rootViewController.presentedViewController is UINavigationController) {
            let navigationController = (rootViewController.presentedViewController as! UINavigationController)
            let lastViewController = navigationController.viewControllers.last!
            return self.topViewController(lastViewController)
        }
        let presentedViewController = (rootViewController.presentedViewController)
        return self.topViewController(presentedViewController!)
    }
    
    //MARK: - Fetch User Location
    func fetchUserLocation()
    {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
        //locationManager.startMonitoringSignificantLocationChanges()
    }
    
    //MARK: - CLLocationManager delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        logD(error)
        if CLLocationManager.locationServicesEnabled()
        {
            if CLLocationManager.authorizationStatus() == .denied
            {
                print("Denied")
                showMessageWithConfirm(title: "Application Requires Location Services", message: "Please enable location services for the application", okTitle:"Settings" , cancelTitle: "Cancel", okCompletion: { (action) in
                    UIApplication.shared.openURL(URL (string: UIApplicationOpenSettingsURLString)!)
                    
                }, cancelCompletion: { (action) in
                    
                })
            }
        }
        else {
            showMessageWithConfirm(title: "Application Requires Location Services", message: "Please enable location services for the application", okTitle:"Settings" , cancelTitle: "Cancel", okCompletion: { (action) in
                openScheme(Url: "prefs:root=LOCATION_SERVICES")
                
            }, cancelCompletion: { (action) in
                
            })
            print("Please enable location services for the application")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        location = locations.last! as CLLocation
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "LocationUpdate"), object: nil)
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {
            (placemarks, error) -> Void in
            if placemarks != nil{
                if placemarks!.count > 0 {
                    let pm = placemarks![0] as CLPlacemark
                    self.displayLocationInfo(pm)
                } else {
                    print("Problem with the data received from geocoder")
                }
            }
        })
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark) {
        //stop updating location to save battery life
        locationManager.stopUpdatingLocation()
        if placemark.country != nil {
            print(placemark.country!)
        }
        if placemark.addressDictionary != nil {
            let addDic = placemark.addressDictionary as! [String: AnyObject]
            //self.currentState = addDic["State"] as! String
            //self.currentCity = addDic["SubAdministrativeArea"] as! String
        }
    }
    
    //MARK: - Get Sync Data
    func getSyncData() {
        SVProgressHUD.show()
        self.setTimeStamp()
        DBManager.sharedDB.createDatabase()
        let dicRequestData = ["TimeStamp": strRegionTimeStamp as AnyObject]
        APIManager.callSyncAPIRequest(Method: .post, url: "\(api_Synchronization)", parameters: dicRequestData, headers: const_dictHeader, completion:
            { (result, headerMessage) in
                let dicJSONResponse = result.dictionaryValue
                let dicData = (dicJSONResponse["response"]?.dictionaryValue)!
                self.arrCountry = (dicData["CountryData"]?.arrayValue)!
                self.arrState = (dicData["StateData"]?.arrayValue)!
                self.arrProperty = (dicData["PropertyData"]?.arrayValue)!
                self.arrMostPopular = (dicData["MostPopular"]?.arrayValue)!
                if DBManager.sharedDB.openDatabase(){
                    self.bindCountriesData()
                    self.bindStatesData()
                    self.bindPropertiesData()
                    self.bindMostPopularData()
                }
                let resTimeStamp = (dicData["TimeStamp"]?.stringValue)
                print(resTimeStamp!)
                setToUserDefaultForKey(resTimeStamp as AnyObject, key: key_TimeStamp)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Sync"), object: nil)
                SVProgressHUD.dismiss()
                
        }) { (httpresponse, errorMessage) in
            print(errorMessage)
            if self.strRegionTimeStamp == "" {
                self.getSyncData()
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //MARK: - Set TimeStamp
    func setTimeStamp()
    {
        let getRegionTimeStamp = getFromUserDefaultForKey(key_TimeStamp)
        if getRegionTimeStamp == nil {
            self.strRegionTimeStamp = const_Default_TimeStamp
        }
        else {
            self.strRegionTimeStamp = String(describing: getRegionTimeStamp!)
        }
    }
    
    //MARK: - Bind Data -
    //Get countries data
    func bindCountriesData()
    {
        if self.arrCountry.count > 0
        {
            for i in 0..<self.arrCountry.count  {
                var  objData = self.arrCountry[i]
                let insertQuery = "insert into \(tblCountry) (\(field_countryId), \(field_countryName), \(field_countryDesc), \(field_currency),\(field_cTeleCode),\(field_code)) values (\"\(String(data: objData["CountryId"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\",\"\(String(data: objData["Name"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\",\"\(String(data: objData["CurrencyDesc"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\", \"\(String(data: objData["Currency"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\",\"\(String(data: objData["CountryTeleCode"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\", \"\(String(data: objData["Code"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\")"
                
                let result = DBManager.sharedDB.database.executeUpdate(insertQuery, withArgumentsIn: [])
                if !result {
                    print("Fail")
                } else {
                    print("Success")
                }
            }
        }
    }
    //Get state data
    func bindStatesData()
    {
        if self.arrState.count > 0
        {
            for i in 0..<self.arrState.count  {
                var  objData = self.arrState[i]
                
                let insertQuery = "insert into \(tblState) (\(field_sId), \(field_cId), \(field_sName)) values (\"\(String(data: objData["StateId"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\",\"\(String(data: objData["CountryId"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\",\"\(String(data: objData["StateName"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\")"
                print(insertQuery)
                let result = DBManager.sharedDB.database.executeUpdate(insertQuery, withArgumentsIn: [])
                if !result {
                    print("Fail")
                } else {
                    print("Success")
                }
            }
        }
        
    }
    //Get property data
    func bindPropertiesData()
    {
        if self.arrProperty.count > 0
        {
            for i in 0..<self.arrProperty.count  {
                var  objData = self.arrProperty[i]
                
                let insertQuery = "insert into \(tblProperty) (\(field_pId), \(field_pName), \(field_pCountry),\(field_pState) ,\(field_pCity), \(field_pAdd1),\(field_pAdd2)) values (\"\(String(data: objData["PropertyId"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\",\"\(String(data: objData["PropertyName"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\",\"\(String(data: objData["CountryName"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\", \"\(String(data: objData["StateName"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\",\"\(String(data: objData["City"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\", \"\(String(data: objData["PropertyAddress"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\", \"\(String(data: objData["PropertyAddress1"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\")"
                print(insertQuery)
                let result = DBManager.sharedDB.database.executeUpdate(insertQuery, withArgumentsIn: [])
                if !result {
                    print("Fail")
                } else {
                    print("Success")
                }
            }
        }
        
    }
    //Get MostPopular data
    func bindMostPopularData()
    {
        if self.arrMostPopular.count > 0
        {
            let deleteQuery = "DELETE FROM \(tblMostPopular)"
            print(deleteQuery)
            let result = DBManager.sharedDB.database.executeUpdate(deleteQuery, withArgumentsIn: [])
            if !result {
                print("Fail")
            } else {
                print("Success")
            }
            let Vaccume = "VACUUM"
            print(Vaccume)
            let result1 = DBManager.sharedDB.database.executeUpdate(Vaccume, withArgumentsIn: [])
            if !result1 {
                print("Fail")
            } else {
                print("Success")
            }
            for i in 0..<self.arrMostPopular.count  {
                var  objData = self.arrMostPopular[i]
                let insertQuery = "insert into \(tblMostPopular) (\(field_pId),\(field_pName),\(field_pCountry),\(field_pCountryName),\(field_pCity),\(field_pImage),\(field_pRating)) values (\"\(String(data: objData["PropertyId"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\",\"\(String(data: objData["PropertyName"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\",\"\(String(data: objData["Country"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\", \"\(String(data: objData["CountryName"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\",\"\(String(data: objData["City"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\", \"\(String(data: objData["Image"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\", \"\(String(data: objData["Rating"].stringValue.data(using: .utf8)!, encoding: .utf8)!)\")"
                print(insertQuery)
                let result = DBManager.sharedDB.database.executeUpdate(insertQuery, withArgumentsIn: [])
                if !result {
                    print("Fail")
                } else {
                    print("Success")
                }
            }
        }
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.updateToken()
        getSyncData()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func setStatusBarStyle()
    {
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor =  const_Color_Primary
    }
    
    //MARK: - Update Device Token
    func updateToken()
    {
        if getFromUserDefaultForKey(key_User_Object) != nil {
            let strDeviceToken = getFromUserDefaultForKey(key_DeviceToken)
            if strDeviceToken != nil && strDeviceToken as! String != "" {
                APIManager.callAPIRequest(Method: .post,url: "\(api_UpdateToken)", parameters: ["DeviceID": strDeviceToken!], headers: const_dictHeaderWithToken, completion:
                    { (result, headerMessage) in
                        print("Device token is updated")
                }) { (httpresponse, errorMessage) in
                    print("Device token is failed to update")
                }
            }
        }
    }
}

