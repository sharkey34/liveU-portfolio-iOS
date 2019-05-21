//
//  AppliedArtistsTableViewController.swift
//  LiveU
//
//  Created by Eric Sharkey on 9/14/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//

import UIKit
import Firebase

class AppliedArtistsTableViewController: UITableViewController {
    private var ref: DatabaseReference?
    var appliedArtists: [String] = []
    private var artistArray: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        tableView.rowHeight = 267
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Applied Artists"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistArray.count
    }
    
    // Setting the label values for the cell.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AppliedArtistTableViewCell else {return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)}
        
        
        cell.fullNameLabel.text = artistArray[indexPath.row].fullName
        cell.artistImage.image = #imageLiteral(resourceName: "ArtistProfile")
        cell.emailLabel.text = artistArray[indexPath.row].email
        
        let city = artistArray[indexPath.row].location.split(separator: ",")
        let loc: String = city[1] + ", " + city[2]
        
        cell.locationLabel.text = loc
        return cell
    }
    
    
    // Getting the applied users and adding to the array.
    func setup(){
        ref = Database.database().reference()
        for user in appliedArtists {
            ref?.child("users").child(user).observeSingleEvent(of: .value, with: { (snapshot) in
                if let data = snapshot.value as? [String:Any]{
                    let uid = user
                    let fullName = data["fullName"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let about = data["about"] as? String ?? ""
                    let artist = data["artist"] as? String ?? ""
                    let venue = data["venue"] as? String ?? ""
                    let payPal = data["payPal"] as? String ?? ""
                    let location = data["location"] as? String ?? ""
                    let posts = data["posts"] as? [String] ?? nil
                    self.artistArray.append(User(uid: uid, fullName: fullName, email: email, about: about, artist: artist, venue: venue, payPal: payPal, profileImage: nil, location: location, posts: posts, distance: nil))
                    self.tableView.reloadData()
                }
            }, withCancel: { (error) in
                print(error.localizedDescription)
            })
        }
    }
}
