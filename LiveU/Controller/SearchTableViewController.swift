//
//  SearchTableViewController.swift
//  LiveU
//
//  Created by Eric Sharkey on 9/12/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class SearchTableViewController: UITableViewController{
    
    private var searchController = UISearchController(searchResultsController: nil)
    private var ref: DatabaseReference!
    private var userLoc: CLLocation?
    private let locationManager = CLLocationManager()
    private let formatter = MKDistanceFormatter()
    private var currentUser: User!
    var sorted: Bool = false
    
    // Hold users selections
    var selectedPost: Posts?
    var appliedArtist: [String] = []
    
    // Used specifically for getting the applied users
    var dicArray: [String:[String]] = [:]
    private var users: [String] = []
    
    // Arrays holding data
    private var posts: [Posts] = []
    private var sortedArray: [Posts] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if navigationItem.searchController != nil {
            searchController.definesPresentationContext = true
        } else {
            setUpSearchController()
        }
        setUp()
    }
    
    // Doing current user setup
    override func viewWillAppear(_ animated: Bool) {
        if currentUser.artist == "true"{
            artistSetup()
        } else if currentUser.venue == "true"{
            venueSetup()
        } else {
            print("Unable to determine UserType")
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        posts = []
        tableView.reloadData()
        sorted = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // TableView Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        tableView.rowHeight =  view.frame.height / 3
       
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedArray.count
    }


    // Setting the cell label values depending on the user type
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SearchTableViewCell else {return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)}
        if currentUser.artist == "true"{
            cell.postImageView.image = #imageLiteral(resourceName: "VenueProfile")
            if sortedArray[indexPath.row].distance != nil{
                let d = formatter.string(fromDistance: sortedArray[indexPath.row].distance)
                cell.cellLabelCollection[2].text = d
            } else {
                cell.cellLabelCollection[2].text = sortedArray[indexPath.row].date
            }
            cell.cellLabelCollection[3].text = sortedArray[indexPath.row].genre
            cell.cellLabelCollection[1].text = sortedArray[indexPath.row].budget
        } else if currentUser.venue == "true" {
            cell.postImageView.image = #imageLiteral(resourceName: "ArtistProfile")
            cell.cellLabelCollection[1].text = sortedArray[indexPath.row].budget
            cell.cellLabelCollection[3].text = sortedArray[indexPath.row].genre
            cell.cellLabelCollection[2].text = sortedArray[indexPath.row].date
        }

        cell.cellLabelCollection[0].text = sortedArray[indexPath.row].title

        return cell
    }


    // Getting the item that was selected and performing a segue to the correct view controller depending on the user type.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPost = sortedArray[indexPath.row]

        if currentUser.artist == "true"{
            performSegue(withIdentifier: "gigDetails", sender: self)
        } else if currentUser.venue == "true"{

            let appliedArtistArray = dicArray[sortedArray[indexPath.row].uid]
            if let arr = appliedArtistArray {
                appliedArtist = arr
            }
            self.performSegue(withIdentifier: "toAppliedArtists", sender: self)
        }
    }
    // Setup of the UISearchController
    func setUpSearchController(){
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    // Controller setup.
    func setUp(){
        currentUser = UserDefaults.standard.currentUser(forKey: "currentUser")
        checkLocationServices()
        ref = Database.database().reference()
        formatter.units = MKDistanceFormatter.Units.imperial
        formatter.unitStyle = .full
    }

    // Getting the posts and appending to the post array.
    func artistSetup(){
        navigationItem.title = "Gigs"
        searchController.searchBar.scopeButtonTitles = ["Location", "Genre"]

        ref.child("posts").observe(.childAdded, with: { (snapshot) in

            if let data = snapshot.value as? [String: Any] {
                let uid = snapshot.key
                let title = data["title"] as? String ?? ""
                let genre = data["genre"] as? String ?? ""
                let location = data["location"] as? String ?? ""
                let budget = data["budget"] as? String ?? ""
                let date = data["date"] as? String ?? ""
                let lat = data["lat"] as? Double ?? nil
                let long = data["long"] as? Double ?? nil

                self.posts.append(Posts(uid: uid, title: title, genre: genre, budget: budget, date: date, location: location, distance: nil, lat: lat, long:long))
            }
            self.sortedArray = self.posts
            self.tableView.reloadData()
        }, withCancel: nil)
    }


    // Getting the users posts
    func venueSetup(){
        navigationItem.title = "My Posts"
        // MARK: add artists later
        searchController.searchBar.scopeButtonTitles = ["My Posts","Genre"]
        ref.child("users").child(currentUser.uid).child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                for keys in data.keys {
                    self.ref.child("posts").child(keys).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let postsData = snapshot.value as? [String:Any]{
                            let uid = snapshot.key
                            let title = postsData["title"] as? String ?? ""
                            let location = postsData["location"] as? String ?? ""
                            let genre = postsData["genre"] as? String ?? ""
                            let budget = postsData["budget"] as? String ?? ""
                            let date = postsData["date"] as? String ?? ""
                            let lat = postsData["lat"] as? Double ?? nil
                            let long = postsData["long"] as? Double ?? nil
                            if let d = postsData["applied"] as? [String:Any] {
                                self.users = []
                                for key in d.keys{
                                    self.users.append(key)
                                }
                                self.dicArray[uid] = self.users
                            }

                            self.posts.append(Posts(uid: uid, title: title, genre: genre, budget: budget, date: date, location: location, distance: nil, lat: lat, long:long))
                        }
                        self.sortedArray = self.posts
                        self.tableView.reloadData()
                    }, withCancel: { (error) in
                        print(error.localizedDescription)
                    })
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }


    // Function getting the distance from the users location and sorting the distances returned.
    func sortPosts(){
        sorted = true
        for post in posts {
            let postLoc = CLLocation(latitude: post.lat, longitude: post.long)
            let distance = userLoc?.distance(from: postLoc)

            if let d = distance{
                post.distance = d
            }
        }
        
        sortedArray = posts.sorted(by: {$0.distance < $1.distance})
    }


    // Location Manger Functions
    func checkLocationPermissions(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            // logic here
            print("Authorized SearchController")
            locationManager.startUpdatingLocation()
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

    func locationManagerSetup(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }

    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            locationManagerSetup()
            checkLocationPermissions()
        } else {
            //Display alert telling user to turn on location services
        }
    }

    // Doing logic depending on the segue identifier.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toAppliedArtists" {
            let appliedView = segue.destination as? AppliedArtistsTableViewController
            appliedView?.appliedArtists = appliedArtist

        } else if segue.identifier == "gigDetails" {
            let detailsView = segue.destination as? PostDetailsViewController
            detailsView?.localPost = selectedPost
        }
    }
}

