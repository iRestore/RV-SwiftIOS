//
//  VDADetailsViewController.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 16/01/20.
//  Copyright © 2020 iRestoreApp. All rights reserved.
//
import UIKit
import GoogleMaps
import MapKit
import ImageLoader
import AWSS3
class VDADetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//
    @IBOutlet var  tagView: UIView!
    @IBOutlet var  tagViewHeightConstraint:NSLayoutConstraint!

    @IBOutlet var  damageDetailsBtn: UIButton!
    @IBOutlet var  damagePartsBtn: UIButton!
    @IBOutlet var  dmgDetailUnderlineView: UIView!
    @IBOutlet var  dmgPartUnderlineView: UIView!

    @IBOutlet var  lblTitle: UILabel!
    @IBOutlet var  iconImgView: UIImageView!
    @IBOutlet var  mainImgView: UIImageView!

    
    @IBOutlet var  lblName: UILabel!
    @IBOutlet var  lblEmail: UILabel!
    @IBOutlet var  lblPhone: UILabel!
    @IBOutlet var  lblDate: UILabel!
    @IBOutlet var  lblDamageType: UILabel!
    @IBOutlet var  lblDeviceAddress: UILabel!
    @IBOutlet var  lblUserAddress: UILabel!
    @IBOutlet var  lblLocation: UILabel!
    @IBOutlet var  lblSafeStatus: UILabel!
    @IBOutlet var  lblComments: UILabel!
    @IBOutlet var  lblRoadStatus: UILabel!
    @IBOutlet var  lblWireGuardStatus: UILabel!
    @IBOutlet var  lblFeederLine1: UILabel!
    @IBOutlet var  lblFeederLine2: UILabel!
    @IBOutlet var  lblPoliceStandBy: UILabel!
    @IBOutlet var  lblDmgType: UILabel!

    
    @IBOutlet var  tapToExpandPhotoLbl: UILabel!
    @IBOutlet var  tags: UILabel!
  //  @IBOutlet var  lblTags: UILabel!
    @IBOutlet var  hasShownDirection: UILabel!
    
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
    @IBOutlet var  damageDetailsTableView:UITableView!
    @IBOutlet var  damagePartsLabel: UILabel!
    @IBOutlet var  lblPoleNumber: UILabel!
    @IBOutlet var  lblPoleHeight: UILabel!




    @IBOutlet var  tapToExpandPhotoYConstraint:NSLayoutConstraint!
    @IBOutlet var  tapToExpandPhotoBottomConstraint:NSLayoutConstraint!
    @IBOutlet var  poleDetailsHeightConstraint:NSLayoutConstraint!
    @IBOutlet var  addressViewHeightConstraint:NSLayoutConstraint!
    @IBOutlet var  scrollViewConstraint:NSLayoutConstraint!

    let appDelegate: AppDelegate        = UIApplication.shared.delegate as! AppDelegate
    var activityIndicator =  ActivityIndicator()

    var reportData : ReportData?

    override func viewDidLoad() {
        navigationBarSettings()
        selectDamageDetails()
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
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 15.0) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationItem.title = NSLocalizedString("Damage Reports", comment: "")
        
        var backButton: UIButton
        var leftBarBtnItem : UIBarButtonItem
        backButton = UIButton.init(type: UIButton.ButtonType.custom)
        backButton.setImage(UIImage.init(named: "back_green"), for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(backBtnClicked), for: .touchUpInside)
        backButton.sizeToFit()
        leftBarBtnItem = UIBarButtonItem.init(customView: backButton)
        self.navigationItem.leftBarButtonItem = leftBarBtnItem

    }
    func selectDamageDetails () {
        self.damageDetailsBtn.setTitleColor(UIColor.init("0x2DB2A8"), for: .normal)
        self.dmgDetailUnderlineView.backgroundColor = UIColor.init("0x2DB2A8")
        
        self.damagePartsBtn.setTitleColor(UIColor.init("0x363636"), for: .normal)
        self.dmgPartUnderlineView.backgroundColor = UIColor.init("0x363636")

        self.reportDetailsScrollview.isHidden = false
        self.damageDetailsTableView.isHidden = true
        self.damagePartsLabel.isHidden = true

    }
    func selectDamageParts() {
        self.damagePartsBtn.setTitleColor(UIColor.init("0x2DB2A8"), for: .normal)
        self.dmgPartUnderlineView.backgroundColor = UIColor.init("0x2DB2A8")
        
        self.damageDetailsBtn.setTitleColor(UIColor.init("0x363636"), for: .normal)
        self.dmgDetailUnderlineView.backgroundColor = UIColor.init("0x363636")

        self.reportDetailsScrollview.isHidden = true
        self.damageDetailsTableView.isHidden = false
        self.damagePartsLabel.isHidden = false
        if let count = self.reportData?.partData.count , let value = self.reportData?.damageSubTypeDisplayName {
            self.damagePartsLabel.text =  "\(count) \(value) Reports"

        }
        
//        setText:[NSString stringWithFormat:@"%d %@ Reports", _reportModel.partData.count,_reportModel.damageSubTypeDisplayName]];

    }
    func populateData() {
        
    self.perform(#selector(setScrollViewContentSize), with: nil, afterDelay: 1.0)

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
        if reportData?.imageCount ?? 0 > 0 {
            let image1Url:NSString = reportData?.thumbnail1Path as? NSString ?? ""
            self.downloadImage(path: image1Url.lastPathComponent
                , isThumbnail: true,identifier: -1)
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(VDADetailsViewController.imageTapped(_:)))
            tap.cancelsTouchesInView = false
            self.mainImgView.addGestureRecognizer(tap)

           }
           
        if let damageType = reportData?.damageType  as? String {
            let imageName = "\(damageType)_icon"
            iconImgView.image = UIImage.init(named: imageName)
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
        
        
        lblDamageType.text = "\((reportData?.damageTypeDisplayName)!)"
        lblTitle.text = "\((reportData?.damageSubTypeDisplayName)!)"
        if (self.reportData?.columnValues.count ?? 0 >= 1) {
            self.lblDeviceAddress.text = self.reportData?.columnValues.first
        }

        
        //check for boolean value
        lblRoadStatus.text  = reportData?.roadBlockedStatus
        lblPoliceStandBy.text = reportData?.safeStatus
        lblWireGuardStatus.text = reportData?.wireGuardStandBy
        lblFeederLine1.text =  reportData?.feederLine1
        lblFeederLine2.text =  reportData?.feederLine2
        
        
        if reportData?.poleNumber == "" ||  reportData?.poleNumber == nil {
            lblPoleNumber.text = "NA"
            
        }
        else {
            lblPoleNumber.text = reportData?.poleNumber
            
        }
        
        if reportData?.poleHeight == "" ||  reportData?.poleHeight == nil {
            lblPoleHeight.text = "NA"
            
        }
        else {
            lblPoleHeight.text = reportData?.poleHeight
            
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
        let pinName = "pin_\((reportData?.damageType)!)"
        marker.icon = UIImage.init(named: pinName)
        
  
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
        
        self.poleDetailsHeightConstraint.constant = self.tagView.frame.origin.y + self.tagViewHeightConstraint.constant + 5
        
        self.addressViewHeightConstraint.constant = self.lblDate.frame.origin.y + self.lblDate.frame.size.height + 2

        
    }
    
    func hideHeightConstraints() {
        var str :String = ""
        if let _tagArray =  reportData?.tagArray  as?  [String] {
            if (Helper.shared.nullToNil(value:_tagArray as AnyObject ) != nil && _tagArray.count ?? 0 > 0 ){
                
                let tagListView  = TagListView.init(frame: CGRect.init(x: 0, y: 0, width: self.tagView.frame.width, height: 100))
                tagListView.textFont = UIFont(name: "Avenir-Book", size: 15.0) ??  UIFont.systemFont(ofSize: 15)
                tagListView.textColor = .black
                tagListView.paddingY = 10
                tagListView.paddingX = 15

                tagListView.alignment = .left
                for tag in _tagArray {
                    let tag = tagListView.addTag(tag)
                    tag.cornerRadius = 15
                    tag.tagBackgroundColor = UIColor.init("0xe7e7e7")
                    tag.enableRemoveButton = false
                    tag.enableIconButton = false
                }
                
                let size = tagListView.intrinsicContentSize
                self.tagViewHeightConstraint.constant = size.height
                self.tagView.addSubview(tagListView)
            }
            else {
                self.tagViewHeightConstraint.constant = 10
                //self.lblTags.isHidden = true
                //self.tags.isHidden = true

            }
        }
               //0 str = str.appending(_tagArray.com)

      
    }
//    func downloadImage(path:String) {
//
//    }

//    #pragma mark IBAction Methods
    

    
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
            self.present(av, animated: true, completion: nil)
        }
    }
    
    // send phone call.
    @IBAction func imageTapped(_ sender: UIButton) {
        
        if reportData?.imageCount ?? 0 > 0 {
            let image1Url:NSString = reportData?.img1URL as? NSString ?? ""
            self.downloadImage(path: image1Url.lastPathComponent
             , isThumbnail: false,identifier: -1)
         
        

        }
        
    }

    @objc func cellImageTapped(_ sender: UITapGestureRecognizer) {
        print (sender.view!.tag)
        //to get indexPath
        
        let index =   (sender.view!.tag - 1)
        let part = self.reportData?.partData[index] as? PartData
         if (part?.image1Url != nil &&  part?.image1Url != "") {
                 

             let image1Url :NSString  = part?.image1Url as? NSString ?? ""
             let path = image1Url.lastPathComponent
            self.downloadImage(path: image1Url.lastPathComponent
                        , isThumbnail: false,identifier: index)
             }

        
    }
    
    @objc func backBtnClicked() -> Void {
        self.navigationController?.popViewController(animated: true)
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
                        self.mainImgView.image = image

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
        S3BucketName = S3BucketName.replacingOccurrences(of: "fr", with: "sda")
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
                        if (isThumbnail == true  && identifier == -1) {
                            self.mainImgView.image = downloadedImage
                        }
                        else if (isThumbnail == true ) {
                            if (identifier >= 0 ) {
                            let indexPath = NSIndexPath.init(row: identifier, section: 0)
                                self.damageDetailsTableView.reloadRows(at: [(indexPath as IndexPath)], with: .none)
                            }
                        }
                        else{
                            self.showFullImage(downloadedImage:downloadedImage)
                        }

                    }
                    do {
                        // writes the image data to disk
                        try data?.write(to: NSURL.init(fileURLWithPath: filePath) as URL)
                        print("file saved")
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
    
    func showFullImage(downloadedImage:UIImage) {
        
//        let downloadedImage = UIImage(data: data!)
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
        view.addSubview(scrollView)

//        if #available(iOS 13.0, *) {
//            self.view.window?.addSubview(scrollView)
//
//         }
//        else {
//            self.appDelegate.window?.addSubview(scrollView)
//
//         }
        
        
        //self.view.addSubview(newImageView)
    }
    @IBAction func showDamageDetails(_ sender:UIButton ) {
        
        self.selectDamageDetails()
    }
    
    @IBAction func showParts(_ sender:UIButton ) {
        self.selectDamageParts()
    }

    
    @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        
        self.navigationController?.isNavigationBarHidden = false
        //self.tabBarController?.tabBar.isHidden = false
        print(sender.view)
        sender.view?.superview?.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportData?.partData.count ?? 0
        
            
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 135.0
//    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!  DamagePartsTableViewCell
        
        let part = self.reportData?.partData[indexPath.row] as? PartData
        cell.lblPart.text = part?.partDislayText
        cell.lblComment.text  = part?.comment
        cell.lblType.text = part?.type;
        if (part?.size != nil &&  part?.size != "") {
            cell.lblphaseTitle.text = "Size"
            cell.lblphase.text = part?.size

            }
            else {
            cell.lblphaseTitle.text = "Phase"
            cell.lblphase.text = part?.phase


            }
        if (part?.thumbnail1Url != nil &&  part?.thumbnail1Url != "") {
                

            let thumbnailUrl :NSString  = part?.thumbnail1Url as? NSString ?? ""
            let path = thumbnailUrl.lastPathComponent
            let _path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                   var filePath   = ""
                   let url = NSURL(fileURLWithPath: _path)
                   if let pathComponent = url.appendingPathComponent(path) {
                       filePath = pathComponent.path
                       let fileManager = FileManager.default
                       if fileManager.fileExists(atPath: filePath) {
                           if let image    = UIImage(contentsOfFile: filePath) as? UIImage {
                            cell.imgViewDmgType.isUserInteractionEnabled = true
                            cell.imgViewDmgType.image = image
                            if cell.imgViewDmgType.gestureRecognizers?.count ?? 0 < 1 {
                                let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(VDADetailsViewController.cellImageTapped(_ :)))
                                cell.imgViewDmgType.tag = indexPath.row + 1
                                //tap.cancelsTouchesInView = false
                                cell.imgViewDmgType.addGestureRecognizer(tap)
                            }
                           }
                       } else {
                           self.downloadImage(path: path, filePath: filePath, isThumbnail: true, identifier: indexPath.row)

                       }
                   } else {
                    self.downloadImage(path: path, filePath: filePath, isThumbnail: true, identifier: indexPath.row)
                   }
            
       



            }
            

            var x = 0
            var y = 10

        var index = 0
        
        if part?.metaDataTitles.count ?? 0 > 0 {
            for title in (part?.metaDataTitles)!     {
                
                if (index%2 == 0 ){
                    x = 10
                    if (index != 0) {
                        y = y + 80
                    }
                    
                }
                else {
                    
                    x =  210;
                }
                
                let name = UILabel.init(frame: CGRect.init(x: x, y: y, width: 160, height: 50))
                name.numberOfLines = 0
                name.text = MapViewController.damageMetaDataDisplayDict[title]
                name.font = UIFont.init(name: NSLocalizedString("FONT_MEDIUM",  comment: ""), size: 14)
                cell.partsMetadataView .addSubview(name)
                name.textColor = UIColor.init("0x000000")
                
                let value = UILabel.init(frame: CGRect.init(x: x, y: y + 55, width: 160, height: 20))
                value.text = title
                value.font = UIFont.init(name: NSLocalizedString("FONT_MEDIUM", comment: ""), size: 14)
                cell.partsMetadataView .addSubview(value)
                value.textColor = UIColor.init("0x535353")
                let num = part!.metaDataValues[index] as? Int
                
                
                
                
                if (num == 0) {
                    value.text = "No"
                }
                else {
                    value.text = "Yes"
                }
                index = index + 1
                
            }
            y = y + 90
            cell.partsMetadataViewHeightConstarint.constant = CGFloat(y)
            
        }
            return cell

    }
  
}
class DamagePartsTableViewCell : UITableViewCell {
    @IBOutlet var  lblPart: UILabel!
    @IBOutlet var  lblType: UILabel!
    @IBOutlet var  lblphase: UILabel!
    //@IBOutlet var  lblTitle: UILabel!
    @IBOutlet var  lblComment: UILabel!
    @IBOutlet var  lblphaseTitle: UILabel!
    @IBOutlet var  partsMetadataView: UIView!
    @IBOutlet weak var imgViewDmgType: UIImageView!


@IBOutlet var  partsMetadataViewHeightConstarint: NSLayoutConstraint!

@IBOutlet var  activityIndicator: UIActivityIndicatorView!

}


extension UIColor {
    convenience init(_ hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

