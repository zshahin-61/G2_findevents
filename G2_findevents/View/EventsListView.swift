//
//  EventsListView.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//
import SwiftUI
import MapKit

struct EventsListView: View {
    //@Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var dbHelper: FirestoreController
    @EnvironmentObject var authHelper: FireAuthController
    @State var evntList: [Event] = []
    @State private var selectedCity = ""
    
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    var body: some View {
        VStack {
            Text("All Events Near You").font(.title)
            VStack {
                HStack{
                    TextField("Enter City", text: $selectedCity)
                         .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action:{
                        evntList.removeAll()
                        if(!self.selectedCity.isEmpty)
                        {
                            loadDataFromAPIbyCity()
                        }
                        else
                        {
                            loadDataFromAPI()
                        }
                        //calculateMapRegion()
                        
                    }){
                        Text("Search")
                    }
                }
                VStack {
                    Text("Event Map")
                        .font(.headline)
                    if !evntList.isEmpty {
                        Map(coordinateRegion: $mapRegion, annotationItems: evntList) { event in
                            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: event.venue.location.lat, longitude: event.venue.location.lon)) {
                                NavigationLink(destination: EventDetailsView(event: event).environmentObject(authHelper).environmentObject(self.dbHelper)) {
                                    VStack {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.title)
                                        Text(event.type)
                                            .font(.caption)
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 4)
                                    }
                                }
                            }
                        }
                        .frame(height: 300)
                        .border(Color.gray)
                        .onAppear {
                            calculateMapRegion()
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
        .onAppear {
            loadDataFromAPI()
        }
    }
    
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    func loadDataFromAPI() {
        self.evntList = [Event]()
        print("Getting data from API")
        
        // 1. Specify the API URL
        let apiUrlString = "https://api.seatgeek.com/2/events?datetime_utc.gt=\(getCurrentDate())&client_id=MzQ1MjY2NjN8MTY4Nzc0MzYxNi45MzE5NzMy"
        
        print("%%%%%$$$$######\(apiUrlString)")
        
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
                print("Data retrieved")
                if let decodedResponse = try? JSONDecoder().decode(eventsReponseObj.self, from: jsonData) {
                    DispatchQueue.main.async {
                        //print(decodedResponse)
                        let events = decodedResponse.events
                        self.evntList = events
                    }
                } else {
                    print("ERROR: Error converting data to JSON")
                }
            } else {
                print("ERROR: Did not receive data from the API")
            }
        }
        task.resume()
    }
    
    func loadDataFromAPIbyCity() {
        self.evntList = [Event]()
        //evntList.removeAll()
        print("Getting data from API")
        
        // 1. Specify the API URL
        let apiUrlString = "https://api.seatgeek.com/2/events?venue.city=\(self.selectedCity)&datetime_utc.gt=\(getCurrentDate())&client_id=MzQ1MjY2NjN8MTY4Nzc0MzYxNi45MzE5NzMy"
        
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
                print("Data retrieved")
                if let decodedResponse = try? JSONDecoder().decode(eventsReponseObj.self, from: jsonData) {
                    DispatchQueue.main.async {
                        print(decodedResponse)
                        let events = decodedResponse.events
                        self.evntList = events
                    }
                } else {
                    print("ERROR: Error converting data to JSON")
                }
            } else {
                print("ERROR: Did not receive data from the API")
            }
        }
        task.resume()
    }
    
    func calculateMapRegion() {
        guard let firstEvent = evntList.first else {
            return
        }
        
        var minLatitude = firstEvent.venue.location.lat
        var maxLatitude = firstEvent.venue.location.lat
        var minLongitude = firstEvent.venue.location.lon
        var maxLongitude = firstEvent.venue.location.lon
        
        for event in evntList {
            let latitude = event.venue.location.lat
            let longitude = event.venue.location.lon
            
            if latitude < minLatitude {
                minLatitude = latitude
            }
            
            if latitude > maxLatitude {
                maxLatitude = latitude
            }
            
            if longitude < minLongitude {
                minLongitude = longitude
            }
            
            if longitude > maxLongitude {
                maxLongitude = longitude
            }
        }
        
        let center = CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude) / 2.0, longitude: (minLongitude + maxLongitude) / 2.0)
        let span = MKCoordinateSpan(latitudeDelta: (maxLatitude - minLatitude) * 1.1, longitudeDelta: (maxLongitude - minLongitude) * 1.1)
        mapRegion = MKCoordinateRegion(center: center, span: span)
    }
}
