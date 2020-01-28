//
//  NewFilterViewController.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 21/01/20.
//  Copyright © 2020 iRestoreApp. All rights reserved.
//

import UIKit

protocol ScopeDelegate  {
    func didSelectScopesAndPart(scopes:[String],parts:[String])
}

protocol FilterDelegate  {
   func didSelectItem(selectedDisplayString: String,keyName:String)
    
}

protocol LocationCategoryPlacesAPIDelegate  {
   func didSelectItemFromLocation(selectedDisplayString: String,keyName:String)
}

class  NewFilterViewController : UIViewController,UITableViewDelegate,UITableViewDataSource,FilterDelegate,LocationCategoryPlacesAPIDelegate,ScopeDelegate {

 
    @IBOutlet weak var filterButton:UIButton!
    @IBOutlet weak var tabControllerView:UIView!
    @IBOutlet weak var tab1:UIButton!
    @IBOutlet weak var tab2:UIButton!
    @IBOutlet weak var tab3:UIButton!
    @IBOutlet weak var filterTableView:UITableView!
    
    var delegate:FilterReportsDelegate?
    var datePicker : UIDatePicker?
    var toolBar: UIToolbar?
    var cellItemsArray = NSMutableArray()
    var activeTextField:UITextField?
    var toolbar:UITextField?
    var filterDisplayDict = [String:Any]()
    var filterValueDict = [String:Any]()
    var selectedTabsArray = [String]()
    
    var selectedSubmittedByArray = NSMutableArray()
    var addressArray = NSMutableArray()
    var divisionArray = NSMutableArray()
    var regionArray = NSMutableArray()
    var platformArray = NSMutableArray()
    var countyArray = NSMutableArray()
    var tagsArray = [[String:Any]]()
    var FeederLinesArray = NSMutableArray()


    
    var  locationSelectionDict = ["Zipcode":"zipcode","City":"city","County":"county","State":"state","Division":"division","Region":"region","Platform":"platform"]
  
    override func viewDidLoad() {
        self.navigationBarSettings()
        populateTabControl()
        datePicker?.datePickerMode = .date
        selectTab(index: 1)
        populateUIItems(tabIndex: 1)
        self.filterTableView.delegate  = self
        self.filterTableView.dataSource = self
        self.filterValueDict = DataHandler.shared.filterValueDict
        self.filterDisplayDict = DataHandler.shared.filterDisplayDict

    }
    override func viewDidLayoutSubviews() {
        self.tab3.roundCorners(corners:  [.topRight, .bottomRight], radius: 10.0)
        self.tab1.roundCorners(corners:  [.topLeft, .bottomLeft], radius: 10.0)


    }
    func navigationBarSettings() {

        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 15.0) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationItem.title = "Filter" // NSLocalizedString("Damage Reports", comment: "")
        
        var backButton: UIButton
        var leftBarBtnItem : UIBarButtonItem
        backButton = UIButton.init(type: UIButton.ButtonType.custom)
        backButton.setImage(UIImage.init(named: "back_green"), for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(backBtnOnClick), for: .touchUpInside)
        backButton.sizeToFit()
        leftBarBtnItem = UIBarButtonItem.init(customView: backButton)
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        let submitBtn = UIButton(type: .custom)
        submitBtn.setTitle("Reset", for: .normal)
        submitBtn.setTitleColor(UIColor.init("0X26A69A"), for: .normal)
        submitBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        submitBtn.addTarget(self, action: #selector(reset), for: .touchUpInside)
        let submitItem = UIBarButtonItem(customView: submitBtn)
        self.navigationItem.setRightBarButton(submitItem, animated: true)
        
        
    }
    
    func populateTabControl() {
        
        self.tabControllerView.layer.borderWidth = 1.0
        self.tabControllerView.layer.cornerRadius = 10.0
        self.tabControllerView.layer.borderColor  = UIColor.lightGray.cgColor
        
        let lineView = UIView(frame: CGRect.init(x:self.tab1.frame.size.width - 1 ,y: 0, width: self.tab1.frame.size.width - 1, height: self.tab1.frame.size.height))
        lineView.backgroundColor=UIColor.lightGray
        self.tab1.addSubview(lineView)
        
        let lineView2 = UIView(frame: CGRect.init(x:self.tab2.frame.size.width - 1 ,y: 0, width: self.tab1.frame.size.width - 1, height: self.tab2.frame.size.height))
        lineView2.backgroundColor=UIColor.lightGray
        self.tab2.addSubview(lineView2)
        
    }
    
