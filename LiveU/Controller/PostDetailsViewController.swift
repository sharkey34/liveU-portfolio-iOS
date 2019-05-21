//
//  PostDetailsViewController.swift
//  LiveU
//
//  Created by Eric Sharkey on 9/12/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class PostDetailsViewController: UIViewController {
    let locationManager = CLLocationManager()
    var geocoder = CLGeocoder()
    
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var labelCollection: [UILabel]!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    var ref: DatabaseReference!
    var localPost: Posts!
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Saving the post to the user and the user to the post when apply is selected.
    @IBAction func applyButtonSelected(_ sender: UIButton) {
        if let currentUser = UserDefaults.standard.currentUser(forKey: "currentUser") {
            ref.child("posts").child(localPost.uid).child("applied").updateChildValues([currentUser.uid: currentUser.fullName])
            ref.child("users").child(currentUser.uid).child("applied").updateChildValues([localPost.uid: localPost.title])
            
            sender.isEnabled = false
            sender.backgroundColor = UIColor.red
            sender.setTitle("Applied", for: .normal)
        }
    }
    
    
    // ViewController setup
    func setup(){
        checkLocationServices()
        centerViewOnVenueLocation()
        mapView.delegate = self
        ref = Database.database().reference()
        postImageView.image = #imageLiteral(resourceName: "VenueProfile")
        labelCollection[0].text = localPost.title
        labelCollection[1].text = localPost.date
        labelCollection[2].text = localPost.genre
        labelCollection[3].text = localPost.budget
        labelCollection[4].text = localPost.location
        
        
        backgroundView.layer.cornerRadius = 15
        mapView.layer.cornerRadius = 15
        applyButton.layer.cornerRadius = 15
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(launchMaps(sender:)))
        mapView.addGestureRecognizer(gesture)
    }
    
    
    //Location functions
    func locationManagerSetup(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            locationManagerSetup()
        } else {
            //Display alert telling user to turn on location services
        }
    }
    
    
    func centerViewOnVenueLocation(){
        // Get Location coordinates from venue.
        geocoder.geocodeAddressString(localPost.location) { (placemarks, error) in
            if let _ = error {
                
                // Alert the user
                return
            }
            
            // setting up the map to display the venue location.
            if let placemarks = placemarks?.first {
                self.lat = placemarks.location?.coordinate.latitude
                self.long = placemarks.location?.coordinate.longitude
                let rgn = MKCoordinateRegion.init(
                    center: CLLocationCoordinate2DMake(self.lat!, self.long!), latitudinalMeters: 350, longitudinalMeters: 350)
                let venue = MKPointAnnotation()
                venue.coordinate = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.long!)
                self.mapView.addAnnotation(venue)
                self.mapView.setRegion(rgn, animated: true)
            }
        }
    }
    
    // Luanching maps when the map is tapped.
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
        MKMapItem.openMaps(with: [mapItem], launchOptions: options)
    }
}

extension PostDetailsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
