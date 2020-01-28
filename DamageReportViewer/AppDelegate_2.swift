//
//  AppDelegate.swift
//  Inspection
//
//  Created by Greeshma Mullakkara on 07/08/17.
//  Copyright © 2017 iRestoreApp. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import AddressBookUI
import AWSS3
import Fabric
import Crashlytics
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

#if DEV
let CONFIG_KEY = "configKeyForDEV"
#elseif QA
let CONFIG_KEY = "configKeyForQA"
#elseif BETA
let CONFIG_KEY = "configKeyForBETA"
#else
let CONFIG_KEY = "configForPRO"
#endif


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentAddress: String?
    var navigationController: UINavigationController?
//    var firebaseDBref:DatabaseReference?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
         FirebaseApp.configure()
//        //For iOS - Swift
//        if var firebaseDB = UserDefaults.standard.value(forKey: Constants.API.FIREBAE_DB)as? String
//        {
////            firebaseDB = UserDefaults.standard.value(forKey: "Constants.API.FIREBAE_DB") as! String//"irestore-inspections-app-test"
//            let dbURL = "https://\(firebaseDB).firebaseio.com/"
//            Database.database(url:dbURL).isPersistenceEnabled = true
//            self.firebaseDBref =  Database.database(url:dbURL).reference()
//
//        }
//        Fabric.with([Crashlytics.self])
//        MSAppCenter.start("873df4ae-25f5-4aeb-8202-e9022eda8cca", withServices:[
//            MSAnalytics.self,
//            MSCrashes.self
//            ])

        locationManager.delegate = self
        if (locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        syncUser()
        
        //let navigationController = window?.rootViewController as! UINavigationController?
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController")
        let  navigationController  = UINavigationController(rootViewController: viewController)
        window!.rootViewController = navigationController
        window!.rootViewController = navigationController
        window?.makeKeyAndVisible()
        

        
        /*let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)

        let isSignUpDone =  UserDefaults.standard.value(forKey:Constants.IS_SIGN_COMPLETED )
        if((isSignUpDone) != nil) {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            if let viewController = mainStoryBoard.instantiateViewController(withIdentifier: "TabbarController") as? TabbarController {
                navigationController?.setViewControllers([viewController], animated: true)
            }


        }
        else {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController")
            navigationController?.setViewControllers([viewController], animated: true)
        }
*/
        return true
    }

    
    
