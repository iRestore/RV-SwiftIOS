//
//  OTPViewController.swift
//  YellowCard
//
//  Created by Kundan Kumar on 15/02/18.
//  Copyright © 2018 Kundan Kumar. All rights reserved.
//

import UIKit
//import MMDrawerController

let MAX_TIME : Int  = 300

class OTPViewController: UIViewController ,UITextFieldDelegate {
    
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel :UILabel!
    @IBOutlet weak var logoHolderBg :UIView!
    @IBOutlet weak var customerLogoView :UIImageView!
    let defaults : UserDefaults = UserDefaults.standard
    let appDelegate: AppDelegate        = UIApplication.shared.delegate as! AppDelegate
    var timeInSeconds : Int = 0
    var isOtpExpired : Bool = false
    var timer : Timer? = nil
    var maintimer : Timer? = nil
    override func viewDidLoad() {
        navigationBarSettings()
        
    }
    func navigationBarSettings() -> Void {
        
        
        print(self.navigationController)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationItem.hidesBackButton = false
       // self.navigationController?.navigationBar.isTranslucent = false
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationItem.title = "OTP"
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 15.0) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        
        var backButton: UIButton
        var leftBarBtnItem : UIBarButtonItem
        backButton = UIButton.init(type: UIButton.ButtonType.custom)
        backButton.setImage(UIImage.init(named: "back_green"), for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(backBtnOnClick), for: .touchUpInside)
        backButton.sizeToFit()
        leftBarBtnItem = UIBarButtonItem.init(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarBtnItem
        self.customerLogoView.image = UIImage.init(named: "irestorelogo@2x.png")
    }
    @objc func backBtnOnClick() -> Void {
        self.maintimer?.invalidate()
        self.timer?.invalidate()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _timerstartDate = defaults.value(forKey: Constants.OTP_TIMER_VALUE)  {
            let timerstartDate : Date = _timerstartDate as! Date
            let timeDifference = Int( Date.init().timeIntervalSince(timerstartDate))
            if(Int(timeDifference) >= MAX_TIME ) {
               // appDelegate.displayAlert(message: "The OTP sent to you has expired!", isActionRequired: true)
                self.timerLabel.text = "00:00"
                
            }
            else {
                self.maintimer?.invalidate()
                self.timer?.invalidate()
                self.startTimer(time: MAX_TIME - timeDifference )
            }
        }
        else {
            self.maintimer?.invalidate()
            self.timer?.invalidate()
            self.startTimer(time: MAX_TIME )
        }
        
    }
    
    
    
    func startTimer(time :Int )-> Void {
        defaults.set(Date.init(), forKey: Constants.OTP_TIMER_VALUE)
        timeInSeconds  = time;
        maintimer  =  Timer.scheduledTimer(timeInterval: TimeInterval(timeInSeconds), target: self, selector: #selector(self.otpExpired), userInfo: nil, repeats: true)
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
    }
    @objc func otpExpired () -> Void {
        
        isOtpExpired = true
    }
    
    @objc func update() -> Void {
        
        var minutes : Int = 0
        var seconds : Int = 0
        if (timeInSeconds > 0) {
            timeInSeconds = timeInSeconds - 1;
            minutes = (timeInSeconds % 3600) / 60
            seconds = (timeInSeconds % 3600) % 60
            self.timerLabel .text = NSString.init(format: "%02d:%02d", minutes,seconds) as String
        }
        else {
            timer?.invalidate()
            appDelegate.displayAlert(message: "The OTP sent to you has expired!", isActionRequired: true)
            self.timerLabel .text = NSString.init(format: "%02d:%02d", 0,0) as String
        }
    }
    
    func isEmpty( text : String ) -> Bool {
        let whiteSpaceCharacterSet = CharacterSet.whitespacesAndNewlines
        let trimmedString = text.trimmingCharacters(in: whiteSpaceCharacterSet)
        if text.count == 0  || trimmedString.count == 0  {
            return true
        }
        else {
            return false
            
        }
    }
    //Mark : IBAction
    override  func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !((touches.first?.view?.isEqual(otpTextField))!){
            otpTextField.resignFirstResponder()
            
        }
        else {
            super.touchesBegan(touches, with: event)
            
        }
    }
    
