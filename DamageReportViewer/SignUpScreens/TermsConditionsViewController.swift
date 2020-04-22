//
//  TermsConditionsViewController.swift
//  YellowCard
//
//  Created by Kundan Kumar on 15/02/18.
//  Copyright © 2018 Kundan Kumar. All rights reserved.
//

import UIKit

class TermsConditionsViewController : UIViewController  {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var buttonView:UIView!
    @IBOutlet var termsTextView:UITextView!

    let appDelegate: AppDelegate        = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        navigationBarSettings()
        
    }
    
    func navigationBarSettings() -> Void {
        
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationItem.title = "Terms and Conditions"
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0) as Any, NSAttributedString.Key.foregroundColor : UIColor.init("0x363636")]
        
        var backButton: UIButton
        var leftBarBtnItem : UIBarButtonItem
        backButton = UIButton.init(type: UIButton.ButtonType.custom)
        backButton.setImage(UIImage.init(named: "back_green"), for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(backBtnOnClick), for: .touchUpInside)
        backButton.sizeToFit()
        leftBarBtnItem = UIBarButtonItem.init(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarBtnItem
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        //self.nextBtn.isEnabled = true
    }
    @objc func backBtnOnClick() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func cancel() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func next() -> Void {
        let apiClient  = V1ApiClient.init()
        apiClient.updateDeviceConfiguration(){
            result in
            switch result {
            case .Success(let value):
                     if let responseDict = value.data as? [String:Any] {
                        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)

                        if responseDict["Error"] as! Bool {
                            print("error")
                            
                        }
                        else {
                            DispatchQueue.main.async {

                            UserDefaults.standard.set(true, forKey: Constants.IS_TERMS_EXISTS)
                            print("device configuration updated successfully")
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
                    break
            case .Failure(let error):
                    print("the error \(error.errormessage)")
                }
                
        }
    }
    
    
}

