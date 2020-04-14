//
//  CurrentTemperatureViewController.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage

class CurrentTemperatureViewController: UIViewController {
    
    //locationRequestView is shown whenever the user has denied the app's access to their current location
    @IBOutlet var locationRequestView: UIView!
    @IBOutlet var openSettingsButton: UIButton!
    
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var reloadButton: UIButton!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
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
            weatherImageView.backgroundColor = .systemGray6
            openSettingsButton.backgroundColor = .white
            openSettingsButton.setTitleColor(.black, for: .normal)
            reloadButton.backgroundColor = .white
            reloadButton.setTitleColor(.black, for: .normal)
        } else {
            weatherImageView.backgroundColor = .lightGray
            openSettingsButton.backgroundColor = .black
            openSettingsButton.setTitleColor(.white, for: .normal)
            reloadButton.backgroundColor = .black
            reloadButton.setTitleColor(.white, for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        openSettingsButton.layer.cornerRadius = openSettingsButton.frame.height / 2
        reloadButton.layer.cornerRadius = reloadButton.frame.height / 2
    }
    
    @IBAction func openSettingsButtonPressed(_ sender: Any) {
        //Open Detroit Lab Forecast's page in the settings app so the user can enable location services
        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
    }
    
    @IBAction func reloadButtonPressed(_ sender: Any) {
        reloadButton.isHidden = true
        weatherImageView.image = nil
        activityIndicatorView.startAnimating()
        temperatureLabel.text = "Getting current temperature..."
        locationLabel.text = "Getting current location..."
        locationManager.requestLocation()
    }
}

extension CurrentTemperatureViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            print("Found user's location: \(location)")
            
            //Using a dispatch group so that the reload button is only visible after both asynchronous requests for the weather snapshot and the current placename are completed
            let group: DispatchGroup = DispatchGroup()
            
            group.enter()
            location.getPlaceName { (placeName, error) in
                group.leave()
                DispatchQueue.main.async {
                    guard error == nil else {
                        if let cllocationError = error as? CLLocationError {
                            //We can handle these known errors
                            if cllocationError == .noPlacemarksReturned {
                                //No placemarks were found at this location
                                self.presentError(description: "The location name could not be found.")
                            } else {
                                //We were unable to get the location name
                                self.presentError(description: "The location name could not be found.")
                            }
                        } else {
                            //Unknown error occured
                            self.presentError()
                        }
                        return
                    }
                    
                    self.locationLabel.text = "Location: \(placeName!)"
                }
            }
            
            group.enter()
            OpenWeatherManager.shared.getSnapshot(from: location.coordinate) { (weatherSnapshot, error) in
                group.leave()
                DispatchQueue.main.async {
                    guard error == nil else {
                        self.presentError()
                        return
                    }
                    self.weatherImageView.sd_setImage(with: URL(string: "https://openweathermap.org/img/wn/\(weatherSnapshot!.weatherIcon)@2x.png")) { (image, error, cacheType, url) in
                        self.activityIndicatorView.stopAnimating()
                    }
                    self.temperatureLabel.text = "Temperature: \(String(format: "%.1f", weatherSnapshot!.temp))° F"
                }
            }
            
            group.notify(queue: .main) {
                self.reloadButton.isHidden = false
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationRequestView.isHidden = true
            locationManager.requestLocation()
        default:
            locationRequestView.isHidden = false
        }
    }
}

