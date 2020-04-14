//
//  UIViewController.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentError(description: String = "An unknown error occurred.") {
        let alertController = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
}
