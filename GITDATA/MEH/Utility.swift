//
//  utility.swift
//  Swift Structure
//
//  Created by Nishant on 03/08/16.
//  Copyright © 2016 9series. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
import MapKit
import CoreLocation
import Alamofire
import SideMenu
import IQKeyboardManagerSwift

//MARK: - Log(Print) Utility
func logD(_ message:Any,
          file: String = #file, line: Int = #line,function: String = #function) {
    let str  : NSString = file as NSString
    //   #if DEBUG
    print("[\(str.lastPathComponent)][\(line)][\(function)]\n💜\(message)💜\n")
    //  #endif
}

//MARK: - User Default
//Set Value
func setToUserDefaultForKey(_ value:AnyObject?,key:String)
{
    UserDefaults.standard.set(value, forKey: key)
    UserDefaults.standard.synchronize()
}

//Set Archive Value
func setToUserDefaultForKeyByArchive(_ value:AnyObject?,key:String)
{
    UserDefaults.standard.set(value == nil ? nil : NSKeyedArchiver.archivedData(withRootObject: value!), forKey: key)
    UserDefaults.standard.synchronize()
}

//Get Value
func getFromUserDefaultForKey(_ key:String)->AnyObject?
{
    return UserDefaults.standard.object(forKey: key) as AnyObject?
}

//Get UnArchive Value
func getFromUserDefaultForKeyByUnArchive(_ key:String)->AnyObject?
{
    return UserDefaults.standard.object(forKey: key) == nil ? nil :NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: key) as! Data) as AnyObject?
}

//Remove Value
func removeFromUserDefaultForKey(_ key:String)
{
    UserDefaults.standard.removeObject(forKey: key)
}

//MARK: - UIView
//Border
func setDefaultBorder(_ view : UIView, color : UIColor, width : CGFloat)
{
    view.layer.borderColor = color.cgColor
    view.layer.borderWidth = width
}

//Set Borders
func setBorders(_ arrViews: [UIView], color : UIColor, radius : CGFloat, width : CGFloat)
{
    for view in arrViews
    {
        view.layer.borderWidth = width
        view.layer.borderColor = color.cgColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
    }
}

func setCornerRadius(_ arrViews : [UIView], radius : CGFloat)
{
    for view in arrViews
    {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
    }
}
/*//MARK: - Set TextField Indicator Right/Left View
 func setTextFieldsIndicator(_ txtFields : [UITextField], position: Int)
 {
 //position = 0 = left side, position = 1 = right side
 for txtField : UITextField in txtFields
 {
 //let imgView = UIImageView (image: UIImage (imageLiteral: "down_drop"))
 let imgView = UIImageView (image: UIImage (named: "down_drop"))
 
 
 if (position==1)
 {
 txtField.rightViewMode = UITextFieldViewMode.always
 imgView.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 20.0)
 imgView.contentMode = UIViewContentMode.scaleAspectFit
 txtField.rightView = imgView;
 }
 else {
 //imgView.image = UIImage (imageLiteral: "down_drop")
 imgView.image = UIImage (named: "down_drop")
 txtField.leftViewMode = UITextFieldViewMode.always
 imgView.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 20.0)
 imgView.contentMode = UIViewContentMode.scaleAspectFit
 txtField.leftView = imgView;
 }
 }
 }*/
func setTextFieldsIndicator(_ txtFields : UITextField, image:UIImage, position: Int)
{
    //position = 0 = left side, position = 1 = right side
    let imgView = UIImageView(image: image)
    imgView.contentMode = UIViewContentMode.scaleAspectFit
    if (position==1)
    {
        let v = UIView(frame: CGRect(x: 10, y: 0, width: txtFields.frame.size.height, height: txtFields.frame.size.height))
        imgView.frame = CGRect(x: v.bounds.size.height-24, y: 10, width: v.bounds.size.height-20, height: v.bounds.size.height-20)
        
        v.addSubview(imgView)
        txtFields.rightViewMode = UITextFieldViewMode.always;
        txtFields.rightView = v;
    }
    else
    {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: txtFields.frame.size.height, height: txtFields.frame.size.height))
        imgView.frame = CGRect(x: 10, y: 10, width: v.bounds.size.height-20, height: v.bounds.size.height-20);
        
        v.addSubview(imgView)
        txtFields.leftViewMode = UITextFieldViewMode.always;
        txtFields.leftView = v;
    }
}

