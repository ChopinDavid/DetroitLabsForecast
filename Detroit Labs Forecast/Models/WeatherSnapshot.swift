//
//  WeatherSnapshot.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import CoreLocation

//Weather snapshot is our class for the object returned by the OpenWeatherAPI
//I originally had it include things like wind direction, humidity, sunrise time, sunset time, but removed those properties for simplicity's sake
class WeatherSnapshot {
    var coord: CLLocationCoordinate2D?
    var weatherDescription: String
    var weatherIcon: String
    var temp: Double
    var country: String?
    var name: String
    var time: Int
    
    init(coord: CLLocationCoordinate2D?, weatherDescription: String, weatherIcon: String, temp: Double, country: String?, name: String, time: Int) {
        self.coord = coord
        self.weatherDescription = weatherDescription
        self.weatherIcon = weatherIcon
        self.temp = temp
        self.country = country
        self.name = name
        self.time = time
    }
    
    //This initializer lets us initialize a WeatherSnapshot from the dictionary returned from an OpenWeather single day temp API request
    convenience init(dict: [String:Any]) {
        let coord: [String:Double] = dict["coord"] as! [String:Double]
        let weather: [String:Any] = (dict["weather"] as! [[String:Any]]).first!
        let main: [String:Any] = dict["main"] as! [String:Any]
        let sys: [String:Any] = dict["sys"] as! [String:Any]
        let lat: Double? = coord["lat"]
        let long: Double? = coord["lon"]
        let weatherDescription: String = weather["description"] as! String
        let weatherIcon: String = weather["icon"] as! String
        let temp: Double = main["temp"] as! Double
        let country: String? = sys["country"] as? String
        let name: String = dict["name"] as! String
        let time: Int = dict["dt"] as! Int
        var coordinate: CLLocationCoordinate2D!
        if lat != nil && long != nil {
            coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        }
        self.init(coord: coordinate, weatherDescription: weatherDescription, weatherIcon: weatherIcon, temp: temp, country: country, name: name, time: time)
    }
    
    //This array function takes the dictionary returned from a five day OpenWeather API request, initializes all weather snapshots, and returns the array of said snapshots
    //We also return an array of the ordinal days of the year (for example, february 3 would be the 34th day of the year)
    //This array of day integers is used to create the sections for our table view in our FiveDayTempsViewController
    static func array(from dict: [String:Any]) -> ([Int], [WeatherSnapshot]) {
        let city: [String:Any] = dict["city"] as! [String:Any]
        let coord: [String:Double] = city["coord"] as! [String:Double]
        let list: [[String:Any]] = dict["list"] as! [[String:Any]]
        var snapshots: [WeatherSnapshot] = []
        let calendar: Calendar = Calendar.current
        for day in list {
            var mutableDay: [String:Any] = day
            mutableDay["coord"] = coord
            mutableDay["name"] = city["name"] as! String
            mutableDay["country"] = city["country"] as? String
            snapshots.append(WeatherSnapshot(dict: mutableDay))
        }
        let daysOfYear: [Int] = Array(Set(snapshots.map({ calendar.ordinality(of: .day, in: .year, for: Date(timeIntervalSince1970: TimeInterval($0.time)))! }))).sorted()
        return (daysOfYear, snapshots)
    }
}
