//
//  Posts.swift
//  LiveU
//
//  Created by Eric Sharkey on 9/12/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//

import Foundation

class Posts {
    
    // Post properties
    var uid: String
    var title: String
    var genre: String
    var budget: String
    var date : String
    var location: String
    var distance: Double!
    var lat: Double!
    var long: Double!
    
    
    init(uid: String, title: String, genre: String, budget: String, date: String, location: String, distance: Double?, lat: Double?, long: Double?) {
        
        self.uid = uid
        self.title = title
        self.genre = genre
        self.budget = budget
        self.date = date
        self.location = location
        self.distance = distance
        self.lat = lat
        self.long = long
    }
}
