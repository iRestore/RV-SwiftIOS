//
//  Environment.swift
//  QA Manager
//
//  Created by Kundan Kumar on 19/03/19.
//  Copyright © 2019 iRestoreApp. All rights reserved.
//

import Foundation

public enum PlistKey {
    case V1API
    case V2API
    func value() -> String {
        switch self {
        case .V1API:
            return "V1_API"
        case .V2API:
            return "V2_API"
        
        }
    }
}
public struct Environment {
    
    fileprivate var infoDict: [String: Any]  {
        get {
            if let dict = Bundle.main.infoDictionary {
                print(dict)
                return dict
            }else {
                fatalError("Plist file not found")
            }
        }
    }
    public func configuration(_ key: PlistKey) -> String {
        switch key {
        case .V1API:
            return infoDict[PlistKey.V1API.value()] as! String
        case .V2API:
            return infoDict[PlistKey.V2API.value()] as! String

        }
    }
}
