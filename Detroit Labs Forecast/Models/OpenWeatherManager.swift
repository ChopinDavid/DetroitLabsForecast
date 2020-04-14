//
//  OpenWeatherManager.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import CoreLocation

class OpenWeatherManager {
    //I will generally use a singleton pattern when dealing with an API
    static let shared: OpenWeatherManager = OpenWeatherManager()
    
    let apiKey: String = "67efa96997e6ab79b95e04a4f24f038e"
    
    func getSnapshot(from coordinates: CLLocationCoordinate2D, completion: @escaping (WeatherSnapshot?, Error?) -> Void) {
        let urlString: String = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&units=imperial&appid=\(apiKey)"
        print(urlString)
        let request = URLRequest(url: URL(string: urlString)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let unwrappedData = data else {
                return
            }
            guard let jsonObject = try? (JSONSerialization.jsonObject(with: unwrappedData, options: []) as! [String:Any]) else {
                return
            }
            let snapshot: WeatherSnapshot = WeatherSnapshot(dict: jsonObject)
            completion(snapshot, nil)
        }
        task.resume()
    }
    
    func getFiveDayForecast(from coordinates: CLLocationCoordinate2D, completion: @escaping ([Int]?, [WeatherSnapshot]?, Error?) -> Void) {
        let urlString: String = "https://api.openweathermap.org/data/2.5/forecast?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&units=imperial&appid=\(apiKey)"
        print(urlString)
        let request = URLRequest(url: URL(string: urlString)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let unwrappedData = data else {
                return
            }
            guard let jsonObject = try? (JSONSerialization.jsonObject(with: unwrappedData, options: []) as! [String:Any]) else {
                return
            }
            completion(WeatherSnapshot.array(from: jsonObject).0, WeatherSnapshot.array(from: jsonObject).1, nil)
        }
        task.resume()
    }
}
