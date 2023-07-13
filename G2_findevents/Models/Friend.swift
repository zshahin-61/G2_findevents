//
//  Friends.swift
//  G2_findevents
//
//  Created by Golnaz Chehrazi on 2023-07-13.
//

import Foundation
import FirebaseFirestoreSwift

struct Friend: Codable, Hashable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    var friendEmail: String
    

    init?(dictionary: [String: Any]) {
        guard let myId = dictionary["id"] as? String else {
            print(#function, "Unable to get ID from JSON")
            return nil
        }

        
        guard let myFriend = dictionary["friendEmail"] as? String else {
            print(#function, "Unable to get friend Email from JSON")
            return nil
        }


        self.init(id: myId, friendEmail: myFriend)
    }

    init(id: String, friendEmail: String) {
        self.id = id
        
        self.friendEmail = friendEmail
    }
}
