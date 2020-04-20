//
//  FRDetailsViewController.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 13/01/20.
//  Copyright © 2020 iRestoreApp. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
import ImageLoader
import AWSS3

enum ButtonTag : Int {
    case kTagImage1_Button = 11, kTagImage2_Button = 12,kTagImage3_Button  = 13

}
class FRDetailsViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate {

    @IBOutlet var  damageScopeLabel: UILabel!
    @IBOutlet var  damagePartLabel: UILabel!
    @IBOutlet var  iconImgView: UIImageView!
    @IBOutlet var  tagView: UIView!
    @IBOutlet var  tagViewHeightConstraint:NSLayoutConstraint!

    @IBOutlet var  lblName: UILabel!
    @IBOutlet var  lblEmail: UILabel!
    @IBOutlet var  lblPhone: UILabel!
    @IBOutlet var  lblDate: UILabel!
    @IBOutlet var  lblDamageType: UILabel!
    @IBOutlet var  lblDeviceAddress: UILabel!
    @IBOutlet var  lblUserAddress: UILabel!
    @IBOutlet var  lblLocation: UILabel!
    @IBOutlet var  lblSafeStatus: UILabel!
    @IBOutlet var  lblPoleNumber: UILabel!
    @IBOutlet var  lblComments: UILabel!
    @IBOutlet var  lblRoadStatus: UILabel!
    
    @IBOutlet var  tapToExpandPhotoLbl: UILabel!
    @IBOutlet var  tags: UILabel!
    @IBOutlet var  lblTags: UILabel!
//    @IBOutlet var  hasShownDirection: UILabel!
    
    @IBOutlet var  img1View:UIImageView!
    @IBOutlet var  img2View:UIImageView!
    @IBOutlet var  img3View:UIImageView!
    
    @IBOutlet var  btnImg2View:UIButton!
    @IBOutlet var  btnImg1View:UIButton!
    @IBOutlet var  btnImg3View:UIButton!
    @IBOutlet var  btnShare:UIButton!

    
    @IBOutlet var  googleMapView:GMSMapView!
    @IBOutlet var  geoLocationMapView:MKMapView!
    
    @IBOutlet var  reportDetailsScrollview:UIScrollView!
    @IBOutlet var  tapToExpandPhotoYConstraint:NSLayoutConstraint!
    @IBOutlet var  tapToExpandPhotoBottomConstraint:NSLayoutConstraint!

    let appDelegate: AppDelegate        = UIApplication.shared.delegate as! AppDelegate
    var activityIndicator =  ActivityIndicator()