func setTextFieldModification(arrTextField:[UITextField],arrImages :[AnyObject],position:Int,showIndicatorImage:Bool)
{
    for textField in arrTextField
    {
        if showIndicatorImage {
            setTextFieldsIndicator(textField , image: UIImage(named: arrImages[arrTextField.index(of: textField)!] as! String)! , position: position);
        }
    }
}

//Right Indicator
func setTextFieldIndicator(_ txtField : UITextField, image : UIImage)
{
    let imageView = UIImageView(image: image)
    txtField.rightViewMode = UITextFieldViewMode.always
    imageView.frame = CGRect(x: 0.0, y: 0.0, width: 15.0, height: 15.0)
    imageView.contentMode = UIViewContentMode.scaleAspectFit
    imageView.clipsToBounds = true
    txtField.rightView = imageView;
}

//Right Indicator ArrTextFields
func setArrTextFieldIndicator(_ arrTextFields: [UITextField], arrImages : [AnyObject])
{
    for txtField in arrTextFields
    {
        setTextFieldIndicator(txtField, image: UIImage(named: arrImages[arrTextFields.index(of: txtField)!] as! String)!)
    }
}

//User Interaction
func setUserInterAction(_ arrViews: [UIView], isOn : Bool)
{
    for view in arrViews
    {
        view.isUserInteractionEnabled = isOn
    }
}

//Label Color
func setLabelColor(_ arrLables: [UILabel], color : UIColor)
{
    for label in arrLables
    {
        label.textColor = color
    }
}

//Text Color
func setTextColor(_ arrtxtflds: [UITextField], color : UIColor)
{
    for txtfld in arrtxtflds
    {
        txtfld.textColor = color
    }
}

//Left Margin
func setLeftPadding(_ txtField: UITextField)
{
    let view = UIView()
    view.frame = CGRect(x: 0.0, y: 0.0, width: 10, height: 20)
    txtField.leftViewMode = UITextFieldViewMode.always
    txtField.leftView = view
}

//MARK: - Set Borders
func addTextFieldsBottomBorder(_ arrTextFields: [UITextField], color: UIColor)
{
    for textfields in arrTextFields
    {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textfields.bounds.size.height - 1, width: textfields.bounds.size.width, height: 1.0)
        bottomLine.backgroundColor = color.cgColor
        textfields.borderStyle = UITextBorderStyle.none
        textfields.layer.addSublayer(bottomLine)
    }
}
//Add Border to View
func addTopBorderWithColor(_ objView : UIView, color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: 0, width: objView.frame.size.width, height: width)
    objView.layer.addSublayer(border)
}

func addBottomBorderWithColor(_ objView : UIView, color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: objView.frame.size.height - width, width: objView.frame.size.width, height: width)
    objView.layer.addSublayer(border)
}

func addLeftBorderWithColor(_ objView : UIView, color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: 0, width: width, height: objView.frame.size.height)
    objView.layer.addSublayer(border)
}

func addRightBorderWithColor(_ objView : UIView, color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: objView.frame.size.width, y: 0, width: width, height: objView.frame.size.height)
    objView.layer.addSublayer(border)
}

func addTextViewBottomBorder(_ arrTextViews: [IQTextView])
{
    for textView in arrTextViews
    {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textView.bounds.height - 1, width: textView.bounds.width, height: 1.0)
        bottomLine.backgroundColor = const_Color_Border.cgColor
        textView.layer.addSublayer(bottomLine)
    }
}

//MARK: - UIImageView
//Tint Color
func setTintColor(imgView : UIImageView, color : UIColor)
{
    imgView.image = imgView.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    imgView.tintColor = color
}

