//
//  User.swift
//  IOSApp
//
//  Created by Dimitar on 1.2.21.
//

import Foundation

let avatars = ["avatarOne","avatarTwo","avatarThree"]

struct User: Codable {
    var id: String?
    var username: String?
    var avatarImage: String?
    
   static func createUser(id: String, username: String) -> User {
        var user = User()
        user.id = id
        user.username = username
        user.avatarImage = avatars.randomElement()
        return user
   }
    
   mutating func setRandomImage() {
        self.avatarImage = avatars.randomElement()
    }

//    init(id:String, username: String) {
//        self.id = id
//        self.username = username
//    }
}
