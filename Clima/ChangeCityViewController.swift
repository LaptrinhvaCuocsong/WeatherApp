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
protocol ChangeCityDelegate: class {
    func updateWeatherForLocation(_ location: CLLocation)
    func closeViewController()
}


class ChangeCityViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UIButton!
    @IBOutlet weak var getWeatherBtn: UIButton!
    
    let clGeocoder = CLGeocoder()
    let showGetWeatherBtn = true
    var location: CLLocation?
    var previusLocation: CLLocation?
    
    //Declare the delegate variable here:
    weak var delegate: ChangeCityDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getWeatherBtn.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let l = location {
            let region = MKCoordinateRegionMakeWithDistance(l.coordinate, 100000.0, 100000.0)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //MARK: - IBAction
    /***************************************************************/
    
    @IBAction func addressLabelPressed(_ sender: Any) {
        if getWeatherBtn.isHidden {
            getWeatherBtn.isHidden = false
            let frame = getWeatherBtn.frame
            let frameOfAddressLB = addressLabel.frame
            getWeatherBtn.frame = frameOfAddressLB
            weak var weakSelf = self
            UIView.animate(withDuration: 0.2) {
                weakSelf?.getWeatherBtn.frame = frame
            }
        }
        else {
            getWeatherBtn.isHidden = true
        }
    }
    
    @IBAction func getWeatherBtnPressed(_ sender: Any) {
        delegate?.updateWeatherForLocation(CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))
        delegate?.closeViewController()
    }
    
    //This is the IBAction that gets called when the user taps the back button. It dismisses the ChangeCityViewController.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - CLGeocoder
    /***************************************************************/
    
    func geocoding(_ location: CLLocation, _ completion: (((AddressDataModel)?) -> Void)?) {
        if !clGeocoder.isGeocoding {
            if let pl = previusLocation {
                if location.distance(from: pl) < 100.0 {
                    return
                }
            }
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
