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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //We call this updateColors method to handle the different user interface styles, i.e. light and dark mode
        updateColors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestLocation()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        //Update the UI colors anytime the user inteface style changes
        updateColors()
    }
    
    func updateColors() {
        //Dark mode is only available in iOS13+
        //Check if the device is running iOS13+ and the user interfae style is dark and change the UI elements accordingly
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
        } else {
        }
    }
}

extension FiveDayTempsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            print("Found user's location: \(location)")
            OpenWeatherManager.shared.getFiveDayForecast(from: location.coordinate) { (weatherSnapshots, error) in
                DispatchQueue.main.async {
                    guard error == nil else {
                        self.presentError()
                        return
                    }
                    
                    self.weatherSnapshots = weatherSnapshots
                    self.tableView.reloadData()
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            //locationRequestView.isHidden = true
            locationManager.requestLocation()
        default:
            break
            //locationRequestView.isHidden = false
        }
    }
}

extension FiveDayTempsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if weatherSnapshots == nil {
            return 1
        } else {
            return weatherSnapshots.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if weatherSnapshots == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as! LoadingTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell") as! ForecastTableViewCell
            cell.timeLabel.text = weatherSnapshots[indexPath.row].time.unixToDateString()
            cell.weatherImageView.sd_setImage(with: URL(string: "https://openweathermap.org/img/wn/\(weatherSnapshots[indexPath.row].weatherIcon)@2x.png")) { (image, error, cacheType, url) in }
            cell.temperatureLabel.text = "\(String(format: "%.1f", weatherSnapshots[indexPath.row].temp))° F"
            return cell
        }
    }
}