// Search Controller extension
extension SearchTableViewController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchBar.text = nil
        tableView.reloadData()
        if currentUser.artist == "true" {
            switch selectedScope {
            case 0 :
                // Change array instead of redoing the distance.
                sortPosts()
            case 1:
                // Create another array to hold the posts sorted by genre then chekc if it is empty or not here so that the sort happens once.
                sortedArray = posts.sorted(by: {$0.genre.lowercased() < $1.genre.lowercased()})
                // sortedArray = posts.sorted(by: {$0.genre.caseInsensitiveCompare($1.genre) == .orderedAscending})
                tableView.reloadData()
            default:
                print("selected artist Scope out of range.")
            }
        } else if currentUser.venue == "true"{
            switch selectedScope {
            case 0 :
                navigationItem.title = "My Posts"
            case 1 :
                navigationItem.title = "Artists"
            default:
                print("selected venue Scope out of range.")
            }
        }
    }
}

// Location Manager extension
extension SearchTableViewController: CLLocationManagerDelegate {

    func updateSearchResults(for searchController: UISearchController) {

        let text = searchController.searchBar.text
        let scopeIndex = searchController.searchBar.selectedScopeButtonIndex
        let scopes = searchController.searchBar.scopeButtonTitles
        let selectedScope = scopes![scopeIndex]

        sortedArray = posts

        // Search logic for artist user.
        if currentUser.artist == "true"{

            if selectedScope == "Location" {
                if text?.isEmpty == false{
                    sortedArray = posts.filter({$0.title.lowercased().range(of: text!.lowercased()) != nil})
                    tableView.reloadData()
                }
            } else if selectedScope == "Genre" {
                if text?.isEmpty == false{
                    sortedArray = posts.filter({$0.genre.lowercased().range(of: text!.lowercased()) != nil})
                    tableView.reloadData()
                }
            }

            // Searching logic for venue user.
        } else if currentUser.venue == "true"{

            if selectedScope == "My Posts" {
                if text?.isEmpty == false{
                    sortedArray = posts.filter({$0.title.lowercased().range(of: text!.lowercased()) != nil})
                    tableView.reloadData()
                }

            } else if selectedScope == "Genre" {
                if text?.isEmpty == false{
                    sortedArray = posts.filter({$0.genre.lowercased().range(of: text!.lowercased()) != nil})
                    tableView.reloadData()
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLoc = locations[0]
        if sorted == false{
            print("sorted")
            sortPosts()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationServices()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
