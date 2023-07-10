//
//  EventDetailsView.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-26.
//

import SwiftUI

struct EventDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dbHelper : FirestoreController
    @EnvironmentObject var authHelper : FireAuthController
    
    var event: Event //= Event(id: 6032999, type:"broadway_tickets_national", title: "Hamilton - Toronto", performers: [Performer(id: 97669, type: "theater_broadway_national_tours", name: "Hamilton", image: "https://seatgeek.com/images/performers-landscape/hamilton-328ab3/97669/huge.jpg")], datetime_utc: "2023-06-24T17:30:00", venue: Venue(id: 1971, state: "ON", name: "Princess of Wales Theatre Toronto", location: Location(lat: 43.647, lon: -79.3892), address: "300 King St. W", country: "Canada", city: "Toronto", display_location: "Toronto, Canada", url:"https://seatgeek.com/venues/princess-of-wales-theatre-toronto/tickets"),datetime_local: "2023-06-24T13:30:00", stats: Stats(average_price: 284, median_price:0 , lowest_sg_base_price: 0, lowest_sg_base_price_good_deals:0))
    
    @State private var toggleBtnText : String = "I will Attend"
    
    var body: some View {
        VStack{
            Text(event.type)
            MapView(latitude: event.venue.location.lat, longitude: self.event.venue.location.lon)
            //.edgesIgnoringSafeArea(.all)
                .frame(width: 300, height: 150).border(.gray)
            List{
                Text("\(event.title)")
                Section(header: Text("Performers")){
                    ForEach(event.performers, id:\.self){ per in
                        if let name = per.name{
                            Text(name)
                        }
                        //Text("type: \(per.type)")
                        if let image = per.image{
                            AsyncImage(url:URL(string:image))
                        }
                    }
                }
                Text("Local Date:\(event.datetime_local)")
                
                if let price = event.stats.average_price{
                    Text("Price: $\(price)")
                }
                Section(header:Text("Venue")){
                    if let  name = event.venue.name{
                        Text("Name: \(name)")
                    }
                    if let location = event.venue.display_location{
                        Text("Location: \(location)")
                    }
                    if let city = event.venue.city{
                        Text("City: \(city)")
                    }
                }
            }//List
            Spacer()
            Button(action:{
                var counter = 0
                
                let dateString = event.datetime_local
                guard let dateDate = formattedDate(dateString: dateString) else {
                    print("Error: Invalid date format!")
                    return
                }
                
                var newEvent = MyEvent(id: String(event.id), type: event.type, title: event.title, date: dateDate, image: event.performers[0].image ?? "" , location: event.venue.display_location ?? "")
                
                if(!dbHelper.myEventsList.contains(where: {$0.id == newEvent.id })){
                    dbHelper.insertMyEvent(newEvent: newEvent)
                    toggleBtnText = "Cancel Attending"
                    counter = 1
                }
                else{
                    toggleBtnText = "I will attend"
                    dbHelper.deleteMyEvent(eventToDelete: newEvent)
                    counter = -1
                }
                
                if let currentUser = dbHelper.userProfile{
                    dbHelper.userProfile!.numberOfEventsAttending += counter
                    dbHelper.updateUserProfile(userToUpdate: dbHelper.userProfile!)
                }
            }){
                Text(self.toggleBtnText)
            }.buttonStyle(.borderedProminent)
        }.onAppear(){
            if(dbHelper.myEventsList.contains(where: {$0.id == String(event.id)}))
            {
                toggleBtnText = "Cancel Attending"
            }
            else
            {
                toggleBtnText = "I will Attend"
            }
        }
    }
    
    func formattedDate(dateString: String)-> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .medium
            return date
        } else {
            return nil
        }
    }
}
