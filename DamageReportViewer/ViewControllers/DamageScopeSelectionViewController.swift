//
//  DamageScopeSelectionViewController.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 28/01/20.
//  Copyright © 2020 iRestoreApp. All rights reserved.
//

import UIKit
import Firebase

class  DamageScopeSelectionViewController : UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating {
   
    
        @IBOutlet weak var scopeTableView:UITableView!
        @IBOutlet weak var searchBar:UISearchBar!
        @IBOutlet weak var topView:UIView!

        var resultSearchController = UISearchController()
        var isSearchRequired:Bool = true
        var isFRRequired = false
        var isVDARequired = false
        var activityIndicator =  ActivityIndicator()
        var titleString = ""
        var selectedScopesArray = [String]()
        var selectedPartsArray = [String]()
        var selectedReportTypes = [String]()
        var scopeDict = [String:String]()
        var delegate:ScopeDelegate?
        var filteredItems: NSMutableArray?
        var filteredscopeArray = [[String:Any]]()
        var scopeArray = [[String:Any]]()
        var partsDict = [String:Any]()
        var filteredPartsDict = [String:Any]()


    
    
        override func viewDidLoad() {
            //self.searchBar.isHidden = true
            if isSearchRequired == true {
                resultSearchController = ({
                    let controller = UISearchController(searchResultsController: nil)
                    controller.searchResultsUpdater = self as? UISearchResultsUpdating
                    controller.dimsBackgroundDuringPresentation = false
                    controller.searchBar.sizeToFit()
                    self.topView.addSubview(controller.searchBar)
                    //controller.searchBar = searchBar
                    return controller
                })()
            }
            navigationBarSettings()
            fetchDataFromFireStore()
        }
    
        func navigationBarSettings() {

            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 15.0) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
            self.navigationItem.title = titleString
            
            var backButton: UIButton
            var leftBarBtnItem : UIBarButtonItem
            backButton = UIButton.init(type: UIButton.ButtonType.custom)
            backButton.setImage(UIImage.init(named: "back_green"), for: UIControl.State.normal)
            backButton.addTarget(self, action: #selector(backBtnClicked), for: .touchUpInside)
            backButton.sizeToFit()
            leftBarBtnItem = UIBarButtonItem.init(customView: backButton)
            self.navigationItem.leftBarButtonItem = leftBarBtnItem

        }
        @objc  func backBtnClicked() {
            //self.selectedScopesArray.removeAll()
            //self.selectedPartsArray.removeAll()
            var sectionIndex = 0
            for  data in self.scopeArray {
                let id = "\(data["dmgId"])"
                let scopeName = (data["dmgCategoryKey"])

                if var itemsArray = self.partsDict[id] as? [[String:Any]] {
                    for  item  in itemsArray {
                        let name = (item["dmgCategoryKey"]) as! String
                        if (item["isSelected"] as? Int) == 1 {
                            if self.selectedPartsArray.contains(name) {
                                
                            }
                            else {
                            self.selectedPartsArray.append(name)
                            }

                        }
                        else {
                           if self.selectedPartsArray.contains(name) {
                            guard let index = self.selectedPartsArray.firstIndex(of:name ) else { return  }
                            self.selectedPartsArray.remove(at: index)
                            }
                           
                        }
                        
                    }
                     if (data["isSelected"] as? Int) != 0 {
                        if self.selectedScopesArray.contains(scopeName as! String) {
                            
                        }
                        else {
                            self.selectedScopesArray.append(scopeName as! String)
                        }


                    }
                    else {
                        if self.selectedScopesArray.contains(scopeName as! String) {
                            guard let index = self.selectedScopesArray.firstIndex(of:scopeName as! String ) else { return  }
                                self.selectedScopesArray.remove(at: index)
                                                   
                        }
                    }
                }
                
                sectionIndex = sectionIndex +  1
            }
            self.delegate?.didSelectScopesAndPart(scopes: self.selectedScopesArray, parts: self.selectedPartsArray,scopesDict:self.scopeDict)
            self.navigationController?.popViewController(animated: true)
        }
    
