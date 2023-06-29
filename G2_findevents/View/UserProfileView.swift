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
    
    @State private var isFriend: Bool = false
    
    var body: some View {
        VStack {
            HStack{
                if let imageData = userProfile.image, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                }
                
                VStack{
                    Text(userProfile.name)
                        .font(.title)
                    Text("Events Attending: \(userProfile.numberOfEventsAttending)")
                }
                
                
                
                
            }
            Spacer()
            Toggle(isOn: $isFriend, label: {
                Text(isFriend ? "Remove Friend" : "Add Friend")
            })
            .font(.headline)
            .padding()
            .foregroundColor(.white)
            .background(isFriend ? Color.red : Color.blue)
            .cornerRadius(10)
            .onTapGesture {
                if isFriend {
                    //  removeFriend()
                } else {
                 //   addFriend()
                }
            }
            
            
        }
        VStack{
            Text("\(userProfile.name) Next Event")
                .font(.title)
            Spacer()
            
            Text("Name of  Event")
            Spacer()
            List{
                Text("Are Also Attending")
            }
                
        }
        
    }
}
