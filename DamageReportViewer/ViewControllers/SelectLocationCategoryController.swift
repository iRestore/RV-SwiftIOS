//
//  SelectLocationCategoryController.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 23/01/20.
//  Copyright © 2020 iRestoreApp. All rights reserved.
//

import UIKit
import GooglePlaces

class SelectLocationCategoryController:UIViewController,UIGestureRecognizerDelegate,GMSAutocompleteViewControllerDelegate {

    
    @IBOutlet  var lblTitle:UILabel!
     var titleString: String?
     var selectedCategory:String?
     var delegate : LocationCategoryPlacesAPIDelegate?
     var keyName:String = ""
     override func viewDidLoad() {
        navigationBarSettings()
        GMSPlacesClient.provideAPIKey("AIzaSyDyl4k5gUWEubmujgz7hRaggulHMrK0AUA")

        lblTitle.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(googleAPi))
        lblTitle.addGestureRecognizer(tap)
        
    }
    
    
    func navigationBarSettings() {

        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.isTranslucent = false
        

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
        self.delegate?.didSelectItemFromLocation(selectedDisplayString: self.lblTitle.text ?? "", keyName: keyName)
        self.navigationController?.popViewController(animated: true)
    }
    @objc  func googleAPi() {
        let autocompleteController = GMSAutocompleteViewController()
               autocompleteController.delegate = self as! GMSAutocompleteViewControllerDelegate
               //autocompleteController.searc
               let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.formattedAddress.rawValue) |
                UInt(GMSPlaceField.placeID.rawValue)|UInt(GMSPlaceField.addressComponents.rawValue))!
               autocompleteController.placeFields = fields
               
               // Specify a filter.
               let filter = GMSAutocompleteFilter()
                if self.selectedCategory == "City"  || self.selectedCategory == "State" || self.selectedCategory == "Zipcode" {
                    filter.type = .region
                }
               
               autocompleteController.autocompleteFilter = filter
               // Display the autocomplete view controller.
               present(autocompleteController, animated: true, completion: nil)
//               activeAddressView = tapGestureRecognizer.view as! UILabel
        
    }
    // MARK:
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print(place.formattedAddress)
        print(place.addressComponents)
        var text = ""
        for component in place.addressComponents ?? [] {
            let _comp  = component as! GMSAddressComponent
            let type : String = _comp.types.joined(separator: ",")
             if self.selectedCategory == "City"  {
                
                if type == "locality,political" {
                    text = text.appending(component.name)
                }
                if type == "administrative_area_level_1,political" {
                    let _text = ",\(component.name)"
                    text = text.appending(_text)
//                    print(component.name)
                }
            }
            else if self.selectedCategory == "Zipcode"  {
                if type == "postal_code" {
                    text = text.appending(component.name)
//                    self.lblTitle.text  = component.name
                    break
                }
            }
             else if self.selectedCategory == "State"  {
                    if type == "administrative_area_level_1,political" {
                        text = text.appending(component.name)
                        break
                    }
            }
            

         }
         self.lblTitle.text  = text
        dismiss(animated: true, completion: nil)

        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)

        
    }
}
