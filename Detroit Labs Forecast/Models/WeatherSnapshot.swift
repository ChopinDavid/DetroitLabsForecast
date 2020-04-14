//
//  WeatherSnapshot.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import CoreLocation

class WeatherSnapshot {
    var coord: CLLocationCoordinate2D
    var weatherId: Int
    var weatherDescription: String
    var weatherIcon: String
    var temp: Double
    var feelsLike: Double
    var tempMin: Double
    var tempMax: Double
    var pressure: Int
    var humidity: Int
    var windSpeed: Double
    var windDirection: Double
    var country: String?
    var sunrise: Int
    var sunset: Int
    var name: String
    var time: Int
    init(coord: CLLocationCoordinate2D, weatherId: Int, weatherDescription: String, weatherIcon: String, temp: Double, feelsLike: Double, tempMin: Double, tempMax: Double, pressure: Int, humidity: Int, windSpeed: Double, windDirection: Double, country: String?, sunrise: Int, sunset: Int, name: String, time: Int) {
        self.coord = coord
        self.weatherId = weatherId
        self.weatherDescription = weatherDescription
        self.weatherIcon = weatherIcon
        self.temp = temp
        self.feelsLike = feelsLike
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.pressure = pressure
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.sunrise = sunrise
        self.sunset = sunset
        self.country = country
        self.name = name
        self.time = time
    }
    
    convenience init(dict: [String:Any]) {
        let coord = dict["coord"] as! [String:Double]
        let weather = (dict["weather"] as! [[String:Any]]).first!
        let main = dict["main"] as! [String:Any]
        let wind = dict["wind"] as! [String:Double]
        let sys = dict["sys"] as! [String:Any]
        let lat: Double = coord["lat"]!
        let long: Double = coord["lon"]!
        let weatherId: Int = weather["id"] as! Int
        let weatherDescription: String = weather["description"] as! String
        let weatherIcon: String = weather["icon"] as! String
        let temp: Double = main["temp"] as! Double
        let feelsLike: Double = main["feels_like"] as! Double
        let tempMin: Double = main["temp_min"] as! Double
        let tempMax: Double = main["temp_max"] as! Double
        let pressure: Int = main["pressure"] as! Int
        let humidity: Int = main["humidity"] as! Int
        let windSpeed: Double = wind["speed"]!
        let windDirection: Double = wind["deg"]!
        let country: String? = sys["country"] as? String
        let sunrise: Int = sys["sunrise"] as! Int
        let sunset: Int = sys["sunset"] as! Int
        let name: String = dict["name"] as! String
        let time: Int = dict["dt"] as! Int
        self.init(coord: CLLocationCoordinate2D(latitude: lat, longitude: long), weatherId: weatherId, weatherDescription: weatherDescription, weatherIcon: weatherIcon, temp: temp, feelsLike: feelsLike, tempMin: tempMin, tempMax: tempMax, pressure: pressure, humidity: humidity, windSpeed: windSpeed, windDirection: windDirection, country: country, sunrise: sunrise, sunset: sunset, name: name, time: time)
    }
    
    static func array(from dict: [String:Any]) -> ([Int], [WeatherSnapshot]) {
        let city: [String:Any] = dict["city"] as! [String:Any]
        let coord: [String:Double] = city["coord"] as! [String:Double]
        let list = dict["list"] as! [[String:Any]]
        var snapshots: [WeatherSnapshot] = []
        let calendar = Calendar.current
        var firstDate: Date!
        for day in list {
            if firstDate == nil || calendar.ordinality(of: .day, in: .year, for: Date(timeIntervalSince1970: TimeInterval(day["dt"] as! Int)))! - calendar.ordinality(of: .day, in: .year, for: firstDate)! < 5 {
                if firstDate == nil {
                    firstDate = Date(timeIntervalSince1970: TimeInterval(day["dt"] as! Int))
                }
                var mutableDay = day
                mutableDay["coord"] = coord
                mutableDay["name"] = city["name"] as! String
                mutableDay["country"] = city["country"] as? String
                mutableDay["sys"] = ["sunrise":city["sunrise"] as! Int, "sunset":city["sunset"] as! Int]
                snapshots.append(WeatherSnapshot(dict: mutableDay))
            } else {
                let set = Array(Set(snapshots.map({ calendar.ordinality(of: .day, in: .year, for: Date(timeIntervalSince1970: TimeInterval($0.time)))! }))).sorted()
                return (set, snapshots)
            }
        }
        return ([],snapshots)
    }
}
