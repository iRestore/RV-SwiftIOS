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
    

}

