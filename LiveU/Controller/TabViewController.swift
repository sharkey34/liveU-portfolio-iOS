//
//  ProfileTabViewController.swift
//  LiveU
//
//  Created by Eric Sharkey on 9/10/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Setup
    func setup(){
        tabBar.items![0].selectedImage = #imageLiteral(resourceName: "ProfileIconSelected")
        tabBar.items![1].selectedImage = #imageLiteral(resourceName: "AddIconSelected")
        
        // Disabling access to the add viewController if the user is an Artist.
        currentUser = UserDefaults.standard.currentUser(forKey: "currentUser")
        if currentUser.artist == "true"{
            tabBar.items![1].isEnabled = false
            tabBar.items![1].image = nil
            tabBar.items![1].title = nil
        }
    }
}
