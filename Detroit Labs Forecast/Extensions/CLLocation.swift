//
//  CLLocation.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import CoreLocation

extension CLLocation {
    func getPlaceName(completion: @escaping (String?, Error?) -> Void) {
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(self) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let placemark: CLPlacemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil, CLLocationError.noPlacemarksReturned)
                return
            }
            
            var nameString = ""
            
            // City
            let city: String? = placemark.subAdministrativeArea
            //State
            let state: String? = placemark.administrativeArea
            // Country
            let country: String? = placemark.country
            
            //Name, if all else fails
            let name: String? = placemark.name
            
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
                completion(nil, CLLocationError.unableToGetLocationName)
            }
            completion(nameString, nil)
        }
    }
}

enum CLLocationError: Error {
    case noPlacemarksReturned
    case unableToGetLocationName
}
