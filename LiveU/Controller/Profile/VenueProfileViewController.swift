//
//  VenueProfileViewController.swift
//  LiveU
//
//  Created by Eric Sharkey on 9/7/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MapKit
import CoreLocation

class VenueProfileViewController: UIViewController {
    
    var geocoder = CLGeocoder()
    private var ref: DatabaseReference!
    var currentUser:User!
    let locationManager = CLLocationManager()
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // Setting up view and variables.
    func setup(){
        checkLocationServices()
        currentUser = UserDefaults.standard.currentUser(forKey: "currentUser")
        centerViewOnVenueLocation()
        if let user = currentUser{
            profileImageView.image = #imageLiteral(resourceName: "VenueProfile")
            venueNameLabel.text = user.fullName
            descriptionTextField.text = user.about
        }
        ref = Database.database().reference()
        backgroundView.layer.cornerRadius = 15
        mapView.layer.cornerRadius = 15
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(launchMaps(sender:)))
        mapView.addGestureRecognizer(gesture)
    }
    // Location Manager Functions
    func checkLocationPermissions(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            // logic here
            break
        case .authorizedAlways:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Let user know about possible parental restrictions
            break
        case . denied:
            // Display alert telling the user to authorize permissions
            break
        @unknown default:
            print("Unknown Error")
        }
    }
    
        //Location functions
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
    
    
    func centerViewOnVenueLocation(){
        // Get Location coordinates from venue.
        geocoder.geocodeAddressString(currentUser.location) { (placemarks, error) in

            if let _ = error {
                
                // Alert the user
                return
            }
            
            // Setting up the map for the location of the Venue.
            if let placemarks = placemarks?.first {
           
              self.lat = placemarks.location?.coordinate.latitude
              self.long = placemarks.location?.coordinate.longitude
                // Alert the user
                let rgn = MKCoordinateRegion.init(
                    center: CLLocationCoordinate2DMake(self.lat!, self.long!), latitudinalMeters: 1000, longitudinalMeters: 1000)
                let venue = MKPointAnnotation()
                venue.title = self.currentUser.fullName
                venue.coordinate = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.long!)
                self.mapView.addAnnotation(venue)
                self.mapView.setRegion(rgn, animated: true)
            }
        }
    }
    
    
    // Launching the Apple maps when the map is selected.
    @objc func launchMaps(sender: UITapGestureRecognizer){
        
        let rgn = MKCoordinateRegion.init(
            center: CLLocationCoordinate2DMake(self.lat!, self.long!), latitudinalMeters: 350, longitudinalMeters: 350)
        self.mapView.setRegion(rgn, animated: true)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: rgn.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: rgn.span)
        ]
        let mark = MKPlacemark(coordinate: rgn.center, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: mark)
        mapItem.name = currentUser.fullName
        MKMapItem.openMaps(with: [mapItem], launchOptions: options)
    }
}
