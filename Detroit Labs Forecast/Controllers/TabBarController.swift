//
//  TabBarController.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    //We only make a custom subclass of UITabBarController so that our view controllers can communicate with our containing view controller without the use of Notifications
    var containerViewController: ContainerViewController!
}
