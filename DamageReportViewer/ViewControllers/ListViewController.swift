//
//  ListViewController.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 07/01/20.
//  Copyright © 2020 iRestoreApp. All rights reserved.
//
import UIKit
import Firebase

protocol FilterReportsDelegate {
    func  fetchReportsWithFilter()
    func  resetFilter()
}
class ListViewController: MainViewController,UITableViewDelegate,UITableViewDataSource ,UIScrollViewDelegate,FilterReportsDelegate{

    @IBOutlet var tblView: UITableView!
    @IBOutlet var noReportsLabel: UILabel!
    @IBOutlet var filterBtn: UIButton!
    @IBOutlet weak var slideOutPanel :UIView!
    @IBOutlet weak var userName :UILabel!
    @IBOutlet weak var versionNum :UILabel!
    @IBOutlet weak var profileView :UIImageView!

    var currentPage : Int = 1
    let isSortClicked: Bool = true
    var isloading: Bool = false
    var isDataFinished: Bool = false
    var filterDict = [String:Any]()
    var isFilterApplied = false
    var isSortDescending = true
    var refreshControl = UIRefreshControl()
    var activityIndicator =  ActivityIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()
        let prefs : UserDefaults = UserDefaults.standard
        prefs.set(true, forKey: Constants.IS_SIGN_COMPLETED)
        MainViewController.isFilterAppliedInTabs = false
        navBarSettings()
        if Reachability.isConnectedToNetwork () {
            DataHandler.shared.fetchDataFromDefaults()
            let filterDict = DataHandler.shared.filterValueDict
//            if(filterDict.count < 1) {
                let date = Date()
                let dateFormatter: DateFormatter = DateFormatter()
                dateFormatter.dateFormat = Constants.fromDateDisplayFormat
                let dateString = dateFormatter.string(from: date)
                DataHandler.shared.filterValueDict["toDate"] = dateString
                
                guard let thirtyDaysBeforeToday = Calendar.current.date(byAdding: .month, value: -5, to: Date()) else { return  }
                let dateString1 = dateFormatter.string(from: thirtyDaysBeforeToday)
                DataHandler.shared.filterValueDict["fromDate"] = dateString1
                
                let dateFormatter1: DateFormatter = DateFormatter()
                dateFormatter1.dateFormat = Constants.fromDateDisplayFormat
                let dateString2 = dateFormatter1.string(from: date)
                DataHandler.shared.filterDisplayDict["toDate"] = dateString2
                let dateString3 = dateFormatter1.string(from: thirtyDaysBeforeToday)
                DataHandler.shared.filterDisplayDict["fromDate"] = dateString3
                
                self.filterBtn.setImage(UIImage.init(named: "filter_active"), for: .normal)
                self.isFilterApplied = true

//            }
            self.getDataFromFirebase()
            self.getMetaDataFromFirebase()
        }
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
        tblView.addSubview(refreshControl)

        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if MainViewController.isFilterAppliedInTabs == true {
            let filterDict = DataHandler.shared.filterValueDict
            if(filterDict.count > 1) {
                self.filterBtn.setImage(UIImage.init(named: "filter_active"), for: .normal)

            }
            else {
                self.filterBtn.setImage(UIImage.init(named: "filter"), for: .normal)
            }
            currentPage = 1
            self.tblView.reloadData()
        }
    }
    
    func navBarSettings (){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0) as Any, NSAttributedString.Key.foregroundColor : UIColor.init("0x363636")]
        self.navigationItem.title = NSLocalizedString("Damage Reports", comment: "")

    }

    
    @IBAction func btnFilterbtnSortWithSender(_ sender: UIButton) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailsController = mainStoryBoard.instantiateViewController(withIdentifier: "NewFilterViewController") as? NewFilterViewController else { return  }
        detailsController.delegate = self
        self.navigationController?.pushViewController(detailsController, animated: true)
        
        
