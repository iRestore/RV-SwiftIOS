//
//  DataHandler.swift
//  QA Manager
//
//  Created by Greeshma Mullakkara on 25/01/18.
//  Copyright © 2018 iRestoreApp. All rights reserved.
//

import Foundation
class DataHandler {
    static let shared = DataHandler()
    var filterDisplayDict = [String : Any]()
    var filterValueDict = [String : Any]()
    private init() {
        
    }
    func saveDataToDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(filterDisplayDict, forKey: Constants.FILTER_DISPLAY_DICT)
        defaults.set(filterValueDict, forKey: Constants.FILTER_VALUE_DICT)
        defaults.synchronize()
    }
    func fetchDataFromDefaults() {
        let defaults = UserDefaults.standard
        if let dict = defaults.dictionary(forKey: Constants.FILTER_DISPLAY_DICT) as? [String : Any] {
            filterDisplayDict = dict
        }
        if let dict = defaults.dictionary(forKey: Constants.FILTER_VALUE_DICT) as? [String : Any] {
            filterValueDict = dict
        }
    }
    
    func removeFromDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "filter")
        defaults.synchronize()
    }
//    func getArrayOfDisplayValue(keyName: String) -> NSArray? {
//        if let dict  = filterDisplayDict[keyName] as? [String : Any] {
//
//            if let displayValues = dict["displayValue"] as? String {
//
//                let displayValuesArray = displayValues.components(separatedBy: ",")
//
//                return displayValuesArray as NSArray
//            }
//            else {
//                return nil
//
//            }
//        }
//        else
//        {
//            return nil
//        }
//    }
    
//    func getArrayOfFilterValue(keyName: String) -> NSArray? {
//        if let dict  = filterDict[keyName] as? [String : Any] {
//            
//            if let displayValues = dict["filterValue"] as? String {
//                
//                let displayValuesArray = displayValues.components(separatedBy: ",")
//                
//                return displayValuesArray as NSArray
//            }
//            else {
//                return nil
//                
//            }
//        }
//        else
//        {
//            return nil
//        }
//    }
}
