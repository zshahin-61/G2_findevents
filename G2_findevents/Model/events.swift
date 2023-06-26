//
//  events.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//

import Foundation

struct eventsReponseObj: Codable {
    var events:[Event]
}

struct Images: Codable {
    let large: String?
    let huge: String?
    let small: String?
    let medium: String?
}

struct Venue: Codable {
    let state: String
    let name_v2: String
}

struct Location: Codable {
    let lat: Double
    let lon: Double
}

struct Event: Codable {
    let type: String
   // let id: Int
    let datetime_utc: String
//   let venue: Venue
//    let links: [String]
//    let location: Location
//    let images: Images
}
 

