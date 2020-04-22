//
//  SceneDelegate.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 04/12/19.
//  Copyright © 2019 iRestoreApp. All rights reserved.
//

import UIKit
@available(iOS 13.0, *)

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            
            let defaults =  UserDefaults.standard


            let email = defaults.value(forKey: Constants.EMAIL_KEY)
            let phone = defaults.value(forKey: Constants.PHONE_KEY)
            let isOTPRequired = defaults.bool(forKey: Constants.IS_OTP_REQUIRED)
            let isSubscriptionExists = defaults.bool(forKey: Constants.IS_SUBSCRIPTION_EXISTS)
            let isUserApproved = defaults.bool(forKey: Constants.IS_USER_APPROVED)
            let isTermsExists = defaults.bool(forKey: Constants.IS_USER_APPROVED)
            
            if(email == nil ||  phone == nil){
                if let SignUp = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
                    let centerNav = UINavigationController(rootViewController: SignUp)
                    window.rootViewController = centerNav
                }
            }
            else if(isOTPRequired == true){
                guard let SignUp = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return  }
                    guard let otp = mainStoryBoard.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController else { return  }
                    let centerNav = UINavigationController(rootViewController: SignUp)
                    window.rootViewController = centerNav
                    centerNav.setViewControllers([SignUp,otp], animated: true)
            }
            else if(isSubscriptionExists == false){
                guard let SignUp = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return  }
                guard let otp = mainStoryBoard.instantiateViewController(withIdentifier: "CreateProfileViewController") as? CreateProfileViewController else { return  }
                let centerNav = UINavigationController(rootViewController: SignUp)
                window.rootViewController = centerNav
                centerNav.setViewControllers([SignUp,otp], animated: true)
            }
            else if(isUserApproved == false){
                guard let SignUp = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return  }
                guard let otp = mainStoryBoard.instantiateViewController(withIdentifier: "AdminApprovalViewController") as? AdminApprovalViewController else { return  }
                let centerNav = UINavigationController(rootViewController: SignUp)
                window.rootViewController = centerNav
                centerNav.setViewControllers([SignUp,otp], animated: true)
            }
            else if(isTermsExists == false){
                guard let SignUp = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return  }
                guard let otp = mainStoryBoard.instantiateViewController(withIdentifier: "TermsConditionsViewController") as? TermsConditionsViewController else { return  }
                let centerNav = UINavigationController(rootViewController: SignUp)
                window.rootViewController = centerNav
                centerNav.setViewControllers([SignUp,otp], animated: true)
            }
            else {
                if let tabbar = mainStoryBoard.instantiateViewController(withIdentifier: "TabbarController") as? TabbarController {
                    //let centerNav = UINavigationController(rootViewController: SignUp)
                    window.rootViewController = tabbar
                }
            }
            

            self.window = window
            window.makeKeyAndVisible()
        }