//MARK: - Date-Time Formattion
func getDefaultTime(time: String, format : String) -> Date { //Convert String Time to NSDate
    let timeFormatOriginal = DateFormatter()
    timeFormatOriginal.dateStyle = DateFormatter.Style.none
    timeFormatOriginal.timeStyle = DateFormatter.Style.short
    timeFormatOriginal.timeZone = TimeZone.current
    timeFormatOriginal.dateFormat = format
    return timeFormatOriginal.date(from: time)!
}

func getDefaultTimeToStore(time: String, format : String) -> String {
    let timeFormatOriginal = DateFormatter()
    timeFormatOriginal.dateStyle = DateFormatter.Style.none
    timeFormatOriginal.timeStyle = DateFormatter.Style.short
    timeFormatOriginal.timeZone = TimeZone.current
    timeFormatOriginal.dateFormat = format
    
    let time24 = timeFormatOriginal.date(from: time)
    
    timeFormatOriginal.dateFormat = timeFormatDefault
    
    return timeFormatOriginal.string(from: time24!)
}

func getGMTDateTime(_ datetime: Date, format : String) -> String {
    let timezone: TimeZone = TimeZone.autoupdatingCurrent
    let seconds: Int = timezone.secondsFromGMT()
    //offset
    
    //let currentdate: NSDate = NSDate()
    let dateFormat: DateFormatter = DateFormatter()
    dateFormat.dateFormat = format
    // format
    
    dateFormat.timeZone = TimeZone(secondsFromGMT: seconds)
    return dateFormat.string(from: datetime)
}

func getDefaultDate(_ datetime: String, format : String) -> Date {
    let dateFormat: DateFormatter = DateFormatter()
    dateFormat.dateFormat = format
    return dateFormat.date(from: datetime)!
}

func getDefaultDateWithTimeZone(_ datetime: String, format : String) -> Date {
    let dateFormat: DateFormatter = DateFormatter()
    dateFormat.dateFormat = format
    dateFormat.timeZone = TimeZone(identifier: "GMT")
    return dateFormat.date(from: datetime)!
}

func getDisplayDate(date: String, dateFormat : String, displayFormat : String) -> String {
    let datetimeFormatOriginal = DateFormatter()
    datetimeFormatOriginal.dateFormat = dateFormat
    
    let datetimeFormatDisplay = DateFormatter()
    datetimeFormatDisplay.dateFormat = displayFormat
    
    return datetimeFormatDisplay.string(from: datetimeFormatOriginal.date(from: date)!)
}

func getDateInDefaultFormat(date: String, dateFormat : String, dateStyle : DateFormatter.Style, timeStyle : DateFormatter.Style, isDisplayTime: Bool) -> String {
    let datetimeFormatOriginal = DateFormatter()
    datetimeFormatOriginal.dateFormat = dateFormat
    
    let datetimeFormatDisplay = DateFormatter()
    datetimeFormatDisplay.timeZone = TimeZone.current
    if isDisplayTime {
        datetimeFormatDisplay.timeStyle = timeStyle
    }
    datetimeFormatDisplay.dateStyle = dateStyle
    
    return datetimeFormatDisplay.string(from: datetimeFormatOriginal.date(from: date)!)
}

func convertDateFormate(date: String, convertFromFormat : String, convertToFormat : String) -> String {
    let datetimeFormatOriginal = DateFormatter()
    datetimeFormatOriginal.dateFormat = convertFromFormat
    
    let datetimeFormatDisplay = DateFormatter()
    datetimeFormatDisplay.dateFormat = convertToFormat
    
    return datetimeFormatDisplay.string(from: datetimeFormatOriginal.date(from: date)!)
}

func daysBetweenTwoDates(date: Date) -> String
{
    let calendar = NSCalendar.current
    
    // Replace the hour (time) of both dates with 00:00
    let fromDate = calendar.startOfDay(for: Date())
    let toDate = calendar.startOfDay(for: date)
    
    let flags = Calendar.Component.day
    let components = calendar.dateComponents([flags], from: fromDate, to: toDate)
    if components.day == 0 {
        let currentHour = calendar.component(.hour, from: Date())
        let newHour = calendar.component(.hour, from: date)
        return "\(currentHour - newHour) hours ago"
    }
    if components.day == -1 {
        return "Yesterday"
    }
    if components.day == -2 {
        return "Two days ago"
    }
    return ""
}

