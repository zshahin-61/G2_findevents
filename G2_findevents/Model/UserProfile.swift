//
//  UserProfile.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//

import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Codable, Hashable {
    @DocumentID var id: String? = UUID().uuidString
    var name: String
    var contactNumber: String
    var address: String
    var events:[String] = [String]()

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

        guard let myEvents = dictionary["events"] as? [String] else {
            print(#function, "Unable to get events from JSON")
            return nil
        }

        self.init(id: myId, name: myName, contactNumber: myContactNumber, address: myAddress, events: myEvents)
    }

    init(id: String, name: String, contactNumber: String, address: String, events: [String]) {
        self.id = id
        self.name = name
        self.contactNumber = contactNumber
        self.address = address
        self.events = events
    }
}
