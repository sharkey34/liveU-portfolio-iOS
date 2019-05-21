//
//  ArtistProfileViewController.swift
//  LiveU
//
//  Created by Eric Sharkey on 9/7/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//
// Search icon by freepik from www.flaticon.com
// Add icon by dimitri13 from www.flaticon.com
// Profile icon by Gregor Cresnar from www.flaticon.com


import UIKit
import FirebaseAuth
import Firebase
import CoreLocation

class ArtistProfileViewController: UIViewController {
    var ref: DatabaseReference!
    var currentUser:User!
    let locationManager = CLLocationManager()
    
    @IBOutlet var labelCollection: [UILabel]!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var aboutTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Setting up profile values.
    func setup(){
        checkLocationServices()
        currentUser = UserDefaults.standard.currentUser(forKey: "currentUser")
        if let user = currentUser{
            profileImage.image = #imageLiteral(resourceName: "ArtistProfile")
            labelCollection[0].text = user.fullName
            aboutTextField.text = currentUser.about
        }
        ref = Database.database().reference()
        backGroundView.layer.cornerRadius = 15
        aboutView.layer.cornerRadius = 15
    }
    
    // Location Manager Functions
    func checkLocationPermissions(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            // Logic
            break
        case .authorizedAlways:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("location Restricted")
            // Let user know about possible parental restrictions
            break
        case . denied:
            print("location denied")
            // Display alert telling the user to authorize permissions
            break
        @unknown default:
            print("Unknown Error")
        }
    }
    
    func locationManagerSetup(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            locationManagerSetup()
            checkLocationPermissions()
        } else {
            //Display alert telling user to turn on location services
        }
    }
}