       func  fetchDataFromFireStore()  {
            activityIndicator.showActivityIndicator(uiView: self.view)
           let db = Firestore.firestore()
           let collectionName = UserDefaults.standard.value(forKey: Constants.FIREBAE_DB)
        db.collection(collectionName as! String).whereField("level", in: [1, 2])
               .addSnapshotListener { querySnapshot, error in
                   guard let documents = querySnapshot?.documents else {
                       print("Error fetching documents: \(error!)")
                       return
                   }
                   self.scopeArray.removeAll()
                   for document in documents {
                       if var data = document.data() as? [String:Any] {
                            let  level =  data["level"] as! Int
                            let scopeName =  data["dmgCategoryKey"] as! String
                            self.scopeDict[scopeName] = data["displayName"] as! String
                        if self.selectedReportTypes.contains(data["damageType"] as! String) {
                            if level == 1 {
                                data["isSelected"] = 0
                                self.scopeArray.append(data)
                                
                            }
                            else {
                                let  parentId = "\(data["parentId"])"
                                if var array  = self.partsDict[parentId ] as? [Any] {
                                    data["isSelected"] = 0
                                    array.append(data)
                                    self.partsDict[parentId]  = array
                                }
                                else {
                                    var newItemArray = [[String:Any]]()
                                    data["isSelected"] = 0
                                    newItemArray.append(data)
                                    self.partsDict[parentId]  = newItemArray
                                }
                                
                                
                            }
                        }
                       }
                    
                }


                
                self.scopeArray = self.scopeArray.sorted(by: { (($0 as Dictionary<String, AnyObject>)["dmgId"] as! String).localizedCaseInsensitiveCompare(($1 as Dictionary<String, AnyObject>)["dmgId"] as! String) == ComparisonResult.orderedAscending }) ;
                
                var sectionIndex = 0
                for  data in self.scopeArray {
                    var selectedPartsCount = 0
                    var dataCopy = data
                    let id = "\(data["dmgId"])"
                    let  name =  data["dmgCategoryKey"] as! String
                    if var itemsArray = self.partsDict[id] as? [[String:Any]] {
                        var rowIndex = 0
                        for  item  in itemsArray {
                            let  _name =  item["dmgCategoryKey"] as! String
                            var itemCopy = item
                            if self.selectedScopesArray.contains(name) {
                                if self.selectedPartsArray.contains(_name) {
                                    itemCopy["isSelected"] = 1

                                }
                                else {
                                    itemCopy["isSelected"] = 0

                                }
                                

                            }
                            if (itemCopy["isSelected"] as! Int) == 1  {
                                selectedPartsCount = selectedPartsCount + 1
                            }
                            itemsArray[rowIndex] = itemCopy
                            rowIndex = rowIndex + 1
                            
                        }
                        self.partsDict[id] = itemsArray

                        if self.selectedScopesArray.contains(name) {
                            if selectedPartsCount == itemsArray.count {
                                dataCopy["isSelected"] = 1
                            }
                            else if selectedPartsCount >  0 {
                                dataCopy["isSelected"] = -1

                            }
                        }
                        else {
                            dataCopy["isSelected"] = 0

                        }
                     
                        
                    }
                    self.scopeArray [sectionIndex] = dataCopy
                    sectionIndex = sectionIndex +  1
                }
                self.scopeTableView.delegate = self
                self.scopeTableView.dataSource = self
                self.scopeTableView.reloadData()
                self.activityIndicator.hideActivityIndicator(uiView: self.view)
                

           }
       }
    @objc func scopeButtonTapped(_ sender: UIButton) {
        if  (resultSearchController.isActive) {
            let index = sender.tag - 1
            if  var  itemDict =  self.filteredscopeArray[index] as? [String:Any] {
                
                if (itemDict["isSelected"] as? Int) == 1 {
                    itemDict["isSelected"] = 0
                }
                else {
                    itemDict["isSelected"] = 1
                    
                }
                self.filteredscopeArray[index] = itemDict
                
                if let data = self.filteredscopeArray[index] as? [String:Any] {
                    let id = "\(data["dmgId"])"
                    let originalScopeArrayIndex = self.scopeArray.firstIndex(where: { ($0["dmgCategoryKey"] as? String) == data["dmgCategoryKey"] as? String})
                    if originalScopeArrayIndex != nil &&  originalScopeArrayIndex ?? 0 >= 0 {
                        self.scopeArray[originalScopeArrayIndex!] = itemDict

                    }
                    
                    if var itemsArray = self.filteredPartsDict[id] as? [[String:Any]] {
                        var index = 0
                        for  item  in itemsArray {
                            var itemCopy = item
                            itemCopy["isSelected"] = itemDict["isSelected"]
                            itemsArray[index] = itemCopy
                            index = index +  1
                        }
                        self.filteredPartsDict[id] = itemsArray
                        
                        
                    }
                    //To persist the part selection
                    if var itemsArray = self.partsDict[id] as? [[String:Any]] {
                        var index = 0
                        for  item  in itemsArray {
                            var itemCopy = item
                            itemCopy["isSelected"] = itemDict["isSelected"]
                            itemsArray[index] = itemCopy
                            index = index +  1
                        }
                        self.partsDict[id] = itemsArray
                    }
                    
                    
                    
                }
                self.scopeTableView.reloadData()
                
            }
        }
        else {
            let index = sender.tag - 1
            if  var  itemDict =  self.scopeArray[index] as? [String:Any] {
                if (itemDict["isSelected"] as? Int) == 1 {
                    itemDict["isSelected"] = 0
                }
                else {
                    itemDict["isSelected"] = 1
                    
                }
                self.scopeArray[index] = itemDict
                
                if let data = self.scopeArray[index] as? [String:Any] {
                    let id = "\(data["dmgId"])"
                    if var itemsArray = self.partsDict[id] as? [[String:Any]] {
                        var index = 0
                        for  item  in itemsArray {
                            var itemCopy = item
                            itemCopy["isSelected"] = itemDict["isSelected"]
                            itemsArray[index] = itemCopy
                            index = index +  1
                        }
                        self.partsDict[id] = itemsArray
                        
                    }
                    
                    
                }
                self.scopeTableView.reloadData()
                
            }
        }
    }
    
