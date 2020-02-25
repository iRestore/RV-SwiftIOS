//
//  OldSignUpViewController.swift
//  YellowCard
//
//  Created by Kundan Kumar on 15/02/18.
//  Copyright © 2018 Kundan Kumar. All rights reserved.
//

import UIKit
//import AWSS3

class SignUpViewController: UIViewController, UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource  {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneNoPart1: UITextField!
    @IBOutlet weak var utilityTextField: UITextField!
    @IBOutlet weak var utilityUnderLineView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    
    var utilityPicker: UIPickerView!
    var utilityArray = [Any]()
    var selectedTenantObj = [String : Any]()
    var appDelegate:AnyObject?
    let prefs:UserDefaults              = UserDefaults.standard
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        utilityPicker = UIPickerView()
        utilityPicker.delegate = self;
        utilityPicker.dataSource = self;
        self.phoneNoPart1.isEnabled = true;
        self.emailField.isEnabled = true;
        DispatchQueue.main.async {
//            if #available(iOS 13.0, *) {
//                self.scen = self.view.window?.windowScene?.delegate as! SceneDelegate
//            }
//            else {
//                self.appDelegate =  UIApplication.shared.delegate as! AppDelegate
//            }
            
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isTranslucent = true
        self.signUpButton.isUserInteractionEnabled = true
    }
    @IBAction func signInClicked(_ sender: UIButton) {
        let prefs : UserDefaults = UserDefaults.standard
        prefs.set(false, forKey: Constants.IS_SIGN_COMPLETED)
        if(self.utilityTextField.isHidden == true) {
            self.submitForSignUp()
        }
        else {
           
            if prefs.value(forKey: Constants.OTP_TIMER_VALUE) != nil
            {
                prefs.removeObject(forKey: Constants.OTP_TIMER_VALUE)
            }
            if (utilityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0)
                
            {
//                appDelegate.displayAlert(message: NSLocalizedString("SELECT_UTILITY", comment: ""), isActionRequired: true)
            }
            else {
                sender.isUserInteractionEnabled = false
                self.storeTenantData()
                let  isOtpRequired = prefs.bool(forKey: Constants.IS_OTP_REQUIRED)
                if(isOtpRequired) {
                    self.getOTP()
                    
                }
                else {
                    self.downloadTenantLogoFromS3()
                }
                
                
            }

            
            
        }
        
    }
    
    
    func submitForSignUp()-> Void {
        

        if emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
            || phoneNoPart1.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
        {
//            appDelegate.displayAlert(message: NSLocalizedString("EMAIL_PHONE_CANNOT_BE_BLANK", comment: ""), isActionRequired: true)
            return
        }
        else if !(self.isValidEmail(testStr:emailField.text!)) {
//            appDelegate.displayAlert(message:NSLocalizedString("VALID_EMAIL", comment: ""), isActionRequired: true)
            return
        }
        else if !(self.isValidPhoneNumber(phoneNumber:self.phoneNoPart1.text!)) {
//            appDelegate.displayAlert(message: NSLocalizedString("VALID_PHONE", comment: ""), isActionRequired: true)
            return
        }
        
        prefs.set(Constants.MASTER_TOKEN, forKey: Constants.accessToken)
        prefs.set(Constants.MASTER_ACCOUNT_KEY, forKey:  Constants.accountKey)
        let phoneNumber = phoneNoPart1.text?.components(separatedBy: CharacterSet.init(charactersIn:"1234567890").inverted).joined(separator: "")
        prefs.set(phoneNumber, forKey: Constants.PHONE_KEY)
        self.activityIndicator.startAnimating()
        let signUpEmail = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
//        let phoneNumber = phoneNoPart1.text?.components(separatedBy: CharacterSet.init(charactersIn:"1234567890").inverted).joined(separator: "")
        let apiClient  = V1ApiClient.init()
        
        apiClient.signUpWithEmailAndPhone(email: signUpEmail!, phone: phoneNumber!){
            result in
            _ = DispatchQueue.main.sync() {
                self.activityIndicator.stopAnimating()
            }
            print(result)
            switch result {
            case .Success(let value):
                if let responseDict = value.data {
                    let userArray = responseDict["User"] as? [[String:Any]]
                    if(userArray != nil && userArray?.count ?? 0 > 0) {
                        if let userDict = userArray?.first  {
                            self.saveUserData(userDict:userDict)

                        }

                    }
                    
                    if let permissionArray   = responseDict["Permissions"] as? NSArray {
                        
                        if let  permissionMainObj = permissionArray.firstObject as? [String:Any] {
                            
                            if let  permissionObj = permissionMainObj["permissions"] as? [String:Any] {
                                if let  damageReportObj = permissionMainObj["damageReports"] as? [String:Any] {
                                    
                                    if  let canViewReport = damageReportObj["view"] as? Bool {
                                        UserDefaults.standard.set(canViewReport, forKey: Constants.PERMISSION_TO_VIEW_REPORT)
                                    }
                                    if  let canViewAcknowledgedReport = damageReportObj["viewAcknowledged"] as? Bool {
                                        UserDefaults.standard.set(canViewAcknowledgedReport, forKey: Constants.PERMISSION_TO_VIEW_ACKNOWLEDGE)
                                    }
                                    

                                }
                                
                            }
                            
                            
                        }

                        
                    }
                    let ownersDict : [String : Any]   = responseDict["Owners"] as! [String : Any]
                    self.utilityArray = ownersDict ["utilities"] as! [Any]
                    let isSubscriptionExists   = responseDict["Subscription"] != nil
                    if(isSubscriptionExists) {
                        
                        if let _subscriptionArray   = Helper.shared.nullToNil(value: responseDict["Subscription"] as AnyObject ){
                            
                            let subscriptionArray:[Any] =  _subscriptionArray as! [Any]
                            
                            if (subscriptionArray.count == 0) {
                                _ = DispatchQueue.main.sync() {
                                    
                                    self.utilityTextField.isHidden = false
                                    self.utilityUnderLineView.isHidden = false
                                }
                                
                                let mailDomain = signUpEmail?.components(separatedBy: "@").last
                                
                                let filteredArray = self.utilityArray.filter {
                                    guard let dictionary = $0 as? [String: Any],
                                        let name = dictionary["emailDomains"] as? String else {
                                            return false
                                    }
                                    return name.contains(mailDomain!)
                                    
                                }
                                if(filteredArray.count == 1 ) {
                                    
                                    self.selectedTenantObj = filteredArray.first as! [String : Any];
                                    _ = DispatchQueue.main.sync() {
                                        
                                        self.utilityTextField.text = self.selectedTenantObj["name"] as? String
                                        self.utilityTextField.isEnabled = false
                                    }
                                    self.prefs.set("EMPLOYEE", forKey: Constants.DEFAULTS_USER_TYPE)
                                    
                                }
                                else if(filteredArray.count > 1 ) {
                                    self.utilityArray = filteredArray
                                    _ = DispatchQueue.main.sync() {
                                        
                                        self.utilityTextField.inputView = self.utilityPicker
                                        let toolBar = UIToolbar()
                                        toolBar.barStyle = UIBarStyle.default
                                        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
                                        toolBar.sizeToFit()
                                        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.dismissPicker))
                                        toolBar.setItems([ doneButton], animated: false)
                                        toolBar.isUserInteractionEnabled = true
                                        self.utilityTextField.inputAccessoryView = toolBar
                                    }
                                    
                                    self.prefs.set("EMPLOYEE", forKey: Constants.DEFAULTS_USER_TYPE)
                                }
                                  
                                else {
                                    _ = DispatchQueue.main.sync() {
                                        
                                        self.utilityTextField.inputView = self.utilityPicker
                                        let toolBar = UIToolbar()
                                        toolBar.barStyle = UIBarStyle.default
                                        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
                                        toolBar.sizeToFit()
                                        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.dismissPicker))
                                        toolBar.setItems([ doneButton], animated: false)
                                        toolBar.isUserInteractionEnabled = true
                                        self.utilityTextField.inputAccessoryView = toolBar
                                        self.prefs.set("TOWN_USER", forKey: Constants.DEFAULTS_USER_TYPE)
                                    }
                                    
                                    
                                }
                                self.prefs.set(false, forKey: Constants.IS_SUBSCRIPTION_EXISTS)
                                
                            }
                            else {
                                
                                self.prefs.set(true, forKey: Constants.IS_SUBSCRIPTION_EXISTS)
                                let subscriptionDict : [String :String] = subscriptionArray.first as! [String : String]
                                
                                let userSatus : String = subscriptionDict["subscriptionStatus"]!;
                                
                                
                                self.prefs.set(false, forKey: Constants.IS_TERMS_EXISTS)
                                self.prefs.set(false, forKey: Constants.IS_USER_APPROVED)
                                
                                let isEqual = (userSatus == Constants.USER_STATUS_APPROVED)
                                if isEqual {
                                    
                                    self.prefs.set(true, forKey: Constants.IS_USER_APPROVED)
                                    if let termsString  = subscriptionDict["terms"]  {
                                        if let _termsDict = Helper.shared.convertToDictionary(text:termsString ) {
                                            
                                            let termsDict  = _termsDict
                                            if  let isAccepted   = termsDict["isAccepted"] as?  Bool {
                                                if(isAccepted == true) {
                                                    self.prefs.set(true, forKey: Constants.IS_TERMS_EXISTS)
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                self.selectedTenantObj = self.utilityArray.first as! [String : Any]
                                let emailDomain : String = self.selectedTenantObj["emailDomains"] as! String
                                let mailDomain : String = (signUpEmail?.components(separatedBy: "@").last)!
                                if emailDomain.range(of: mailDomain) != nil {
                                    self.prefs.set("EMPLOYEE", forKey: Constants.DEFAULTS_USER_TYPE)
                                    
                                }
                                else{
                                    self.prefs.set("TOWN_USER", forKey: Constants.DEFAULTS_USER_TYPE)
                                    
                                }
                                _ = DispatchQueue.main.sync() {
                                    
                                    self.utilityTextField.isHidden = false
                                    self.utilityUnderLineView.isHidden = false
                                    self.utilityTextField.isEnabled = false
                                    self.utilityTextField.text = self.selectedTenantObj["name"] as? String
                                }
                                
                            }
                            
                            
                        }
                    }
                    _ = DispatchQueue.main.sync() {
                                      
                                      self.signUpButton.setTitle("Next",for: .normal)
                                      self.phoneNoPart1.isEnabled = false
                                      self.emailField.isEnabled = false
                                  }


                }
                

                
                break
            case .Failure(let error):
//                self.appDelegate.displayAlert(message: error.errormessage ?? "", isActionRequired: true)
               print("the error \(error.errormessage)")
                }
            

        }
        
        }
        
    func saveUserData(userDict:[String:Any]) {
        UserDefaults.standard.set(userDict["firstName"], forKey: "firstName")
        UserDefaults.standard.set(userDict["lastName"], forKey: "lastName")
        UserDefaults.standard.set(userDict["primaryPhone"], forKey: "primaryPhone")
        UserDefaults.standard.set(userDict["job"], forKey: "job")
        UserDefaults.standard.set(userDict["organization"], forKey: "organization")
        UserDefaults.standard.set(userDict["city"], forKey: "city")
        UserDefaults.standard.set(userDict["state"], forKey: "state")
        UserDefaults.standard.set(userDict["county"], forKey: "county")
        UserDefaults.standard.set(userDict["userId"], forKey: "userId")

    }
    
    func storeTenantData() {
        
        let logoUrl = NSURL(string: self.selectedTenantObj["logo"] as! String)
        let logoLastPath : String = logoUrl!.lastPathComponent!.components(separatedBy: ".").first!
        let scale = UIScreen.main.scale
        let scaleInt = Int(scale)
        let logoName = String(format: "%@@\(scaleInt)x.png", logoLastPath)
        prefs.set(logoName, forKey: "logo")
        prefs.set(self.selectedTenantObj["token"], forKey: Constants.accessToken)
        prefs.set(self.selectedTenantObj["accountKey"], forKey: Constants.accountKey)
        prefs.set(self.selectedTenantObj["name"], forKey: Constants.DEFAULT_TENANT_NAME)
        prefs.set(self.selectedTenantObj["id"], forKey: Constants.UTILITY_ID)

        
        var configurationObj = [String :Any]()
        if let _configurationObj =  Helper.shared.convertToDictionary(text: self.selectedTenantObj["configuration"] as! String) {
            configurationObj = _configurationObj
            
            var isOTPRequired = false
            if configurationObj["otpValidation"] as! Bool {
                isOTPRequired  = true
                prefs.set(isOTPRequired, forKey: Constants.IS_OTP_REQUIRED)
            }
            
            // self.prefs.set(configurationObj, forKey: Constants.CONFIGURATION_OBJECT)
            let s3BucketName :String = configurationObj["s3Bucket"] as! String
            self.prefs.set(s3BucketName,forKey: Constants.BUCKET_NAME)
            
            let profileBucketName :String = configurationObj["profilePicBucket"] as! String
            UserDefaults.standard.set(profileBucketName,forKey: Constants.PROFILE_BUCKET_NAME)
            
            if let config  = configurationObj["viewConfig"] as? [String:Any] {
                self.prefs.set(config,forKey: Constants.DEFAULTS_TENANT_CONFIG)

            }

            
//            let profilePicsBucketName :String = configurationObj["profilePicBucket"] as! String
//            self.prefs.set(profilePicsBucketName,forKey:Constants.PROFILE_BUCKET_NAME)
            
            
            let firebaseDB :String = configurationObj["firestoreCollection"] as! String
            self.prefs.set(firebaseDB,forKey:Constants.FIREBAE_DB)


        }
        
        
        let isAdminApproved  =  prefs.bool(forKey: Constants.IS_USER_APPROVED)
        if(!isAdminApproved ) {
            
            if  configurationObj["adminApproval"] as! Bool {
                
                prefs.set(false, forKey: Constants.IS_USER_APPROVED)
            }
            else {
                prefs.set(true, forKey: Constants.IS_USER_APPROVED)
                
            }
            
        }
        
        
        
        self.prefs.synchronize()
        
        
    }
    
    func getOTP(){
        
        self.activityIndicator.startAnimating()
        let apiClient  = V1ApiClient.init()
        apiClient.getOTP(){
            result in
            _ = DispatchQueue.main.sync() {
                self.activityIndicator.stopAnimating()
            }
            switch result {
            case .Success(let value):
                     if let responseDict = value.data as? [String:Any] {
                        if responseDict["Error"] as! Bool {
                            print("error")
                            //self.appDelegate.displayAlert(message:obj["Message"]  as! String, isActionRequired: true)
                        }
                        else {
                            if let otpValue  = responseDict["OTP"] {
                                self.prefs.set(otpValue, forKey: Constants.OTP_VALUE)
                                print("OTP:\(otpValue)" )
                            }
                            self.downloadTenantLogoFromS3()
                            
                            
                        }
                        
                     }
                    break
            case .Failure(let error):
                    print("the error \(error.errormessage)")
                }
                
        }
    }
//        let submitReportUrlString = Constants.SERVER_ADRESS + Constants.GET_OTP_API
//
//        let phoneNumber = phoneNoPart1.text?.components(separatedBy: CharacterSet.init(charactersIn:"1234567890").inverted).joined(separator: "")
//
//        let serverParamValue = ""// Environment().configuration(PlistKey.ServerParamValue)
//        var newSignUPString = submitReportUrlString.replacingOccurrences(of: Constants.serverParamKEY, with: serverParamValue)
//
//        newSignUPString = newSignUPString.appendingFormat("phone=%@",phoneNumber!)
//        let url = URL(string:newSignUPString)!
//
//        let session = URLSession.shared
//        let request = NSMutableURLRequest(url: url)
//        request.httpMethod = "GET"
//        let accessToken : String  = prefs.value(forKey: Constants.accessToken) as! String
//        let accountKey : String = prefs.value(forKey: Constants.accountKey) as! String
//        request.setValue(accessToken , forHTTPHeaderField: "x-access-token")
//        request.setValue(accountKey, forHTTPHeaderField: "x-account-key")
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
//        request.setValue(Constants.applicationKey, forHTTPHeaderField: "x-application")
//        request.setValue(phoneNumber!, forHTTPHeaderField: "x-user")
//
//        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
//            guard let _: Data = data, let _: URLResponse = response, error == nil else {
//                print (error?.localizedDescription ?? "Error")
//                return
//            }
//
//            do {
//                _ = DispatchQueue.main.sync() {
//                    self.activityIndicator.stopAnimating()
//                }
//                let obj:[String:Any] = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
//                if obj["Error"] as! Bool {
//                    //self.appDelegate.displayAlert(message:obj["Message"]  as! String, isActionRequired: true)
//                }
//                else {
//                    if let otpValue  = obj["OTP"] {
//                        self.prefs.set(otpValue, forKey: Constants.OTP_VALUE)
//                        print("OTP:\(otpValue)" )
//                    }
//                    self.downloadTenantLogoFromS3()
//
//
//
//                }
//            }
//            catch {
//                print(error.localizedDescription)
//            }
//
//        }
//        task.resume()
        
        
        
   // }
    
    func downloadTenantLogoFromS3 () {
        
            var   logoDownloadInitiated : Bool = false
        
              let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
              let documentDirectorPath:String = paths[0]
              let logoName =     prefs.object(forKey:"logo" ) as! String
              let newFilePath = documentDirectorPath.appending("/\(logoName)")
        
              let isExist = FileManager.default.fileExists(atPath: newFilePath)
       
                if isExist == false{
       
                 logoDownloadInitiated = true
       
                 DispatchQueue.global(qos: .userInitiated).async {
       
                     let actualLogoUrl = NSURL(string: self.selectedTenantObj["logo"] as! String)
                     let logoFirstPart: URL = (actualLogoUrl?.deletingLastPathComponent)!
                     let logoFirstPartString = logoFirstPart.absoluteString
       
                     let logoLastPath : String = actualLogoUrl!.lastPathComponent!.components(separatedBy: ".").first!
                     let scale = UIScreen.main.scale
                     let scaleInt = Int(scale)
                     let newPath = "\(logoFirstPartString)\(logoName)"
                     let logoURL = NSURL(string: newPath)
                    self.getData(from: logoURL as! URL) { data, response, error in
                        guard let data = data, error == nil else {
                            print("hi")
                            return
                            
                        }
                        if let image =  UIImage(data: data) {
                            FileManager.default.createFile(atPath: newFilePath as String, contents: data, attributes: nil)
                        }
                        self.proceedToNextScreen()

                    }

       
                 }
       
             }
            else {
                    self.proceedToNextScreen()
            }

        }
        
        
        
        //        let transferManager = AWSS3TransferManager.default()
        //        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        //
        //
        //        let logoName =     prefs.object(forKey:"logoName" ) as! String
        //
        //       // let logofolderName = "Documents\\(logoName)"
        //        let downloadingFileURL = URL(fileURLWithPath: documentsPath).appendingPathComponent(logoName)
        //
        //        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        //        downloadRequest?.bucket = prefs.object(forKey: Constants.AWS_BUCKET_NAME ) as! String
        //        downloadRequest?.key = "myImage.jpg"
        //        downloadRequest?.downloadingFileURL = downloadingFileURL
        //        transferManager.download(downloadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
        //
        //            if let error = task.error as? NSError {
        //                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
        //                    switch code {
        //                    case .cancelled, .paused:
        //                        break
        //                    default:
        //                        Apple1234$Apple1("Error downloading: \(downloadRequest?.key) Error: \(error)")
        //                    }
        //                } else {
        //                    print("Error downloading: \(downloadRequest?.key) Error: \(error)")
        //                }
        //                return nil
        //            }
        //           // print("Download complete for: \(downloadRequest.key)")
        //            let downloadOutput = task.result
        //            return nil
        //        })
        
//    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func proceedToNextScreen ()  {
        
        
        let isOtpRequired  = prefs.bool(forKey: Constants.IS_OTP_REQUIRED)
        let isSubscriptionExists  = prefs.bool(forKey: Constants.IS_SUBSCRIPTION_EXISTS)
        let isUserApproved  = prefs.bool(forKey: Constants.IS_USER_APPROVED)
        let isTermsExists  = prefs.bool(forKey: Constants.IS_TERMS_EXISTS)

        _ = DispatchQueue.main.sync() {
            let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            prefs.set(email, forKey: Constants.EMAIL_KEY)
            let random = Helper.shared.generateRandomNumber()
            prefs.set(random, forKey: "RandomNumber")
            
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            if(isOtpRequired) {
                
                if let nextViewController = mainStoryBoard.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController {
                            self.navigationController?.pushViewController(nextViewController, animated: true)          //

                }
                
            }
            else if(!isSubscriptionExists) {
                let loginVc = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController")
                let nextViewController = mainStoryBoard.instantiateViewController(withIdentifier: "CreateProfileViewController")
                navigationController?.setViewControllers([loginVc,nextViewController], animated: true)
            }
            else if(!isUserApproved) {
                let loginVc = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController")
                let nextViewController = mainStoryBoard.instantiateViewController(withIdentifier: "AdminApprovalViewController")
                navigationController?.setViewControllers([loginVc,nextViewController], animated: true)
            }
                
                
            else if(!isTermsExists) {
                let loginVc = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController")
                let nextViewController = mainStoryBoard.instantiateViewController(withIdentifier: "TermsConditionsViewController")
                navigationController?.setViewControllers([loginVc,nextViewController], animated: true)
            }
            
        }
        // NSString *randomUUID = [Helper  generateRandomUUID];
        //[defaults setObject:email forKey:"emailKey"];
        
        // [defaults setValue:randomUUID forKey:DEFAULTS_RANDOM_UUID];
        // [defaults synchronize];
        
        
        
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[a-zA-Z0-9._'-]+@[a-z]+\\.+[a-z]+"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPhoneNumber(phoneNumber :String)->Bool {
        
        let newString : String =  phoneNumber.components(separatedBy: CharacterSet.init(charactersIn:"1234567890").inverted).joined(separator: "")
        
        let phoneRegEx = "[0-9]{10}"
        let phoneNumberTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phoneNumberTest.evaluate(with: newString)
        
    }
    // MARK: TextField Delegate Methods

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneNoPart1 {
            
            let length = self.getPhoneLength(mobNumber: textField.text!)
            if(length == 9 ) {
                if let _ = string.rangeOfCharacter(from: CharacterSet.init(charactersIn: "1234567890")){
                    let num = textField.text;
                    textField.text = String(format: "%@%@",  num!,string)
                    textField.resignFirstResponder();
                }
                else {
                    
                }
                
            }
            if(length == 10)
            {
                if(range.length == 0) {
                    return false
                }
            }
            if(length == 3)
            {
                let num : String =  self.formatNumber(mobNumber: textField.text!)
                
                textField.text = String(format: "(%@)",  num)
                
                if(range.length > 0){
                    let ss: String = (num as NSString).substring(to: 3)
                    textField.text  = ss
                }
            }
            else if(length == 6)
            {
                let num : String =  self.formatNumber(mobNumber: textField.text!)
                
                let sstoIndex : String = (num as NSString).substring(to: 3)
                let ssFromIndex : String = (num as NSString).substring(from:3)
                textField.text = String(format: "(%@) %@-",  sstoIndex,ssFromIndex)
                if(range.length > 0){
                    textField.text = String(format: "(%@) %@",  sstoIndex,ssFromIndex)
                }
                
            }
        }
        return true
    }
    
