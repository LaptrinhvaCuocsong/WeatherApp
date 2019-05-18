//
//  WeatherService.swift
//  Clima
//
//  Created by nguyen manh hung on 5/17/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WeatherService: NSObject {

    //Constants
    let WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "c54d3b93d438ae8eadba14bbbe6a58c3"
    
    public static let share = WeatherService()
    
    public func getWeatherData(_ lat: Double, _ lon: Double,_ completion: ((WeatherDataModel?) -> Void)?) {
        let params: [String:Any] = ["lat": lat, "lon": lon, "appid": APP_ID]
        let dataReq: DataRequest = Alamofire.request(URL(string: WEATHER_URL)!,
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: nil)
        dataReq.responseJSON(queue: DispatchQueue.main,
                             options: .allowFragments) { dataResponse in
            if dataResponse.result.isSuccess {
                if let value = dataResponse.result.value {
                    let jsonObject = JSON(value)
                    let weatherDataModel = WeatherDataModel()
                    weatherDataModel.condition = jsonObject["weather"][0]["id"].int
                    weatherDataModel.temperature = jsonObject["main"]["temp"].double
                    weatherDataModel.iconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition ?? Int.min)
                    if completion != nil {
                        completion!(weatherDataModel)
                    }
                }
            }
            else {
                print("error: \(dataResponse.result.error.debugDescription)")
            }
        }
    }
    
}
