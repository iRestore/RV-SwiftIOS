//
//  CreateProfileViewController.swift
//  YellowCard
//
//  Created by Kundan Kumar on 15/02/18.
//  Copyright © 2018 Kundan Kumar. All rights reserved.
//

import UIKit
extension String {
    var isAlphabets: Bool {
        return !isEmpty && range(of: "[^a-zA-Z ]", options: .regularExpression) == nil
    }
}

class CreateProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phone : UITextField!
    @IBOutlet weak var email : UITextField!
    @IBOutlet weak var firstname : UITextField!
    @IBOutlet weak var lastname : UITextField!
    @IBOutlet weak var jobTitle : UITextField!
    @IBOutlet weak var organization : UITextField!
    @IBOutlet weak var city : UITextField!
    @IBOutlet weak var state : UITextField!
    @IBOutlet weak var county : UITextField!
    @IBOutlet weak var nextBtn : UIButton!
    @IBOutlet weak var closeBtn : UIButton!
    @IBOutlet weak var viewHolder : UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    let appDelegate: AppDelegate        = UIApplication.shared.delegate as! AppDelegate
    let prefs : UserDefaults = UserDefaults.standard
    var userObj : [String : Any] =   [String : Any]()
    var isFromCreateScreen : Bool = true
    var primaryPhone : String = ""
    var keyboardSize = CGSize()
    var alertMsg = String()
    
    override func viewDidLoad() {
        self.navigationController?.navigationItem.hidesBackButton = true
        let n: Int! = self.navigationController?.viewControllers.count
        self.navigationItem.title = "My Profile"
        let phone  = prefs.value(forKey:Constants.PHONE_KEY) as! String
        let email  = prefs.value(forKey:Constants.EMAIL_KEY) as! String
        self.phone.text = phone
        self.email.text = email
        
        
        self.firstname.text = prefs.value(forKey: "firstName") as? String
        self.lastname.text = prefs.value(forKey: "lastName") as? String
        self.jobTitle.text = prefs.value(forKey: "job") as? String
        self.organization.text  = prefs.value(forKey: "organization") as? String
        self.city.text = prefs.value(forKey: "city") as? String
        self.state.text = prefs.value(forKey: "sate") as? String
        self.county.text = prefs.value(forKey: "county") as? String

    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateProfileViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        if self.view.frame.origin.y != 64 {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    @objc func backBtnPressed() -> Void
    {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        
        if county.isFirstResponder {
            if self.view.frame.origin.y == 64 {
                self.view.frame.origin.y -= keyboardSize.height
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if county.isFirstResponder {
            if self.view.frame.origin.y != 64 {
                self.view.frame.origin.y += keyboardSize.height
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func constructPostString () -> String {
        
        let prefs = UserDefaults.standard
        
        let phone  = prefs.value(forKey: Constants.PHONE_KEY) as! String
        let email  = prefs.value(forKey: Constants.EMAIL_KEY) as! String
        
        var postString = "email=\(email)"
        postString =  postString.appending("&phone=\(phone)")
        
        if( primaryPhone != "") {
            postString =  postString.appending("&primaryPhone=\(primaryPhone)")
            
        }
        else{
            postString =  postString.appending("&primaryPhone=\(phone)")
            
        }
        
        
        if let firstName = self.firstname.text {
            postString = postString.appending("&firstName=\(firstName)")
        }
        if let lastName = self.lastname.text {
            postString = postString.appending("&lastName=\(lastName)")
        }
        if let organization = self.organization.text {
            postString = postString.appending("&organization=\(organization)")
        }
        if let job = self.jobTitle.text {
            postString = postString.appending("&job=\(job)")
        }
        if let city = self.city.text {
            postString = postString.appending("&city=\(city)")
        }
        if let state = self.state.text {
            postString = postString.appending("&state=\(state)")
        }
        if let county = self.county.text {
            postString = postString.appending("&county=\(county)")
        }
        
        let owner  = prefs.object(forKey: Constants.accountKey) as! String
        let userType : String = prefs.object(forKey: Constants.DEFAULTS_USER_TYPE) as! String
        if(userType  == "EMPLOYEE") {
            postString = postString.appending("&owner=\(owner)")
            
        }
        else{
            postString = postString.appending("&owner= ")
            
        }
        postString = postString.appending("&userType=\(userType)")
        return postString
        //Constants.accountKey //[defaults valueForKey:DEFAULT_TENANT_ACCOUNT_KEY];
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
    @IBAction func next(sender: UIButton)
    {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        if(isFromCreateScreen) //createProfileScree
        {
            let postString = self.constructPostString()
            guard let postData = postString.data(using: String.Encoding.utf8) else { return }

            let apiClient  = V1ApiClient.init()
            
            apiClient.createProfile(postData: postData) {
                result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                print(result)
                switch result {
                    
                case .Success(let value):
                    if let responseDict = value.data as? [String:Any] {
                      if responseDict["Error"] as! Bool {
                            DispatchQueue.main.async {

                            self.displayAlert(message: responseDict["Message"] as! String, isActionRequired: true)
                            print("Failed with error")
                            }
                        }
                        else {
                        
                        if let userArray = responseDict["User"] as? [[String:Any]] {
                             if(userArray.count > 0) {
                                let userDict = userArray.first
                                self.saveUserData(userDict: userDict!)
                            }
                        }
                        
                        if let permissionsArray = responseDict["Permissions"] as? [[String:Any]] {
                            if permissionsArray.count>0 {
                                let permissionMainObj = permissionsArray.first as! [String:Any]
                                if let permissionObj = permissionMainObj["permissions"] as? [String:Any] {
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
                        UserDefaults.standard.set(true, forKey: Constants.IS_SUBSCRIPTION_EXISTS)
                        let  isUserApproved = UserDefaults.standard.bool(forKey: Constants.IS_USER_APPROVED)
                        let  isTermsExists = UserDefaults.standard.bool(forKey: Constants.IS_TERMS_EXISTS)
                        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)

                        if (isUserApproved == false) {
                            DispatchQueue.main.async {

                            let nextViewController = mainStoryBoard.instantiateViewController(withIdentifier: "AdminApprovalController")
                            self.navigationController?.setViewControllers([nextViewController], animated: true)
                            }
                        }
                        else if (isTermsExists == false) {
                            DispatchQueue.main.async {

                            let loginVc = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController")
                                               let nextViewController = mainStoryBoard.instantiateViewController(withIdentifier: "TermsConditionsViewController")
                            self.navigationController?.setViewControllers([loginVc,nextViewController], animated: true)
                            }
                        }
                        else {
                            DispatchQueue.main.async {

                            if let tabbar = mainStoryBoard.instantiateViewController(withIdentifier: "TabbarController") as? TabbarController {
                               if #available(iOS 13.0, *) {
                                    self.view.window?.rootViewController = tabbar
                                }
                               else {
                                    self.appDelegate.window?.rootViewController = tabbar

                                }
                            }
                            }

                            
                        }
                    }
                    }
                        
                    break
                case .Failure(let error):
                    DispatchQueue.main.async {

                        self.displayAlert(message: error.errormessage as! String, isActionRequired: true)
                    }
                    break
                    


                    }
    
        }
        }
    }
    
    func showAlertForProfile()
    {
        DispatchQueue.main.async()
            {
                self.alertMsg = self.alertMsg + " doesn't accept numbers."
                let alert = UIAlertController(title: "Attention Required!", message: self.alertMsg, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: .default, handler: { action in
                    switch action.style
                    {
                    case .default:
                        print("OK")
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    func updateInfo()
    {
       
        self.alertMsg = ""
        if !(firstname.text?.isAlphabets)! {
            self.alertMsg = "First name"
            showAlertForProfile()
            return
        }
        if !(lastname.text?.isAlphabets)! {
            if !self.alertMsg.isEmpty
            {
                self.alertMsg = self.alertMsg + ", "
            }
            self.alertMsg = self.alertMsg + "Last name"
            showAlertForProfile()
            return
        }
        if !(jobTitle.text?.isAlphabets)! {
            if !self.alertMsg.isEmpty
            {
                self.alertMsg = self.alertMsg + ", "
            }
            self.alertMsg = self.alertMsg + "Job title"
            showAlertForProfile()
            return
        }
        if !(organization.text?.isAlphabets)! {
            if !self.alertMsg.isEmpty
            {
                self.alertMsg = self.alertMsg + ", "
            }
            self.alertMsg = self.alertMsg + "Organization"
            showAlertForProfile()
            return
        }
        if !(city.text?.isAlphabets)! {
            if !self.alertMsg.isEmpty
            {
                self.alertMsg = self.alertMsg + ", "
            }
            self.alertMsg = self.alertMsg + "City"
            showAlertForProfile()
            return
        }
        if !(state.text?.isAlphabets)! {
            if !self.alertMsg.isEmpty
            {
                self.alertMsg = self.alertMsg + ", "
            }
            self.alertMsg = self.alertMsg + "State"
            showAlertForProfile()
            return
        }
        if !(county.text?.isAlphabets)! {
            if !self.alertMsg.isEmpty
            {
                self.alertMsg = self.alertMsg + ", "
            }
            self.alertMsg = self.alertMsg + "Country"
            showAlertForProfile()
            return
        }
        
        let data = prefs.value(forKey: Constants.USER_DATA_OBJECT)
        userObj = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! [String : Any]
        
        if  firstname.text != userObj["firstName"] as? String || lastname.text != userObj["lastName"] as? String || jobTitle.text != userObj["job"] as? String || organization.text != userObj["organization"] as? String || city.text != userObj["city"] as? String || state.text != userObj["state"] as? String || county.text != userObj["county"] as? String
        {
            let postString = self.constructPostString()
            guard let postData = postString.data(using: String.Encoding.utf8) else { return  }

            activityIndicator.startAnimating()
            
            let apiClient  = V1ApiClient.init()
            
            apiClient.updateProfile(postData: postData) {
                result in
                _ = DispatchQueue.main.sync() {
                    self.activityIndicator.stopAnimating()
                }
                print(result)
                switch result {
                    
                case .Success(let value):
                    break
                case .Failure(let error):
                    break
            
                }
            }
            
        }
    }
    
    func saveUpdatedValues()
    {
        let data = prefs.value(forKey: Constants.USER_DATA_OBJECT)
        userObj = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! [String : Any]
        userObj["firstName"] = firstname.text
        userObj["lastName"] = lastname.text
        userObj["job"] = jobTitle.text
        userObj["organization"] = organization.text
        userObj["city"] = city.text
        userObj["state"] = state.text
        userObj["county"] = county.text
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: userObj)
        prefs.set(encodedData, forKey: Constants.USER_DATA_OBJECT)
        self.prefs.synchronize()
    }
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        //<#code#>
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //        textField.resignFirstResponder()
        //        return true
        
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            return true;
        }
        return false
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let n: Int! = self.navigationController?.viewControllers.count
        //        if self.navigationController?.viewControllers[n-2] is DashboardViewController
        //        {
        //            let data = prefs.value(forKey: Constants.USER_DATA_OBJECT)
        //            userObj = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! [String : Any]
        //
        //            if  firstname.text != userObj["firstName"] as? String || lastname.text != userObj["lastName"] as? String || jobTitle.text != userObj["job"] as? String || organization.text != userObj["organization"] as? String || city.text != userObj["city"] as? String || state.text != userObj["state"] as? String || county.text != userObj["county"] as? String
        //            {
        //                if  firstname.text == "" || lastname.text == "" || jobTitle.text == "" || organization.text == "" || city.text == "" || state.text == "" || county.text == ""
        //                {
        //                    nextBtn.isEnabled = false;
        //                }
        //                else
        //                {
        //                    nextBtn.isEnabled = true;
        //                }
        //            }
        //            else
        //            {
        //                nextBtn.isEnabled = false;
        //            }
        //        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if county.isFirstResponder {
            if self.view.frame.origin.y == 64 {
                showKeyBoard()
            }
        }
    }
    
    func showKeyBoard()
    {
        self.view.frame.origin.y -= keyboardSize.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    func displayAlert(message:String,isActionRequired:Bool) {
        DispatchQueue.main.async {

            let alert = UIAlertController(title: NSLocalizedString("ALERT", comment: ""), message: message, preferredStyle: UIAlertController.Style.alert)
        if(isActionRequired) {
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
        }
    }
    
}