    func populateUIItems (tabIndex :Int) {
        var item1  = CellItem.init(name: "scope", displayName: "Select Scope & Damage", type: "TYPE1", subType:"")
        item1.rowHeight = Constants.FILTER_TABLECELL_NORML_HEIGHT
        
        var item2  = CellItem.init(name: "", displayName: "", type: "TYPE4", subType:"")
        item2.rowHeight = 10
        
        var item3  = CellItem.init(name: "fromDate", displayName: "From Date", type: "TYPE3", subType:"")
        item3.rowHeight = 60
        
        var item4  = CellItem.init(name: "toDate", displayName: "To Date", type: "TYPE3", subType:"")
        item4.rowHeight = 60
        
        var item5  = CellItem.init(name: "", displayName: "", type: "TYPE4", subType:"")
        item5.rowHeight = 10
        
        var item6  = CellItem.init(name: "submittedBy", displayName: "Submitted By", type: "TYPE1", subType:"")
        item6.rowHeight = Constants.EXTENDING_CELL_HEIGHT
        item6.placeHolderText = "Please select"
        
        var item7  = CellItem.init(name: "selectedLocationType", displayName: "Location Category", type: "TYPE1", subType:"")
        item7.rowHeight = Constants.EXTENDING_CELL_HEIGHT
        item7.placeHolderText = "Select Scope"
        
        var item8  = CellItem.init(name: "selectedCategory", displayName: "Category Value", type: "TYPE1", subType:"")
        item8.rowHeight = Constants.EXTENDING_CELL_HEIGHT
        item8.placeHolderText = "Select Category"
        
        var item9  = CellItem.init(name: "address", displayName: "Address", type: "TYPE1", subType:"")
        item9.rowHeight = Constants.EXTENDING_CELL_HEIGHT
        item9.placeHolderText = "Select Address"
        
        var item10 = CellItem.init(name: "tags", displayName: "Tags", type: "TYPE1", subType:"")
        item10.rowHeight = Constants.EXTENDING_CELL_HEIGHT
        item10.placeHolderText = "Select Tag how to test all tags here because its not an isssue to test"
        
        
        var item11 = CellItem.init(name: "policeFireStandingBy", displayName: "Fire/Police on Standby", type: "TYPE2", subType:"")
        item11.rowHeight = Constants.EXTENDING_CELL_HEIGHT
        
        var item12 = CellItem.init(name: "roadBlocked", displayName: "Road Blocked", type: "TYPE2", subType:"")
        item12.rowHeight = Constants.EXTENDING_CELL_HEIGHT
        
        var item13 = CellItem.init(name: "", displayName: "FR Filter", type: "TYPE5", subType:"")
        item13.rowHeight = 30
        item13.iconImageName = "fr_5_tree"
        
        var item14 = CellItem.init(name: "viewAcknowledged", displayName: "Include Acknowledged Reports", type: "TYPE2", subType:"")
        item14.rowHeight = Constants.FILTER_TABLECELL_NORML_HEIGHT
               
        var item15 = CellItem.init(name: "", displayName: "VDA Filter", type: "TYPE5", subType:"")
        item15.rowHeight = 30
        item15.iconImageName = "vda_11_tree"

        
//        var item16 = CellItem.init(name: "", displayName: "Feeder Line", type: "TYPE2", subType:"")
//        item16.rowHeight = Constants.FILTER_TABLECELL_NORML_HEIGHT
//
        var item16 = CellItem.init(name: "wireGuardStandingBy", displayName: "Wire Guard On Standby", type: "TYPE2", subType:"")
        item16.rowHeight = Constants.FILTER_TABLECELL_NORML_HEIGHT
        
        var item17 = CellItem.init(name: "feederLine", displayName: "Feeder Line", type: "TYPE1", subType:"")
        item17.rowHeight = Constants.EXTENDING_CELL_HEIGHT
        item17.placeHolderText = "select"
        
        if tabIndex == 1 {
            cellItemsArray = [item1, item2,item3, item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15,item16,item17]
        }
        
        
    }
    func  selectTab(index:Int) {
        self.selectedTabsArray.removeAll()
        if (index == 1) {
            tab1.backgroundColor = UIColor.init("0X26A69A")
            tab2.backgroundColor = .white
            tab3.backgroundColor = .white

            tab1.setTitleColor(.white, for: .normal)
            tab2.setTitleColor(UIColor.init("0X26A69A"), for: .normal)
            tab3.setTitleColor(UIColor.init("0X26A69A"), for: .normal)
            
            self.selectedTabsArray.append("FR")
            self.selectedTabsArray.append("VDA")

            //#848484
        }
        else if (index == 2) {
            
            tab1.backgroundColor = .white
            tab2.backgroundColor = UIColor.init("0X26A69A")
            tab3.backgroundColor = .white

            tab1.setTitleColor(UIColor.init("0X26A69A"), for: .normal)
            tab2.setTitleColor(.white, for: .normal)
            tab3.setTitleColor(UIColor.init("0X26A69A"), for: .normal)
            
            self.selectedTabsArray.append("FR")

        }
        if (index == 3) {
            
             tab1.backgroundColor = .white
             tab2.backgroundColor = .white
              tab3.backgroundColor = UIColor.init("0X26A69A")

            tab1.setTitleColor(UIColor.init("0X26A69A"), for: .normal)
            tab2.setTitleColor(UIColor.init("0X26A69A"), for: .normal)
            tab3.setTitleColor(.white, for: .normal)
            self.selectedTabsArray.append("VDA")

        }
    }
    
