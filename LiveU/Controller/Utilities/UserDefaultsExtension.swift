//
//  UserDefaultsExtension.swift
//  LiveU
//
//  Created by Eric Sharkey on 9/10/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//

import Foundation


// Extension to Archive and Unarchive the currentUser
extension UserDefaults{
    
    func set(currentUser: User, forKey key: String){
        let binaryData = NSKeyedArchiver.archivedData(withRootObject: currentUser)
        self.set(binaryData, forKey: key)
    }
    
    func currentUser(forKey key: String) -> User?{
        if let binaryData = data(forKey: key){
            if let currentUser = NSKeyedUnarchiver.unarchiveObject(with: binaryData) as? User {
                return currentUser
            }
        }
        return nil
    }
}
