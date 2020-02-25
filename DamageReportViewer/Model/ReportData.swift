//
//  ReportData.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 08/01/20.
//  Copyright © 2020 iRestoreApp. All rights reserved.
//

import Foundation
class ReportData {
    var name: String?
    var emil: String?
    var phone: String?
    var timeStamp: String?
    var damageType: String?
    var damageSubType: String?
    var damageTypeDisplayName: String?
    var damageSubTypeDisplayName: String?
    var userAddress: String?
    var resolvedAddress: String?
    var city: String?
    var stateShortName: String?
    var zipcode: String?
    var roadBlockedStatus: String?
    var safeStatus: String?
    var wireGuardStandBy: String?
    var img1URL: String?
    var img2URL: String?
    var thumbnail1Path: String?
    var thumbnail2Path: String?
    var poleNumber: String?
    var poleHeight: String?
    var feederLines: String?
    var comments: String?
    var reportDetailURL: String?
    var reportType: String?
    var dateCreated: String?
    var feederLine1: String?
    var feederLine2: String?
    var imageCount: Int = 0
    var latitude:Double? = 0.0
    var longitude:Double? = 0.0
    var columnValues = [String]()
    var partData = [Any]()
    var tagArray = [String]()


    
    init?(data: [String: Any]) {
        print(data)
        
        self.timeStamp = data["displayTimestamp"] as? String
        self.dateCreated = data["dateCreated"] as? String
        self.damageType = data["damageType"] as? String
        self.damageSubType = data["damagedParts"] as? String
        self.reportType = data["reportType"] as? String
        self.reportDetailURL = data["reportLink"] as? String 
        
        if let submittedBy = data["submittedBy"] as? [String:Any] {
             self.name = submittedBy["name"] as? String
             self.emil = submittedBy["email"] as? String
             self.phone = submittedBy["phone"] as? String
        }
        if let address = data["address"] as? [String:Any] {
            self.userAddress = address["userAddress"] as? String
            self.resolvedAddress = address["resolvedAddress"] as? String
            if ((address["city"] as? String) == ""){
                self.city = address["subLocality"] as? String
            }
            else{
                self.city = address["city"] as? String
            }
            
            self.stateShortName = address["stateShortName"] as? String
            self.zipcode = address["zipcode"] as? String
            
         
            

        }
        if let tags = data ["tags"] as? [String] {
              self.tagArray = tags
        }


        if let sceneDetails = data["sceneDetails"] as? [String:Any] {
            print(sceneDetails)
            self.comments = sceneDetails["comments"] as? String
           
            if let policeStandBy = sceneDetails["policeFireStandingBy"] as? Bool {
                if policeStandBy == true {
                     self.safeStatus = "Yes"
                }
                else {
                    self.safeStatus = "No"

                }
            }
            else {
                self.safeStatus = "NA"
            }
            
            if let roadBlocked = sceneDetails["roadBlocked"] as?  Bool {
                if roadBlocked == true {
                    self.roadBlockedStatus = "Yes"

                }
                else {
                    self.roadBlockedStatus = "No"

                }
            }
            else {
                self.roadBlockedStatus = "NA"
            }
            
            if let wireGuardStandBy = sceneDetails["wireGuardStandingBy"] as? Bool {
                if wireGuardStandBy == true  {
                    self.wireGuardStandBy = "Yes"

                }
                else {
                    self.wireGuardStandBy = "No"

                }
            }
            else {
                self.wireGuardStandBy = "NA"
            }
            
        }
        if let partDetails = data["damagedPartDetails"] as? [String:Any] {
            print(partDetails)

            if let items = partDetails["damageData"] as?  [[String:Any]] {
                for item in items {
                    let data = PartData.init(data: item, metadaata: data)
                    self.partData.append(data)
//                    PartData *data = [[PartData alloc] initWithData:dict withMetaData:scope.metaDict];
//                    [self.partData addObject:data];
                }
            }

        }
        if let sceneImages = data["sceneImages"] as? [[String:Any]]  {
            if sceneImages.count == 2 {
                if let item = sceneImages[0] as? [String:Any] {
                    if let url = item["imageUrl"] as? String {
                         self.img1URL = url
                    }
                    if let url = item["thumbnailUrl"] as? String {
                        self.thumbnail1Path = url

                    }

                }
                if let item = sceneImages[1] as? [String:Any] {
                   if let url = item["imageUrl"] as? String {
                         self.img2URL = url
                    }
                    if let url = item["thumbnailUrl"] as? String {
                        self.thumbnail2Path = url

                    }
                }
               
            }
            else if sceneImages.count == 1 {
                
                if let item = sceneImages[0] as? [String:Any] {
                    if let url = item["imageUrl"] as? String {
                         self.img1URL = url
                    }
                    if let url = item["thumbnailUrl"] as? String {
                        self.thumbnail1Path = url

                    }

                }
            }
            
        }

      
        if(self.thumbnail1Path != nil
                  && self.thumbnail2Path != nil
                  && self.thumbnail2Path != ""
                  && self.thumbnail1Path != ""){
            self.imageCount = 2
        }  else if ((self.thumbnail1Path != nil
                  && self.thumbnail1Path != "")
                  || ( self.thumbnail2Path != nil
                  && self.thumbnail2Path  != "" ))
              {
                  self.imageCount = 1
              }
        else {
            self.imageCount = 0
        }
        
        
        if let locDetails = data["loc"] as? [String:Any] {
            if let coordinatesDetails = locDetails["coordinates"] as? [Double] {
                self.longitude = coordinatesDetails[0] as? Double
                self.latitude = coordinatesDetails[1] as? Double

            }

        }
        
   
        
        if let poleDetails = data["poleDetails"] as? [String:Any] {
            if let _poleNumber = poleDetails["poleNumber"]  as? Int {
                    self.poleNumber = "\(_poleNumber)"
                
            }
            else {
                 self.poleNumber = "NA"
            }
            
            if let _poleHeight = poleDetails["height"]  {
                
               self.poleHeight = "\(_poleHeight) ft"
            }
            else {
                 self.poleHeight = "NA"
            }
            
//            self.poleHeight = poleDetails["poleHeight"] as? String
            
            if let array  = poleDetails["feederLine"] as? [Any] {
                if array.count > 0 {
                    if let item = array[0] as? String   {
                        if item != "" && item != "null" {
                            self.feederLine1 = item

                        }
                        else {
                             self.feederLine1  = "NA"
                        }
                        
                    }
                    else {
                        self.feederLine1  = "NA"
                    }
                }
                if array.count > 1 {
                    if let item = array[1] as? String   {
                        if item != "" && item != "null" {
                            self.feederLine2 = item

                        }
                        else {
                             self.feederLine2  = "NA"
                        }
                        
                    }
                    else {
                        self.feederLine2  = "NA"
                    }
                }
                 //print(array)
                
            }
            else {
                    self.feederLine1  = "NA"
                    self.feederLine2  = "NA"


            }

        }
        if let tenantConfig = UserDefaults.standard.value(forKey:Constants.DEFAULTS_TENANT_CONFIG) as? [String:Any] {
            let cols = tenantConfig["cols"] as? NSArray
            print(cols)
            for index in 0...((cols?.count ?? 1)-1) {
                let item = cols?.object(at: index) as? [String:Any]
                let dataKey = item?["docKey"] as? String
                if (dataKey == "timestamp"
                || dataKey ==  "damageType"
                || dataKey == "address.city"
                || dataKey ==  "address.stateShortName") {
                continue
                
                }
                else {
                    if (dataKey == "address.resolvedAddress" ||  dataKey == "address.userAddress" ){
                        guard let key = item?["key"] as? String else { return }
                         if let address = data["address"] as? [String:Any] {
                            if var userAddressArray = (address[key] as? String)?.components(separatedBy: ",") {
                                userAddressArray.removeLast()
                                var count = 0
                                var addressString = ""
                                for st in userAddressArray {
                                    count = count + 1
                                    addressString =  addressString.appending(st)
                                    if count>0 && count < userAddressArray.count {
                                        addressString = addressString.appending(",")
                                    }
                                }
                                self.columnValues.append(addressString)
                            }
                        }
                        
                    }
                    else {
                        guard let key = item?["key"] as? String else { return }
                        if let address = data["address"] as? [String:Any] {
                            guard let key = item?["key"] as? String else { return }
                            if let address = data["address"] as? [String:Any] {
                                
                                 let objExists = address[key] != nil
                                if (objExists) {
                                    if let value = (address[key]as? String)
                                    {
                                        if !(value.isEmpty){
                                            self.columnValues.append(value)

                                        }
                                        
                                    }
                                }

                            }
                        }

                    }
                    
                    
                }
        }
            print(self.columnValues)

        }


    }

}

