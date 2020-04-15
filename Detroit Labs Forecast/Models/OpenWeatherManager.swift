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
    
    //Get snapshot lets us pass a coordinate aand get the corresponding weather snapshot
    //This method is used for the current temperature OpenWeather API request
    func getSnapshot(from coordinates: CLLocationCoordinate2D, completion: @escaping (WeatherSnapshot?, Error?) -> Void) {
        let urlString: String = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&units=imperial&appid=\(apiKey)"
        print(urlString)
        let request: URLRequest = URLRequest(url: URL(string: urlString)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            guard let unwrappedData: Data = data else {
                completion(nil, OpenWeatherError.badData)
                return
            }
            guard let jsonObject: [String:Any] = try? (JSONSerialization.jsonObject(with: unwrappedData, options: []) as! [String:Any]) else {
                completion(nil, OpenWeatherError.badData)
                return
            }
            let snapshot: WeatherSnapshot = WeatherSnapshot(dict: jsonObject)
            completion(snapshot, nil)
        }
        task.resume()
    }
    
    //As the name implies, this method returns the an array of the ordinal days of the year and corresponding 3-hour weather snapshots for those days
    //This method makes use of OpenWeathers 5 day forecast endpoint
    func getFiveDayForecast(from coordinates: CLLocationCoordinate2D, completion: @escaping ([Int]?, [WeatherSnapshot]?, Error?) -> Void) {
        let urlString: String = "https://api.openweathermap.org/data/2.5/forecast?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&units=imperial&appid=\(apiKey)"
        print(urlString)
        let request: URLRequest = URLRequest(url: URL(string: urlString)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(nil, nil, error)
                return
            }
            guard let unwrappedData: Data = data else {
                completion(nil, nil, OpenWeatherError.badData)
                return
            }
            guard let jsonObject: [String:Any] = try? (JSONSerialization.jsonObject(with: unwrappedData, options: []) as! [String:Any]) else {
                completion(nil, nil, OpenWeatherError.badData)
                return
            }
            completion(WeatherSnapshot.array(from: jsonObject).0, WeatherSnapshot.array(from: jsonObject).1, nil)
        }
        task.resume()
    }
}

enum OpenWeatherError: Error {
    case badData
}
