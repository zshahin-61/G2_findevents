//
//  UserProfile.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//

import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Codable, Hashable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    var name: String
    var contactNumber: String
    var address: String
    var image: Data?
    var friends: [String] // DocumentID
    var numberOfEventsAttending: Int

    init?(dictionary: [String: Any]) {
        guard let myId = dictionary["id"] as? String else {
            print(#function, "Unable to get user ID from JSON")
            return nil
        }

        guard let myName = dictionary["name"] as? String else {
            print(#function, "Unable to get user Name from JSON")
            return nil
        }

        guard let myContactNumber = dictionary["contactNumber"] as? String else {
            print(#function, "Unable to get contactNumber from JSON")
            return nil
        }

        guard let myAddress = dictionary["address"] as? String else {
            print(#function, "Unable to get address from JSON")
            return nil
        }
        
        guard let myImage = dictionary["image"] as? Data else {
            print(#function, "Unable to get image from JSON")
            return nil
        }
        
        guard let myFriends = dictionary["friends"] as? [String] else {
            print(#function, "Unable to get friends from JSON")
            return nil
        }
        
        guard let myNumberOfEventsAttending = dictionary["numberOfEventsAttending"] as? Int else {
            print(#function, "Unable to get numberOfEventsAttending from JSON")
            return nil
        }

        self.init(id: myId, name: myName, contactNumber: myContactNumber, address: myAddress, image: myImage, friends: myFriends, numberOfEventsAttending: myNumberOfEventsAttending)
    }

    init(id: String, name: String, contactNumber: String, address: String, image: Data?, friends: [String], numberOfEventsAttending: Int = 0) {
        self.id = id
        self.name = name
        self.contactNumber = contactNumber
        self.address = address
        self.image = image
        self.friends = friends
        self.numberOfEventsAttending = numberOfEventsAttending
    }
}
