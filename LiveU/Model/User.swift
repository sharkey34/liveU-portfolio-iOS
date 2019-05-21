//
//  User.swift
//  LiveU
//
//  Created by Eric Sharkey on 9/7/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//

import Foundation
import UIKit

class User:  NSObject, NSCoding {
    
    // Properties
    var uid: String
    var fullName: String
    var email: String
    var about: String
    var artist: String!
    var venue: String!
    var payPal: String!
    var profileImage: UIImage!
    var location: String!
    var posts: [String]!
    var distance: Double!
    
    // Encoding properties
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(fullName, forKey: "fullName")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(about, forKey: "about")
        aCoder.encode(artist, forKey: "artist")
        aCoder.encode(venue, forKey: "venue")
        aCoder.encode(payPal, forKey: "payPal")
        aCoder.encode(profileImage, forKey: "profileImage")
        aCoder.encode(location, forKey: "location")
        aCoder.encode(posts, forKey: "posts")
        aCoder.encode(posts, forKey: "distance")

    }
    
    // Decoding intializer
    required init?(coder aDecoder: NSCoder) {
        
        self.uid = (aDecoder.decodeObject(forKey: "uid") as! String)
        self.fullName = (aDecoder.decodeObject(forKey: "fullName") as! String)
        self.email = (aDecoder.decodeObject(forKey: "email") as! String)
        self.about = (aDecoder.decodeObject(forKey: "about") as! String)
        self.artist = aDecoder.decodeObject(forKey: "artist") as? String
        self.venue = aDecoder.decodeObject(forKey: "venue") as? String
        self.payPal = (aDecoder.decodeObject(forKey: "payPal") as? String)
        self.profileImage = (aDecoder.decodeObject(forKey: "profileImage") as? UIImage)
        self.location = (aDecoder.decodeObject(forKey: "location") as? String)
        self.posts = (aDecoder.decodeObject(forKey: "posts") as? [String])
        self.distance = (aDecoder.decodeObject(forKey: "distance") as? Double)
    }
    
    init(uid: String,fullName: String, email: String,about: String, artist: String?, venue: String?, payPal: String?, profileImage: UIImage?, location: String?, posts: [String]?, distance: Double?) {
        
        self.uid = uid
        self.fullName = fullName
        self.email = email
        self.about = about
        self.artist = artist
        self.venue = venue
        self.payPal = payPal
        self.profileImage = profileImage
        self.location = location
        self.posts = posts
        self.distance = distance
    }
}
