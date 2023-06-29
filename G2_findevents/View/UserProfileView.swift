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
    
        let userProfile: UserProfile

        var body: some View {
            Text("Hello new user")
            VStack {
                Text(userProfile.name)
                    .font(.title)

                Text("Events Attending: \(userProfile.numberOfEventsAttending)")
                    .padding()

                Button(action: {
                    
                }) {
                    Text("Add Friend")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

               
            }
        }
    }
