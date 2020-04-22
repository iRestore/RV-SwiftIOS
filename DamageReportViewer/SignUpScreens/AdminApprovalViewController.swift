//
//  AdminApprovalViewController.swift
//  YellowCard
//
//  Created by Kundan Kumar on 15/02/18.
//  Copyright © 2018 Kundan Kumar. All rights reserved.
//

import UIKit
//import MMDrawerController

class AdminApprovalViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //    var messageTxt : String
    //    var screenTitle : String
    let appDelegate: AppDelegate        = UIApplication.shared.delegate as! AppDelegate
    
    
    
    override func viewDidLoad() {
        navigationBarSettings()
        
    }
    func navigationBarSettings() -> Void {
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationItem.title = "Admin Approval"
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0) as Any, NSAttributedString.Key.foregroundColor : UIColor.init("0x363636")]
        
        var backButton: UIButton
        var leftBarBtnItem : UIBarButtonItem
        backButton = UIButton.init(type: UIButton.ButtonType.custom)
        backButton.setImage(UIImage.init(named: "back_green"), for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(backBtnOnClick), for: .touchUpInside)
        backButton.sizeToFit()
        leftBarBtnItem = UIBarButtonItem.init(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarBtnItem
        
        
        self.messageLabel.text = "Thank you for registering for iRestore. The administrator will respond to your request within 48 hours and you will be notified of the response"
        
    }
    
    @objc func backBtnOnClick() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func cancel() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func startAgain() -> Void {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: NSLocalizedString("ALERT", comment: ""), message: "Do you want to Sign Up again", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in
                    self.appDelegate.clearProfile(shouldDeleteFromServer:true)
                    }
                ))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func checkApprovalStatus() -> Void {
        
        activityIndicator.startAnimating()
        let prefs = UserDefaults.standard
        let apiClient  = V1ApiClient.init()
        apiClient.checkApprovalStatus(){
            result in
            _ = DispatchQueue.main.sync() {
                self.activityIndicator.stopAnimating()
            }
            switch result {
                case .Success(let value):
                    if let responseDict = value.data as? [String:Any] {
                        if responseDict["Error"] as! Bool {
                            let message =  responseDict["Message"] as! String
                            
                        }
                            
                            
                        else {
                            
                            if let subscriptionArray :[Any]  = responseDict["Subscription"] as? [Any]  {
                                let subscriptionObj :[String : Any] = subscriptionArray[0] as! [String : Any]
                                print(subscriptionObj)
                                let status :String   = subscriptionObj["subscriptionStatus"] as! String
                                
                                if(status == "approved" ) {
                                    prefs.set(true, forKey: Constants.IS_USER_APPROVED)
                                    _ = DispatchQueue.main.sync() {
                                        let isTermsExists  = prefs.bool(forKey: Constants.IS_TERMS_EXISTS)
                                        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                                        if(!isTermsExists) {
                                            let loginVc = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController")
                                            let nextViewController = mainStoryBoard.instantiateViewController(withIdentifier: "TermsConditionsViewController")
                                            self.navigationController?.setViewControllers([loginVc,nextViewController], animated: true)
                                        }
                                        else {
                                            
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
                                else if (status == "submitted") {
                                    
                                    DispatchQueue.main.async() {
                                        let alert = UIAlertController(title: "Alert!", message: Constants.USER_SUBMITTED_TEXT, preferredStyle: .alert)
                                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                        alert.addAction(cancelAction)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                                else if (status == "rejected"){
                                    DispatchQueue.main.async() {
                                        let alert = UIAlertController(title: "Alert!", message: Constants.USER_REJECTED_ALERT_TEXT, preferredStyle: .alert)
                                        
                                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                        
                                        alert.addAction(cancelAction)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    
                                }
                                
                            }
                            
                            
                            
                            
                        }
                }
                break
            case .Failure(let error):
                break
                
            }
            
        
        
        
    }
}

}