//    func clearProfile(deleteFromServer:Bool) {
//
//        if(deleteFromServer){
//            deleteProfileFromServer()
//        }
//
//        let appDomain :String = (Bundle.main.bundleIdentifier as? String)!
//        UserDefaults.standard.removePersistentDomain(forName:appDomain )
//        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//        let loginVc = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
//        navigationController?.setViewControllers([loginVc!], animated: true)
//        loginVc?.resetDefaults()
//        //[signUp resetDefaults];
//    }
    
    
//    func  deleteProfileFromServer() {
//
//
//
//        let prefs:UserDefaults = UserDefaults.standard
//        let subscriptionUrlString :String = Constants.SERVER_ADRESS + Constants.API.ADMIN_APPROVAL_API
//        let serverParam1Value = Environment().configuration(PlistKey.ServerParamValue)
//        var newSignUPString = subscriptionUrlString.replacingOccurrences(of: Constants.API.serverParamKEY, with: serverParam1Value)
//
//        let phoneNumber = prefs.value(forKey: "phoneKey") as! String
//        let email = prefs.value(forKey: "emailKey") as! String
//
//        newSignUPString = newSignUPString.appendingFormat("email=%@&phone=%@",email,phoneNumber)
//        newSignUPString = newSignUPString.appendingFormat("&application=%@",Constants.API.applicationKey)
//        let url = URL(string: newSignUPString)!
//        let request = NSMutableURLRequest(url: url)
//        let accessToken : String  = prefs.value(forKey: Constants.API.accessToken) as! String
//        let accountKey : String = prefs.value(forKey: Constants.API.accountKey) as! String
//
//        request.setValue(accessToken , forHTTPHeaderField: "x-access-token")
//        request.setValue(accountKey, forHTTPHeaderField: "x-account-key")
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "DELETE"
//        request.setValue(Constants.API.applicationKey, forHTTPHeaderField: "x-application")
//        request.setValue("0", forHTTPHeaderField: "x-user")
//        let config = URLSessionConfiguration.default//()
//        let session = URLSession(configuration: config)
//        let task = session.dataTask(with: request as URLRequest) {
//
//            (data ,response , error) in
//
//
//            guard error == nil else {
//                print("Error calling GET")
//                return
//            }
//            guard let responseData = data else {
//
//                print("Error: did not receive data")
//                return
//            }
//
//            do {
//
//                let obj:[String:Any] = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String:Any]
//
//                if obj["Error"] as! Bool {
//
//                    let message =  obj["Message"] as! String
//                    self.displayAlert(message: message, isActionRequired: true)
//
//                }
//
//            }
//            catch {
//                // print("Error: (data: contentsOf: url)")
//                print("Error in Serializing objects" + error.localizedDescription)
//            }
//
//        }
//        task.resume()
//
//
//    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        // Store the completion handler.
        AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        syncUser()

        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func displayAlert(message:String,isActionRequired:Bool) {
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
            if(isActionRequired) {
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            }
            self.window?.makeKeyAndVisible()
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

extension  AppDelegate : CLLocationManagerDelegate {
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        currentLocation = locations.last
        
//        var locObj = [String: Any]()
//        locObj["type"] = "Point"
//        locObj["coordinates"] = [Double((self.currentLocation?.coordinate.longitude)!),Double((self.currentLocation?.coordinate.latitude)!)]
//        DataHandler.sharedInstance.damageReportDict["loc"] = locObj
        
        CLGeocoder().reverseGeocodeLocation(currentLocation!, completionHandler: {(placemarks, error) -> Void in
            //            print(self.currentLocation!)
            
            if error != nil {
                // print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            /*
            if (placemarks?.count)! > 0 {
                
                let pm = (placemarks?[0])! as CLPlacemark
                

                if let lines = pm.addressDictionary?["FormattedAddressLines"] as? [String] {
                    self.currentAddress = lines.joined(separator: ", ")
                }
                let addressObj = ["userAddress": self.currentAddress, "resolvedAddress": self.currentAddress]
                DataHandler.sharedInstance.damageReportDict["address"] = addressObj
                if let street = pm.thoroughfare {
                    DataHandler.sharedInstance.street = street
                }
                if let city = pm.locality  {
                    DataHandler.sharedInstance.city = city
                }
                if let state = pm.administrativeArea {
                    DataHandler.sharedInstance.state = state
                }
                
                if let country = pm.country {
                    DataHandler.sharedInstance.state = country
                }
                if let postalCode = pm.postalCode {
                    DataHandler.sharedInstance.zip = postalCode

                }
            }
            else {
                // print("Problem with the data received from geocoder")
            }
 */
        })
    }
    
    func checkLocationServices() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                displayAlert(message: "Please enable location services on your device for iRestore Inspection",isActionRequired: true)
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            displayAlert(message: "Please enable location services on your device",isActionRequired: true)
            return false
        }
    }
    
    func syncUser() -> Void {
        
        
        let prefs:UserDefaults              = UserDefaults.standard
        
        let isSignUpDone =  prefs.bool(forKey: Constants.IS_SIGN_COMPLETED )
        if(!isSignUpDone) {
            return
        }
        
        
        let apiClient  = V1ApiClient.init()
        apiClient.syncAPI(){
            result in
            
            switch result {
            case .Success(let value):
                if let obj = value.data as? [String:Any] {
                    if obj["Error"] as! Bool {
                        
                    }
                    else {
                        
                        let isUserExists   = obj["User"] != nil
                        var userObj = [String :Any]()
                        if(isUserExists) {
                            let userArray = obj["User"] as? [[String:Any]]
                            if(userArray != nil && userArray?.count ?? 0 > 0) {
                                if let userDict = userArray?.first  {
                                    self.saveUserData(userDict:userDict)
                                    
                                }
                                
                            }
                        }
                        if let subscriptionArray :[Any]  = obj["Subscription"] as? [Any]  {
                            let subscriptionObj :[String : Any] = subscriptionArray[0] as! [String : Any]
                            print(subscriptionObj)
                            let status :String   = subscriptionObj["subscriptionStatus"] as! String
                            if(status == "approved" ) {
                                
                                
                                let existingDeviceString : String = subscriptionObj["deviceString"] as! String
                                let existingPushNotification : String = subscriptionObj["pushNotificationToken"] as! String
                                let existingDeviceType : String = subscriptionObj["deviceType"] as! String
                                let existingDeviceOS  : String = subscriptionObj["deviceOs"] as! String
                                let existingDeviceModel: String = subscriptionObj["deviceModel"] as! String
                                let existingDeviceMake: String = subscriptionObj["deviceMake"] as! String
                                
                                let currentDeviceOS : String = UIDevice.current.systemVersion
                                let currentDeviceType  :String = UIDevice.current.systemName
                                let currentDeviceMake  :String = "Apple"
                                let currentDeviceModel  :String = UIDevice.current.model
                                let currentDeviceString  : String = prefs.object(forKey: "RandomNumber") as! String
                                var currentPushNotification  : String = ""
                                if currentDeviceString != existingDeviceString {
                                    self.displayAlert(message: Constants.USER_DEVICE_STRING_MISMATCH_TEXT, isActionRequired: false)
                                    return
                                }
                                else if (existingPushNotification != currentPushNotification || existingDeviceType != currentDeviceType || existingDeviceOS != currentDeviceOS || existingDeviceModel != currentDeviceModel ||   existingDeviceMake != currentDeviceMake ) {
                                    
                                    self.updateDeviceConfigurations()
                                    
                                }
                                
                                
                                
                                
                                
                            }
                            else if (status == "revoked") {
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: "Alert", message: Constants.USER_REVOKED_ALERT_TEXT, preferredStyle: UIAlertController.Style.alert)
                                    self.window?.makeKeyAndVisible()
                                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                                }
                                
                            }
                            else if (status == "rejected"){
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: "Alert", message: Constants.USER_REJECTED_ALERT_TEXT, preferredStyle: UIAlertController.Style.alert)
                                    self.window?.makeKeyAndVisible()
                                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                                    
                                    return;
                                }
                            }
                            
                        }
                        else {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Alert", message: Constants.USER_SUBSCRIPTION_DOESNOT_EXISTS_ALERT_TEXT, preferredStyle: UIAlertController.Style.alert)
                                self.window?.makeKeyAndVisible()
                                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                                return;
                            }
                        }
                        
                        //Reading & Saving the Tenant Data
                        let isTenantDataExists   = obj["Owners"] != nil
                        if(isTenantDataExists) {
                            if let _tenantObjArray   = Helper.shared.nullToNil(value: obj["Owners"] as AnyObject ){
                                let tenantObjArray:[Any] =  _tenantObjArray as! [Any]
                                if(tenantObjArray.count > 0) {
                                    let tenantObj = tenantObjArray.first as! [String : Any]
                                    prefs.set(tenantObj["token"], forKey: Constants.accessToken)
                                    prefs.set(tenantObj["accountKey"], forKey: Constants.accountKey)
                                    
                                    var configurationObj = [String :Any]()
                                    if let _configurationObj =  Helper.shared.convertToDictionary(text: tenantObj["configuration"] as! String) {
                                        configurationObj = _configurationObj
                                        
                                        
                                        let s3BucketName :String = configurationObj["s3Bucket"] as! String
                                        prefs.set(s3BucketName,forKey: Constants.BUCKET_NAME)
                                        let firebaseDB :String = configurationObj["firebaseDb"] as! String
                                        prefs.set(firebaseDB,forKey:Constants.FIREBAE_DB)
                                    }
                                    
                                }
                                
                            }
                        }
                        
                        
                        
                    }
                    
                }
                break
                
            case .Failure(let _):
                break
                
                
            }
            
            
            
            
            
            
        }
    }
    func updateDeviceConfigurations()   {
        
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
}
