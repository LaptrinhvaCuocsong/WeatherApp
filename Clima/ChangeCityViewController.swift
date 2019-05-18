//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


//Write the protocol declaration here:



class ChangeCityViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UIButton!
    
    let locationManager = CLLocationManager()
    var locationServiceEnable = false
    let clGeocoder = CLGeocoder()
    let showGetWeatherBtn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationServiceEnable = checkLocationService()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthorizationStatus()
    }
    
    //MARK: - IBAction
    /***************************************************************/
    
    @IBAction func addressLabelPressed(_ sender: Any) {
        
    }
    
    
    //MARK: - Setting Location Service
    /***************************************************************/
    
    func checkLocationService() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            return true
        }
        return false
    }
    
    func checkAuthorizationStatus() {
        if locationServiceEnable {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                fallthrough
            case .authorizedAlways:
                startUpdateLocation()
                break
            default:
                break
            }
        }
    }
    
    func startUpdateLocation() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func geocoding(_ location: CLLocation, _ completion: (((AddressDataModel)?) -> Void)?) {
        if !clGeocoder.isGeocoding {
            clGeocoder.reverseGeocodeLocation(location) { clPlacemarks, error in
                if error == nil {
                    if let placemark = clPlacemarks?.last {
                        let addressDataModel = AddressDataModel()
                        addressDataModel.city = placemark.locality
                        addressDataModel.country = placemark.country
                        if completion != nil {
                            completion!(addressDataModel)
                        }
                    }
                }
            }
        }
    }
    
    //Declare the delegate variable here:
    

    //This is the IBAction that gets called when the user taps the back button. It dismisses the ChangeCityViewController.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ChangeCityViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let coordinate = mapView.centerCoordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        weak var weakSelf = self
        geocoding(location) { addressDataModel in
            var a = [String]()
            let city = (addressDataModel!.city != nil) ? addressDataModel!.city! : ""
            if city != "" {
                a.append(city)
            }
            let country = (addressDataModel!.country != nil) ? addressDataModel!.country! : ""
            if country != "" {
                a.append(country)
            }
            weakSelf?.addressLabel.setTitle(a.joined(separator: ", "), for: .normal)
        }
    }
    
}

extension ChangeCityViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last {
            let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000000.0, 1000000.0)
            mapView.setRegion(region, animated: true)
        }
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
}