    //Mark : IBAction
    @IBAction func validateOTP(sender: UIButton) {
        
        self.view.endEditing(true)
        if (self.isEmpty(text: self.otpTextField.text!) == true) {
            appDelegate.displayAlert(message: "Please enter the One Time PIN texted to your cell", isActionRequired: true)
        }
        else {
            
            if (!isOtpExpired) {
                let otpValue :String = defaults.value(forKey: Constants.OTP_VALUE) as! String
                if(otpValue == self.otpTextField.text)  {
                    
                    let prefs : UserDefaults = UserDefaults.standard
                    if prefs.value(forKey: Constants.OTP_TIMER_VALUE) != nil
                    {
                        prefs.removeObject(forKey: Constants.OTP_TIMER_VALUE)
                    }
                    
                    let isSubscriptionExists  = prefs.bool(forKey: Constants.IS_SUBSCRIPTION_EXISTS)
                    let isUserApproved  = prefs.bool(forKey: Constants.IS_USER_APPROVED)
                    let isTermsExists  = prefs.bool(forKey: Constants.IS_TERMS_EXISTS)
                    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                    
                    self.maintimer?.invalidate()
                    self.timer?.invalidate()
                    prefs.set(false, forKey: Constants.IS_OTP_REQUIRED)
                    if(!isSubscriptionExists) {
                        let loginVc = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController")
                        let nextViewController = mainStoryBoard.instantiateViewController(withIdentifier: "CreateProfileViewController")
                        navigationController?.setViewControllers([loginVc,nextViewController], animated: true)
                    }
                    else if(!isUserApproved) {
                        let nextViewController = mainStoryBoard.instantiateViewController(withIdentifier: "AdminApprovalController")
                        navigationController?.setViewControllers([nextViewController], animated: true)

                    }
                        
                    else if(!isTermsExists) {
                        let loginVc = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController")
                        let nextViewController = mainStoryBoard.instantiateViewController(withIdentifier: "TermsConditionsViewController")
                        navigationController?.setViewControllers([loginVc,nextViewController], animated: true)                    }
                    else {
                        self.updateDeviceConfigurations()
                        UserDefaults.standard.set(true, forKey: "launchedBefore")
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
                else {
                    let alert = UIAlertController(title: "Alert!", message: "Incorrect OTP", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            
            
        }
    }
    
    
    func updateDeviceConfigurations() {
        
        let apiClient  = V1ApiClient.init()
        apiClient.updateDeviceConfiguration(){
            result in
            switch result {
            case .Success(let value):
                     if let responseDict = value.data as? [String:Any] {
                        if responseDict["Error"] as! Bool {
                            print("error")
                            
                        }
                        else {
                           print("device configuration updated successfully")

                            
                        }
                        
                     }
                    break
            case .Failure(let error):
                    print("the error \(error.errormessage)")
                }
                
        }

    }
    
    @IBAction func resendOTP(sender: UIButton) {
        self.maintimer?.invalidate()
        self.timer?.invalidate()
        self.startTimer(time: MAX_TIME)
        
        self.isOtpExpired = false
        //self.activityIndicator.startAnimating()
        let apiClient  = V1ApiClient.init()
        apiClient.getOTP(){
            result in
            
            switch result {
            case .Success(let value):
                     if let responseDict = value.data as? [String:Any] {
                        if responseDict["Error"] as! Bool {
                            print("error")
                            //self.appDelegate.displayAlert(message:obj["Message"]  as! String, isActionRequired: true)
                        }
                        else {
                            if let otpValue  = responseDict["OTP"] {
                                UserDefaults.standard.set(otpValue, forKey: Constants.OTP_VALUE)
                                print("OTP:\(otpValue)" )
                            }
                            
                            
                        }
                        
                     }
                    break
            case .Failure(let error):
                    print("the error \(error.errormessage)")
                }
                
        }
        
        

        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

