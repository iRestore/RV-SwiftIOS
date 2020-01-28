//
//  TabbarController.swift
//  Crew Mobilizer
//
//  Created by Greeshma Mullakkara on 28/12/19.
//  Copyright © iRestoreApps. All rights reserved.
//

import UIKit
class TabbarController: UITabBarController {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
       setTabbarItemImages()
    }

    func setTabbarItemImages() {
//        let arrayOfImageNameForSelectedState = ["lid", "activeAvailabilityCheck","activeProfile", "activeNotifications"]
        let arrayOfImageNameForUnselectedState = ["listView", "mapView"]
        
        if let count = self.tabBar.items?.count {
            for i in 0...(count-1) {
                
//                let imageNameForSelectedState   = arrayOfImageNameForSelectedState[i]
                let imageNameForUnselectedState = arrayOfImageNameForUnselectedState[i]
                
//                self.tabBar.items?[i].selectedImage = UIImage(named: imageNameForSelectedState)?.withRenderingMode(.alwaysOriginal)
                self.tabBar.items?[i].image = UIImage(named: imageNameForUnselectedState)?.withRenderingMode(.alwaysOriginal)
            }
        }
        
//        let unselectedColor = UIColor.init(hexColor: "0xd5d5d5")
//        let selectedColor  = UIColor.init(hexColor: "0x26A69A")
//
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: unselectedColor], for: .normal)
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: selectedColor], for: .selected)
    }
    
    
}
