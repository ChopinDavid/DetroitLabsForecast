//
//  TimeInterval.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import Foundation

extension TimeInterval {
    func unixToDateString() -> String {
        let date: Date = Date(timeIntervalSince1970: Double(self))
        let formatter: DateFormatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "E, MMM d, yyyy"

        return formatter.string(from: date)
        
    }
    
    func unixToTimeString() -> String {
        let date: Date = Date(timeIntervalSince1970: Double(self))
        let formatter: DateFormatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "h:mm a"

        return formatter.string(from: date)
    }
}
