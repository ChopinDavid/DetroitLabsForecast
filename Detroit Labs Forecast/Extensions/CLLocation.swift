//
//  CLLocation.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import CoreLocation

extension CLLocation {
    
    //The getPlaceName method takes a CLLocation and completes with the string representation of that location, or an error
    func getPlaceName(completion: @escaping (String?, Error?) -> Void) {
        
        //We can use a CLGeocoder to convert aa CLLocation to an array of CLPlacemarks
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(self) { placemarks, error in
            
            //Check errors
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil, error)
                return
            }
            
            //If there are no placemarks returned, complete with the CLLocationError.noPlacemarksReturned error
            guard let placemark: CLPlacemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil, CLLocationError.noPlacemarksReturned)
                return
            }
            
            //Create an empty, mutable string
            var nameString: String = ""
            
            // City
            let city: String? = placemark.subAdministrativeArea
            //State
            let state: String? = placemark.administrativeArea
            // Country
            let country: String? = placemark.country
            
            //Name, if all else fails
            let name: String? = placemark.name
            
            //Check which elements of the placemark are available and structure the nameString accordingly
            if city != nil {
                nameString = city!
                if state != nil {
                    nameString += ", \(state!)"
                } else if country != nil {
                    nameString += ", \(country!)"
                }
            } else if state != nil {
                nameString = state!
                if country != nil {
                    nameString += ", \(country!)"
                }
            } else if country != nil {
                nameString = country!
            } else if name != nil {
                nameString = name!
            } else {
                //If no placename elements were returned, complete with a CLLocationError.unableToGetLocationName error
                completion(nil, CLLocationError.unableToGetLocationName)
            }
            
            //Complete with the nameString we built
            completion(nameString, nil)
        }
    }
}

enum CLLocationError: Error {
    case noPlacemarksReturned
    case unableToGetLocationName
}