    func selectMultiselectPicker(itemsArray:NSMutableArray, selectedItemsString: String, isSingleSelect:Bool,titleString:String,keyName:String,isSearchRequired:Bool,
        showAlert:Bool, alertText:String) {
        let suggestionsVC = storyboard?.instantiateViewController(withIdentifier: "MultiSelectionListViewController") as! MultiSelectionListViewController
        suggestionsVC.items = itemsArray
        suggestionsVC.selectedDisplayString = selectedItemsString
        suggestionsVC.titleString = titleString
        suggestionsVC.isSearchRequired = isSearchRequired
        suggestionsVC.isSingleSelection = isSingleSelect
        suggestionsVC.delegate = self
        suggestionsVC.keyName = keyName
        if showAlert == true {
            suggestionsVC.shouldShowAlert = true
            suggestionsVC.alertText = alertText
        }
        else {
            suggestionsVC.shouldShowAlert = false

        }
        self.navigationController?.pushViewController(suggestionsVC, animated: true)
        print("tap working")
        
    }
    
    
    
    // MARK: UIButton Action
    @objc func backBtnOnClick(){

         self.navigationController?.popViewController(animated: true)
     }
     
     @objc func reset () {
        self.filterValueDict.removeAll()
        self.filterDisplayDict.removeAll()
         self.filterTableView.reloadData()
     }
     
    
    @IBAction func filter(_ sender:UIButton) {
        
        DataHandler.shared.filterDisplayDict = self.filterDisplayDict
        DataHandler.shared.filterValueDict = self.filterValueDict
        self.delegate?.fetchReportsWithFilter()
        self.navigationController?.popViewController(animated: true)

        
    }
    @IBAction func tabSelected(_ sender:UIButton) {
        let tag = sender.tag
        self.selectTab(index: tag)
        
       // [self selectTab:tag];
        //[self populateFilterItems:tag];
        
        
        
    }
    func showDatePicker(keyName:String, date:String) {
        
        datePicker = UIDatePicker.init()
        datePicker?.backgroundColor = UIColor.white
        datePicker?.autoresizingMask = .flexibleWidth
        datePicker?.datePickerMode = .date
        if keyName == "fromDate"{
            datePicker?.tag  = 100
        }
        else{
            datePicker?.tag  = 101

        }
        if (date != "") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  Constants.fromDateDisplayFormat
            if let _date = dateFormatter.date(from: date) {
                datePicker?.date = _date

            }
        }
        

        datePicker?.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        datePicker?.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(datePicker!)

