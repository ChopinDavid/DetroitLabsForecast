//
//  FiveDayTempsViewController.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import UIKit
import CoreLocation
class FiveDayTempsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    //We use a CLLocationManager to grab the user's location
    var locationManager: CLLocationManager = CLLocationManager()
    //Each weather snapshot represents a 3-hour forecast
    var weatherSnapshots: [WeatherSnapshot]!
    //Each section represents the ordinal day of the year (for example, February 3 would be the 34th day of the year)
    //Cells are grouped by their ordinal day of the year
    var sections: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the locationManager's delegate and request authorization
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        //Set tableView delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Since this is not our initial view controller, we request the location when the view appears
        locationManager.requestLocation()
    }
}

extension FiveDayTempsViewController: CLLocationManagerDelegate {
    //Assuming we can successfully access the user's location, this delegate method is called whenever our locationManager grabs the user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location: CLLocation = locations.first {
            
            print("Found user's location: \(location)")
            //We use our OpenWeatherManager singleton to get the five day forecast
            //This method returns the array of ordinal days we'll use as our sections and each 3-hour weather snapshot
            OpenWeatherManager.shared.getFiveDayForecast(from: location.coordinate) { (days, weatherSnapshots, error) in
                DispatchQueue.main.async {
                    guard error == nil else {
                        if error is OpenWeatherError {
                            self.presentError(description: "The API request returned bad data.")
                            return
                        }
                        self.presentError()
                        return
                    }
                    
                    //Set sections and snapshots accordingly
                    self.sections = days
                    self.weatherSnapshots = weatherSnapshots
                    self.tableView.reloadData()
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        
        presentError(description: "Unable to get user's location.")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //Whenever location authorization status changes, we have to set whether the container view controller's locationRequestView is hidden accordingly
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
        //If we can get the users location, we hide the locationRequestView
            if let tabBarController: TabBarController = tabBarController as? TabBarController {
                tabBarController.containerViewController.locationRequestView.isHidden = true
            }
            locationManager.requestLocation()
            
        default:
        //If we cannot get the users location, we show the locationRequestView
            if let tabBarController: TabBarController = tabBarController as? TabBarController {
                tabBarController.containerViewController.locationRequestView.isHidden = false
            }
        }
    }
}

extension FiveDayTempsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if weatherSnapshots == nil {
            //The forecast is still loading
            return "Loading Forecast"
        } else {
            //For each section, we have to convert the ordinal day of the year into a Date
            //We then have the unixToDateString() method that converts the date's Unix time to a string
            let calendar: Calendar = Calendar.current
            let year: Int = calendar.component(.year, from: Date(timeIntervalSince1970: TimeInterval(weatherSnapshots[0].time)))  // 2017
            let date: Date = DateComponents(calendar: calendar, year: year, day: sections[section]).date!
            return date.timeIntervalSince1970.unixToDateString()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if weatherSnapshots == nil {
            //Loading forecast section
            return 1
        } else {
            //Each of the five days of the forecast
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if weatherSnapshots == nil {
            //There is only one loadingCell when the forecast is loading
            return 1
        } else {
            //For each section, we have to find how many weather snapshots match the section's ordinal day of the year
            //We then return the count of weather snapshots that should be in the respective section
            let calendar: Calendar = Calendar.current
            let dayOfYear: Int = sections[section]
            let snapshotsOnDay: [WeatherSnapshot] = weatherSnapshots.filter({ calendar.ordinality(of: .day, in: .year, for: Date(timeIntervalSince1970: TimeInterval($0.time)))! == dayOfYear })
            return snapshotsOnDay.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if weatherSnapshots == nil {
            //We use a loading cell when the forecast is still loading
            let cell: LoadingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as! LoadingTableViewCell
            return cell
        } else {
            //Dequeue a forecast cell
            let cell: ForecastTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell") as! ForecastTableViewCell
            
            //Get only the weather snapshots that have the same ordinal day of the year as the section of this indexPath
            let calendar: Calendar = Calendar.current
            let dayOfYear: Int = sections[indexPath.section]
            let snapshotsOnDay: [WeatherSnapshot] = weatherSnapshots.filter({ calendar.ordinality(of: .day, in: .year, for: Date(timeIntervalSince1970: TimeInterval($0.time))) == dayOfYear })
            
            //Set the cell UI accordingly
            //We use the unixToTimeString() to convert a unix integer to a text representation of an hour and minute of the day
            cell.timeLabel.text = TimeInterval(snapshotsOnDay[indexPath.row].time).unixToTimeString()
            cell.weatherImageView.sd_setImage(with: URL(string: "https://openweathermap.org/img/wn/\(snapshotsOnDay[indexPath.row].weatherIcon)@2x.png")) { (image, error, cacheType, url) in }
            
            //Set the cell's temperature label to the weather snapshot's temperature, rounded to one decimal place
            cell.temperatureLabel.text = "\(String(format: "%.1f", snapshotsOnDay[indexPath.row].temp))° F"
            
            //Return the cell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //We want all of our cells to be the same height
        return 60
    }
}
