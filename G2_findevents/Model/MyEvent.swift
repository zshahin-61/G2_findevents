//
//  MyEvent.swift
//  G2_findevents
//
//  Created by Golnaz Chehrazi on 2023-06-26.
//

import Foundation
import FirebaseFirestoreSwift

struct MyEvent: Codable, Hashable{
    @DocumentID var id : String? = UUID().uuidString
    var type: String
    var title: String
    var date: Date
    var image: String
    var location: String
   
    init?(dictionary: [String: Any], documentId: String, dateFromDB : Date) {
//        guard let mId = dictionary["id"] as? String else {
//            print(#function, "Unable to get Event ID from JSON")
//            return nil
//        }
        
        let mId = dictionary["id"] as? String ?? documentId
        
        guard let mType = dictionary["type"] as? String else {
            print(#function, "Unable to get type from JSON")
            return nil
        }
        
        guard let mTitle = dictionary["title"] as? String else {
            print(#function, "Unable to get title from JSON")
            return nil
        }
        
//        guard let mDate = dictionary["date"] as? Date else {
//            print(#function, "Unable to get date from JSON")
//            return nil
//        }
        let mDate = dictionary["date"] as? Date ?? dateFromDB
        
        guard let mImage = dictionary["image"] as? String else {
            print(#function, "Unable to get image from JSON")
            return nil
        }
        
        guard let mlocation = dictionary["location"] as? String else {
            print(#function, "Unable to get location from JSON")
            return nil
        }
        
        self.init(id: mId, type: mType, title: mTitle, date: mDate, image: mImage, location: mlocation)
    }
    
    init(id: String, type: String, title: String, date: Date, image:String,  location:String) {
        self.id = id
        self.type = type
        self.title = title
        self.date = date
        self.location = location
        self.image = image
    }
    
}