//MARK: - Currency Formattion
func getCurrencyFormat(localeIdentifier: String, price: NSNumber) -> String
{
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = NumberFormatter.Style.currency
    // localize to your grouping and decimal separator
    let locale = NSLocale(localeIdentifier: localeIdentifier)
    locale.displayName(forKey:  NSLocale.Key.currencySymbol, value: localeIdentifier)
    currencyFormatter.locale = locale as Locale!
    let priceString = currencyFormatter.string(from: price)
    return priceString!
    
}

// MARK: - CONSTANTS
/* colors */
func RGB(_ red:CGFloat,green:CGFloat,blue:CGFloat, alpha:CGFloat)->UIColor
{
    return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}

//MARK: - CollectionView equal Space
func setupCollectionView(classname:AnyClass,collectionView:UICollectionView,space:CGFloat)
{
    let identifier = String(describing: classname)
    collectionView.register(classname, forCellWithReuseIdentifier: identifier)
    collectionView.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = space
    collectionView.collectionViewLayout = layout
}

//MARK: - Loading Cell
func showLoadingCell(_ indicatorColor:UIColor) -> UITableViewCell
{
    let cell = UITableViewCell(style: .default, reuseIdentifier: "LoadingCell")
    cell.backgroundColor = UIColor.clear
    cell.selectionStyle = .none
    cell.isUserInteractionEnabled = false
    
    //cell.textLabel?.text = msg_LoadingMore
    
    let actIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    actIndicator.color = indicatorColor
    //actIndicator.center = CGPoint(x: (UIScreen.mainScreen().bounds.size.width/2)-(actIndicator.bounds.size.width/2), y: cell.center.y)
    actIndicator.frame = CGRect(x: 20.0, y: 20.0, width: 20.0, height: 20.0)
    cell.contentView.addSubview(actIndicator)
    actIndicator.startAnimating()
    actIndicator.hidesWhenStopped = true
    
    //let lblLoading: UILabel     = UILabel(frame: CGRectMake(50, 0, cell.bounds.size.width-70.0, cell.bounds.size.height))
    let lblLoading: UILabel     = UILabel(frame: CGRect(x: 50, y: actIndicator.frame.origin.y, width: cell.bounds.size.width-70.0, height: 20.0))
    lblLoading.text             = msg_LoadingMore
    lblLoading.numberOfLines    = 0
    lblLoading.lineBreakMode    = NSLineBreakMode.byWordWrapping
    lblLoading.textColor        = UIColor.lightGray
    lblLoading.textAlignment    = .left   //.Center
    cell.contentView.addSubview(lblLoading)
    
    return cell
}

//MARK: - Add Pull to Refresh
func addPullToRefresh(_ tableView: UITableView, ctrlRefresh: inout UIRefreshControl?, targetController: UIViewController, refreshMethod: Selector)
{
    //let ctrlRefresh = UIRefreshControl()
    ctrlRefresh = UIRefreshControl()
    ctrlRefresh!.backgroundColor = UIColor.white
    ctrlRefresh!.tintColor = const_Color_Primary
    ctrlRefresh!.attributedTitle = NSAttributedString(string: msg_PullToRefersh, attributes: [NSForegroundColorAttributeName: const_Color_Border_Default])
    ctrlRefresh!.addTarget(targetController, action: refreshMethod, for: .valueChanged)
    tableView.addSubview(ctrlRefresh!)
}

//MARK: - Check Record Available
func checkRecordAvailable(_ arrData: [AnyObject], tableView: UITableView, targetController: UIViewController, displayMessage: String)
{
    if arrData.count > 0 {
        tableView.reloadData()
        tableView.backgroundView = nil
    }
    else {
        tableView.reloadData()
        
        let lblNoData: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        lblNoData.text             = displayMessage
        lblNoData.numberOfLines    = 0
        lblNoData.lineBreakMode    = NSLineBreakMode.byWordWrapping
        lblNoData.textColor        = UIColor.lightGray
        lblNoData.textAlignment    = .center
        tableView.backgroundView = lblNoData
        tableView.separatorStyle = .none
    }
}