//        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//        guard let detailsController = mainStoryBoard.instantiateViewController(withIdentifier: "NewFilterViewController") as? NewFilterViewController else { return  }
//        self.navigationController?.pushViewController(detailsController, animated: true)
//
        
    }
    
    func fetchReportsWithFilter() {
        isloading = true
        currentPage = 1
        self.isFilterApplied = true
        let filterDict = DataHandler.shared.filterValueDict
        if filterDict.count > 1 {
            self.filterBtn.setImage(UIImage.init(named: "filter_active"), for: .normal)
        }
        else {
            self.filterBtn.setImage(UIImage.init(named: "filter"), for: .normal)

        }
        self.getReports(isDeleteDelta:true)
    }
    func resetFilter() {
//        self.filterBtn.setImage(UIImage.init(named: "filter"), for: .normal)
//        isloading = true
//        currentPage = 1
//        self.isFilterApplied = true
//        self.getReports(isDeleteDelta:true)
    }
    
    @IBAction func btnSort(_ sender: UIButton) {

        if (isSortDescending == true) {
            isSortDescending = false
        }
        else {
            isSortDescending = true
        }
        currentPage = 1
        self.getReports(isDeleteDelta:true)

    }
    
    
     @objc  func refreshTable()  {
        refreshControl.endRefreshing()
        isloading = true
        currentPage = 1
        self.getReports(isDeleteDelta:true)

    }
 
    func getDataFromFirebase() {
        activityIndicator.showActivityIndicator(uiView: self.view)
        let db = Firestore.firestore()
        let collectionName = UserDefaults.standard.value(forKey: Constants.FIREBAE_DB)
       db.collection(collectionName as! String).whereField("level", in: [1, 2])
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                MainViewController.damageTypeSubTypeDisplayNamesDict.removeAll()
                for document in documents {
                    if let data = document.data() as? [String:Any] {
                        if let key = data["dmgCategoryKey"] as? String {
                            let displayName = data["displayName"] as? String
                            let  level =  data["level"] as! Int
                            if level == 2 {
                                let  dmgId =  data["dmgId"] as! String
                                MainViewController.damageSubTypeDmgIdMapDict[key] = dmgId
                            }
                            print("\(key):\(displayName)")
                            MainViewController.damageTypeSubTypeDisplayNamesDict[key] = displayName
                        }
                         
                        
                    }                    // print("\(document.documentID) => \(document.data())")
                }
                self.activityIndicator.hideActivityIndicator(uiView: self.view)
                self.getReports(isDeleteDelta:true)

        }
    }
    func getMetaDataFromFirebase() {
        activityIndicator.showActivityIndicator(uiView: self.view)
        let db = Firestore.firestore()
        let collectionName = UserDefaults.standard.value(forKey: Constants.FIREBAE_DB)
        db.collection(collectionName as! String).whereField("level", in: [3])
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                MainViewController.self.damageMetaDataDisplayDict.removeAll()
                for document in documents {
                    if let data = document.data() as? [String:Any] {
                        if let key = data["dmgCategoryKey"] as? String ,let sortOrder =  data["sortOrder"] as? String {
                            let displayName = data["displayName"] as? String
                            if let parentId = data["parentId"] as? String {
                                let newKey = "\(parentId)_\(key)"
                                MainViewController.self.damageMetaDataDisplayDict[newKey] = displayName
                                MainViewController.self.metaDataSortOrderDict[newKey] = "\(sortOrder)"
                                
                            }
                        }
                         
                        
                    }                    // print("\(document.documentID) => \(document.data())")
                }
                print(MainViewController.self.damageMetaDataDisplayDict)
                self.activityIndicator.hideActivityIndicator(uiView: self.view)

        }
    }
    
    
    func getReports(isDeleteDelta:Bool) {
        activityIndicator.showActivityIndicator(uiView: self.view)
        self.isloading = true
        self.getAllReports(page: currentPage, isdeleteDelta: isDeleteDelta, isFilterApplied: isFilterApplied, isSortDescending: isSortDescending)
        {
            result in
            
            DispatchQueue.main.async {
                self.activityIndicator.hideActivityIndicator(uiView: self.view)
                self.isDataFinished = false
                self.isloading = false
            }
            switch result {

            case .Data( _):
                DispatchQueue.main.async {
                    self.noReportsLabel.isHidden = true
                    self.tblView.isHidden = false
                    self.tblView.reloadData()
                    self.isDataFinished = true
                }
                break
            case .NoData( _):
                if self.currentPage != 1  {
                    self.isloading = false
                }
                else {
                    DispatchQueue.main.async {
                        self.tblView.isHidden = true
                        self.noReportsLabel.isHidden = false
                    }
                }
                break
            case .TimeOut( _):
                break
            case .ServerError(let value):
                DispatchQueue.main.async {
                    self.tblView.isHidden = true
                    self.noReportsLabel.isHidden = false
                }
                break
                
                
                
            }
            
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MainViewController.reportArray.count
            
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135.0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableItem", for: indexPath) as!  ReportsViewCell
            if  MainViewController.reportArray.count > indexPath.row {
                let modelObj = MainViewController.reportArray[indexPath.row]
                cell.setCellInfo(modelObject: modelObj)

            }
            return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let reportData:ReportData = MainViewController.reportArray[indexPath.row]
        if reportData.reportType == "SDA" {
            guard let detailsController = mainStoryBoard.instantiateViewController(withIdentifier: "VDADetailsViewController") as? VDADetailsViewController else { return  }
            detailsController.reportData = reportData
            self.navigationController?.pushViewController(detailsController, animated: true)
            
        }
        else {
            guard let detailsController = mainStoryBoard.instantiateViewController(withIdentifier: "FRDetailsViewController") as? FRDetailsViewController else { return  }
            detailsController.reportData = reportData
            self.navigationController?.pushViewController(detailsController, animated: true)
            
        }

    }
    func ShouldLoadNextPage(tableView:UITableView) -> Bool
     {
        let yOffset = tableView.contentOffset.y;
        let height = tableView.contentSize.height - tableView.frame.height
        return yOffset / height > 0.85
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let shouldLoadNextPage = ShouldLoadNextPage(tableView:self.tblView)
        if (shouldLoadNextPage && !isloading )  {
              currentPage = currentPage + 1
              self.getReports(isDeleteDelta:false)
          }
    }

    
}


