//
//  ForecastTableViewCell.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import UIKit

//The ForecastTableViewCell is the cell shown for each of the 3-hour forecasts returned from the OpenWeather forecast endpoint
class ForecastTableViewCell: UITableViewCell {
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    
    //Before a cell is reused, we set its weather image to nil. This way, the weather image of a previously used cell won't appear while the new icon is loading
    //This usually causes no issues as SDWebImage, the Cocoapod we use for asynchronous image loading, caches previously used images
    override func prepareForReuse() {
        super.prepareForReuse()
        weatherImageView.image = nil
    }
}
