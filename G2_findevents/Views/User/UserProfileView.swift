//
//  UserprofileView.swift
//  G2_findevents
//
//  Created by Created by Zahra Shahin - Golnaz Chehrazi on 2023-06-25 on 2023-06-28.
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
    @State private var attendingList : [UserProfile]? = []
    
    var body: some View {
        VStack {
            Form{
                Section{
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
                }  .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if isFriend {
                                removeFriend()
                            } else {
                                addFriend()
                            }
                        }) {
                            Image(systemName: isFriend ? "person.badge.minus" : "person.badge.plus").font(.system(size: 27))
                        }
                    }
                }
                .onChange(of: isFriend){
                    newvalue in
                   
                   
                }
                
                
           
                Section(header: Text("\(selectedUser.name)'s Next Event")
                    .font(.headline)){
                   
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
                                                    .frame(width: 120, height: 120)
                                            case .failure(_):
                                                
                                                EmptyView()
                                            case .empty:
                                                
                                                EmptyView()
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                }
                                VStack {
                                    Text(nextEVT.title).font(.headline)
                                    Spacer()
                                    Text("\(nextEVT.date)").font(.subheadline)
                                }
                            }
                        
                     
                    }//if let
                    else{
                        Text("No Next Event")
                    }
                }
                Section(header: Text("Friends Attending")
                    .font(.headline)){
                        if let attList = self.attendingList {
                            ForEach(attList, id:\.id){
                                att in
                                Text(att.name)
                                
                            }
                        }
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
                        //print("Event: \(events)")
        dbHelper.getFriendsAttendingInEvent(nextEventId: evt.id!){
            (attList, err) in
            if let errr = err {
                // Handle the error
                print("Error retrieving attendingList: \(errr.localizedDescription)")
            } else if var att = attList {
               att.removeAll(where: {$0.id == self.selectedUser.id})

                                self.attendingList = att
                                // print("%%%%%%%%%\(att) and \(evt.id)")
                            } //else if let
                        } //getFriendsAttendingInEvent
                    } // else if let
                }
                checkfriendship()
            }
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Friend Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            })
        }
    }
    func addFriend() {
        dbHelper.addFriend(newFriend: selectedUser)
        isFriend = true
    }
    
    func removeFriend() {
        dbHelper.removeFriend(friendDelet: selectedUser)
        isFriend = false
    }
    func checkfriendship(){
        isFriend = dbHelper.isUserFriend(selectedUser)
    }
}
