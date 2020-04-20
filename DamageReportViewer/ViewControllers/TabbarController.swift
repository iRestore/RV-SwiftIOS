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
        let arrayOfImageNameForSelectedState = ["listView_Selected_Icon", "mapView_Selected_Icon"]
        let arrayOfImageNameForUnselectedState = ["listView_Icon", "mapView_Icon"]
        
        if let count = self.tabBar.items?.count {
            for i in 0...(count-1) {
                
                let imageNameForSelectedState   = arrayOfImageNameForSelectedState[i]
                let imageNameForUnselectedState = arrayOfImageNameForUnselectedState[i]
                
                self.tabBar.items?[i].selectedImage = UIImage(named: imageNameForSelectedState)?.withRenderingMode(.alwaysOriginal)
                self.tabBar.items?[i].image = UIImage(named: imageNameForUnselectedState)?.withRenderingMode(.alwaysOriginal)
            }
        }
        //0xd5d5d5
        let unselectedColor = UIColor.init("0x666666")
        let selectedColor  =  UIColor.init("0x666666")
//
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: unselectedColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor], for: .selected)
    }
    
    
}
