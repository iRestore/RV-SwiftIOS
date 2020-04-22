//
//  MainViewController.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 08/01/20.
//  Copyright © 2020 iRestoreApp. All rights reserved.
//

import UIKit
enum ReportStatus<T> {
    case Data(T)
    case NoData(T)
    case TimeOut(T)
    case ServerError(T)
}
struct Response {
    let message: String?
}
class MainViewController:UIViewController {
    static var reportArray = [ReportData]()
    static var isFilterAppliedInTabs = false
    
    static var damageTypeSubTypeDisplayNamesDict = [String:String]()
    static var damageSubTypeDmgIdMapDict = [String:String]()

    static var damageMetaDataDisplayDict = [String:String]()
    static var metaDataSortOrderDict = [String:String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0) as Any, NSAttributedString.Key.foregroundColor : UIColor.init("0x363636")]
        self.navigationItem.title = NSLocalizedString("Damage Reports", comment: "")
        
        var backButton: UIButton
        var leftBarBtnItem : UIBarButtonItem
        backButton = UIButton.init(type: UIButton.ButtonType.custom)
        backButton.setImage(UIImage.init(named: "profile"), for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(profileBtnClicked), for: .touchUpInside)
        backButton.sizeToFit()
        leftBarBtnItem = UIBarButtonItem.init(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarBtnItem

        
    }

    @objc func profileBtnClicked() -> Void {

        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let profileController = mainStoryBoard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else { return  }
        profileController.image = self.captureScreenshot()
        self.navigationController?.pushViewController(profileController, animated: false)


        
    }
    
     func captureScreenshot() -> UIImage? {
              let layer = UIApplication.shared.keyWindow!.layer
              let scale = UIScreen.main.scale
              // Creates UIImage of same size as view
              UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
              layer.render(in: UIGraphicsGetCurrentContext()!)
              let screenshot = UIGraphicsGetImageFromCurrentImageContext()
              UIGraphicsEndImageContext()
              return screenshot
              // THIS IS TO SAVE SCREENSHOT TO PHOTOS
              //UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
    }
    
    func getAllReports(page:Int,isdeleteDelta:Bool,isFilterApplied:Bool,isSortDescending:Bool,completion: @escaping (ReportStatus<Response>) -> ()) {
        var newFilterDictionary = [String:Any]()
//        if isFilterApplied == true {
//            let array =  ["fr_5_tree",
//               "fr_6_wire",
//               "vda_11_tree",
//               "vda_9_poletopequipment",
//               "fr_4_pole",
//               "fr_2_fire",
//               "fr_1_electric equipment",
//               "vda_8_pole",
//               "vda_12_wire",
//               "vda_10_splequipment",
//               "fr_3_gas equipment",
//               "vda_7_other"]
//            
        newFilterDictionary["reportType"] = ""
        newFilterDictionary["damageType"] = []
        newFilterDictionary["vdaFilterDamageParts"] = []
        newFilterDictionary["vdaFilterDamageParts"] = []

      
        for (key,value)  in  DataHandler.shared.filterValueDict {
               newFilterDictionary[key] = value
        }
       
        newFilterDictionary["page"] = page
        newFilterDictionary["count"] = 10
        newFilterDictionary["isActive"] = true
        newFilterDictionary["sort"] = "date"
        if isSortDescending {
            newFilterDictionary["order"] = "dsc"

        }
        else {
            newFilterDictionary["order"] = "asc"

        }
    
        do {
           let data
               = try JSONSerialization.data(withJSONObject: newFilterDictionary, options: [])
           let apiClient  = V2ApiClient.init()
           apiClient.getReports(postData: data) {
               result in
             
//               print(result)
                if (isdeleteDelta == true ) {
                    MainViewController.self.reportArray.removeAll()
                }
               switch result {
                   
               case .Success(let value):
                      if let responseDict = value.data {
                        if let itemsArray = responseDict["reports"] as? [[String:Any]] {
                            if itemsArray.count > 0 {
                                for item in itemsArray {
                                    let reportData = ReportData.init(data: item)
                                    
                                     let damageTypeDisplayName = MainViewController.damageTypeSubTypeDisplayNamesDict[reportData?.damageType ?? ""]
                                    
                                    let damageSubTypeDisplayName = MainViewController.damageTypeSubTypeDisplayNamesDict[reportData?.damageSubType ?? ""]
                                    
                                    if damageTypeDisplayName != nil  &&  damageTypeDisplayName != "" && damageSubTypeDisplayName != nil && damageSubTypeDisplayName != ""  {
                                         reportData?.damageTypeDisplayName = damageTypeDisplayName!
                                         reportData?.damageSubTypeDisplayName = damageSubTypeDisplayName!
                                        MainViewController.reportArray.append(reportData!)

                                    }
                                    else {
                                        print(reportData)
                                    }

//
//
//                                    reportData?.damageTypeDisplayName = MainViewController.damageTypeSubTypeDisplayNamesDict[reportData?.damageType ?? ""] ?? ""
//                                    reportData?.damageSubTypeDisplayName = MainViewController.damageTypeSubTypeDisplayNamesDict[reportData?.damageSubType ?? ""] ?? ""

                                }
                                let response = Response.init(message: "")
                                completion(ReportStatus.Data(response))
                            }
                            else {
                                let response = Response.init(message: "")
                                completion(ReportStatus.NoData(response))
                            }

                            
                        }
                       
                      }
                     break
               case .Failure(let error):
                       let response = Response.init(message: error.errormessage)
                       completion(ReportStatus.ServerError(response))

                   break
           
               }
            
           }
            
        } catch {
            print(error.localizedDescription)
        }
        
        
        

        
    }
}
