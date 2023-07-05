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
                //dbHelper.myEventsList.removeAll()
                dbHelper.deleteAllMyEvents()
                if let currUser = dbHelper.userProfile{
                    dbHelper.userProfile!.numberOfEventsAttending = 0
                    dbHelper.updateUserProfile(userToUpdate: dbHelper.userProfile!)
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
                    VStack{
                        //VStack{
                        Text(myEvt.title)
                        Text("\(myEvt.date)")
                        Text(myEvt.location)
                        //                        }
                        Spacer()
                        //                        VStack{
                        //AsyncImage(url: URL(string: myEvt.image)).frame(width: 100, height: 50)
                        //}
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
            //dbHelper.myEventsList.removeAll()
            //dbHelper.getMyEventsList()
        }
    }
    
}