//With Refresh - UITableView
func checkRecordAvailableWithRefreshControl(_ arrData: [AnyObject], tableView: UITableView, ctrlRefresh: UIRefreshControl?, targetController: UIViewController, displayMessage: String)
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = DateFormatter.Style.short
    dateFormatter.timeStyle = DateFormatter.Style.long
    dateFormatter.dateFormat = "MMM d, h:mm a"
    let now = Date()
    let updateString = "Last Updated at " + dateFormatter.string(from: now)
    ctrlRefresh!.attributedTitle = NSAttributedString(string: updateString)
    
    //ctrlRefresh!.attributedTitle = NSAttributedString(string: msg_PullToRefersh, attributes: [NSForegroundColorAttributeName: const_Color_Border_Default])
    ctrlRefresh!.endRefreshing()
    
    if arrData.count > 0 {
        tableView.reloadData()
        tableView.backgroundView = nil
    }
    else {
        tableView.reloadData()
        
        let lblNoData: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        lblNoData.text             = displayMessage
        lblNoData.numberOfLines    = 0
        lblNoData.lineBreakMode    = NSLineBreakMode.byWordWrapping
        lblNoData.textColor        = UIColor.lightGray
        lblNoData.textAlignment    = .center
        tableView.backgroundView = lblNoData
        tableView.separatorStyle = .none
    }
}

//With image - UITableView
func checkRecordAvailableWithImg(_ arrData: [AnyObject], tableView: UITableView, targetController: UIViewController, displayMessage: String, vc: UIViewController, img: UIImage)
{
    if arrData.count > 0 {
        tableView.reloadData()
        tableView.backgroundView = nil
    }
    else {
        tableView.reloadData()
        let views = Bundle.main.loadNibNamed("NoDataView", owner: vc, options: nil)
        let calloutView = views?[0] as! NoDataView
        calloutView.lblMsg.text = displayMessage
        calloutView.ivNoData.image = img
        tableView.backgroundView = calloutView
        tableView.separatorStyle = .none
    }
}

//UIView
func checkRecordAvailableForView(_ arrData: [AnyObject], targetController: UIViewController, displayMessage: String)
{
    if arrData.count > 0 {
        // targetController.backgroundView = nil
    }
    else {
        
        let lblNoData: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: targetController.view.bounds.size.width, height: targetController.view.bounds.size.height))
        lblNoData.text             = displayMessage
        lblNoData.numberOfLines    = 0
        lblNoData.lineBreakMode    = NSLineBreakMode.byWordWrapping
        lblNoData.textColor        = UIColor.lightGray
        lblNoData.textAlignment    = .center
        targetController.view.addSubview(lblNoData)
    }
}

//UICollectionView
func checkRecordAvailableForCollView(_ arrData: [AnyObject], collectionView: UICollectionView, targetController: UIViewController, displayMessage: String)
{
    if arrData.count > 0 {
        collectionView.reloadData()
        collectionView.backgroundView = nil
    }
    else {
        collectionView.reloadData()
        
        let lblNoData: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
        lblNoData.text             = displayMessage
        lblNoData.numberOfLines    = 0
        lblNoData.lineBreakMode    = NSLineBreakMode.byWordWrapping
        lblNoData.textColor        = UIColor.lightGray
        lblNoData.textAlignment    = .center
        collectionView.backgroundView = lblNoData
    }
}

//MARK: - No data Found Message - UITableView
//Without image
func setNoDataFoundMsg(tableView: UITableView, displayMessage: String)
{
    let lblNoData: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
    lblNoData.text             = displayMessage
    lblNoData.numberOfLines    = 0
    lblNoData.lineBreakMode    = NSLineBreakMode.byWordWrapping
    lblNoData.textColor        = UIColor.lightGray
    lblNoData.textAlignment    = .center
    tableView.backgroundView = lblNoData
    tableView.separatorStyle = .none
}

