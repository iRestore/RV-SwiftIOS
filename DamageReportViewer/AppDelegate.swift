//
//  AppDelegate.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 04/12/19.
//  Copyright © 2019 iRestoreApp. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyD6TXyRawmCPlDPLs-RASPU2SErg3aYHpY")
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        MSAppCenter.start("a59fe333-26a5-4ae0-8eda-a4294075690d", withServices:[ MSAnalytics.self, MSCrashes.self ])
        if #available(iOS 13.0, *) {

            UIApplication.shared.registerForRemoteNotifications()
            UNUserNotificationCenter.current().delegate = self
            
        }
        else {
            let window = UIWindow(frame: UIScreen.main.bounds)
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
            else if(isOTPRequired == true ){
                    guard let SignUp = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return false }
                        guard let otp = mainStoryBoard.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController else { return  false}
                        let centerNav = UINavigationController(rootViewController: SignUp)
                        window.rootViewController = centerNav
                        centerNav.setViewControllers([SignUp,otp], animated: true)
                }
            else if(isSubscriptionExists == false){
                guard let SignUp = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return false }
                guard let otp = mainStoryBoard.instantiateViewController(withIdentifier: "CreateProfileViewController") as? CreateProfileViewController else { return false }
                let centerNav = UINavigationController(rootViewController: SignUp)
                window.rootViewController = centerNav
                centerNav.setViewControllers([SignUp,otp], animated: true)
            }
            else if(isUserApproved == false){
                guard let SignUp = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return false }
                guard let otp = mainStoryBoard.instantiateViewController(withIdentifier: "AdminApprovalViewController") as? AdminApprovalViewController else { return false }
                let centerNav = UINavigationController(rootViewController: SignUp)
                window.rootViewController = centerNav
                centerNav.setViewControllers([SignUp,otp], animated: true)
            }
            else if(isTermsExists == false){
                guard let SignUp = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return false }
                guard let otp = mainStoryBoard.instantiateViewController(withIdentifier: "TermsConditionsViewController") as? TermsConditionsViewController else { return false }
                let centerNav = UINavigationController(rootViewController: SignUp)
                window.rootViewController = centerNav
                centerNav.setViewControllers([SignUp,otp], animated: true)
            }
            else {
                if let tabbar = mainStoryBoard.instantiateViewController(withIdentifier: "TabbarController") as? TabbarController {
                    window.rootViewController = tabbar
                    
//                    for vc in tabbar.viewControllers! {
//                        if vc is UINavigationController {
//                            if let navController = vc as? UINavigationController {
//                                for _vc in navController.viewControllers {
//                                             guard let _detailsController = mainStoryBoard.instantiateViewController(withIdentifier: "VDADetailsViewController") as? VDADetailsViewController else { return true }
//
//                                    _vc.navigationController?.pushViewController(_detailsController,
//                                                                                 animated: true)
//                                    break
//
//                                }
//                            }
//
//                        }
//                    }
                    
                    
                    
                }
            }
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("D'oh: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {

                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
            self.window = window
            window.makeKeyAndVisible()
            
        }
        
        // Override point for customization after application launch.
        return true
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 13.0, *) {


        }
        else {
                    self.doSync()
            
        }
    }
    func  clearProfile(shouldDeleteFromServer:Bool) {
        
        if shouldDeleteFromServer == true {
            let v1APi =  V1ApiClient .init()
            v1APi.deleteProfile() {
                result in
                _ = DispatchQueue.main.sync() {
                }
                print(result)
                switch result {
                    
                case .Success(let value):
                    print("success")
                    break
                case .Failure(let error):
                    print("error")

                    break
            
                }
            }
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let signUp = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            let centerNav = UINavigationController(rootViewController: signUp)
            if #available(iOS 13.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first  {
                    if let windowScene = scene as? UIWindowScene {
                        let _window = UIWindow(windowScene: windowScene)
                        //_window.rootViewController = centerNav
                        UIApplication.shared.windows.first!.rootViewController = centerNav
                        _window.makeKeyAndVisible()
                       // scene.window

                    }
                }
             }
            else {
                 window?.rootViewController = centerNav

             }
            
        }

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
    
    
    func  doSync()
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
                        print(responseDict)
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
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceToken = deviceToken.map {String(format:"%02.2hhx",$0)}.joined()
        print(deviceToken)
        UserDefaults.standard.set(deviceToken, forKey: Constants.pushNotificationKey)

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
        
        if let userInfoDict = userInfo as? NSDictionary  {
            if  let reportId = userInfoDict.value(forKey: "reportId") as? String {
            let apiClient  = V2ApiClient.init()
            apiClient.getDetails(reportId:reportId){
            result in
        
            switch result {
                    case .Success(let value):
                        if let responseDict = value.data {
                            print(responseDict)
                            let reportData = ReportData.init(data: responseDict)
                            reportData?.damageTypeDisplayName = MainViewController.damageTypeSubTypeDisplayNamesDict[reportData?.damageType ?? ""] ?? ""
                            
                            reportData?.damageSubTypeDisplayName = MainViewController.damageTypeSubTypeDisplayNamesDict[reportData?.damageSubType ?? ""] ?? ""
                            
                            DispatchQueue.main.async {
                                let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                            guard let tabbar = mainStoryBoard.instantiateViewController(withIdentifier: "TabbarController") as? TabbarController else { return }
                                if reportData?.reportType == "SDA" {
                                    guard let _detailsController = mainStoryBoard.instantiateViewController(withIdentifier: "VDADetailsViewController") as? VDADetailsViewController else { return }
                                    _detailsController.reportData = reportData
                                    if #available(iOS 13.0, *) {
                                        if let scene = UIApplication.shared.connectedScenes.first  {
                                            if let windowScene = scene as? UIWindowScene {
                                                let _window = UIWindow(windowScene: windowScene)
                                                UIApplication.shared.windows.first!.rootViewController = tabbar
                                                _window.makeKeyAndVisible()
                                               // scene.window

                                            }
                                        }
                                     }
                                    else {
                                        self.window?.rootViewController = tabbar

                                     }
                                    for vc in tabbar.viewControllers! {
                                        if vc is UINavigationController {
                                            if let navController = vc as? UINavigationController {
                                                for _vc in navController.viewControllers {
                                                   _vc.navigationController?.pushViewController(_detailsController,
                                                                                                 animated: true)
                                                     return

                                                }
                                            }

                                        }
                                    }
                                }
                                else {
                                    guard let _detailsController = mainStoryBoard.instantiateViewController(withIdentifier: "FRDetailsViewController") as? FRDetailsViewController else { return  }
                                    _detailsController.reportData = reportData
                                    if #available(iOS 13.0, *) {
                                        if let scene = UIApplication.shared.connectedScenes.first  {
                                            if let windowScene = scene as? UIWindowScene {
                                                let _window = UIWindow(windowScene: windowScene)
                                                UIApplication.shared.windows.first!.rootViewController = tabbar
                                                _window.makeKeyAndVisible()
                                               // scene.window

                                            }
                                        }
                                     }
                                    else {
                                        self.window?.rootViewController = tabbar

                                     }
                                    for vc in tabbar.viewControllers! {
                                        if vc is UINavigationController {
                                            if let navController = vc as? UINavigationController {
                                                for _vc in navController.viewControllers {
                                                   _vc.navigationController?.pushViewController(_detailsController,
                                                                                                 animated: true)
                                                     return

                                                }
                                            }

                                        }
                                    }
                                    
                                    
                                }


                                
                                
                            }
                            

                        }
                    case .Failure(let error):
                            DispatchQueue.main.async {
                                    
                            }
                                             
                            default:
                                    print("hi")
                            }
            
        }
    }
        
        }

}

    
    func  userNotificationCenter(_ center:UNUserNotificationCenter, willPresent notification:UNNotification,withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("hi")
        completionHandler([.alert,.sound])
    }
    
    
    func  userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
        if #available(iOS 13.0, *) {

        if let userInfoDict = response.notification.request.content.userInfo as? NSDictionary {
                    if  let reportId = userInfoDict.value(forKey: "reportId") as? String {
                    let apiClient  = V2ApiClient.init()
                    apiClient.getDetails(reportId:reportId){
                    result in
                
                    switch result {
                            case .Success(let value):
                                if let responseDict = value.data {
                                    print(responseDict)
                                    let reportData = ReportData.init(data: responseDict)
                                    reportData?.damageTypeDisplayName = MainViewController.damageTypeSubTypeDisplayNamesDict[reportData?.damageType ?? ""] ?? ""
                                    
                                    reportData?.damageSubTypeDisplayName = MainViewController.damageTypeSubTypeDisplayNamesDict[reportData?.damageSubType ?? ""] ?? ""
                                    
                                    DispatchQueue.main.async {
                                        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                                    guard let tabbar = mainStoryBoard.instantiateViewController(withIdentifier: "TabbarController") as? TabbarController else { return }
                                        if reportData?.reportType == "SDA" {
                                            guard let _detailsController = mainStoryBoard.instantiateViewController(withIdentifier: "VDADetailsViewController") as? VDADetailsViewController else { return }
                                            _detailsController.reportData = reportData
                                            if #available(iOS 13.0, *) {
                                                if let scene = UIApplication.shared.connectedScenes.first  {
                                                    if let windowScene = scene as? UIWindowScene {
                                                        let _window = UIWindow(windowScene: windowScene)
                                                        UIApplication.shared.windows.first!.rootViewController = tabbar
                                                        _window.makeKeyAndVisible()
                                                       // scene.window

                                                    }
                                                }
                                             }
                                            else {
                                                self.window?.rootViewController = tabbar

                                             }
                                            for vc in tabbar.viewControllers! {
                                                if vc is UINavigationController {
                                                    if let navController = vc as? UINavigationController {
                                                        for _vc in navController.viewControllers {
                                                           _vc.navigationController?.pushViewController(_detailsController,
                                                                                                         animated: true)
                                                             return

                                                        }
                                                    }

                                                }
                                            }
                                        }
                                        else {
                                            guard let _detailsController = mainStoryBoard.instantiateViewController(withIdentifier: "FRDetailsViewController") as? FRDetailsViewController else { return  }
                                            _detailsController.reportData = reportData
                                            if #available(iOS 13.0, *) {
                                                if let scene = UIApplication.shared.connectedScenes.first  {
                                                    if let windowScene = scene as? UIWindowScene {
                                                        let _window = UIWindow(windowScene: windowScene)
                                                        UIApplication.shared.windows.first!.rootViewController = tabbar
                                                        _window.makeKeyAndVisible()
                                                       // scene.window

                                                    }
                                                }
                                             }
                                            else {
                                                self.window?.rootViewController = tabbar

                                             }
                                            for vc in tabbar.viewControllers! {
                                                if vc is UINavigationController {
                                                    if let navController = vc as? UINavigationController {
                                                        for _vc in navController.viewControllers {
                                                           _vc.navigationController?.pushViewController(_detailsController,
                                                                                                         animated: true)
                                                             return

                                                        }
                                                    }

                                                }
                                            }
                                            
                                            
                                        }


                                        
                                        
                                    }
                                    

                                }
                            case .Failure(let error):
                                    DispatchQueue.main.async {
                                            
                                    }
                                                     
                                    default:
                                            print("hi")
                                    }
                    
                }
            }
                
                }
      
        }
    }
        

    

}
