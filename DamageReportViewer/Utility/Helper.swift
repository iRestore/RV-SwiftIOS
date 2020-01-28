//
//  Helper.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 04/12/19.
//  Copyright © 2019 iRestoreApp. All rights reserved.
//

import Foundation
class Helper {
    static let shared = Helper()
    var filterValueDict = [String : Any]()
    var filterDisplayDict = [String:Any]()

    //This prevents others from using the default '()' initializer for this class.
    private init() {
        
        
    }
    func generateRandomNumber() -> String {
//        let currentDate : Date = Date.init()
//        let dateFormatter: DateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let dateString = dateFormatter.string(from: currentDate)
//        let phone  = UserDefaults.standard.value(forKey: Constants.PHONE_KEY) as! String
//        let deviceString  :String = "\(phone)_\(dateString)"
        let uuid = UUID().uuidString
        print(uuid)
        return uuid
    }
    //This method is to convert the json struncture in a string to dictionary
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }


    
}