class ReportsViewCell : UITableViewCell {
    
    @IBOutlet weak var lblDmgType: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPlace: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var imgViewDmgType: UIImageView!
    @IBOutlet weak var heightConstraintNameFld: NSLayoutConstraint!
    @IBOutlet weak var SeparatorDamageFld: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintEmailFld: NSLayoutConstraint!
    @IBOutlet weak var SeparatorEmailFld: NSLayoutConstraint!
    @IBOutlet weak var SeparatorNameFld: NSLayoutConstraint!

    
    func setCellInfo(modelObject:ReportData) {
        
        lblDmgType.text = "\(modelObject.damageTypeDisplayName!)/ \(modelObject.damageSubTypeDisplayName!)"
        if (modelObject.columnValues.count >= 1) {
            self.lblName.text = modelObject.columnValues.first
            let constraintRect = CGSize(width: self.lblName.frame.width, height: .greatestFiniteMagnitude)
            let boundingBox = self.lblName.text?.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.lblName.font], context: nil)
            var height = ceil(boundingBox?.height ?? 22)
            if height > 40 {
                height = 40
            }
            self.SeparatorDamageFld.constant = 2
            self.heightConstraintNameFld.constant = height
            self.SeparatorNameFld.constant = 2
        }
        else  {
            self.SeparatorDamageFld.constant = 0;
            self.heightConstraintNameFld.constant = 0;
            self.SeparatorNameFld.constant = 0;
            self.heightConstraintEmailFld.constant = 0;
            self.SeparatorEmailFld.constant = 0;
        }
        
        if (modelObject.columnValues.count >= 2 ) {
            
            lblEmail.text = modelObject.columnValues[1] as? String
            self.heightConstraintEmailFld.constant = 22;
            self.SeparatorEmailFld.constant = 2;
         }else{
            self.heightConstraintEmailFld.constant = 0;
            self.SeparatorEmailFld.constant = 0;
         }
        if modelObject.damageType != nil {
            imgViewDmgType.image = UIImage.init(named: modelObject.damageType!)

        }

        if let city = modelObject.city, let state = modelObject.stateShortName {
            lblPlace.text = "\(city) , \(state)"

        }
        else {
             lblPlace.text = ""
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormatterKey
        let timeZone = NSTimeZone(name: "UTC")
        dateFormatter.timeZone = timeZone! as TimeZone
        if let date : Date =  dateFormatter.date(from: modelObject.dateCreated ?? "") {
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = Constants.listScreenDateFormat
            lblDateTime.text = dateFormatter2.string(from: date)
            
        }
        else {
             lblDateTime.text = ""
        }

    }
}


