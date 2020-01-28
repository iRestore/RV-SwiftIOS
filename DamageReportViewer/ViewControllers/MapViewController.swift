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

class MapViewController: MainViewController,GMSMapViewDelegate {
    @IBOutlet var  googleMapView : GMSMapView!
    private let locationManager = CLLocationManager()
    override func viewDidLoad() {
           super.viewDidLoad()

    }
    override func viewDidAppear(_ animated: Bool) {
        getCordinates()
      //  googleMapView.isMyLocationEnabled = true
        googleMapView.delegate = self

    }
    @IBAction func btnFilterClicked(_ sender:UIButton ){
        
    }
    func getCordinates () {
        var index = 0
        let bounds = GMSCoordinateBounds.init()
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
        googleMapView.animate(with: GMSCameraUpdate.fit(bounds))
        
        
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        print("didTapInfoWindowOfMarker")
        //let storeMarker = marker as StoreMarker
        //performSegueWithIdentifier("productMenu", sender: storeMarker.store)
    }
    

    func mapView(mapView: GMSMapView!, didTapOverlay marker: GMSMarker!) {
        //let storeMarker = marker as StoreMarker
        //performSegueWithIdentifier("productMenu", sender: storeMarker.store)
    }
    
}
