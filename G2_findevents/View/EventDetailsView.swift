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
    
    var event: Event = Event(id: 6032999, type:"broadway_tickets_national", title: "Hamilton - Toronto", performers: [Performer(id: 97669, type: "theater_broadway_national_tours", name: "Hamilton", image: "https://seatgeek.com/images/performers-landscape/hamilton-328ab3/97669/huge.jpg")], datetime_utc: "2023-06-24T17:30:00", venue: Venue(id: 1971, state: "ON", name: "Princess of Wales Theatre Toronto", location: Location(lat: 43.647, lon: -79.3892), address: "300 King St. W", country: "Canada", city: "Toronto", display_location: "Toronto, Canada", url:"https://seatgeek.com/venues/princess-of-wales-theatre-toronto/tickets"),datetime_local: "2023-06-24T13:30:00", stats: Stats(average_price: 284, median_price:0 , lowest_sg_base_price: 0, lowest_sg_base_price_good_deals:0))
    
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
                            Text(per.name)
                            //Text("type: \(per.type)")
                            AsyncImage(url:URL(string:per.image))
                        }
                    }
                    Text("Local Date:\(event.datetime_local)")
                    
                    Section(header:Text("Venue")){
                        Text("Name: \(event.venue.name)")
                        Text("Location: \(event.venue.display_location)")
                        Text("City: \(event.venue.city)")
                    }
                }//List
                Spacer()
                Button(action:{
                    // TODO: add to firestore
                    //var newEvent = Event()
                    //var newEvent = MyEvent(id: String(event.id), event: event)
                    dbHelper.insertEvent(newEvent: event)
                    
                }){
                    Text("I will Attend")
                }.buttonStyle(.borderedProminent)
        }
    }
    // MARK: function for ToggleFavorite
    private func toggleFavorite() {
        
        //isFav = user.favorites.contains(where: {$0 == activity.id})
        //activity.isFavorite.toggle()
        //if !isFav{
            //user.addFavorite(activity.id)
        //} else {
            //user.removeFavorite(activity.id)
        //}
        //isFav.toggle()
    }
    
    
}
