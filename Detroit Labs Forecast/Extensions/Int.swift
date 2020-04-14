//
//  Int.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import Foundation

extension Int {
    func unixToDateString() -> String {
        let date: Date = Date(timeIntervalSince1970: Double(self))
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "E, MMM d, yyyy\nh:mm a"

        return formatter.string(from: date)
        
    }
}