    var reportData : ReportData?
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    var hasShownDirection = false
    override func viewDidLoad() {
        googleMapView.delegate = self
        navigationBarSettings()
        populateData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        refreshMap()
    }
    func navigationBarSettings() {

        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.isTranslucent = false
        

        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Avenir", size: 20.0) as Any, NSAttributedString.Key.foregroundColor : UIColor.init("0x363636")]
        self.navigationItem.title = NSLocalizedString("Damage Detail Report", comment: "")
        
        var backButton: UIButton
        var leftBarBtnItem : UIBarButtonItem
        backButton = UIButton.init(type: UIButton.ButtonType.custom)
        backButton.frame.size = CGSize.init(width: 50, height: 50)
        backButton.contentHorizontalAlignment = .left

        // add image
        backButton.setImage(UIImage.init(named: "back_green"), for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(backBtnClicked), for: .touchUpInside)
        leftBarBtnItem = UIBarButtonItem.init(customView: backButton)
        self.navigationItem.leftBarButtonItem = leftBarBtnItem

    }
    @objc func backBtnClicked() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    func populateData() {
        
        self.perform(#selector(setScrollViewContentSize), with: nil, afterDelay: 1.0)
        if (reportData?.imageCount == 1) {
            
            let image1Url:NSString = reportData?.thumbnail1Path as? NSString ?? ""
            self.downloadImage(path: image1Url.lastPathComponent
                , isThumbnail: true,identifier: 2)
            
//            self.downloadImage(path: (reportData?.thumbnail1Path)!, isThumbnail: true, identifier: 1)
//            img2View.load.request(with: URL.init(string: (reportData?.thumbnail1Path)!) ?? "")
            
            
            btnImg1View.isEnabled = false
            btnImg3View.isEnabled = false
            self.img1View.isHidden = true
            self.img3View.isHidden = true

            
        }else if (reportData?.imageCount == 2){
            let image1Url:NSString = reportData?.thumbnail1Path as? NSString ?? ""
            self.downloadImage(path: image1Url.lastPathComponent
                , isThumbnail: true,identifier: 1)
            
            let image2Url:NSString = reportData?.thumbnail2Path as? NSString ?? ""
            self.downloadImage(path: image2Url.lastPathComponent
                , isThumbnail: true,identifier: 3)
            
            
//            img1View.load.request(with: URL.init(string: (reportData?.thumbnail1Path)!) ?? "")

//            img3View.load.request(with: URL.init(string: (reportData?.thumbnail2Path)!) ?? "")
            
            self.img1View.isHidden = false
            self.img3View.isHidden = false

            btnImg1View.isEnabled = true
            btnImg3View.isEnabled = true
            
            self.img2View.isHidden = true
            btnImg2View.isEnabled = false
        } else {
            btnImg1View.isEnabled = false
            btnImg3View.isEnabled = false
            btnImg2View.isEnabled = false
            self.img1View.isHidden = true
            self.img3View.isHidden = true
            self.img2View.isHidden = true
            self.tapToExpandPhotoLbl.text = "No Images are available!"
            self.tapToExpandPhotoYConstraint.priority = UILayoutPriority(rawValue: 999)
            self.tapToExpandPhotoBottomConstraint.priority = UILayoutPriority(rawValue: 250)
        }
        lblName.text = reportData?.name
        lblEmail.text = reportData?.emil
        
        if  let phone = reportData?.phone {
            let part1 = phone.prefix(3)
            let part3 = phone.suffix(4)
            
            let start = phone.index(phone.startIndex, offsetBy: 3)
            let end = phone.index(phone.endIndex, offsetBy: -4)
            let range = start..<end
            
            let part2 = phone[range]
            lblPhone.text = "\(part1) \(part2)-\(part3)"
        }
        
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormatterKey
        let timeZone = NSTimeZone(name: "UTC")
        dateFormatter.timeZone = timeZone! as TimeZone
        if let date : Date =  dateFormatter.date(from: reportData?.dateCreated ?? "") {
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = Constants.listScreenDateFormat
            lblDate.text = dateFormatter2.string(from: date)
            
        }
        else {
            lblDate.text = ""
        }
        
        damageScopeLabel.text = (reportData?.damageTypeDisplayName) as! String
        lblDamageType.text =  reportData?.damageSubTypeDisplayName
        
        if let type = reportData?.damageType as? String {
            let imageName = "\(type)_icon"
            iconImgView.image = UIImage.init(named: imageName)

        }

        
//        if var userAddressArray  = self.reportData?.userAddress?.components(separatedBy: ",") {
//            userAddressArray.removeLast()
//            var count = 0
//            var addressString = ""
//            for st in userAddressArray {
//                if (count == 1 ) {
//                    addressString =  addressString.appending("\n")
//                    
//                }
//                else {
//                    if (count == 1 ) {
//                        let trimmedSt =  st.trimmingCharacters(in: .whitespaces)
//                        addressString =  addressString.appending(trimmedSt)
//                        
//                    }
//                    else {
//                        addressString =  addressString.appending(st)
//                    }
//                    
//                }
//                count = count + 1
//                
//            }
//            lblUserAddress.text = addressString
//            
//        }
        
        if var resolvedAddressArray  = self.reportData?.userAddress?.components(separatedBy: ",")
        {
            print(resolvedAddressArray)
            resolvedAddressArray.removeLast()
            var count = 0
            var addressString = ""
            for st in resolvedAddressArray {
                if (count == 1 ) {
                    addressString =  addressString.appending("\n")

                }
                
                if (count == 1 ) {
                        let trimmedSt =  st.trimmingCharacters(in: .whitespaces)
                        addressString =  addressString.appending(trimmedSt)

                }
                else {
                        addressString =  addressString.appending(st)
                }

                count = count + 1

            }
            lblDeviceAddress.text = addressString
            lblUserAddress.text = addressString //for time being


        }
        
        
        
        lblLocation.text = self.formatLatLong()
        
        //check for boolean value
        lblRoadStatus.text  = reportData?.roadBlockedStatus
        lblSafeStatus.text  = reportData?.safeStatus
        
        
        if reportData?.poleNumber == "" ||  reportData?.poleNumber == nil {
            lblPoleNumber.text = "NA"
            
        }
        else {
            lblPoleNumber.text = reportData?.poleNumber
            
        }
        
        
        
        if (reportData?.comments == "") {
            lblComments.text = "NA"
            
        } else {
            lblComments.text = reportData?.comments
        }
        
        self.hideHeightConstraints()
        
    }
    func refreshMap()  {
        
        let placeCord = CLLocationCoordinate2D.init(latitude: reportData?.latitude ?? 0.0, longitude: reportData?.longitude ?? 0.0)
        let camerPos  = GMSCameraPosition.init(latitude: placeCord.latitude, longitude: placeCord.longitude, zoom: 10)
        self.googleMapView.camera = camerPos
        
        let marker = GMSMarker.init()
        marker.position = CLLocationCoordinate2D.init(latitude: placeCord.latitude, longitude: placeCord.longitude)
        marker.map = googleMapView
        if let type  = reportData?.damageType as?  String {
            let pinName = "pin_\((reportData?.damageType)!)"
            marker.icon = UIImage.init(named: pinName)
        }
        
  
    }
    
    func formatLatLong()  -> String {
        
        let latitude = self.reportData?.latitude
        let longitude = self.reportData?.longitude
    
        if latitude != nil && longitude != nil {
            
        
        var latSeconds : Int = Int(round(abs((latitude ?? 0) * 3600)))
        var latDegrees = (latSeconds ?? 0) / 3600
        latSeconds = (latSeconds ?? 0) % 3600
        let latMinutes = (latSeconds ?? 9) / 60
        latSeconds %= 60
        
        var longSeconds : Int = Int(round(abs((longitude ?? 0) * 3600)))
        var longDegrees = (longSeconds ?? 0) / 3600
        longSeconds = (longSeconds ?? 0) % 3600
        var longMinutes = (longSeconds ?? 0) / 60
        longSeconds %= 60
        
        let  latDirection = (latitude! > 0.0) ? "N" : "S"
        let  longDirection = (longitude! > 0.0) ? "E" : "W";
        
        let st  = "\(latDegrees)° \(latMinutes)' \(latDirection), \(longDegrees)° \(longMinutes)' \(longDirection) "
            return st

        }
        else {
           return ""
        }
    }
    @objc func setScrollViewContentSize()
    {
//        if let _tagArray =  reportData?.tagArray  as?  [String] {
//            if (Helper.shared.nullToNil(value:_tagArray as AnyObject ) != nil && _tagArray.count ?? 0 > 0 ){
//                self.reportDetailsScrollview.contentSize = CGSize.init(width: self.reportDetailsScrollview.frame.size.width, height:  self.lblTags.frame.origin.y + self.lblTags.frame.size.height + 2)
//            }
//            else {
//                self.reportDetailsScrollview.contentSize = CGSize.init(width: self.reportDetailsScrollview.frame.size.width, height:  self.lblUserAddress.frame.origin.y + self.lblUserAddress.frame.size.height + 2)
//            }
//
//        }
//        else {
            self.reportDetailsScrollview.contentSize = CGSize.init(width: self.reportDetailsScrollview.frame.size.width, height:  (self.lblUserAddress.frame.origin.y + self.lblUserAddress.frame.size.height + 250))
//        }
        
        
    }
    
    
    func hideHeightConstraints() {
        //var _ :String = ""
        if let _tagArray =  reportData?.tagArray  as?  [String] {
            if (Helper.shared.nullToNil(value:_tagArray as AnyObject ) != nil && _tagArray.count ?? 0 > 0 ){
                
                let tagListView  = TagListView.init(frame: CGRect.init(x: 0, y: 0, width: self.tagView.frame.width, height: 100))
                tagListView.textFont = UIFont(name: "Avenir-Medium", size: 14.0) ??  UIFont.systemFont(ofSize: 15)
                tagListView.textColor = UIColor.init("0x666666")
                tagListView.paddingY = 10
                tagListView.paddingX = 15

                tagListView.alignment = .left
                for tag in _tagArray {
                    let tag = tagListView.addTag(tag)
                    tag.cornerRadius = 15
                    tag.tagBackgroundColor = UIColor.init("0xF0F0F0") //UIColor.init("0xe7e7e7")
                    tag.enableRemoveButton = false
                    tag.enableIconButton = false
                }
                
                let size = tagListView.intrinsicContentSize
                self.tagViewHeightConstraint.constant = size.height
                self.tagView.addSubview(tagListView)
            }
            else {
                 self.tagViewHeightConstraint.constant = 10
                //self.lblTags.text = ""
                //self.tags.text = ""
                //lblTags.isHidden = true
                //tags.isHidden = true
            }
        }
               //0 str = str.appending(_tagArray.com)

      
    }
    //MARK: Location Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        if(hasShownDirection){
            self.showDirection()
        }

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }
    func  showDirection()
    {
        if let lat = currentLocation?.coordinate.latitude , let long = currentLocation?.coordinate.longitude {
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                UIApplication.shared.openURL(NSURL(string:
                    "comgooglemaps://?saddr=&daddr=\(lat),\(long)&directionsmode=driving")! as URL)

            } else {

//
//            NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",[latitude floatValue], [longitude floatValue], self.reportModel.latitude, self.reportModel.longitude]; //start address(current location) and destinatin address is passed.
//            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: directionsURL]];
        }
            }
        
        
        
        hasShownDirection = false
    }
    func getAddressDict() -> CLLocation?
       {
           var currentLocation: CLLocation
           
           if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
               CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
               
               if let loc = locationManager?.location {
                   
                   currentLocation = loc
                    return currentLocation

               }
               else{
                    return nil
                }
              
           }
           else {
              return nil

               
           }
       }
    
    
    @IBAction func mapsDirection(_ sender: UIButton) {
        if(locationManager == nil) {
            
            locationManager = CLLocationManager.init()
            locationManager?.requestAlwaysAuthorization()
            locationManager?.delegate = self
            if CLLocationManager.locationServicesEnabled() {
                locationManager?.requestAlwaysAuthorization()
                locationManager?.startUpdatingLocation()
            }
            
        }
        if let latLong = self.getAddressDict() as? CLLocation  {
            currentLocation = latLong
        }
        if(currentLocation == nil){
               hasShownDirection = true

           }
           else {
                self.showDirection()
                hasShownDirection = false

           }
    }
    

    @IBAction func placePhoneCall(_ sender: UIButton) {
        let phone = (self.reportData?.phone)!
        let phoneUrl = URL(string: "telprompt://\(phone)")
        let phoneFallbackUrl = URL(string: "tel://\(phone)")
        if(phoneUrl != nil && UIApplication.shared.canOpenURL(phoneUrl!)) {
            UIApplication.shared.open(phoneUrl!, options: [:] ) { (success) in
            if(!success) {
              // Show an error message: Failed opening the url
            }
          }
        }
        else if(phoneFallbackUrl != nil && UIApplication.shared.canOpenURL(phoneFallbackUrl!)) {
               UIApplication.shared.open(phoneFallbackUrl!, options: [:] ) { (success) in
               if(!success) {
                 // Show an error message: Failed opening the url
               }
             }
           }

        else {
            // Show an error message: Your device can not do phone calls.
        }
    }
    @IBAction func btnShare(_ sender: UIButton) {
        let text = "Report Link : \((reportData?.reportDetailURL)!)"
        let activityItems = [text]
        if let av =  UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil) as? UIActivityViewController {
            av.excludedActivityTypes =  [.airDrop]
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                av.popoverPresentationController?.sourceView = sender as! UIView
                av.popoverPresentationController?.sourceRect =  sender.bounds
                av.popoverPresentationController?.permittedArrowDirections = [.down]
            }
            self.present(av, animated: true, completion: nil)

        }
    }
    
    // send phone call.
    @IBAction func imageTapped(_ sender: UIButton) {
        guard let value = ButtonTag(rawValue: sender.tag) else { return }
        let image1Url:NSString = reportData?.img1URL as? NSString ?? ""
        let image2Url:NSString = reportData?.img2URL as? NSString ?? ""

        let thumbNail1:NSString = reportData?.thumbnail1Path as? NSString ?? ""
        let thumbNail2:NSString = reportData?.thumbnail2Path as? NSString ?? ""

        switch (value) {
            case   .kTagImage1_Button:
            if (image1Url.length == 0) {
                // [Helper displayAlert:@"Image has not been uploaded for this thumbnail."];
                return;   // return if image is not available for that thumbnail.
            }
            else {
                self.downloadImage(path: image1Url.lastPathComponent,isThumbnail:false,identifier:-1)
               // self.downloadImage(path:image1Url.lastPathComponent ) //gree

            }
            
           // [activityIndicator startAnimating];
            //[self downloadImage:[_reportModel.img1URL lastPathComponent]];
            //pass respective name for the image in param
            break;
        case  .kTagImage2_Button:
                if (image1Url.length == 0 &&  image2Url.length == 0) {

                   // [Helper displayAlert:@"Image has not been uploaded for this thumbnail."];
                    return;
                }
                else if thumbNail1 != "" {
                    self.downloadImage(path: image1Url.lastPathComponent,isThumbnail:false,identifier:-1)

                    //self.downloadImage(path:image1Url.lastPathComponent )//gree

                }
                else {
                    self.downloadImage(path: image2Url.lastPathComponent,isThumbnail:false,identifier:-1)
                    //self.downloadImage(path:image2Url.lastPathComponent )//gree

                }
            

        case  ButtonTag.kTagImage3_Button :
            if (image2Url.length == 0) {
                // [Helper displayAlert:@"Image has not been uploaded for this thumbnail."];
                return;   // return if image is not available for that thumbnail.
            }
            else {
                //self.downloadImage(path:image2Url.lastPathComponent )//gree

            }
            
            
        }
    }

    
    func downloadImage(path: String,isThumbnail:Bool,identifier:Int) {
        
        let _path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        var filePath   = ""
        let url = NSURL(fileURLWithPath: _path)
        if let pathComponent = url.appendingPathComponent(path) {
            filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                if let image    = UIImage(contentsOfFile: filePath) as? UIImage {
                    if isThumbnail == true {
                        if identifier == 1 {
                            self.img1View.image = image
                        }
                        else if identifier == 2 {
                            self.img2View.image = image

                        }
                        else {
                            self.img3View.image = image

                        }
                        //self.mainImgView.image = image

                    }
                    else {
                        self.showFullImage(downloadedImage: image)

                    }

                }
                //print("FILE AVAILABLE")
            } else {
                self.downloadImage(path:path, filePath:filePath,isThumbnail: isThumbnail,identifier: identifier)
            }
        } else {
            self.downloadImage(path:path, filePath:filePath,isThumbnail: isThumbnail,identifier:identifier)
        }

    }
    func downloadImage(path:String, filePath:String,isThumbnail:Bool,identifier:Int){
        self.activityIndicator.showActivityIndicator(uiView: self.view)
        var dnldCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.AWS_COGNITO_POOL_ID)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let fileURL = URL(fileURLWithPath: path)
        var S3BucketName = UserDefaults.standard.value(forKey: Constants.BUCKET_NAME) as! String
        if isThumbnail == true {
            //var S3BucketNamethumb = "\(S3BucketName)-thumbnails"
            S3BucketName = "\(S3BucketName)-thumbnails"

        }

        var bucketFolder:String = ""
        if let  _bucketFolder = UserDefaults.standard.value(forKey: Constants.accountKey) {
            bucketFolder = _bucketFolder as! String
        }
        let S3DownloadKeyName : String = bucketFolder + fileURL.path
        let expression = AWSS3TransferUtilityDownloadExpression()
        
        dnldCompletionHandler = { (task, location, data, error) -> Void in
            DispatchQueue.main.sync(execute: {
                self.activityIndicator.hideActivityIndicator(uiView: self.view)
                if ((error) != nil){
                    print("Failed with error")
                    print("Error: \(error!)")
                }
                else{
                    
                                                                                              
                                    
                    //Set your image
                    if let downloadedImage = UIImage(data: data!) as? UIImage {
                        if (isThumbnail == true ){
                            if( identifier == 1) {
                                self.img1View.image = downloadedImage
                            }
                            else if( identifier == 2) {
                               self.img2View.image = downloadedImage
                            }
                            else if( identifier == 3) {
                                self.img3View.image = downloadedImage

                            }
                        }
                        else{
                            self.showFullImage(downloadedImage:downloadedImage)

                        }
//                        if (isThumbnail == true  && identifier == 1) {
//                            self.mainImgView.image = downloadedImage
//                        }
//                        else if (isThumbnail == true ) {
//                            if (identifier >= 0 ) {
//                            let indexPath = NSIndexPath.init(row: identifier, section: 0)
//                                self.damageDetailsTableView.reloadRows(at: [(indexPath as IndexPath)], with: .none)
//                            }
//                        }
//                        else{
//                            self.showFullImage(downloadedImage:downloadedImage)
//                        }

                    }
                    do {
                        // writes the image data to disk
                        if (isThumbnail == false){
                        try data?.write(to: NSURL.init(fileURLWithPath: filePath) as URL)
                        print("file saved")
                        }
                    } catch {
                        print("error saving file:", error)
                    }
                    // Define identifier
                    let notificationName = Notification.Name("NotificationImageDownload")
                    NotificationCenter.default.post(name: notificationName, object: nil)
                    
                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.downloadData(fromBucket: S3BucketName, key: S3DownloadKeyName, expression: expression, completionHandler: dnldCompletionHandler).continueWith { (task) -> AnyObject? in
            if let error = task.error {
                self.activityIndicator.hideActivityIndicator(uiView: self.view)
                print("Error: \(error.localizedDescription)")
            }
            if let _ = task.result {
                print("Download Starting!")
            }
            return nil
        }
        
    }
//    func downloadImage(path: String) {
//
//    let _path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        var filePath   = ""
//        let url = NSURL(fileURLWithPath: _path)
//        if let pathComponent = url.appendingPathComponent(path) {
//            filePath = pathComponent.path
//            let fileManager = FileManager.default
//            if fileManager.fileExists(atPath: filePath) {
//                if let image    = UIImage(contentsOfFile: filePath) as? UIImage {
//                    self.showFullImage(downloadedImage: image)
//
//                }
//                //print("FILE AVAILABLE")
//            } else {
//                self.downloadImage(path:path, filePath:filePath)
//            }
//        } else {
//            self.downloadImage(path:path, filePath:filePath)
//        }
//
//    }
//    func downloadImage(path:String, filePath:String){
//        self.activityIndicator.showActivityIndicator(uiView: self.view)
//        var dnldCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
//        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.AWS_COGNITO_POOL_ID)
//        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
//        AWSServiceManager.default().defaultServiceConfiguration = configuration
//
//        let fileURL = URL(fileURLWithPath: path)
//        let S3BucketName = UserDefaults.standard.value(forKey: Constants.BUCKET_NAME) as! String
//
//        var S3BucketNamethumb = "\(S3BucketName)-thumbnails"
//
//        var bucketFolder:String = ""
//        if let  _bucketFolder = UserDefaults.standard.value(forKey: Constants.accountKey) {
//            bucketFolder = _bucketFolder as! String
//        }
//        let S3DownloadKeyName : String = bucketFolder + fileURL.path
//        let expression = AWSS3TransferUtilityDownloadExpression()
//
//        dnldCompletionHandler = { (task, location, data, error) -> Void in
//            DispatchQueue.main.sync(execute: {
//                self.activityIndicator.hideActivityIndicator(uiView: self.view)
//                if ((error) != nil){
//                    print("Failed with error")
//                    print("Error: \(error!)")
//                }
//                else{
//                    //Set your image
//                    if let downloadedImage = UIImage(data: data!) as? UIImage {
//                        self.showFullImage(downloadedImage:downloadedImage)
//
//                    }
//                    do {
//                        // writes the image data to disk
//                        try data?.write(to: NSURL.init(fileURLWithPath: filePath) as URL)
//                        print("file saved")
//                    } catch {
//                        print("error saving file:", error)
//                    }
//                    // Define identifier
//                    let notificationName = Notification.Name("NotificationImageDownload")
//                    NotificationCenter.default.post(name: notificationName, object: nil)
//
//                }
//            })
//        }
//
//        let transferUtility = AWSS3TransferUtility.default()
//        transferUtility.downloadData(fromBucket: S3BucketName, key: S3DownloadKeyName, expression: expression, completionHandler: dnldCompletionHandler).continueWith { (task) -> AnyObject? in
//            if let error = task.error {
//                self.activityIndicator.hideActivityIndicator(uiView: self.view)
//                print("Error: \(error.localizedDescription)")
//            }
//            if let _ = task.result {
//                print("Download Starting!")
//            }
//            return nil
//        }
//
//    }
    
    func showFullImage(downloadedImage:UIImage) {
        
        let newImageView = UIImageView(image: downloadedImage)
        newImageView.frame = self.view.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage(sender:)))
        newImageView.addGestureRecognizer(tap)
        
        let scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.backgroundColor = UIColor.black
        scrollView.contentSize = newImageView.bounds.size
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        scrollView.addSubview(newImageView)
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.view.addSubview(scrollView)

    }
    @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        //self.tabBarController?.tabBar.isHidden = false
        print(sender.view)
        sender.view?.superview?.removeFromSuperview()
    }
    
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//
//   // if marker.title != nil {
//
//        let mapViewHeight = mapView.frame.size.height
//        let mapViewWidth = mapView.frame.size.width
//
//
//        let container = UIView()
//        container.frame = CGRect(x: mapViewWidth - 100, y: mapViewHeight - 63, width: 65, height: 35)
//        container.backgroundColor = UIColor.white
//        self.view.addSubview(container)
//
//        let googleMapsButton = CustomButton()
//        googleMapsButton.setTitle("", for: .normal)
//        googleMapsButton.setImage(UIImage(named: "googlemaps"), for: .normal)
//        googleMapsButton.setTitleColor(UIColor.blue, for: .normal)
//        googleMapsButton.frame = CGRect(x: mapViewWidth - 80, y: mapViewHeight - 70, width: 50, height: 50)
//        googleMapsButton.addTarget(self, action: #selector(markerClick(sender:)), for: .touchUpInside)
//        googleMapsButton.gps = String(marker.position.latitude) + "," + String(marker.position.longitude)
//        googleMapsButton.setTitle(marker.title, for: .normal)
//        googleMapsButton.tag = 0
//
//        let directionsButton = CustomButton()
//
//            directionsButton.setTitle("", for: .normal)
//            directionsButton.setImage(UIImage(named: "maps_icon"), for: .normal)
//                directionsButton.setTitleColor(UIColor.blue, for: .normal)
//                directionsButton.frame = CGRect(x: mapViewWidth - 110, y: mapViewHeight - 70, width: 50, height: 50)
//                directionsButton.addTarget(self, action: #selector(markerClick(sender:)), for: .touchUpInside)
//                directionsButton.gps = String(marker.position.latitude) + "," + String(marker.position.longitude)
//                directionsButton.setTitle(marker.title, for: .normal)
//                directionsButton.tag = 1
//                //self.view.addSubview(googleMapsButton)
//                self.view.addSubview(directionsButton)
//           // }
//            return true
//        }
//        @objc func markerClick(sender: CustomButton) {
//        let fullGPS = sender.gps
//        let fullGPSArr = fullGPS.split(separator: ",")
//
//        let lat1 : String = String(fullGPSArr[0])
//        let lng1 : String = String(fullGPSArr[1])
//
//
//        let latitude = Double(lat1) as! CLLocationDegrees
//        let longitude = Double(lng1) as! CLLocationDegrees
//
//        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
//
//            if (sender.tag == 1) {
//                let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")
//                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//            } else if (sender.tag == 0) {
//                let url = URL(string:"comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)")
//                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//            }
//
//        } else {
//            let regionDistance:CLLocationDistance = 10000
//                    let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
//            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
//                    var options = NSObject()
//                    if (sender.tag == 1) {
//                        options = [
//                            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
//                            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
//                            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
//                            ] as NSObject
//                    } else if (sender.tag == 0) {
//                        options = [
//                            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
//                            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
//                            ] as NSObject
//                    }
//
//                    let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
//                    let mapItem = MKMapItem(placemark: placemark)
//                    mapItem.name = sender.title(for: .normal)
//                    mapItem.openInMaps(launchOptions: options as? [String : AnyObject])
//                }
//            }

}


class CustomButton: UIButton {
    var gps = ""
    override func awakeFromNib() {
        super.awakeFromNib()

        //TODO: Code for our button
    }
}