        toolBar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar?.barStyle = .blackTranslucent
        toolBar?.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneButtonClick))]
        toolBar?.sizeToFit()
        self.view.addSubview(toolBar!)
    }

    @objc func dateChanged(_ sender: UIDatePicker?) {
        var tag  = sender?.tag as! Int
        let dateFormatter = DateFormatter()
        let dateFormatter1 = DateFormatter()

        dateFormatter.dateFormat =  Constants.fromDateDisplayFormat
        dateFormatter1.dateFormat =  Constants.fromDateValueFormat

        if let date = sender?.date {
            let displayString = dateFormatter.string(from: date)
            if (tag  == 100) {
                self.filterDisplayDict["fromDate"] = displayString
                self.filterValueDict["fromDate"] = displayString

            }
            else {
                self.filterDisplayDict["toDate"] = displayString
                self.filterValueDict["toDate"] = displayString


            }
            self.filterTableView.reloadData()
        }
    }

    @objc func onDoneButtonClick() {
        toolBar?.removeFromSuperview()
        datePicker?.removeFromSuperview()
    }
    
    
    
    
    
    // MARK: UITableview Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellItemsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var rowHeight = 0
        if let cellItem  = cellItemsArray.object(at: indexPath.row) as? CellItem {
            if cellItem.rowHeight == Constants.EXTENDING_CELL_HEIGHT {
                return UITableView.automaticDimension
                
            }
            else {
                rowHeight = cellItem.rowHeight

            }
        }
        return CGFloat(rowHeight)
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cellItem  = cellItemsArray.object(at: indexPath.row) as? CellItem {
            if (cellItem .type == "TYPE1") {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as?  Type1Cell {
                    cell.lbltitle.text = cellItem.displayName
                    if let value = self.filterDisplayDict[cellItem.name] as? String {
                        cell.lblvalue.text = value
                    }
                    else if cellItem.name == "selectedCategory" as? String {
                        cell.lblvalue.text = cellItem.placeHolderText
                        if let item = self.filterDisplayDict["selectedLocationType"] as? String {
                            if let value = self.locationSelectionDict[item] as? String {
                                if let categoryValue = self.filterDisplayDict[value] as? String {
                                    cell.lblvalue.text = categoryValue
                                }
                            }
                        }
                    }
                    else {
                        cell.lblvalue.text = cellItem.placeHolderText
                    }
                    return cell
                }
                
            }
            else if (cellItem .type == "TYPE2") {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as?  Type2Cell {
                    cell.lbltitle.text = cellItem.displayName
                    return cell
                }
            }
            else if (cellItem .type == "TYPE3") {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as?  Type3Cell {
                    cell.lbltitle.text = cellItem.displayName
                    if let value = self.filterDisplayDict[cellItem.name] as? String {
                        cell.lblValue.text = value
                    }
                    else {
                        cell.lblValue.text = ""

                    }

                    return cell
                }
            }
            else if (cellItem .type == "TYPE4") {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell4", for: indexPath) as?  Type4Cell {
                    return cell
                }
            }
            else if (cellItem .type == "TYPE5") {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell5", for: indexPath) as?  Type5Cell {
                    cell.lbltitle.text  = cellItem.displayName
                    cell.imgView.image = UIImage.init(named: cellItem.iconImageName)
                    return cell
                }
            }
            
        }
        return UITableViewCell()


    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cellItem  = cellItemsArray.object(at: indexPath.row) as? CellItem {
            switch(cellItem.name){
                case "scope":
                    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                    
                    guard let detailsController = mainStoryBoard.instantiateViewController(withIdentifier: "DamageScopeSelectionViewController") as? DamageScopeSelectionViewController else { return  }
                    detailsController.selectedReportTypes = self.selectedTabsArray
                    detailsController.delegate = self
                     self.navigationController?.pushViewController(detailsController, animated: true)
                    
                case "selectedLocationType":
                    let selectedValue = self.filterDisplayDict[cellItem.name] as? String
                    var locArray = NSMutableArray()
                    for (key,value) in self.locationSelectionDict {
                        locArray.add(key)
                        
                    }
                    self.selectMultiselectPicker(itemsArray: locArray , selectedItemsString: selectedValue ?? "" , isSingleSelect: true, titleString: "Location Category", keyName:cellItem.name,isSearchRequired: false,showAlert:false, alertText:"")
                    break
                case "submittedBy":
                    guard let cell = tableView.cellForRow(at: indexPath) as? Type1Cell else {
                        return
                    }
                    self.selectSubmittedBy(cell: cell,cellItem:cellItem)
                    break
                case "address":
                    guard let cell = tableView.cellForRow(at: indexPath) as? Type1Cell else {
                                      return
                                  }
                    self.selectAddress(cell: cell,cellItem:cellItem)
                    break
                case "tags":
                    guard let cell = tableView.cellForRow(at: indexPath) as? Type1Cell else {
                                      return
                                  }
                    self.getAllTags(cell: cell, cellItem: cellItem)
                    break
                case "selectedCategory":
                    guard let value = self.filterDisplayDict["selectedLocationType"] as? String else {
                        return
                    }
                    guard let cell = tableView.cellForRow(at: indexPath) as? Type1Cell else {
                        return
                    }
                    self.selectCategory(cell: cell,cellItem:cellItem,value: value)
                
            case "fromDate","toDate":
                let value = self.filterDisplayDict[cellItem.name] ?? ""
                self.showDatePicker(keyName: cellItem.name, date:value as! String )

          default:
                        print("ff")

        }
    }
    
    }
    func  selectCategory(cell: Type1Cell,cellItem:CellItem,value:String) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        switch(value) {
            case "Zipcode","City","State":
                     guard let detailsController = mainStoryBoard.instantiateViewController(withIdentifier: "SelectLocationCategoryController") as? SelectLocationCategoryController else { return  }
                    detailsController.selectedCategory = value
                     detailsController.titleString  = value
                     detailsController.delegate = self
                     detailsController.keyName = self.locationSelectionDict[value] ?? ""
                    self.navigationController?.pushViewController(detailsController, animated: true)
                
                break
        case "Division":
            
                if  self.divisionArray.count < 1 {
                    let apiClient  = V1ApiClient.init()
                    cell.activityIndicator.startAnimating()
                    apiClient.getLocationCategory(categoryValue:"DIVISION"){
                        result in
                        DispatchQueue.main.async {
                            cell.activityIndicator.stopAnimating()
                            
                        }
                        switch result {
                        case .Success(let _value):
                            self.divisionArray.removeAllObjects()
                            if let responseDict = _value.data {
                                if let itemsArray = responseDict["Locations"] as? [[String:Any]] {
                                    for item in itemsArray {
                                        let _item = item as [String:Any]
                                        let name = _item["division"]
                                        self.divisionArray.add(name)
                                        
                                        
                                    }
                                    DispatchQueue.main.async {
                                        if let keyName = self.locationSelectionDict[value] as? String  {
                                        self.selectMultiselectPicker(itemsArray:  self.divisionArray , selectedItemsString:  "" , isSingleSelect: true, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:false, alertText:"")
                                        }
                                    }
                                    
                                }
                                else {
                                    if let errorMessage = responseDict["Message "] as? String {
                                        if let keyName = self.locationSelectionDict[value] as? String  {
                                        self.selectMultiselectPicker(itemsArray:  self.divisionArray , selectedItemsString:  "" , isSingleSelect: true, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:true, alertText:errorMessage)
                                        }
                                    }
                                }
                            }
                        case .Failure(let error):
                                if let keyName = self.locationSelectionDict[value] as? String  {
                                    self.selectMultiselectPicker(itemsArray:  self.divisionArray , selectedItemsString:  "" , isSingleSelect: true, titleString: value, keyName:cellItem.name,isSearchRequired:true,showAlert:true, alertText:error.errormessage ?? "No Division Found")
                                }
                        default:
                            print("hi")
                        }
                    }
                    
                    
                    
            }
            else {
                    if let keyName = self.locationSelectionDict[value] as? String  {
                        self.selectMultiselectPicker(itemsArray:  self.divisionArray , selectedItemsString:  "" , isSingleSelect: true, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:false, alertText:"")
                    }
            }
            
        case "Region":
            
                if  self.regionArray.count < 1 {
                    let apiClient  = V1ApiClient.init()
                    cell.activityIndicator.startAnimating()
                    apiClient.getLocationCategory(categoryValue:"REGION"){
                        result in
                        DispatchQueue.main.async {
                            cell.activityIndicator.stopAnimating()
                            
                        }
                        switch result {
                        case .Success(let _value):
                            self.regionArray.removeAllObjects()
                            if let responseDict = _value.data {
                                if let itemsArray = responseDict["Locations"] as? [[String:Any]] {
                                    for item in itemsArray {
                                        let _item = item as [String:Any]
                                        if let name = _item["region"] as? String {
                                            self.regionArray.add(name)

                                        }
                                        
                                        
                                    }
                                    DispatchQueue.main.async {
                                        if let keyName = self.locationSelectionDict[value] as? String  {
                                        self.selectMultiselectPicker(itemsArray:  self.regionArray , selectedItemsString:  "" , isSingleSelect: true, titleString: value, keyName:cellItem.name,isSearchRequired:true,showAlert:false, alertText:"")
                                        }
                                    }
                                    
                                }
                                else {
                                        if let errorMessage = responseDict["Message"] as? String {
                                            if let keyName = self.locationSelectionDict[value] as? String  {
                                            self.selectMultiselectPicker(itemsArray:  self.divisionArray , selectedItemsString:  "" , isSingleSelect: true, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:true, alertText:errorMessage)
                                            }
                                        }
                                }
                            }

                            
                        case .Failure(let error):
                                if let keyName = self.locationSelectionDict[value] as? String  {
                                    self.selectMultiselectPicker(itemsArray:  self.regionArray , selectedItemsString:  "" , isSingleSelect: true, titleString: value, keyName:cellItem.name,isSearchRequired:true,showAlert:true, alertText:error.errormessage ?? "No Division Found")
                                                             
                            }
                        default:
                            print("hi")
                        }
                    }
                    
                    
                    
            }
            else {
                    if let keyName = self.locationSelectionDict[value] as? String  {
                        self.selectMultiselectPicker(itemsArray:  self.regionArray , selectedItemsString:  "" , isSingleSelect: true, titleString: value, keyName:cellItem.name,isSearchRequired:true,showAlert:false, alertText:"")
                    }
           }
                
        case "Platform":
                 if  self.platformArray.count < 1 {
                     let apiClient  = V1ApiClient.init()
                     cell.activityIndicator.startAnimating()
                     apiClient.getLocationCategory(categoryValue:"PLATFORM"){
                         result in
                         DispatchQueue.main.async {
                             cell.activityIndicator.stopAnimating()
                             
                         }
                         switch result {
                         case .Success(let _value):
                             self.platformArray.removeAllObjects()
                             if let responseDict = _value.data {
                                if let itemsArray = responseDict["Locations"] as? [Any] {
                                    self.platformArray.addObjects(from: itemsArray)
                                    
                                    DispatchQueue.main.async {
                                        if let keyName = self.locationSelectionDict[value] as? String  {
                                            self.selectMultiselectPicker(itemsArray:  self.platformArray , selectedItemsString:  "" , isSingleSelect: true, titleString: value, keyName:cellItem.name,isSearchRequired:true,showAlert:false, alertText:"")
                                        }
                                    }
                                }
                                else {
                                    if let errorMessage = responseDict["Message"] as? String {
                                        if let keyName = self.locationSelectionDict[value] as? String  {
                                            self.selectMultiselectPicker(itemsArray:  self.divisionArray , selectedItemsString:  "" , isSingleSelect: true, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:true, alertText:errorMessage)
                                        }
                                    }
                                }
                            }
                             else {
                                
                            }
                                    
                            
                                
                             

                             
                         case .Failure(let error):
                                 if let keyName = self.locationSelectionDict[value] as? String  {
                                     self.selectMultiselectPicker(itemsArray:  self.regionArray , selectedItemsString:  "" , isSingleSelect: true, titleString: value, keyName:cellItem.name,isSearchRequired:true,showAlert:true, alertText:error.errormessage ?? "No Division Found")
                                                              
                             }
                         default:
                             print("hi")
                         }
                     }
                     
                     
                     
             }
             else {
                     if let keyName = self.locationSelectionDict[value] as? String  {
                         self.selectMultiselectPicker(itemsArray:  self.platformArray , selectedItemsString:  "" , isSingleSelect: true, titleString: value, keyName:cellItem.name,isSearchRequired:true,showAlert:false, alertText:"")
                     }
            }
        case "County":
                 if  self.countyArray.count < 1 {
                     let apiClient  = V1ApiClient.init()
                     cell.activityIndicator.startAnimating()
                     apiClient.getLocationCategory(categoryValue:"COUNTY"){
                         result in
                         DispatchQueue.main.async {
                             cell.activityIndicator.stopAnimating()
                             
                         }
                         switch result {
                         case .Success(let _value):
                             self.countyArray.removeAllObjects()
                             if let responseDict = _value.data {
                                 if let itemsArray = responseDict["Locations"] as? [Any] {
                                    self.countyArray.addObjects(from: itemsArray)
                                     DispatchQueue.main.async {
                                         if let keyName = self.locationSelectionDict[value] as? String  {
                                         self.selectMultiselectPicker(itemsArray:  self.countyArray , selectedItemsString:  "" , isSingleSelect: true, titleString: value, keyName:cellItem.name,isSearchRequired:true,showAlert:false, alertText:"")
                                         }
                                     }
                                     
                                 }
                                 else {
                                         if let errorMessage = responseDict["Message"] as? String {
                                             if let keyName = self.locationSelectionDict[value] as? String  {
                                             self.selectMultiselectPicker(itemsArray:  self.countyArray , selectedItemsString:  "" , isSingleSelect: true, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:true, alertText:errorMessage)
                                             }
                                         }
                                 }
                             }

                             
                         case .Failure(let error):
                                 if let keyName = self.locationSelectionDict[value] as? String  {
                                     self.selectMultiselectPicker(itemsArray:  self.countyArray , selectedItemsString:  "" , isSingleSelect: true, titleString: value, keyName:cellItem.name,isSearchRequired:true,showAlert:true, alertText:error.errormessage ?? "No Division Found")
                                                              
                             }
                         default:
                             print("hi")
                         }
                     }
                     
                     
                     
             }
             else {
                     if let keyName = self.locationSelectionDict[value] as? String  {
                         self.selectMultiselectPicker(itemsArray:  self.regionArray , selectedItemsString:  "" , isSingleSelect: true, titleString: value, keyName:cellItem.name,isSearchRequired:true,showAlert:false, alertText:"")
                     }
            }
        default:
             print("")
            
            
        }
        
    }

    
    func selectAddress(cell:Type1Cell,cellItem:CellItem){
            if  self.addressArray.count < 1 {
                let apiClient  = V2ApiClient.init()
                cell.activityIndicator.startAnimating()
                apiClient.getAllAddress(params: ""){
                    result in
                    DispatchQueue.main.async {
                        cell.activityIndicator.stopAnimating()
                        
                    }
                    switch result {
                    case .Success(let value):
                        self.addressArray.removeAllObjects()
                        if let responseDict = value.data {
                            if let itemsObjArray = responseDict["messageObj"] as? [[String:Any]] {
                                if  let arrayObj = itemsObjArray[0] as? [String:Any] {
                                if let itemsArray = arrayObj["uniqueAddressList"] as? [Any] {
                                    self.addressArray.addObjects(from: itemsArray)
                                DispatchQueue.main.async {
                                    self.selectMultiselectPicker(itemsArray:  self.addressArray , selectedItemsString:  "" , isSingleSelect: true, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:false, alertText:"")
                                }
//                                
                            }
                        }
                        }
                        else {
                                DispatchQueue.main.async {
                                    self.selectMultiselectPicker(itemsArray:  self.addressArray , selectedItemsString:  "" , isSingleSelect: true, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:true, alertText:"No Addess found")
                                }
                         }
                        }
                    case .Failure(let error):
                        DispatchQueue.main.async {
                            self.selectMultiselectPicker(itemsArray:  self.addressArray , selectedItemsString:  "" , isSingleSelect: true, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:true, alertText:error.errormessage ?? "")
                                                      
                        
                        }
                        break
                        
                    default:
                        print("hi")
                    }
                }
                
                
                
        }
        else {
                 self.selectMultiselectPicker(itemsArray:  self.addressArray , selectedItemsString:  "" , isSingleSelect: true, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert: false,alertText: "")
        }
    }
    
    func getAllTags(cell:Type1Cell,cellItem:CellItem){
        if  self.tagsArray.count < 1 {
                    let apiClient  = V2ApiClient.init()
                    cell.activityIndicator.startAnimating()
                    apiClient.getAllTags(){
                        result in
                        DispatchQueue.main.async {
                            cell.activityIndicator.stopAnimating()
                            
                        }
                        switch result {
                        case .Success(let value):
                            if let responseDict = value.data {
                                self.tagsArray.removeAll()
                                if let itemsObjArray = responseDict["messageObj"] as? [[String:Any]] {
                                    self.tagsArray.append(contentsOf: itemsObjArray)
                                }
                                if  self.tagsArray.count > 0 {
                                    var displayItems = NSMutableArray()
                                    for  item in self.tagsArray {
                                        if self.selectedTabsArray.count > 1 {
                                            displayItems.add(item["tag_name"])
                                        }
                                        else {
                                            if self.selectedTabsArray[0] == "FR" {
                                                if (item["tag_type"] as! String ) == "DAMAGE_REPORT" {
                                                    displayItems.add(item["tag_name"])

                                                }
                                            }
                                            else {
                                                if (item["tag_type"] as! String ) == "VDA_REPORT" {
                                                    displayItems.add(item["tag_name"])

                                                }
                                            }
                                        }
                                     
                                        
                                    }
                                    if  displayItems.count > 0 {
                                    DispatchQueue.main.async {
                                    self.selectMultiselectPicker(itemsArray:  displayItems , selectedItemsString:  "" , isSingleSelect: false, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:false, alertText:"")
                                    }
                                    
                                    
                                }
                                
                                

                                }
                            }
                          
                        case .Failure(let error):
                            DispatchQueue.main.async {
                            self.selectMultiselectPicker(itemsArray:  [] , selectedItemsString:  "" , isSingleSelect: false, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:true, alertText:error.errormessage ?? "No Tags Found")
                            }
                            
                        default:
                            print("hi")
                        }
                    }
                    
                    
                    
            }
            else {
            
                         var displayItems = NSMutableArray()
                         for  item in self.tagsArray {
                             if self.selectedTabsArray.count > 1 {
                                 displayItems.add(item["tag_name"])
                             }
                             else {
                                 if self.selectedTabsArray[0] == "FR" {
                                     if (item["tag_type"] as! String ) == "DAMAGE_REPORT" {
                                         displayItems.add(item["tag_name"])

                                     }
                                 }
                                 else {
                                     if (item["tag_type"] as! String ) == "VDA_REPORT" {
                                         displayItems.add(item["tag_name"])

                                     }
                                 }
                             }
                          
                             
                         }
                         if  displayItems.count > 0 {
                         DispatchQueue.main.async {
                         self.selectMultiselectPicker(itemsArray:  displayItems , selectedItemsString:  "" , isSingleSelect: false, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:false, alertText:"")
                         }
                         
                         
                     }
                     
                     

            }
        }
    
    func selectSubmittedBy(cell:Type1Cell,cellItem:CellItem){
            if  self.selectedSubmittedByArray.count < 1 {
                let apiClient  = V2ApiClient.init()
                cell.activityIndicator.startAnimating()
                apiClient.getAllSubmittedBy(params: self.selectedTabsArray) {
                    result in
                    DispatchQueue.main.async {
                        cell.activityIndicator.stopAnimating()
                        
                    }
                    switch result {
                    case .Success(let value):
                        self.selectedSubmittedByArray.removeAllObjects()
                        if let responseDict = value.data {
                            if let itemsArray = responseDict["userDetails"] as? [[String:Any]] {
                                for item in itemsArray {
                                    let _item = item as [String:Any]
                                    let name = "\(_item["first_name"]!) \(_item["last_name"]!)"
                                    self.selectedSubmittedByArray.add(name)
                                    
                                    
                                }
                                DispatchQueue.main.async {
                                    self.selectMultiselectPicker(itemsArray:  self.selectedSubmittedByArray , selectedItemsString:  "" , isSingleSelect: true, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert:false, alertText:"")
                                }
                                
                            }
                        }
                        
                    case .Failure(let error): break
                        
                    default:
                        print("hi")
                    }
                }
                
                
                
        }
        else {
                 self.selectMultiselectPicker(itemsArray:  self.selectedSubmittedByArray , selectedItemsString:  "" , isSingleSelect: true, titleString: cellItem.displayName, keyName:cellItem.name,isSearchRequired:true,showAlert: false,alertText: "")
        }
    }
    
    
    // MARK:  Filter Delegate
    func didSelectItem(selectedDisplayString: String, keyName: String) {
         if keyName != ""  && selectedDisplayString != "" {
              if keyName == "selectedCategory" {
                if let key = filterDisplayDict["selectedLocationType"] as? String {
                    let value  = self.locationSelectionDict [key]
                    self.filterDisplayDict [value ?? ""] = selectedDisplayString
                }

              }
              else{
                self.filterValueDict [keyName] = selectedDisplayString
                self.filterDisplayDict [keyName] = selectedDisplayString

              }
          }
        
          self.filterTableView.reloadData()
     }
    // MARK:  Location Category

    func didSelectItemFromLocation(selectedDisplayString: String, keyName: String) {
            if keyName != ""  && selectedDisplayString != "" {
                 self.filterDisplayDict [keyName] = selectedDisplayString
            }
            self.filterTableView.reloadData()

       }
    
    // MARK:  Scope
     func didSelectScopesAndPart(scopes: [String], parts: [String]) {
        self.filterValueDict["damageType"] = scopes
        self.filterValueDict["frFilterDamageParts"] = parts

     }
     
    
       
}
extension UIButton {
    enum ViewSide {
        case left, right, top, bottom
    }
    
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height)
        case .right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height)
        case .top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness)
        case .bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness)
        }
        
        layer.addSublayer(border)
    }
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

class Type1Cell : UITableViewCell {
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var lblvalue: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


}

class Type2Cell : UITableViewCell {
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var yesNoSwitch: UILabel!

}

class Type3Cell : UITableViewCell {  //// TextFiled Input - Date
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var lblValue: UITextField!

}

class Type4Cell : UITableViewCell {
   
}

class Type5Cell : UITableViewCell {
   @IBOutlet var imgView: UIImageView!
   @IBOutlet weak var lbltitle: UILabel!
}

class Type6Cell : UITableViewCell {
   @IBOutlet  var lbltitle: UILabel!
   @IBOutlet weak var lblValue: UITextField!
}





struct CellItem  {
    var name:String
    var displayName:String
    var type:String
    var subType:String
    var placeHolderText = ""
    var iconImageName = ""
    var rowHeight = 0
    init(name:String ,displayName:String, type:String, subType:String) {
        self.name = name
        self.displayName = displayName
        self.type = type
        self.subType  = subType
        
    }
    
}
