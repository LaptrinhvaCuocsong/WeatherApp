//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let clGeocoder = CLGeocoder()
    var locationServiceEnable = false
    var theFirstOpenWeatherVC = true
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO:Set up the location manager here.
        locationServiceEnable = checkLocationService()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if theFirstOpenWeatherVC {
            checkAuthorizationStatus()
            theFirstOpenWeatherVC = false
        }
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
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                fallthrough
            case .denied:
                requestAuthorizationWhenDinied()
                break
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
    
    func requestAuthorizationWhenDinied() {
        present(AlertService.alertRequestOpenSetting(title: "Chúng tôi cần biết vị trị hiện tại của bạn",
                                                     message: "",
                                                     actionCancel: {
            
        }),animated: true, completion: nil)
    }
    
    func startUpdateLocation() {
        if locationServiceEnable {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
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
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    

    
    //Write the PrepareForSegue Method here
    
    
    
    
    
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last {
            weak var weakSelf = self
            self.geocoding(userLocation) { addressDataModel in
                if addressDataModel != nil {
                    var a = [String]()
                    let city = (addressDataModel!.city != nil) ? addressDataModel!.city! : ""
                    if city != "" {
                        a.append(city)
                    }
                    let country = (addressDataModel!.country != nil) ? addressDataModel!.country! : ""
                    if country != "" {
                        a.append(country)
                    }
                    weakSelf?.cityLabel.text = a.joined(separator: ", ")
                }
            }
            WeatherService.share.getWeatherData(userLocation.coordinate.latitude, userLocation.coordinate.longitude) { weatherDataModel in
                if weatherDataModel != nil {
                    weakSelf?.temperatureLabel.text = (weatherDataModel!.temperature != nil) ? "\(Int(weatherDataModel!.convertKelvinToCelsius(weatherDataModel!.temperature!)))ºC" : "..."
                    weakSelf?.weatherIcon.image = UIImage.init(named: weatherDataModel?.iconName ?? "dunno")
                }
            }
        }
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
}
