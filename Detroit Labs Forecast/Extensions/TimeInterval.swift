//
//  TimeInterval.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    //Method for converting a TimeInterval into a string representation of the TimeInterval's day
    func unixToDateString() -> String {
        let date: Date = Date(timeIntervalSince1970: Double(self))
        let formatter: DateFormatter = DateFormatter()
        //We only want the weekday, month, day, and year
        formatter.dateFormat = "E, MMM d, yyyy"

        return formatter.string(from: date)
        
    }
    
    //Method for converting a TimeInterval into a string representation of the TimeInterval's time of day
    func unixToTimeString() -> String {
        let date: Date = Date(timeIntervalSince1970: Double(self))
        let formatter: DateFormatter = DateFormatter()
        //We only want the time of day
        formatter.dateFormat = "h:mm a"

        return formatter.string(from: date)
    }
}
