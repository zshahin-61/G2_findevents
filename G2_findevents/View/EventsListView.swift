//
//  EventsListView.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//

import SwiftUI

struct EventsListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dbHelper : FirestoreController
    @EnvironmentObject var authHelper : FireAuthController

    @State var evntList:[Event] = []
    
    @State private var selectedCityIndex = 0
    let cities = ["New York", "Pennsylvania"]
  
    var body: some View {
           VStack {
               Text("All Events Near You")
               
               VStack {
                   Picker("Chose Your City",selection:$selectedCityIndex ) {
                       ForEach(0..<cities.count) { index in
                           Text(cities[index])
                       }
                   }
                   .pickerStyle(MenuPickerStyle())

                   List {
                       ForEach(evntList, id: \.type) { currevents in
                           NavigationLink(destination: EventDetailsView(event: currevents).environmentObject(self.dbHelper)) {
                               HStack {
                                   Text("\(currevents.title)")
                                   Spacer()
                                   Text("\(currevents.datetime_utc)")
                               }
                           }
                       }
                   }
               }
           }
           .padding()
           .onAppear() {
               loadDataFromAPI()
           }
       }
       
    
    func loadDataFromAPI() {
        print("Getting data from API")
        
        // 1. Specify the API URL
        let apiUrlString = "https://api.seatgeek.com/2/events?client_id=MzQ1MjY2NjN8MTY4Nzc0MzYxNi45MzE5NzMy"
        
        guard let apiUrl = URL(string: apiUrlString) else {
            print("ERROR: Cannot convert API address to a URL object")
            return
        }
        
        // 2. Create a network request object
        let request = URLRequest(url: apiUrl)
        
        // 3. Connect to the API and handle the results
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("ERROR: Network error: \(error)")
                return
            }
            
            if let jsonData = data {
                          print("data retreived")
                          if let decodedResponse
                              = try? JSONDecoder().decode(eventsReponseObj.self, from:jsonData) {
                              // if conversion successful, then output it to the console
                              DispatchQueue.main.async {
                                  print(decodedResponse)
                                  var recipes = decodedResponse.events
                                  self.evntList = recipes
                              }
                          }
                          else {
                              print("ERROR: Error converting data to JSON")
                          }
                      }
                      else {
                          print("ERROR: Did not receive data from the API")
                      }
                  }
                  task.resume()

    }
}// end ContentView struct
