//
//  MultiSelectionListViewController.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 23/01/20.
//  Copyright © 2020 iRestoreApp. All rights reserved.
//

import UIKit
class MultiSelectionListViewController:UITableViewController,UISearchResultsUpdating
{

//    @IBOutlet weak var searchBar: UISearchBar!
    var resultSearchController = UISearchController()
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var alertLabel: UILabel!

    var items: NSMutableArray?
    var filteredItems: NSMutableArray?
    var titleString: String?
    var keyName: String?
    var isSingleSelection:Bool = true
    var isSearchRequired:Bool = false
    var selectedDisplayString: String?
    var selectedDisplayItems: [String]?
    var delegate : FilterDelegate?
    var selectedIndexPath : IndexPath?
    var selectedNotTestedCellIndexPath : IndexPath?
    var alertText :String = ""
    var shouldShowAlert:Bool = false
    var isResetRequired:Bool = false

    let  NOT_TESTED = "Not-Tested"

    override func viewDidLoad() {
        if selectedDisplayString != "" {
            selectedDisplayItems = selectedDisplayString?.components(separatedBy: ",")
        }
        else {
            selectedDisplayItems = [String]()
        }
        if shouldShowAlert || self.items?.count ?? 0 < 1  {
            self.alertLabel.isHidden = false
            self.alertLabel.text = self.alertText
        }
        else {
            self.alertLabel.isHidden = true
        }
        
        
        //self.navigationItem.title = titleString
        navigationBarSettings()
        
        if isSearchRequired == true {
            resultSearchController = ({
                let controller = UISearchController(searchResultsController: nil)
                controller.searchResultsUpdater = self
                controller.dimsBackgroundDuringPresentation = false
                controller.searchBar.sizeToFit()
                tableView.tableHeaderView = controller.searchBar
                return controller
            })()
        }
        
    }
    func navigationBarSettings() {
//
//         self.navigationController?.navigationBar.isHidden = false
//         self.navigationController?.navigationItem.hidesBackButton = false
//         self.navigationController?.navigationBar.isTranslucent = false
         

         let navigationBarAppearace = UINavigationBar.appearance()
         navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 15.0) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationItem.title = titleString // NSLocalizedString("Damage Reports", comment: "")
         
