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
    
    //locationRequestView is shown whenever the user has denied the app's access to their current location
    @IBOutlet var locationRequestView: UIView!
    @IBOutlet var openSettingsButton: UIButton!
    
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
        
        //We call this updateColors method to handle the different user interface styles, i.e. light and dark mode
        updateColors()
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
            openSettingsButton.backgroundColor = .white
            openSettingsButton.setTitleColor(.black, for: .normal)
        } else {
            openSettingsButton.backgroundColor = .black
            openSettingsButton.setTitleColor(.white, for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        openSettingsButton.layer.cornerRadius = openSettingsButton.frame.height / 2
    }
    
    @IBAction func openSettingsButtonPressed(_ sender: Any) {
        //Open Detroit Lab Forecast's page in the settings app so the user can enable location services
        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
    }
}

extension FiveDayTempsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
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
            //locationRequestView.isHidden = true
            locationManager.requestLocation()
        default:
            break
            //locationRequestView.isHidden = false
        }
    }
}

extension FiveDayTempsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if weatherSnapshots == nil {
            return "Loading Forecast"
        } else {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date(timeIntervalSince1970: TimeInterval(weatherSnapshots[0].time)))  // 2017
            let date = DateComponents(calendar: calendar, year: year, day: sections[section]).date!
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
            let calendar = Calendar.current
            let dayOfYear = sections[section]
            let days = weatherSnapshots.filter({ calendar.ordinality(of: .day, in: .year, for: Date(timeIntervalSince1970: TimeInterval($0.time)))! == dayOfYear })
            return days.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if weatherSnapshots == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as! LoadingTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell") as! ForecastTableViewCell
            let calendar = Calendar.current
            let snapshotsOnDate = weatherSnapshots.filter({ calendar.ordinality(of: .day, in: .year, for: Date(timeIntervalSince1970: TimeInterval($0.time))) == sections[indexPath.section] })
            cell.timeLabel.text = TimeInterval(snapshotsOnDate[indexPath.row].time).unixToTimeString()
            cell.weatherImageView.sd_setImage(with: URL(string: "https://openweathermap.org/img/wn/\(snapshotsOnDate[indexPath.row].weatherIcon)@2x.png")) { (image, error, cacheType, url) in }
            cell.temperatureLabel.text = "\(String(format: "%.1f", snapshotsOnDate[indexPath.row].temp))° F"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