    @objc func cellButtonTapped(_ sender: UIButton) {
        print (sender.tag)
        let section = sender.tag / 100
        let row = sender.tag % 100
        var sectionIndex = 0
        if  (resultSearchController.isActive) {

            for  data in self.filteredscopeArray {
                var selectedPartsCount = 0
                var dataCopy = data
                if section == sectionIndex {
                    let id = "\(data["dmgId"])"
                    if var itemsArray = self.filteredPartsDict[id] as? [[String:Any]] {
                        var rowIndex = 0
                        for  item  in itemsArray {
                            var itemCopy = item
                            if rowIndex == row{
                                if (itemCopy["isSelected"] as! Int) == 1 {
                                    itemCopy["isSelected"] = 0
                                }
                                else {
                                    itemCopy["isSelected"] = 1
                                }
                                itemsArray[rowIndex] = itemCopy
                                //break
                            }
                            if (itemCopy["isSelected"] as! Int)  == 1 {
                                selectedPartsCount = selectedPartsCount + 1
                            }
                            rowIndex = rowIndex +  1
                        }
                        self.filteredPartsDict[id] = itemsArray
                        
                        let actualCount = (self.partsDict[id] as! [[String:Any]] ) .count
                        if ( selectedPartsCount == actualCount) {
                            dataCopy["isSelected"] = 1
                        }
                        else if selectedPartsCount > 0 {
                            dataCopy["isSelected"] = -1
                        }
                        else {
                            dataCopy["isSelected"] = 0
                        }
                        
                    }
                    self.filteredscopeArray [sectionIndex] = dataCopy
                    
                    // We have to also select the original scopes and part
                    if var itemsArray = self.partsDict[id] as? [[String:Any]] {
                        let searchItemsArray = self.filteredPartsDict[id] as! [[String:Any]]
                        var index = 0
                        for  item  in itemsArray {
                            for searchItem  in searchItemsArray {
                                let itemKey = item["dmgCategoryKey"] as! String
                                let searchitemKey = searchItem["dmgCategoryKey"] as! String
                                if itemKey  == searchitemKey {
                                    var itemCopy = item
                                    itemCopy = searchItem
                                    itemsArray[index] = itemCopy

                                    
                                }
                                
                            }
                            index =  index + 1
                            
                            
                        }
                        self.partsDict[id] = itemsArray
                        let originalScopeArrayIndex = self.scopeArray.firstIndex(where: { ($0["dmgCategoryKey"] as? String) == dataCopy["dmgCategoryKey"] as? String})
                        if originalScopeArrayIndex != nil &&  originalScopeArrayIndex ?? 0 >= 0 {
                            self.scopeArray[originalScopeArrayIndex!] = dataCopy

                        }
                                                

                    }
                    
                    
                }
                sectionIndex = sectionIndex +  1
            }
            
        }
        else {
            for  data in self.scopeArray {
                var selectedPartsCount = 0
                var dataCopy = data
                if section == sectionIndex {
                    let id = "\(data["dmgId"])"
                    if var itemsArray = self.partsDict[id] as? [[String:Any]] {
                        var rowIndex = 0
                        for  item  in itemsArray {
                            var itemCopy = item
                            if rowIndex == row{
                                if (itemCopy["isSelected"] as! Int) == 1 {
                                    itemCopy["isSelected"] = 0
                                }
                                else {
                                    itemCopy["isSelected"] = 1
                                }
                                itemsArray[rowIndex] = itemCopy
                                //break
                            }
                            if (itemCopy["isSelected"] as! Int)  == 1 {
                                selectedPartsCount = selectedPartsCount + 1
                            }
                            rowIndex = rowIndex +  1
                        }
                        self.partsDict[id] = itemsArray
                        if ( selectedPartsCount == itemsArray.count) {
                            dataCopy["isSelected"] = 1
                        }
                        else if selectedPartsCount > 0 {
                            dataCopy["isSelected"] = -1
                        }
                        else {
                            dataCopy["isSelected"] = 0
                        }
                        
                    }
                    self.scopeArray [sectionIndex] = dataCopy
                    
                }
                sectionIndex = sectionIndex +  1
            }
        }
        self.scopeTableView.reloadData()
    }
    