         var backButton: UIButton
         var leftBarBtnItem : UIBarButtonItem
         backButton = UIButton.init(type: UIButton.ButtonType.custom)
         backButton.setImage(UIImage.init(named: "back_green"), for: UIControl.State.normal)
         backButton.addTarget(self, action: #selector(backBtnOnClick), for: .touchUpInside)
         backButton.sizeToFit()
         leftBarBtnItem = UIBarButtonItem.init(customView: backButton)
         self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        if isResetRequired == true {
            let submitBtn = UIButton(type: .custom)
            submitBtn.setTitle("Reset", for: .normal)
            submitBtn.setTitleColor(UIColor.white, for: .normal)
            submitBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
            submitBtn.addTarget(self, action: #selector(reset), for: .touchUpInside)
            let submitItem = UIBarButtonItem(customView: submitBtn)
            self.navigationItem.setRightBarButton(submitItem, animated: true)
        }
        

     }
    
    @objc func backBtnOnClick(){
        self.selectedDisplayString = self.selectedDisplayItems?.joined(separator: ",")
        delegate?.didSelectItem(selectedDisplayString: selectedDisplayString ?? "",keyName: keyName ?? "")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func reset () {
        
   
        self.selectedDisplayItems?.removeAll()
        self.listTableView.reloadData()
    }
    
    //MARK: Search Delegates
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        if let array = self.items?.filtered(using: searchPredicate) {
            self.filteredItems =  NSMutableArray(array:array)
            selectedIndexPath = nil // this is to reset the selected index pta
            self.listTableView.reloadData()
        }
       
    }
    
    //MARK: TableView Delegates
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if  (resultSearchController.isActive) {
            return self.filteredItems?.count ?? 0
        } else {
            return items?.count ?? 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "multiSelectionCell", for: indexPath)
         cell.accessoryType = .none
        
        var displayName:String?
        if  (resultSearchController.isActive) {
           displayName = self.filteredItems?.object(at: indexPath.row) as? String
        } else {
            displayName = self.items?.object(at: indexPath.row) as? String

        }
        
        if let displayName = displayName as? String {
            cell.textLabel?.text = displayName
            cell.textLabel?.font = UIFont(name: "Avenir-Book", size: 15)
            cell.textLabel?.numberOfLines = 0
            if let items = self.selectedDisplayItems as? [String] {
                let subString = cell.textLabel?.text as! String
                if items.contains(subString) {
                   cell.accessoryType = .checkmark
                    if selectedIndexPath == nil {
                        selectedIndexPath = indexPath
                    }
                    if subString == NOT_TESTED {
                        selectedNotTestedCellIndexPath = indexPath
                    }
                }
            }
           
            
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            var _displayName:String?
            if  (resultSearchController.isActive) {
                _displayName = self.filteredItems?.object(at: indexPath.row) as? String
            } else {
                _displayName = self.items?.object(at: indexPath.row) as? String
            }
            if let displayName = _displayName as? String {
                if isSingleSelection == true {
                    if selectedIndexPath != nil, let prevSelectedCell =  tableView.cellForRow(at: selectedIndexPath!)
                    {
                        prevSelectedCell.accessoryType = .none
                    }
                    self.selectedDisplayItems?.removeAll()
                    self.selectedDisplayItems?.append(displayName)
                    cell.accessoryType = .checkmark
                    selectedIndexPath = indexPath
                    
                }
                else {
                    
                    if cell.accessoryType == .checkmark {
                        cell.accessoryType = .none
                    }
                    else {
                        cell.accessoryType = .checkmark
                    }
                    //Special Case: Handling NOT Tested Senario
                    //*** : Begin
                    if keyName == "inspectionFrequency"{
                        //If we select "Not-Tested", unselect all other frequencies
                        if displayName == NOT_TESTED {
                            if let items = self.selectedDisplayItems {
                                 if items.contains(displayName ) {
                                    let index = items.firstIndex(of: displayName )
                                    self.selectedDisplayItems?.remove(at:index! )
                                 }
                                 else {
                                    self.selectedDisplayItems?.removeAll()
                                    self.selectedDisplayItems?.append(displayName )
                                    let cells =  tableView.visibleCells
                                    for _cell in cells {
                                        _cell.accessoryType  = .none
                                    }
                                    cell.accessoryType = .checkmark
                                    selectedNotTestedCellIndexPath = indexPath
                                }
                            }
                        }
                        else{
                            if let items = self.selectedDisplayItems {
                                if items.contains(NOT_TESTED) {
                                    if selectedNotTestedCellIndexPath != nil, let prevSelectedCell =  tableView.cellForRow(at: selectedNotTestedCellIndexPath!)
                                    {
                                        let index = items.firstIndex(of: NOT_TESTED )
                                        self.selectedDisplayItems?.remove(at:index! )
                                        prevSelectedCell.accessoryType = .none
                                    }
                                }
                                if items.contains(displayName ) {
                                        let index = items.firstIndex(of: displayName )
                                        self.selectedDisplayItems?.remove(at:index! )
                                    }
                                    else {
                                        self.selectedDisplayItems?.append(displayName )
                                    }
                                
                            }
                            else {
                                self.selectedDisplayItems?.append(displayName )
                                
                            }
                            
                        }
                        
                    }
                    //*** : End
                    else {
                        if let items = self.selectedDisplayItems {
                            if items.contains(displayName ) {
                                let index = items.firstIndex(of: displayName )
                                self.selectedDisplayItems?.remove(at:index! )
                            }
                            else{
                                self.selectedDisplayItems?.append(displayName )
                            }
                            
                        }
                        else {
                            self.selectedDisplayItems?.append(displayName )
                            
                        }
                    }

                    
                }

                
            }
            
            

        }
//        if  (resultSearchController.isActive) {
//            resultSearchController.isActive = false
//        }

        
    }
   
}
