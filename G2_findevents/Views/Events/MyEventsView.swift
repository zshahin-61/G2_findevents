//
//  MyEventsView.swift
//  G2_findevents
//
//  Created by Zahra Shahin - Golnaz Chehrazi on 2023-06-25.
//

import SwiftUI
import MapKit

struct MyEventsView: View {
    
    
    @EnvironmentObject var authHelper : FireAuthController
    @EnvironmentObject var dbHelper : FirestoreController
    
    var body: some View {
        VStack {
            Button(action:{
                self.dbHelper.deleteAllMyEvents()
                if let currUser = self.dbHelper.userProfile{
                    self.dbHelper.userProfile!.numberOfEventsAttending = 0
                    self.dbHelper.updateUserProfile(userToUpdate: self.dbHelper.userProfile!)
                }
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
                    Section{
                        Text(myEvt.title).bold().foregroundColor(Color.blue)
                        AsyncImage(url: URL(string: myEvt.image)){ image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        HStack{
                            Text("\(dateFormatter(date: myEvt.date))")
                            Spacer()
                            Text(myEvt.location)
                        }
                    }
                } //FOREACH
                .onDelete(perform: { indexSet in
                    for index in indexSet{
                        //get the  object to delete
                        let evt = self.dbHelper.myEventsList[index]
                        //delete the document from database
                        self.dbHelper.deleteMyEvent(eventToDelete: evt)
                        if let currUser = dbHelper.userProfile{
                            dbHelper.userProfile!.numberOfEventsAttending -= 1
                            dbHelper.updateUserProfile(userToUpdate: dbHelper.userProfile!)
                        }
                    }
                    
                })//onDelete
            }//LIST
            Spacer()
        }//VSTACK
        .onAppear {
            //check/request for permissions

           //self.locationHelper.checkPermission()

            //self.locationHelper.checkPermission()

            
        }
    }
    func dateFormatter(date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
}


