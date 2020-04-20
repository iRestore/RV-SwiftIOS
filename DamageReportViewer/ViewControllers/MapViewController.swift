//
//  MapViewController.swift
//  DamageReportViewer
//
//  Created by Greeshma Mullakkara on 07/01/20.
//  Copyright © 2020 iRestoreApp. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class MapViewController: MainViewController,GMSMapViewDelegate,FilterReportsDelegate,CLLocationManagerDelegate {
    @IBOutlet var  googleMapView : GMSMapView!
    @IBOutlet var filterBtn: UIButton!
    var isloading: Bool = false
    var activityIndicator =  ActivityIndicator()
    var currentLocation : CLLocation?
    private let locationManager = CLLocationManager()
    override func viewDidLoad() {
           super.viewDidLoad()
            enableCurrentLocation()

    }
    override func viewDidAppear(_ animated: Bool) {
        let filterDict = DataHandler.shared.filterValueDict
        if(filterDict.count > 1) {
            self.filterBtn.setImage(UIImage.init(named: "filter_active"), for: .normal)

        }
        else {
            self.filterBtn.setImage(UIImage.init(named: "filter"), for: .normal)
        }
        getCordinates()
        googleMapView.delegate = self
        //googleMapView.isMyLocationEnabled = true

    }
    
    func enableCurrentLocation() {
        
        if(locationManager == nil) {
            
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
            }
            
        }
        if let latLong = self.getAddressDict() as? CLLocation  {
            currentLocation = latLong
        }
    }
    func getAddressDict() -> CLLocation?
       {
           var currentLocation: CLLocation
           
           if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
               CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
               
               if let loc = locationManager.location {
                   
                   currentLocation = loc
                    return currentLocation

               }
               else{
                    return nil
                }
              
           }
           else {
              return nil

               
           }
       }
    
    
    @IBAction func btnFilterClicked(_ sender:UIButton ){
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailsController = mainStoryBoard.instantiateViewController(withIdentifier: "NewFilterViewController") as? NewFilterViewController else { return  }
        detailsController.delegate = self
        self.navigationController?.pushViewController(detailsController, animated: true)
        
    }
    func fetchReportsWithFilter() {
//            isloading = true
//            currentPage = 1
//            self.isFilterApplied = true
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
    //            self.filterBtn.setImage(UIImage.init(named: "filter"), for: .normal)
    //        isloading = true
    //        currentPage = 1
    //        self.isFilterApplied = true
    //        self.getReports(isDeleteDelta:true)
    }
    func getReports(isDeleteDelta:Bool) {
        activityIndicator.showActivityIndicator(uiView: self.view)
        self.isloading = true
        MainViewController.isFilterAppliedInTabs = true
        self.getAllReports(page: 1, isdeleteDelta: isDeleteDelta, isFilterApplied: true, isSortDescending: true)
        {
            result in
            
            DispatchQueue.main.async {
                self.activityIndicator.hideActivityIndicator(uiView: self.view)
                //self.isDataFinished = false
                self.isloading = false
            }
            switch result {

            case .Data( _):
                DispatchQueue.main.async {
                    self.getCordinates()
//                    self.noReportsLabel.isHidden = true
//                    self.tblView.isHidden = false
//                    self.tblView.reloadData()
//                    self.isDataFinished = true
                }
                break
            case .NoData( _):
//                if self.currentPage != 1  {
//                    self.isloading = false
//                }
//                else {
//                    DispatchQueue.main.async {
//                        self.tblView.isHidden = true
//                        self.noReportsLabel.isHidden = false
//                    }
//                }
                break
            case .TimeOut( _):
                break
            case .ServerError(let value):
                break
                
                
                
            }
            
        }
    }
    
    func getCordinates () {
        var index = 0
        let bounds = GMSCoordinateBounds.init()
        googleMapView.clear()
        for item in MainViewController.self.reportArray {
            if let  reportData = item as? ReportData {
                let marker = GMSMarker.init()
                marker.position = CLLocationCoordinate2D.init(latitude: reportData.latitude ?? 0.0, longitude: reportData.longitude ?? 0.0)
                marker.userData = index
                marker.snippet = reportData.userAddress
                marker.title = reportData.damageTypeDisplayName as? String
                marker.map = googleMapView

                index  = index + 1
                let pinName = "pin_\(reportData.damageType!)"
                marker.icon = UIImage.init(named: pinName)
                bounds.includingCoordinate( marker.position)
            }
           

        }
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation?.coordinate.latitude ?? 0, longitude: currentLocation?.coordinate.longitude ?? 0, zoom: 10)
        googleMapView?.camera = camera
        googleMapView?.animate(to: camera)
       // googleMapView.animate(with: GMSCameraUpdate.fit(bounds))
        
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("didTapInfoWindowOfMarker")
        if let index = marker.userData as? Int {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let reportData:ReportData = MainViewController.reportArray[index]
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
        //let storeMarker = marker as StoreMarker
        //performSegueWithIdentifier("productMenu", sender: storeMarker.store)
    }
    

    func mapView(mapView: GMSMapView!, didTapOverlay marker: GMSMarker!) {
        //let storeMarker = marker as StoreMarker
        //performSegueWithIdentifier("productMenu", sender: storeMarker.store)
    }
    
}
