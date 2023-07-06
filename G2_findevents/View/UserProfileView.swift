//
//  UserprofileView.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-28.
//

import SwiftUI
struct UserProfileView: View {
    @EnvironmentObject var dbHelper: FirestoreController
    @EnvironmentObject var authHelper: FireAuthController
    
    let selectedUser: UserProfile
    
    @State private var isFriend: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var nextEvent: MyEvent?
    @State private var attendingList : [UserProfile]?
    
    var body: some View {
        VStack {
            HStack {
                if let imageData = selectedUser.image, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                }
                
                VStack(alignment: .leading) {
                    Text(selectedUser.name)
                        .font(.title)
                    Text("Events Attending: \(selectedUser.numberOfEventsAttending)")
                }
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                if isFriend {
                    removeFriend()
                } else {
                    addFriend()
                }
            }) {
                Text(isFriend ? "Remove Friend" : "Add Friend")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(isFriend ? Color.red : Color.blue)
                    .cornerRadius(10)
            }

            VStack{
                Text("\(selectedUser.name)'s Next Event")
                    .font(.title)
                if let nextEVT = self.nextEvent {
                    HStack{
                        if !nextEVT.image.isEmpty{
                            //AsyncImage(url:URL(string: nextEVT.image))
                            GeometryReader { geometry in
                                AsyncImage(url: URL(string: nextEVT.image)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 120, height: 120) // Set the desired width and height
                                    case .failure(_):
                                        // Handle the failure case or display a placeholder image
                                        // ...
                                        EmptyView()
                                    case .empty:
                                        // Handle the empty case or display a placeholder image
                                        // ...
                                        EmptyView()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                        VStack {
                            Text(nextEVT.title)
                            Text("\(nextEVT.date)")
                        }
                    }
                    List{
                        Text("Friends Attending")
                            .font(.title)
                        if let attList = self.attendingList {
                            ForEach(attList, id:\.id){
                                att in
                                Text(att.name)

                            }
                        }
                    }
                }//if let
                else{
                    Text("No Next Event")
                }
                Spacer()
            }
            .padding()
        }.onAppear(){
            dbHelper.getNearbyEvents(selectedUser: self.selectedUser) { (events, error) in
                if let error = error {
                    // Handle the error
                    print("Error retrieving nearby events: \(error.localizedDescription)")
                } else if let evt = events {
                    // Use the retrieved events
                    self.nextEvent = evt
                    print("Event: \(events)")
                    dbHelper.getFriendsAttendingInEvent(nextEventId: evt.id!){ (attList, err) in
                        if let err = err {
                            // Handle the error
                            print("Error retrieving attendingList: \(err.localizedDescription)")
                        } else if let att = attList {
                            self.attendingList = att
                            print("%%%%%%%%%\(att)")
                        } //else if let
                    } //getFriendsAttendingInEvent
                } // else if let
            }
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Friend Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        })
    }
    
    func addFriend() {
        dbHelper.addFriend(newFriend: selectedUser)
    }
    
    func removeFriend() {
        dbHelper.removeFriend(friendDelet: selectedUser)
        
    }
}
