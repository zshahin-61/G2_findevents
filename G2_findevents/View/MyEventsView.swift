//
//  MyEventsView.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//

import SwiftUI

struct MyEventsView: View {
    @State private var events: [Event] = []
    @State private var selectedEvent: Event? = nil

    var body: some View {
        VStack {
         
              
            Button("Remove All Events", action: removeAllEvents)
        }
        .onAppear {
        }
    }
    
    func removeEvent(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
        if let removedIndex = offsets.first {
            let removedEvent = events[removedIndex]
            
            updateAttendeesList(for: removedEvent, isAttending: false)
        }
    }
    
    func removeAllEvents() {

        events.removeAll()
        for event in events {
            updateAttendeesList(for: event, isAttending: false)
        }
    }
    
    func updateAttendeesList(for event: Event, isAttending: Bool) {
//         event.attendees = isAttending ? event.attendees.filter { $0 != User } : event.attendees
    }
}