    @IBAction func selectAllScopes(_ sender: UIButton) {
        var sectionIndex = 0
        for  data in self.scopeArray {
            var selectedPartsCount = 0
            var dataCopy = data
            let id = "\(data["dmgId"])"
            if var itemsArray = self.partsDict[id] as? [[String:Any]] {
                var rowIndex = 0
                for  item  in itemsArray {
                    var itemCopy = item
                    itemCopy["isSelected"] = 1
                    itemsArray[rowIndex] = itemCopy
                    rowIndex = rowIndex +  1
                }
                self.partsDict[id] = itemsArray
                dataCopy["isSelected"] = 1

             
                
            }
            self.scopeArray [sectionIndex] = dataCopy
            sectionIndex = sectionIndex +  1
        }
        self.scopeTableView.reloadData()

    }
    @IBAction func deselecctAllScopes(_ sender: UIButton) {
        var sectionIndex = 0
        for  data in self.scopeArray {
            var selectedPartsCount = 0
            var dataCopy = data
            let id = "\(data["dmgId"])"
            if var itemsArray = self.partsDict[id] as? [[String:Any]] {
                var rowIndex = 0
                for  item  in itemsArray {
                    var itemCopy = item
                    itemCopy["isSelected"] = 0
                    itemsArray[rowIndex] = itemCopy
                    rowIndex = rowIndex +  1
                }
                self.partsDict[id] = itemsArray
                dataCopy["isSelected"] = 0

             
                
            }
            self.scopeArray [sectionIndex] = dataCopy
            sectionIndex = sectionIndex +  1
        }
        self.scopeTableView.reloadData()
    }

    //MARK: Search Delegates
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredscopeArray.removeAll()
        self.filteredPartsDict.removeAll()
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let filteredArray = self.scopeArray.filter { (($0["displayName"] as? String)?.contains(searchController.searchBar.text!) ?? false )}
        if filteredArray.count > 0 {
            for filteredItem in filteredArray {
                self.filteredscopeArray.append(filteredItem)
                if let _filteredItem = filteredItem as? [String:Any] {
                    let id = "\(_filteredItem["dmgId"])"
                    if let itemsArray = self.partsDict[id] {
                        self.filteredPartsDict[id] = itemsArray

                    }

                }
                
            }
            
        }

