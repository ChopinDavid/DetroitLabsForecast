//
//  UIViewController.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import UIKit

extension UIViewController {
    //This is an extension to UIViewController that lets us present an error alert to the user.
    //If no description is passed, the view controller will present an "Unknown error" alert
    func presentError(description: String = "An unknown error occurred.") {
        let alertController: UIAlertController = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        let ok: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
}
