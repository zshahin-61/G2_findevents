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
    var average_price: Int?
    var median_price: Int?
    var lowest_sg_base_price: Int?
    var lowest_sg_base_price_good_deals: Int?
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

struct Event: Codable,Hashable,Identifiable {
    var id: Int
    var type: String
    var title: String
    var short_title: String
    var url: String
    var performers: [Performer]
    var datetime_utc: String
    var venue: Venue
    var datetime_local: String
    var stats: Stats
}




 