        for item in self.scopeArray {
            if let _item = item as? [String:Any] {
                let id = "\(_item["dmgId"])"
                if let itemsArray = self.partsDict[id] as? [[String:Any]]{
                    let filteredPartsArray = itemsArray.filter { (($0["displayName"] as? String)?.contains(searchController.searchBar.text!) ?? false )}
                    if filteredPartsArray.count > 0 {
                        if !self.filteredscopeArray.contains{ $0["dmgCategoryKey"] as? String == _item["dmgCategoryKey"] as? String } {
                            self.filteredscopeArray.append(_item)
                            self.filteredPartsDict[id] = filteredPartsArray

                          
                        }
                        
                    }
                }

            }
        }
   
        
        self.scopeTableView.reloadData()

    }
    
    // MARK: TableView Delegate and Datasources
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if  (resultSearchController.isActive) {
                return self.filteredscopeArray.count
        }
        else{
            return self.scopeArray.count
        }

    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
         if  (resultSearchController.isActive) {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! HeaderCell
            if let data = self.filteredscopeArray[section] as? [String:Any] {
                headerCell.title.text = data["displayName"] as? String
                let imageName = "\((data["dmgCategoryKey"])!)_icon"
                headerCell.imgView?.image = UIImage.init(named: imageName)
                headerCell.selectButton.tag = section + 1
                headerCell.selectButton.addTarget(self, action:  #selector(DamageScopeSelectionViewController.scopeButtonTapped(_ :)), for: .touchUpInside)
                let isSelected = data["isSelected"] as! Int
                if isSelected == 1 {
                    headerCell.selectButton.setImage(UIImage.init(named: "greenTick"), for: .normal)

                }
                else if isSelected == 0 {
                    headerCell.selectButton.setImage(UIImage.init(named: "whiteCircle"), for: .normal)

                }
                else {
                    headerCell.selectButton.setImage(UIImage.init(named: "greenMinus"), for: .normal)

                }
                
                    
                
            }
            return headerCell
        }
         else {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! HeaderCell
            if let data = self.scopeArray[section] as? [String:Any] {
                headerCell.title.text = data["displayName"] as? String
                let imageName = "\((data["dmgCategoryKey"])!)_icon"
                headerCell.imgView?.image = UIImage.init(named: imageName)
                headerCell.selectButton.tag = section + 1
                headerCell.selectButton.addTarget(self, action:  #selector(DamageScopeSelectionViewController.scopeButtonTapped(_ :)), for: .touchUpInside)
                let isSelected = data["isSelected"] as! Int
                if isSelected == 1 {
                    headerCell.selectButton.setImage(UIImage.init(named: "greenTick"), for: .normal)

                }
                else if isSelected == 0 {
                    headerCell.selectButton.setImage(UIImage.init(named: "whiteCircle"), for: .normal)

                }
                else {
                    headerCell.selectButton.setImage(UIImage.init(named: "greenMinus"), for: .normal)

                }
                
                    
                
            }
            return headerCell
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 60
       }
         
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 60
    }
      

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            if let data = self.filteredscopeArray[section] as? [String:Any] {
                let id = "\(data["dmgId"])"
                if let itemsArray = self.filteredPartsDict[id] {
                    return (itemsArray as AnyObject).count
                    
                }
                else {
                    return 0
                }
            }
            else {
                return 0
            }
        }
        else {
            if let data = self.scopeArray[section] as? [String:Any] {
                let id = "\(data["dmgId"])"
                if let itemsArray = self.partsDict[id] {
                    return (itemsArray as AnyObject).count
                    
                }
                else {
                    return 0
                }
            }
            else {
                return 0
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if  (resultSearchController.isActive) {
        
        var cell:  ItemCell  = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)   as! ItemCell
            if let data = self.filteredscopeArray[indexPath.section] as? [String:Any] {
                let id = "\(data["dmgId"])"
                if let itemsArray = self.filteredPartsDict[id] as? [[String:Any]] {
                    if let data = itemsArray[indexPath.row] as? [String:Any]  {
                        cell.selectButton.tag = (indexPath.section*100)+indexPath.row
                        cell.title.text = data["displayName"] as? String
                        let isSelected = data["isSelected"] as! Int
                        if isSelected == 1 {
                            cell.selectButton.setImage(UIImage.init(named: "greenTick"), for: .normal)

                        }
                        else {
                            cell.selectButton.setImage(UIImage.init(named: "whiteCircle"), for: .normal)

                        }
                        
                    }
                   
                    cell.selectButton.addTarget(self, action:  #selector(DamageScopeSelectionViewController.cellButtonTapped(_ :)), for: .touchUpInside)

                }
            
            return cell
            
        }
        return UITableViewCell()
        }
        else {
        
        var cell:  ItemCell  = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)   as! ItemCell
            if let data = self.scopeArray[indexPath.section] as? [String:Any] {
                let id = "\(data["dmgId"])"
                if let itemsArray = self.partsDict[id] as? [[String:Any]] {
                    if let data = itemsArray[indexPath.row] as? [String:Any]  {
                        cell.selectButton.tag = (indexPath.section*100)+indexPath.row
                        cell.title.text = data["displayName"] as? String
                        let isSelected = data["isSelected"] as! Int
                        if isSelected == 1 {
                            cell.selectButton.setImage(UIImage.init(named: "greenTick"), for: .normal)

                        }
                        else {
                            cell.selectButton.setImage(UIImage.init(named: "whiteCircle"), for: .normal)

                        }
                        
                    }
                   
                    cell.selectButton.addTarget(self, action:  #selector(DamageScopeSelectionViewController.cellButtonTapped(_ :)), for: .touchUpInside)

                }
            
            return cell
            
        }
        return UITableViewCell()
        }
    }
}


class HeaderCell:UITableViewCell {
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var selectButton: UIButton!


}
class ItemCell:UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var selectButton: UIButton!
}
