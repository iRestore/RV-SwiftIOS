//
//  ProfileViewController.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 10/02/20.
//  Copyright © 2020 iRestoreApp. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore
import AWSCognito

class  ProfileViewController : UIViewController {
    @IBOutlet weak var imageScreen:UIImageView!
    @IBOutlet weak var slideOutPanel:UIView!
    @IBOutlet weak var transparentView:UIView!
    @IBOutlet weak var  customerLogoView:UIImageView!
    @IBOutlet weak var  customerLogoPlaceholder:UIView!
    @IBOutlet weak var  loggedInUserName:UILabel!
    @IBOutlet weak var  vesrionLabel:UILabel!
    @IBOutlet weak var  profileImageView:UIImageView!
    var activityIndicator =  ActivityIndicator()

    var image:UIImage?
    
    
    override func viewDidLoad() {
        
        self.imageScreen.image = self.image
        
                
        let fileName = UserDefaults.standard.value(forKey: "logo")
        if var  documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            documentsPathString.append("/\(fileName!)")
            let image =  UIImage(contentsOfFile: documentsPathString)
            self.customerLogoView.image = image

        }
        
        if let image = UIImage.init(named:"logoholder") {
           let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: self.customerLogoPlaceholder.frame.size.width, height: self.customerLogoPlaceholder.frame.size.height)
           self.customerLogoPlaceholder.addSubview(imageView)
        }
        self.customerLogoPlaceholder.bringSubviewToFront(self.customerLogoView)
        if let userId = UserDefaults.standard.value(forKey: "userId"){
            let imageName =  "\(userId).png"
            if let image = getSavedImage(named: imageName) {
                profileImageView.image = image.circleMasked
            }
            else { //download from
                self.downloadProfileImage(imageName: imageName, isThumbNailImage: true)
                self.downloadProfileImage(imageName: imageName, isThumbNailImage: false)

            }
            
        }
        
        profileImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(downloadFullImage(sender:)))
        profileImageView.addGestureRecognizer(tap)
        
        
        if let firstName = UserDefaults.standard.value(forKey: "firstName"), let lastName =   UserDefaults.standard.value(forKey: "lastName") {
            self.loggedInUserName.text = "\(firstName) \(lastName)"
        }
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String {
             vesrionLabel.text =  "v \(appVersion)"

        }
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = false
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0) as Any, NSAttributedString.Key.foregroundColor : UIColor.init("0x363636")]
        self.navigationItem.title = NSLocalizedString("Damage Reports", comment: "")
        
        var backButton: UIButton
        var leftBarBtnItem : UIBarButtonItem
        backButton = UIButton.init(type: UIButton.ButtonType.custom)
        backButton.setImage(UIImage.init(named: "profile"), for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(profileBtnClicked), for: .touchUpInside)
        backButton.frame.size = CGSize.init(width: 50, height: 50)
        backButton.contentHorizontalAlignment = .left
        leftBarBtnItem = UIBarButtonItem.init(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarBtnItem
        
        
        if (self.slideOutPanel.isHidden) {
            self.showSlideoutPanel()
           } else {
               self.hideSlidePanel()
           }
        self.imageScreen.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.transparentView.addGestureRecognizer(gesture)
        
    }
    @objc func checkAction(sender : UITapGestureRecognizer) {
        //self.hideSlidePanel()
        self.navigationController?.popToRootViewController(animated: false)
    }
    @IBAction func  editProfileOnClick(sender:UIButton){
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let profileController = mainStoryBoard.instantiateViewController(withIdentifier: "UpdateProfileViewController") as? UpdateProfileViewController else { return  }
        self.navigationController?.pushViewController(profileController, animated: false)
        self.hideSlidePanel()
    }
    @objc func profileBtnClicked() -> Void {
       //self.hideSlidePanel()
       self.navigationController?.popViewController(animated: false)
    }
    func getSavedImage(named: String) -> UIImage? {
           if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
               return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
           }
           return nil
       }
    func downloadProfileImage(imageName: String, isThumbNailImage:Bool) -> Void {
        
        var dnldCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.AWS_COGNITO_POOL_ID)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        var S3BucketNamethumb = UserDefaults.standard.value(forKey: Constants.PROFILE_BUCKET_NAME) as! String
        if(isThumbNailImage){
            S3BucketNamethumb = "\(S3BucketNamethumb)-thumbnails"
        }
        else {
            S3BucketNamethumb = "\(S3BucketNamethumb)"

        }
        
        
        let S3DownloadKeyName : String = imageName
        let expression = AWSS3TransferUtilityDownloadExpression()
        
        dnldCompletionHandler = { (task, location, data, error) -> Void in
            DispatchQueue.main.sync(execute: {
                if ((error) != nil){
                    print("Failed with error")
                    print("Error: \(error!)")
                    self.profileImageView.image = UIImage.init(named: "cameraIcon")
                    self.profileImageView.contentMode = .center
                    


                }
                else{
                    //Set your image
                    let downloadedImage = UIImage(data: data!)
                    self.profileImageView.image = downloadedImage?.circleMasked
                    
                    guard let data = downloadedImage!.jpegData(compressionQuality: 1) ?? downloadedImage!.pngData() else {
                        return
                    }
                    guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
                        return
                    }
                    do {

                        try data.write(to: directory.appendingPathComponent(imageName)!
                        )
                        return
                        
                    } catch {

                        print(error.localizedDescription)
                        return
                    }
                    
                    
                    // Define identifier
                    let notificationName = Notification.Name("NotificationImageDownload")
                    
                    NotificationCenter.default.post(name: notificationName, object: nil)
                    
                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.downloadData(fromBucket: S3BucketNamethumb, key: S3DownloadKeyName, expression: expression, completionHandler: dnldCompletionHandler).continueWith { (task) -> AnyObject? in
            if let error = task.error {

                print("Error: \(error.localizedDescription)")
            }
            if let _ = task.result {
                print("Download Starting!")
            }
            return nil
        }
        
    }
    func showSlideoutPanel() {
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
       // self.window!.layer.add(transition, forKey: kCATransition)
//        present(profileController, animated: false, completion: nil)
        self.slideOutPanel.isHidden = false
        self.transparentView.isHidden = false
        self.slideOutPanel.layer.add(transition, forKey: "in")
        
    }

    func hideSlidePanel() {
        if (!self.slideOutPanel.isHidden) {
                  let transition = CATransition()
            transition.duration = 0.5
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            
            self.slideOutPanel.isHidden = true
            self.transparentView.isHidden = true
            self.slideOutPanel.layer.add(transition, forKey: "out")

        }
    }
    
    @objc func downloadFullImage(sender: UITapGestureRecognizer) {
        if let userId = UserDefaults.standard.value(forKey: "userId"){
        let imageName =  "\(userId).png"
        if let image = getSavedImage(named: imageName) {
            showFullImage(downloadedImage:image)

            }
    }
    }
    func showFullImage(downloadedImage:UIImage) {
           
           let newImageView = UIImageView(image: downloadedImage)
           newImageView.frame = self.view.bounds
           newImageView.backgroundColor = .black
           newImageView.contentMode = .scaleAspectFit
           newImageView.isUserInteractionEnabled = true
           let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage(sender:)))
           newImageView.addGestureRecognizer(tap)
           self.navigationController?.isNavigationBarHidden = true
           let scrollView = UIScrollView(frame: self.view.bounds)
           scrollView.backgroundColor = UIColor.black
           scrollView.contentSize = newImageView.bounds.size
           scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           scrollView.contentOffset = CGPoint(x: 0, y: 0)
           scrollView.addSubview(newImageView)
           
           self.view.addSubview(scrollView)

       }
       @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
           self.navigationController?.isNavigationBarHidden = false
           print(sender.view)
           sender.view?.superview?.removeFromSuperview()
       }
    
    
}
extension UIImage {
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

