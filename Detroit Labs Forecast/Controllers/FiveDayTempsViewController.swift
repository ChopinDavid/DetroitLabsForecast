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
    
    var locationManager: CLLocationManager = CLLocationManager()
    var weatherSnapshots: [WeatherSnapshot]!
    var sections: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestLocation()
    }
}

extension FiveDayTempsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location: CLLocation = locations.first {
            
            print("Found user's location: \(location)")
            OpenWeatherManager.shared.getFiveDayForecast(from: location.coordinate) { (days, weatherSnapshots, error) in
                DispatchQueue.main.async {
                    guard error == nil else {
                        self.presentError()
                        return
                    }
                    
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
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            if let tabBarController: TabBarController = tabBarController as? TabBarController {
                tabBarController.containerViewController.locationRequestView.isHidden = true
            }
            locationManager.requestLocation()
        default:
            if let tabBarController: TabBarController = tabBarController as? TabBarController {
                tabBarController.containerViewController.locationRequestView.isHidden = false
            }
        }
    }
}

extension FiveDayTempsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if weatherSnapshots == nil {
            return "Loading Forecast"
        } else {
            let calendar: Calendar = Calendar.current
            let year: Int = calendar.component(.year, from: Date(timeIntervalSince1970: TimeInterval(weatherSnapshots[0].time)))  // 2017
            let date: Date = DateComponents(calendar: calendar, year: year, day: sections[section]).date!
            return date.timeIntervalSince1970.unixToDateString()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if weatherSnapshots == nil {
            return 1
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if weatherSnapshots == nil {
            return 1
        } else {
            let calendar: Calendar = Calendar.current
            let dayOfYear: Int = sections[section]
            let snapshotsOnDay: [WeatherSnapshot] = weatherSnapshots.filter({ calendar.ordinality(of: .day, in: .year, for: Date(timeIntervalSince1970: TimeInterval($0.time)))! == dayOfYear })
            return snapshotsOnDay.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if weatherSnapshots == nil {
            let cell: LoadingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as! LoadingTableViewCell
            return cell
        } else {
            let cell: ForecastTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell") as! ForecastTableViewCell
            let calendar: Calendar = Calendar.current
            let dayOfYear: Int = sections[indexPath.section]
            let snapshotsOnDay: [WeatherSnapshot] = weatherSnapshots.filter({ calendar.ordinality(of: .day, in: .year, for: Date(timeIntervalSince1970: TimeInterval($0.time))) == dayOfYear })
            cell.timeLabel.text = TimeInterval(snapshotsOnDay[indexPath.row].time).unixToTimeString()
            cell.weatherImageView.sd_setImage(with: URL(string: "https://openweathermap.org/img/wn/\(snapshotsOnDay[indexPath.row].weatherIcon)@2x.png")) { (image, error, cacheType, url) in }
            cell.temperatureLabel.text = "\(String(format: "%.1f", snapshotsOnDay[indexPath.row].temp))° F"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
