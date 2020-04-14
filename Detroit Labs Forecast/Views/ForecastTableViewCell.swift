//
//  ForecastTableViewCell.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        weatherImageView.image = nil
    }
}
