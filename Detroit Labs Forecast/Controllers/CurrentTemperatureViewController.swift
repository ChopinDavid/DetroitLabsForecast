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

//As the name implies, the CurrentTemperatureViewController is the view controller that shows the current temperature at the user's current location
class CurrentTemperatureViewController: UIViewController {
    
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var reloadButton: UIButton!
    
    //We use a CLLocationManager to grab the user's location
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the locationManager's delegate and request authorization
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
            if weatherImageView.image == nil {
                weatherImageView.backgroundColor = .systemGray6
            }
            reloadButton.backgroundColor = .white
            reloadButton.setTitleColor(.black, for: .normal)
        } else {
            if weatherImageView.image == nil {
                weatherImageView.backgroundColor = .lightGray
            }
            reloadButton.backgroundColor = .black
            reloadButton.setTitleColor(.white, for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //We simply call this to round our reloadButton
        reloadButton.layer.cornerRadius = reloadButton.frame.height / 2
    }
    
    //When the reloadButton is pressed, we are essentially "resetting" the view controller.
    //The labels and weather image all return to their default state and we request the user's location again
    @IBAction func reloadButtonPressed(_ sender: Any) {
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
            weatherImageView.backgroundColor = .systemGray6
        } else {
            weatherImageView.backgroundColor = .lightGray
        }
        reloadButton.isHidden = true
        weatherImageView.image = nil
        activityIndicatorView.startAnimating()
        temperatureLabel.text = "Getting current temperature..."
        locationLabel.text = "Getting current location..."
        locationManager.requestLocation()
    }
}

extension CurrentTemperatureViewController: CLLocationManagerDelegate {
    //Assuming we can successfully access the user's location, this delegate method is called whenever our locationManager grabs the user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location: CLLocation = locations.first {
            
            print("Found user's location: \(location)")
            
            //We are using a dispatch group so that the reload button is only visible after both asynchronous requests for the weather snapshot and the current placename are completed
            let group: DispatchGroup = DispatchGroup()
            
            group.enter()
            
            //getPlaceName is a CLLocation extension method I wrote to convert a CLLocation into its respective place name
            location.getPlaceName { (placeName, error) in
                group.leave()
                DispatchQueue.main.async {
                    guard error == nil else {
                        if let locationError = error as? CLLocationError {
                            if locationError == .noPlacemarksReturned {
                                //No placemarks were returned for this query
                                self.presentError(description: "No place names were returned for this location.")
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
            
            //We also grab the weather snapshot for the current locaation's coordinate
            OpenWeatherManager.shared.getSnapshot(from: location.coordinate) { (weatherSnapshot, error) in
                group.leave()
                DispatchQueue.main.async {
                    guard error == nil else {
                        self.presentError()
                        return
                    }
                    self.weatherImageView.sd_setImage(with: URL(string: "https://openweathermap.org/img/wn/\(weatherSnapshot!.weatherIcon)@2x.png")) { (image, error, cacheType, url) in
                        self.weatherImageView.backgroundColor = .clear
                        self.activityIndicatorView.stopAnimating()
                    }
                    self.temperatureLabel.text = "Temperature: \(String(format: "%.1f", weatherSnapshot!.temp))° F"
                }
            }
            
            //Once both asynchronous tasks are complete, we let users use the reload button again
            group.notify(queue: .main) {
                self.reloadButton.isHidden = false
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

