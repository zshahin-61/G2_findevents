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
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack {
            HStack {
                if let imageData = userProfile.image, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                }
                
                VStack(alignment: .leading) {
                    Text(userProfile.name)
                        .font(.title)
                    Text("Events Attending: \(userProfile.numberOfEventsAttending)")
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

            VStack {
                Text("\(userProfile.name)'s Next Event")
                    .font(.title)
                
                
                Spacer()
                Text("Friends Attending")
                    .font(.title)
            }
            .padding()
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Friend Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        })
    }
    
    func addFriend() {
        dbHelper.addFriend(newFriend: userProfile)
    }
    
    func removeFriend() {
        dbHelper.removeFriend(friendDelet: userProfile)
        
    }
}
