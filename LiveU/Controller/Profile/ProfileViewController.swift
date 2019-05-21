//
//  ProfileViewController.swift
//  LiveU
//
//  Created by Eric Sharkey on 9/10/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileViewController: UIViewController {

    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarItem.image = #imageLiteral(resourceName: "ProfileIcon")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarItem.image = #imageLiteral(resourceName: "ProfileIconSelected")
    }

    func setup(){
        currentUser = UserDefaults.standard.currentUser(forKey: "currentUser")
        if let user = currentUser{
            if user.artist == "true"{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let artistPro = storyboard.instantiateViewController(withIdentifier: "artistProfile")
                self.addChild(artistPro)
                self.view.addSubview(artistPro.view)
                
            } else if user.venue == "true"{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let venuePro = storyboard.instantiateViewController(withIdentifier: "venueProfile")
                self.addChild(venuePro)
                self.view.addSubview(venuePro.view)
            }
        }
    }
}