//With Image
func setNoDataFoundMsgWithImg(tableView: UITableView, displayMessage: String, vc: UIViewController, img: UIImage)
{
    let views = Bundle.main.loadNibNamed("NoDataView", owner: vc, options: nil)
    let calloutView = views?[0] as! NoDataView
    calloutView.lblMsg.text = displayMessage
    calloutView.ivNoData.image = img
    tableView.backgroundView = calloutView
    tableView.separatorStyle = .none
}

//MARK: - Calling Number
func callNumber(_ phoneNumber:String) {
    if let phoneCallURL:URL = URL(string:"tel://\(phoneNumber)") {
        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(phoneCallURL)) {
            if #available(iOS 10.0, *) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

//MARK: - Validate TextField
func requiredField(_ txtField:UITextField,title:String,message:String?) -> Bool {
    if txtField.hasText {
        return true
    }
    else {
        showAlertMessage(title, message: message != nil ? message! :"Please enter \(txtField.placeholder!)", okTitle: nil, cancelTitle: nil, okCompletion: { (UIAlertAction) in
        }, cancelCompletion: nil)
        return false
    }
}
// Email validation
func isValidEmail(_ testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let result = emailTest.evaluate(with: testStr)
    return result
}

// Password validation
func isValidPassword(_ testStr:String) -> Bool {
    let passwordRegEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9]).{7,17}$"
    let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
    let result = passwordTest.evaluate(with: testStr)
    return result
}


//MARK: - Play Audio
func playAudio(_ fileName: String)
{
    let resourcePath = Bundle.main.resourcePath!
    let filePath = "\(resourcePath)/" + "\(fileName)"
    print(filePath)
    let url: URL = URL(fileURLWithPath: filePath)
    let playerObject = AVPlayer(url: url)
    let playerController = AVPlayerViewController()
    playerController.player = playerObject
    playerObject.play()
}

//#pragma mark - ALERT MACRO
// MARK: - ALERT MACRO
/* ALERT MACRO */
func showAlertMessage(_ title:String,message:String,okTitle:String?,cancelTitle:String?,okCompletion: ((UIAlertAction) -> Void)?,cancelCompletion:((UIAlertAction) -> Void)?)
{
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let OKAction = UIAlertAction(title: okTitle != nil ? okTitle: "Ok", style: UIAlertActionStyle.default, handler: okCompletion)
    let cancelAction = UIAlertAction(title: cancelTitle != nil ? cancelTitle: "Cancel", style: UIAlertActionStyle.default, handler: cancelCompletion)
    
    if (okCompletion != nil) {
        alertController.addAction(OKAction)
    }
    if (cancelCompletion != nil) {
        alertController.addAction(cancelAction)
    }
    alertController.show()
}


//MARK: - ALERT
func showMessage(title: String, message: String!, VC: UIViewController) {
    //msg_TitleAppName
    let alert : UIAlertController = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
        UIAlertAction in
    }
    alert.addAction(okAction)
    VC.present(alert, animated: true, completion: nil)
}
func showAlertMessage(title: String, message: String!){
    let alert : UIAlertController = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
        UIAlertAction in
    }
    alert.addAction(okAction)
    alert.show()
}
func showMessageWithConfirm(title: String, message:String, okTitle:String?, cancelTitle:String?, okCompletion: ((UIAlertAction) -> Void)?,cancelCompletion:((UIAlertAction) -> Void)?)
{
    let alertController = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
    let OKAction = UIAlertAction(title: okTitle != nil ? okTitle: "Ok", style: UIAlertActionStyle.default, handler: okCompletion)
    let cancelAction = UIAlertAction(title: cancelTitle != nil ? cancelTitle: "Cancel", style: UIAlertActionStyle.default, handler: cancelCompletion)
    
    if (okCompletion != nil) {
        alertController.addAction(OKAction)
    }
    if (cancelCompletion != nil) {
        alertController.addAction(cancelAction)
    }
    alertController.show()
}

//MARK: - JSON Functions
func loadJson(forFilename fileName: String) -> NSDictionary? {
    
    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
        if let data = NSData(contentsOf: url) {
            do {
                let dictionary = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? NSDictionary
                
                return dictionary
            } catch {
                print("Error!! Unable to parse  \(fileName).json")
            }
        }
        print("Error!! Unable to load  \(fileName).json")
    }
    
    return nil
}

