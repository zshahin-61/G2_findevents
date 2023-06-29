//
//  MyFriendsView.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//

import SwiftUI

struct MyFriendsView: View {
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    
    var body: some View {
        VStack {
            Text("Your Friends List").font(.title)
            
            Button(action: {
                dbHelper.deleteAllMyFriends()
            }) {
                Text("Remove All")
            }
            .buttonStyle(.borderedProminent)
            
            List {
                if dbHelper.myFriendsList.isEmpty {
                    Text("No Friends exist to Show")
                }
                
                ForEach(dbHelper.myFriendsList) { myFrnd in
                    VStack {
                        Text(myFrnd.name)
                        Text(myFrnd.contactNumber)
                        Spacer()
                        if let imageData = myFrnd.image {
                            Image(uiImage: UIImage(data: imageData)!)
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            dbHelper.myFriendsList.removeAll()
            dbHelper.getFriends()
        }
    }
}
