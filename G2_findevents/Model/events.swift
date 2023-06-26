//
//  events.swift
//  G2_findevents
//
//  Created by Zahra SHAHIN - Golnaz Chehrazi on 2023-06-25.
//

import Foundation

struct eventsReponseObj: Codable,Hashable {
    var events:[Event]
}

struct Stats: Codable,Hashable{
    //var average_price: Double
}

struct Performer: Codable,Hashable{
    var id: Int
    var type: String
    var name: String
    var image: String
}

struct Images: Codable,Hashable {
    var large: String?
    var huge: String?
    var small: String?
    var medium: String?
}

struct Location: Codable,Hashable {
    var lat: Double
    var lon: Double
}

struct Venue: Codable,Hashable {
    var id: Int
    var state: String
    var name: String
    var location: Location
    var address: String
    var country: String
    var city: String
    var display_location: String
    var url: String
}

struct Event: Codable,Hashable {
    var id: Int
    var type: String
    var title: String
    var performers: [Performer]
    var datetime_utc: String
    var venue: Venue
    var datetime_local: String
    var stats: Stats
    //var visible_at: String
    
//    let links: [String]
//    let images: Images
}
 