//MARK:- Convert from JSON to NSData
func jsonToData(json: Any) -> Data? {
    do {
        return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
    } catch let myJSONError {
        print(myJSONError)
    }
    return nil;
}
/*
 func jsonToNSData(json: AnyObject) -> NSData?{
 do {
 return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData?
 } catch let myJSONError {
 print(myJSONError)
 }
 return nil;
 }*/
//MARK:- Convert from NSData to JSON Object
func dataToJSON(data: Data) -> Any? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    } catch let myJSONError {
        print(myJSONError)
    }
    return nil
}

//MARK: - LazyLoading Image
func downloadImage(url:String,imgView:UIImageView)
{
    URLSession.shared.dataTask(with: NSURL(string: url)! as URL, completionHandler: { (data, response, error) -> Void in
        if error != nil {
            //print(error ?? <#default value#>)
            return
        }
        DispatchQueue.main.async(execute: { () -> Void in
            let image = UIImage(data: data!)
            imgView.image = image
        })
        
    }).resume()
}

//MARK: - Image Fuctions
func saveImageToDirectory(folderName: String, image: UIImage, imageName: String)
{
    var documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    if folderName != ""
    {
        // Create a new path for the new images folder
        documentsDirectoryURL = documentsDirectoryURL.appendingPathComponent(folderName)
        //var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: documentsDirectoryURL.path)
        //fileExistsAtPath(imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: documentsDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }
    }
    // create a name for your image
    let fileURL = documentsDirectoryURL.appendingPathComponent(imageName)
    if !FileManager.default.fileExists(atPath: fileURL.path) {
        do {
            // UIImagePNGRepresentation(self.imgview.image!)!
            try UIImageJPEGRepresentation(image, 1.0)?.write(to: fileURL)
            print(fileURL)
            print("Image Added Successfully")
            
        } catch {
            print(error)
        }
    } else {
        print("Error! Image Not Added \nImage with same identifire is exist")
    }
}
func getImageFromDirectory(folderName: String, imageName: String) -> UIImage?
{
    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
    let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
    if let dirPath          = paths.first
    {
        var imageURL = URL(fileURLWithPath: "")
        imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(folderName)
        /*
         if folderName != "" {
         imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(folderName)
         }*/
        imageURL = URL(fileURLWithPath: imageURL.path).appendingPathComponent(imageName)
        //print(dirPath)
        let image    = UIImage(contentsOfFile: imageURL.path)
        if image != nil{
            // Do whatever you want with the image
            return image
        }
        else{
            print("Image Not Found")
            return nil
        }
    }
    
    return nil
}

//MARK:- Rounded Picture
func roundedImageView(imgView: UIImageView, borderWidth: Float, borderColor: UIColor)
{
    imgView.layer.cornerRadius = imgView.frame.size.width / 2
    imgView.clipsToBounds = true
    imgView.layer.borderWidth = CGFloat(borderWidth)
    imgView.layer.borderColor = borderColor.cgColor
}
//MARK: - TableView Dynamic cell Height
func configureTableView(tblView:UITableView)
{
    tblView.rowHeight = UITableViewAutomaticDimension
    tblView.estimatedRowHeight = 44
}

func configureTableView(tblView:UITableView,estimatedHeigth : CGFloat)
{
    tblView.rowHeight = UITableViewAutomaticDimension
    tblView.estimatedRowHeight = estimatedHeigth
}


//MARK: - Load TableView Cell
func loadFromNibNamed(viewClass : AnyObject) -> UIView?
{
    let bundle = Bundle(for:type(of: viewClass))
    let nib = UINib(nibName:String(describing: viewClass.classForCoder!), bundle: bundle)
    return (nib.instantiate(withOwner: viewClass, options: nil)[0] as! UIView)
}

//MARK:- Open Translate Url
func openTranslateUrl(withText: String)
{
    let txtAppend = withText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let url = "https://translate.google.com/#auto/en/\(txtAppend!)"
    let openUrl = NSURL(string: url)
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(openUrl! as URL, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(openUrl! as URL)
    }
}