class PartData {
    var partDislayText: String?
    var type: String?
    var phase: String?
    var size: String?
    var comment: String?
    var image1Url: String?
    var thumbnail1Url: String?
    var downloadThumbNailPath: String?
    var metaDataTitles = [String]()
    var metaDataValues = [Any]()

    init?(data: [String: Any] ,metadaata:[String: Any]) {
        for (key,value)  in data {
            if key == "type" {
                self.type = data["type"] as? String

            }
            else  if key == "phase" {
                self.phase = data["phase"] as? String

            }
            else   if key == "size" {
                self.size = data["size"] as? String
            }
            else if key == "partLabel" {
                    self.partDislayText = data["partLabel"] as? String

            }
            else if (key == "images" ){
                if let images =  data["images"] as? [[String:Any]] {
                                       
                        if let imageDict = images[0] as? [String:Any]  {
                                self.image1Url = imageDict["imageUrl"] as! String
                                self.thumbnail1Url = imageDict["thumbnailUrl"] as! String
                            
                            }
                                       
                        }
                }
   
                //self.partDislayText = [data valueForKey:@"partLabel"];
            else if (key == "comments" ){
                self.comment = data["comments"] as! String
            }
            else if (key != "partLabel" ){
                self.metaDataTitles.append(key)
                if let _valueSt = value as? Int {
                    self.metaDataValues.append(_valueSt)
                }
                else  if let _valueSt = value as? String {
                    self.metaDataValues.append(_valueSt)

                }

            }

            
        }

    }
}
