//
//  HomeView.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-26.
//

import SwiftUI
struct HomeView: View {
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    
    @Binding var rootScreen: RootView
    
    @State private var selectedLink: Int? = nil

    var body: some View {
        NavigationView {
            TabView {
                EventsListView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Events")
                    }
                
                MyEventsView()
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("My Events")
                    }
                
                SearchUsersView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search Users")
                    }
                
                MyFriendsView()
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text("My Friends")
                    }
            }
            .navigationBarTitle("", displayMode: .inline) 
            .navigationBarItems(
                leading: Button(action: {
                    // Perform sign out action here
                    authHelper.signOut()
                    rootScreen = .Login
                }) {
                    Image(systemName: "person.crop.circle.badge.xmark")
                },
                trailing: NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.crop.circle")
                }
            )
            .padding(.top, -50) // Adjust the padding to remove the gap
        }
    }
}

