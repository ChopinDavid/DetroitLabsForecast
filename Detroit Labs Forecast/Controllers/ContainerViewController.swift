//
//  ContainerViewController.swift
//  Detroit Labs Forecast
//
//  Created by David G Chopin on 4/14/20.
//  Copyright © 2020 All Caps Software Incorporated. All rights reserved.
//

import UIKit

//ContainerViewController is our app's initial view controller
//It contains a view that embeds the app's main UITabBarController
//The purpose of ContainerViewController is to prompt users with a set of instructions and a button to turn their location services on in order to use the app
//If the app currently has access to the user's location, it will hide its locationRequestView
//If the app currently does not have access to the user's location, it will show the locationRequestView
class ContainerViewController: UIViewController {
    
    //locationRequestView is shown whenever the user has denied the app's access to their current location
    @IBOutlet var locationRequestView: UIView!
    @IBOutlet var issueLabel: UILabel!
    @IBOutlet var instructionsLabel: UILabel!
    @IBOutlet var openSettingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //We call this updateColors method to handle the different user interface styles, i.e. light and dark mode
        updateColors()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        //Update the UI colors anytime the user inteface style changes
        updateColors()
    }
    
    func updateColors() {
        //Dark mode is only available in iOS13+
        //Check if the device is running iOS13+ and the user interfae style is dark and change the UI elements accordingly
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
            openSettingsButton.backgroundColor = .white
            openSettingsButton.setTitleColor(.black, for: .normal)
            issueLabel.textColor = .lightGray
            instructionsLabel.textColor = .lightGray
        } else {
            openSettingsButton.backgroundColor = .black
            openSettingsButton.setTitleColor(.white, for: .normal)
            issueLabel.textColor = .darkGray
            instructionsLabel.textColor = .darkGray
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Simply rounding the button's layer
        openSettingsButton.layer.cornerRadius = openSettingsButton.frame.height / 2
    }
    
    @IBAction func openSettingsButtonPressed(_ sender: Any) {
        //Open Detroit Lab Forecast's page in the settings app so the user can enable location services
        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //We have to set the TabBarController's containerView property to this ContainerViewController
        //To do this, we call prepare(for segue:, sender:), cast the segue's destination as a TabBarController, and set the containerViewController accordingly
        //Now, we can communicate between our ContainerViewController and all other view controllers
        if let tabBarController: TabBarController = segue.destination as? TabBarController {
            tabBarController.containerViewController = self
        }
    }
}
