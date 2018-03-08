//
//  AppDelegate.swift
//  YoTransport
//
//  Created by 9series on 15/09/16.
//  Copyright © 2016 9spl. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Fabric
import Crashlytics
import Foundation
import SystemConfiguration
import RealmSwift
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var userId = 0
    var strUserDealDistance = ""
    let realm = try!Realm()
    var countryNameList = [String]()
    var countryIdList = [Int]()
    var strRegionTimeStamp = ""
    lazy var countriesResult: Results<Countries> = { self.realm.objects (Countries.self) }()
    lazy var statesResult: Results<States> = { self.realm.objects (States.self) }()
    lazy var areasResult: Results<Areas> = { self.realm.objects (Areas.self) }()
    lazy var cityResult: Results<Cities> = { self.realm.objects (Cities.self) }()
    lazy var vehiclesResult: Results<Vehicles> = { self.realm.objects (Vehicles.self) }()
    
    var arrCountry = [AnyObject]()
    var arrState = [AnyObject]()
    var arrArea = [AnyObject]()
    var arrCity = [AnyObject]()
    var arrVehicles = [AnyObject]()
    var dicRegion = [String: AnyObject]()
    var dicState = [String: AnyObject]()
    
    fileprivate var reachability:Reachability!
    fileprivate var reachabilityWithHost:Reachability!
    var isInitialized : Bool = false
    
    //Location
    var locationManager = CLLocationManager()
    var location = CLLocation(latitude: 0, longitude: 0) as CLLocation
    var locationAllowed : Int = 0
    var locationStatusMessage : NSString = "Not Started"
    var currentState : String = ""
    var currentCity : String = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
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
                    
                    let dicNotification = userInfo["aps"] as AnyObject
                    //let pushType = dicNotification!["type"] as! String
                    let pushMessage = dicNotification["alert"] as! String
                    let alertController = UIAlertController(title: msg_TitleAppName, message: pushMessage, preferredStyle: UIAlertControllerStyle.alert)
                    let OKAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (Action) in
                    })
                    alertController.addAction(OKAction)
                    alertController.show()
                }
            }
        }
        checkInternetConnection()
        initializeAppData()
        self.checkStatus()
        return true
    }
    //MARK: - Initialize App Data -
    func initializeAppData()
    {
        self.setStatusBarStyle()
        if self.reachabilityWithHost!.isReachableViaWiFi() || self.reachabilityWithHost!.isReachableViaWWAN() {
            fetchUserLocation()
            isInitialized = true
        }
        else
        {
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.1 * Double(3))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                print(msg_NoService)
                
                let lastController = self.topViewController( (self.window?.rootViewController)!)
                let noConnectionVC = storyBoard_Main.instantiateViewController(withIdentifier: "NoConnectionVC") as! NoConnectionVC
                
                if !(lastController.isKind(of: NoConnectionVC.self)) {
                    noConnectionVC.showController()
                }
            })
        }
    }
    func setStatusBarStyle()
    {
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor =  const_Color_StatusBar
        
    }
    //MARK: - Push Notification -
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        var token: String = deviceToken.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        token = token.replacingOccurrences(of: " ", with: "")
        setToUserDefaultForKey(token as AnyObject?, key: key_DeviceToken)
        logD(token)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logD(error)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        logD(userInfo)
        let dicNotification = userInfo["aps"] as AnyObject
        //let pushType = dicNotification!["type"] as! String
        let pushMessage = dicNotification["alert"] as! String
        let alertController = UIAlertController(title: msg_TitleAppName, message: pushMessage, preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (Action) in
        })
        alertController.addAction(OKAction)
        alertController.show()
    }
    
    //Check Push Notification Permission Access
    func checkPushNotificationPermissionAccess()
    {
        if !(UIApplication.shared.isRegisteredForRemoteNotifications) {
            // Push notifications are disabled in setting by user.
        }else{
            // Push notifications are enabled in setting by user.
        }
    }
    
    //MARK: - Handle URL for FB and Google Sign -
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        //handle the URL that your application receives at the end of the authentication process -
        var flag: Bool = false
        // handle Facebook url scheme
        if let wasHandled:Bool = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            flag = wasHandled
        }
        if let googlePlusFlag: Bool = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication!, annotation: annotation) {
            flag = googlePlusFlag
        }
        return flag
    }
    
    //MARK: - Internet Connection Availabity -
    func checkInternetConnection()
    {
        self.reachability = Reachability.forInternetConnection()
        self.reachabilityWithHost = Reachability(hostName: "www.google.com")
        
        // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
        self.reachability!.reachableOnWWAN = false
        
        // Here we set up a NSNotification observer. The Reachability that caused the notification
        // is passed in the object parameter
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.reachabilityChanged(_:)),name: NSNotification.Name.reachabilityChanged,object: nil)
        
        self.reachability!.startNotifier()
        self.reachabilityWithHost!.startNotifier()
    }
    func reachabilityChanged(_ notification: Foundation.Notification) {
        //if self.reachability!.isReachableViaWiFi() || self.reachability!.isReachableViaWWAN() || self.reachabilityWithHost!.isReachableViaWiFi() || self.reachabilityWithHost!.isReachableViaWWAN() {
        
        if self.reachabilityWithHost!.isReachableViaWiFi() || self.reachabilityWithHost!.isReachableViaWWAN() {
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
            let noConnectionVC = storyBoard_Main.instantiateViewController(withIdentifier: "NoConnectionVC") as! NoConnectionVC
            
            if !(lastController.isKind(of: NoConnectionVC.self)) {
                noConnectionVC.showController()
            }
        }
    }
    // Chek whether user already logged in or not
    func checkStatus()
    {
        let userObject = getFromUserDefaultForKey(key_User_Object)
        if userObject != nil
        {
            let verifyPhone = userObject!["mobileVerified"] as! String
            let userStatus = userObject!["adminApprove"] as! String
            if verifyPhone == "Yes"
            {
                if userStatus != "pending"
                {
                    let tabVC = storyBoard_Home.instantiateViewController(withIdentifier: "TabbarVC") as! TabbarVC
                    // (APP_DELEGATE.window?.rootViewController as! UINavigationController).pushViewController(tabVC, animated: true)
                    
                    let navigationController = UINavigationController(rootViewController: tabVC)
                    window!.rootViewController = navigationController
                    
                    self.window?.rootViewController = navigationController
                    navigationController.navigationBar.isHidden = true
                    self.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    //MARK: - Bind Data -
    //Get countries data
    func bindCountriesData()
    {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        try! realm.write() {
            for listCountry in self.arrCountry
            {
                
                let cName = listCountry["countryName"] as! String
                let cID = Int(listCountry["countryId"] as! String)
                
                let newCountry = Countries()
                newCountry.countryName = cName
                newCountry.countryId = cID!
                
                let countryPredicate = NSPredicate(format: "countryId = %d", cID!)
                let  arrCountries = try! Realm().objects(Countries.self).filter(countryPredicate).sorted(byKeyPath: "countryName", ascending: true)
                if arrCountries.count > 0
                {
                    for objCountry : Countries in arrCountries
                    {
                        objCountry.countryName = cName
                        
                    }
                }
                else
                {
                    self.realm.add(newCountry)
                    countriesResult = realm.objects(Countries.self)
                }
            }
        }
        
    }
    //Get state data
    func bindStateData()
    {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        try! realm.write() {
            for listState in self.arrState
            {
                let cID = Int(listState["countryId"] as! String)
                let sID = Int(listState["stateId"] as! String)
                let sName = listState["stateName"] as! String
                
                let newStates = States()
                newStates.stateName = sName
                newStates.stateId = sID!
                newStates.countryId = cID!
                
                let countryPredicate = NSPredicate(format: "stateId = %d", sID!)
                let  arrStates = try! Realm().objects(States.self).filter(countryPredicate).sorted(byKeyPath: "stateName", ascending: true)
                
                if arrStates.count > 0
                {
                    for objStates : States in arrStates
                    {
                        objStates.countryId = cID!
                        objStates.stateName = sName
                    }
                }
                else
                {
                    self.realm.add(newStates)
                    statesResult = realm.objects(States.self)
                }
            }
        }
    }
    //Get city data
    func bindCityData()
    {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        try! realm.write() {
            
            for listCity in self.arrCity
            {
                let cID = Int(listCity["countryId"] as! String)
                let sID = Int(listCity["stateId"] as! String)
                let cityId = Int(listCity["cityId"] as! String)
                let cityName = listCity["cityName"] as! String
                
                let newCities = Cities()
                newCities.cityId = cityId!
                newCities.stateId = sID!
                newCities.countryId = cID!
                newCities.cityName = cityName
                
                let statePredicate = NSPredicate(format: "cityId = %d", cityId!)
                let  arrCity = try! Realm().objects(Cities.self).filter(statePredicate).sorted(byKeyPath: "cityName", ascending: true)
                if arrCity.count > 0
                {
                    for objCity : Cities in arrCity
                    {
                        objCity.stateId = sID!
                        objCity.countryId = cID!
                        objCity.cityName = cityName
                    }
                }
                else
                {
                    self.realm.add(newCities)
                    cityResult = realm.objects(Cities.self)
                }
            }
        }
    }
    //Get area data
    func bindAreaData()
    {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        try! realm.write() {
            for listArea in self.arrArea
            {
                let cID = Int(listArea["countryId"] as! String)
                let sID = Int(listArea["stateId"] as! String)
                let aId = Int(listArea["areaId"] as! String)
                let cityId = Int(listArea["cityId"] as! String)
                let aName = listArea["areaName"] as! String
                
                let newAreas = Areas()
                newAreas.cityId = cityId!
                newAreas.stateId = sID!
                newAreas.countryId = cID!
                newAreas.areaId = aId!
                newAreas.areaName = aName
                
                let cityPredicate = NSPredicate(format: "areaId = %d", aId!)
                let  arrArea = try! Realm().objects(Areas.self).filter(cityPredicate).sorted(byKeyPath: "areaName", ascending: true)
                if arrArea.count > 0
                {
                    for objArea : Areas in arrArea
                    {
                        objArea.countryId = cID!
                        objArea.cityId = cityId!
                        objArea.stateId = sID!
                        objArea.areaName = aName
                    }
                }
                else
                {
                    self.realm.add(newAreas)
                    areasResult = realm.objects(Areas.self)
                }
            }
        }
    }
    //Get vehicles data
    func bindVehiclesData ()
    {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        try! realm.write() {
            
            for listVehicles in self.arrVehicles
            {
                let dtUpdatedDate = listVehicles["dtUpdatedDate"] as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = dateTimeFormatDefault
                let formatedUpDate = dateFormatter.date( from: dtUpdatedDate )
                let vTypeId = Int(listVehicles["vehicleTypeId"] as! String)
                let vType   = listVehicles["vehicleType"] as! String
                let vIcon   = listVehicles["vehicleIcon"] as! String
                let orderById = Int(listVehicles["orderByID"] as! String)
                
                let newVehicles = Vehicles()
                newVehicles.dtUpdatedDate = formatedUpDate!
                newVehicles.vehicleTypeId = vTypeId!
                newVehicles.vehicleType = vType
                newVehicles.vehicleIcon = vIcon
                newVehicles.orderByID = orderById!
                
                let vehPredicate = NSPredicate(format: "vehicleTypeId = %d", vTypeId!)
                let  arrVehicles = try! Realm().objects(Vehicles.self).filter(vehPredicate).sorted(byKeyPath: "vehicleType", ascending: true)
                if arrVehicles.count > 0 {
                    for objVeh : Vehicles in arrVehicles
                    {
                        objVeh.dtUpdatedDate = formatedUpDate!
                        objVeh.vehicleType = vType
                        objVeh.vehicleIcon = vIcon
                        objVeh.orderByID = orderById!
                    }
                }
                else
                {
                    self.realm.add(newVehicles)
                    vehiclesResult = realm.objects(Vehicles.self)
                }
            }
        }
    }
    //MARK: - Set TimeStamp -
    func setTimeStamp()
    {
        let getRegionTimeStamp = getFromUserDefaultForKey(key_TimeStamp)
        if getRegionTimeStamp == nil{
            self.strRegionTimeStamp = const_Default_TimeStamp
        }
        else
        {
            self.strRegionTimeStamp = String(describing: getRegionTimeStamp)
        }
        print(self.strRegionTimeStamp)
    }
    //MARK: - Get RegionData -
    func getRegionData() {
        
        APIManager.callAPIRequest(Method: .post, url: "\(api_RegionData)", parameters: ["timestamp": strRegionTimeStamp as AnyObject], headers: nil, completion: { (result) in
            
            self.dicRegion = result as! [String : AnyObject]
            self.arrCountry = self.dicRegion["country"]! as! [AnyObject]
            
            self.bindCountriesData()
            
            self.arrState = self.dicRegion["state"] as! [AnyObject]
            self.bindStateData()
            
            self.arrCity = self.dicRegion["city"] as! [AnyObject]
            self.bindCityData()
            
            self.arrArea = self.dicRegion["area"] as! [AnyObject]
            self.bindAreaData()
            
            self.arrVehicles = self.dicRegion["vehicles"] as! [AnyObject]
            self.bindVehiclesData()
            
            let resTimeStamp = String(self.dicRegion["timestamp"]! as! Int)
            print(resTimeStamp)
            
            setToUserDefaultForKey(resTimeStamp as AnyObject?, key: key_TimeStamp)
            
        }) { (httpresponse, Errormessage) in
            SVProgressHUD.dismiss()
        }
    }
    //MARK: - Present View Controller -
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
    //MARK: - Application cycle -
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.setTimeStamp()
        getRegionData()
        FBSDKAppEvents.activateApp()
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            self.checkPushNotificationPermissionAccess()
        })
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: - Fetch User Location -
    func fetchUserLocation()
    {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000.0
        locationManager.startUpdatingLocation()
        //locationManager.startMonitoringSignificantLocationChanges()
    }
    //MARK: - CLLocationManager delegate -
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        logD(error)
        if CLLocationManager.locationServicesEnabled()
        {
            if CLLocationManager.authorizationStatus() == .denied
            {
                print("Denied")
                showMessageWithConfirm("Application Requires Location Services", message: "Please enable location services for the application", okTitle:"Settings" , cancelTitle: "Cancel", okCompletion: { (action) in
                    UIApplication.shared.openURL(URL (string: UIApplicationOpenSettingsURLString)!)
                    
                    }, cancelCompletion: { (action) in
                        
                })
                
            }
        }
        else{
            showMessageWithConfirm("Application Requires Location Services", message: "Please enable location services for the application", okTitle:"Settings" , cancelTitle: "Cancel", okCompletion: { (action) in
                openScheme("prefs:root=LOCATION_SERVICES")
                
                }, cancelCompletion: { (action) in
                    
            })
            
            print("Please enable location services for the application")
        }
    }
    // authorization status
    /* func locationManager(manager: CLLocationManager,
     didChangeAuthorizationStatus status: CLAuthorizationStatus)
     {
     locationAllowed = 0
     
     switch status
     {
     case CLAuthorizationStatus.Restricted:
     locationStatusMessage = msg_LocationStatusDenied
     locationAllowed = 2
     showMessageWithConfirm(msg_LocationRequired, message: msg_LocationStatusRestricted, okTitle:"Settings" , cancelTitle: "Cancel", okCompletion: { (action) in
     
     UIApplication.sharedApplication().openURL(NSURL (string: UIApplicationOpenSettingsURLString)!)
     }, cancelCompletion: { (action) in
     })
     
     case CLAuthorizationStatus.Denied:
     locationStatusMessage = msg_LocationStatusDenied
     locationAllowed = 3
     showMessageWithConfirm(msg_LocationRequired, message: msg_LocationStatusRestricted, okTitle:"Settings" , cancelTitle: "Cancel", okCompletion: { (action) in
     
     UIApplication.sharedApplication().openURL(NSURL (string: UIApplicationOpenSettingsURLString)!)
     }, cancelCompletion: { (action) in
     })
     
     case CLAuthorizationStatus.NotDetermined:
     locationStatusMessage = ""
     locationAllowed = 4
     
     default:
     locationStatusMessage = ""
     locationAllowed = 1
     }
     }*/
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
                    print("Problem with the data received from geocoder")            }
            }
            
        })
        
    }
    func displayLocationInfo(_ placemark: CLPlacemark) {
        //stop updating location to save battery life
        locationManager.stopUpdatingLocation()
        if placemark.country != nil
        {
            print(placemark.country!)
        }
        if placemark.addressDictionary != nil{
            let addDic = placemark.addressDictionary as! [String: AnyObject]
            self.currentState = addDic["State"] as! String
            self.currentCity = addDic["SubAdministrativeArea"] as! String
        
        }
    }
}