//        if #available(iOS 10.0, *) {
//                  // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = self as! UNUserNotificationCenterDelegate
//                  let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//                  UNUserNotificationCenter.current().requestAuthorization(
//                      options: authOptions,
//                      completionHandler: {_, _ in })
//                  // For iOS 10 data message (sent via FCM)
//                  Messaging.messaging().delegate = self
//              } else {
//                  let settings: UIUserNotificationSettings =
//                      UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//                  UIApplication.shared.registerUserNotificationSettings(settings)
//              }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {

                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        //scene.makeKeyAndVisible()
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        doSync()
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func displayAlert(message:String,isActionRequired:Bool) {
        DispatchQueue.main.async {

            let alert = UIAlertController(title: NSLocalizedString("ALERT", comment: ""), message: message, preferredStyle: UIAlertController.Style.alert)
        if(isActionRequired) {
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        }
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    func  clearProfile(shouldDeleteFromServer:Bool) {
        let v1APi =  V1ApiClient .init()
        v1APi.deleteProfile() {
            result in
            _ = DispatchQueue.main.sync() {
            }
            print(result)
            switch result {
                
            case .Success(let value):
                print("success \(value)")
                break
            case .Failure(let error):
                print("error \(error)")

                break
        
            }
        }
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let signUp = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            let centerNav = UINavigationController(rootViewController: signUp)
            window?.rootViewController = centerNav
        }

    }
    func doSync()
    {
                
                let isSignUpDone =  UserDefaults.standard.bool(forKey: Constants.IS_SIGN_COMPLETED)
                if isSignUpDone ==  false {
                    return
                }

            let apiClient  = V1ApiClient.init()
            apiClient.syncAPI{
                result in
                _ = DispatchQueue.main.sync() {
                }
                print(result)
                switch result {
                case .Success(let value):
                         if let responseDict = value.data {
                            if responseDict["Error"] as! Bool {
                                
                                let message =  responseDict["Message"] as! String
                                self.displayAlert(message: message, isActionRequired: false)
                                
                            }
                            else {
                                //Reading & Saving the Tenant Data
                                let isTenantDataExists   = responseDict["Owners"] != nil
                                if(isTenantDataExists) {
                                    if let _tenantObjArray   = Helper.shared.nullToNil(value: responseDict["Owners"] as AnyObject ){
                                        let tenantObjArray:[Any] =  _tenantObjArray as! [Any]
                                        if(tenantObjArray.count > 0) {
                                            let tenantObj = tenantObjArray.first as! [String : Any]
                                            UserDefaults.standard.set(tenantObj["token"], forKey: Constants.accessToken)
                                            UserDefaults.standard.set(tenantObj["accountKey"], forKey: Constants.accountKey)

                                            var configurationObj = [String :Any]()
                                            if let _configurationObj =  Helper.shared.convertToDictionary(text: tenantObj["configuration"] as! String) {
                                                configurationObj = _configurationObj
                                                
                                                
                                                let s3BucketName :String = configurationObj["s3Bucket"] as! String
                                                UserDefaults.standard.set(s3BucketName,forKey: Constants.BUCKET_NAME)
                                                
                                                let profileBucketName :String = configurationObj["profilePicBucket"] as! String
                                                UserDefaults.standard.set(profileBucketName,forKey: Constants.PROFILE_BUCKET_NAME)
                                           
                                                if let config  = configurationObj["viewConfig"] as? [String:Any] {
                                                UserDefaults.standard.set(config,forKey: Constants.DEFAULTS_TENANT_CONFIG)

                                            }
                                                
                                                
                                                let firebaseDB :String = configurationObj["firestoreCollection"] as! String
                                                UserDefaults.standard.set(firebaseDB,forKey:Constants.FIREBAE_DB)
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                    
    //                            if let appVersion   = responseDict["AppVersion"] as? NSArray {
    //
    //                                if  let appVersionObj = appVersion.firstObject as? [String : Any ]{
    //
    //                                    let appVersionLocal : String  = Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString" ) as! String
    //
    //                                    let appiTunesVersion  = appVersionObj["version"] as! String
    //
    //                                    let forceUpgrade : Int = appVersionObj["forceUpgrade"] as! Int
    //                                    if(forceUpgrade == 1 ) && (appVersionLocal < appiTunesVersion) {
    //                                        DispatchQueue.main.async() {
    //                                            let alert = UIAlertController(title: "Update Available", message: String(format: "A new version of Damage Report Viewer is available. Please update to version %@ now.", appiTunesVersion), preferredStyle: UIAlertController.Style.alert)
    //                                            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { action in
    //                                                if let url = URL(string: "itms-apps://itunes.apple.com/"),
    //                                                    UIApplication.shared.canOpenURL(url){
    //                                                    if #available(iOS 10.0, *) {
    //                                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    //                                                    } else {
    //                                                        UIApplication.shared.openURL(url)
    //                                                    }
    //                                                }
    //                                            }))
    //                                            self.window?.makeKeyAndVisible()
    //                                            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    //                                        }
    //                                    }
    //                                }
    //                            }
                                
                                    if let subscriptions   = responseDict["Subscription"] as? NSArray {

                                    if  let subscriptObj = subscriptions.firstObject as? [String : Any ]{
                                        
                                        let userStatus : String = subscriptObj["subscriptionStatus"] as! String
                                        if(userStatus == "approved" ) {
                                            
                                            let existingDeviceString : String = subscriptObj["deviceString"] as! String
                                            let existingPushNotification : String = subscriptObj["pushNotificationToken"] as! String
                                            let existingDeviceType : String = subscriptObj["deviceType"] as! String
                                            let existingDeviceOS  : String = subscriptObj["deviceOs"] as! String
                                            let existingDeviceModel: String = subscriptObj["deviceModel"] as! String
                                            let existingDeviceMake: String = subscriptObj["deviceMake"] as! String
                                            
                                            let currentDeviceOS : String = UIDevice.current.systemVersion
                                            let currentDeviceType  :String = UIDevice.current.systemName
                                            let currentDeviceMake  :String = "Apple"
                                            let currentDeviceModel  :String = UIDevice.current.model
                                            let currentDeviceString  : String = UserDefaults.standard.object(forKey: "RandomNumber") as! String
                                            var currentPushNotification  : String = ""
                                            if let pushNot = UserDefaults.standard.object(forKey: Constants.pushNotificationKey) as? String {
                                                currentPushNotification = pushNot
                                            }
                                            if currentDeviceString != existingDeviceString {
                                                self.displayAlert(message: Constants.USER_DEVICE_STRING_MISMATCH_TEXT, isActionRequired: false)
                                                return
                                            }
                                            else if (existingPushNotification != currentPushNotification || existingDeviceType != currentDeviceType || existingDeviceOS != currentDeviceOS || existingDeviceModel != currentDeviceModel ||   existingDeviceMake != currentDeviceMake ) {
                                                apiClient.updateDeviceConfiguration(){
                                                    result in
                                                    switch result {
                                                    case .Success(let value):  break
                                                        case .Failure(let error):
                                                                                      print("the error \(error.errormessage)")
                                                
                                                    }
                                            //}
                                        }
                                         }
                        
                                        
                                        
                                    }
                                    else if (userStatus == "revoked") {
                                                                let alert = UIAlertController(title: "Alert", message: Constants.USER_REVOKED_ALERT_TEXT, preferredStyle: UIAlertController.Style.alert)
                                                            self.window?.makeKeyAndVisible()
                                                            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                                                            
                                                        }
                                                        else if (userStatus == "rejected"){
                                                            let alert = UIAlertController(title: "Alert", message: Constants.USER_REJECTED_ALERT_TEXT, preferredStyle: UIAlertController.Style.alert)
                                                            self.window?.makeKeyAndVisible()
                                                            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                                                            
                                                            return;
                                                        }
                                        else {
                                                    let alert = UIAlertController(title: "Alert", message: Constants.USER_SUBSCRIPTION_DOESNOT_EXISTS_ALERT_TEXT, preferredStyle: UIAlertController.Style.alert)
                                            self.window?.makeKeyAndVisible()
                                            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                                            return;
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

