//
//  OpenWeatherManager.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import Foundation

class OpenWeatherManager {
    //I will generally use a singleton pattern when dealing with an API
    static let shared: OpenWeatherManager = OpenWeatherManager()
    
    let apiKey: String = "67efa96997e6ab79b95e04a4f24f038e"
    
    
}