    func formatNumber(mobNumber : String ) -> String {
        var mobileNumber : String = mobNumber
        mobileNumber = mobileNumber.replacingOccurrences(of: "(", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: ")", with: "")
        
        mobileNumber = mobileNumber.replacingOccurrences(of: " ", with: "")
        
        mobileNumber = mobileNumber.replacingOccurrences(of: "+", with: "")
        
        mobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "")
        
        let length : Int = mobileNumber.count
        
        if(length > 10)
        {
            let index = mobileNumber.index(mobileNumber.startIndex, offsetBy: 10)
            mobileNumber = mobileNumber.substring(from: index)
            
        }
        return mobileNumber
        
    }
    
    func getPhoneLength(mobNumber : String) -> Int {
        
        var mobileNumber : String = mobNumber
        mobileNumber = mobileNumber.replacingOccurrences(of: "(", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: ")", with: "")
        
        mobileNumber = mobileNumber.replacingOccurrences(of: " ", with: "")
        
        mobileNumber = mobileNumber.replacingOccurrences(of: "+", with: "")
        
        mobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "")
        let length : Int = mobileNumber.count
        return length
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    // MARK: UIPickerView
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.utilityArray.count
        
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        let utilityDict = self.utilityArray[row] as! [String :Any]
        let name = utilityDict["name"] as! String
        return name
        
        
        //        if (pickerView == self.utilityPicker) {
        //            return [self.utilityArray[row] objectForKey:@"name"];
        //        }
        //
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        var utiName = ""
        let utilityDict = self.utilityArray[row] as! [String :Any]
        
        utiName = utilityDict["name"] as! String
        self.utilityTextField.text = utiName;
        
        let filteredArray = self.utilityArray.filter {
            guard let dictionary = $0 as? [String: Any],
                let name = dictionary["name"] as? String else {
                    return false
            }
            return name.contains(utiName)
            
        }
        if(filteredArray.count > 0 ) {
            self.selectedTenantObj = filteredArray.first as! [String : Any]
            self.utilityTextField.text = self.selectedTenantObj["name"] as! String
            
        }
        
        
        //            let token = obj["token"] as! String
        //            let accountKey = obj["accountKey"] as! String
        //
        //            prefs.set(token, forKey: Constants.accessToken)
        //            prefs.set(accountKey, forKey:  Constants.accountKey)
        
    }
    
       @objc func dismissPicker ()  {
            self.utilityTextField.resignFirstResponder()
        }
    
}