//MARK: - Convert hex into color
func HexToColor(hexString: String, alpha:CGFloat?) -> UIColor {
    // Convert hex string to an integer
    let hexint = Int(intFromHexString(hexStr: hexString))
    let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
    let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
    let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
    let alpha = alpha!
    // Create color object, specifying alpha as well
    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    return color
}
func intFromHexString(hexStr: String) -> UInt32 {
    var hexInt: UInt32 = 0
    // Create scanner
    let scanner: Scanner = Scanner(string: hexStr)
    // Tell scanner to skip the # character
    scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet
    // Scan hex value
    scanner.scanHexInt32(&hexInt)
    return hexInt
}

//MARK: - Check Nill
func checkArrayForNill(arrToCheck:Any?) -> Any {
    return arrToCheck == nil ? [] : arrToCheck!
}
func checkDictionaryForNill(dictToCheck:[String : Any]?) -> [String : Any] {
    return dictToCheck == nil ? [:] : dictToCheck!
}
func checkStringForNill(strToCheck:AnyObject?) -> String {
    return strToCheck == nil ? "" : "\(strToCheck!)"
}

//MARK: - String Category
extension String {
    func toBool() -> Bool {
        switch self.lowercased() {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return false
        }
    }
}

//MARK: - Show Map Directions
func getMapDirection(mapView: MKMapView,lattitude: Double, longitude: Double)
{
    let url = "http://maps.apple.com/?saddr=\(mapView.userLocation.coordinate.latitude),\(mapView.userLocation.coordinate.longitude)&daddr=\(lattitude),\(longitude)"
    if #available(iOS 10.0, *) {
        UIApplication.shared.open((NSURL(string: url)! as URL), options: [:], completionHandler: nil)
    } else {
        // Fallback on earlier versions
    }
}

//MARK: - Distance Between Two Location
func distanceBetweenTwoLocations(source:CLLocation,destination:CLLocation) -> Double {
    let distanceMeters = source.distance(from: destination)
    let distanceKM = distanceMeters / 1000
    let roundedTwoDigit = distanceKM.roundedTwoDigit
    return roundedTwoDigit
}
//MARK: - Open Schema
func openScheme(Url: String)
{
    if !(UIApplication.shared.canOpenURL(NSURL (string: Url)! as URL)) {
        let alertController = UIAlertController(title: msg_TitleAppName, message: "MEH is not able to redirect you to the particular settings. Please go to settings and manually do the configuration.", preferredStyle:  UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK", style:  UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
        })
        alertController.addAction(OKAction)
        alertController.show()
    }else{
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(NSURL(string: "prefs:root=LOCATION_SERVICES")! as URL, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
}

//MARK: - Remove UserObject
func removeUserObject()
{
    removeFromUserDefaultForKey(key_User_Object)
}

//MARK: - Remove UserToken
func removeUserToken()
{
    removeFromUserDefaultForKey(key_UserToken)
}

//MARK: - Open Sidemenu
func openSideMenu2(vc: UIViewController)
{
    if (SideMenuManager.menuLeftNavigationController != nil) {
        vc.view.endEditing(true)
        vc.present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }
    else {
        let menuLeftNavController = storyBoard_SideMenu.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
        
        //Add Left Menu//
        menuLeftNavController.leftSide = true
        SideMenuManager.menuLeftNavigationController = menuLeftNavController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.menuAddPanGestureToPresent(toView: vc.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: vc.navigationController!.view)
        
        SideMenuManager.menuPresentMode = .menuSlideIn   //.ViewSlideOut
        vc.present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        //Add Left Menu End//
    }
}

//MARK: - Add Shadow To View
func addShadow(views: [UIView], opacity: CGFloat, radius: CGFloat, color: UIColor)
{
    for view in views
    {
        view.layer.shadowOpacity = Float(opacity) //0.7
        view.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        view.layer.shadowRadius = radius //5.0
        view.layer.shadowColor = color.cgColor
    }
}

