//
//  MyEventsView.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//

import SwiftUI

struct MyEventsView: View {
    
    @EnvironmentObject var authHelper : FireAuthController
    @EnvironmentObject var dbHelper : FirestoreController
    
    var body: some View {
        VStack {
            Button(action:{
                dbHelper.myEventsList.removeAll()
                
            }){
                Text("Remove All")
            }.buttonStyle(.borderedProminent)
            
            List{
                if(dbHelper.myEventsList.isEmpty)
                {
                    Text("No Event To Show")
                }
                
                ForEach(dbHelper.myEventsList, id:\.id){
                    myEvt in
                    //HStack{
                        AsyncImage(url: URL(string: myEvt.image)).frame(width: 100, height: 50)
                        VStack{
                            Text(myEvt.title)
                            Text(myEvt.date)
                            Text(myEvt.location)
                        }//VSTACK
                        
                   // }//HSTACK
                    
                } //FOREACH
            }//LIST
            Spacer()
        }//VSTACK
        .onAppear {
            dbHelper.myEventsList.removeAll()
            dbHelper.getMyEventsList()
        }
    }
    
//    func removeEvent(at offsets: IndexSet) {
//        events.remove(atOffsets: offsets)
//        if let removedIndex = offsets.first {
//            let removedEvent = events[removedIndex]
//
//            updateAttendeesList(for: removedEvent, isAttending: false)
//        }
//    }
    
//    func removeAllEvents() {
//
//        events.removeAll()
//        for event in events {
//            updateAttendeesList(for: event, isAttending: false)
//        }
//    }
    
    //func updateAttendeesList(for event: Event, isAttending: Bool) {
//         event.attendees = isAttending ? event.attendees.filter { $0 != User } : event.attendees
    //}
}


