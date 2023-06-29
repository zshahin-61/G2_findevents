//
//  SearchUsersView.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//

import SwiftUI

struct SearchUsersView: View {
    @EnvironmentObject var dbHelper: FirestoreController
    @EnvironmentObject var authHelper: FireAuthController
    
    @State private var searchQuery = ""
    @State private var searchResults: [UserProfile] = []
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchQuery, onCommit: performSearch)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            List(searchResults, id: \.id) { userProfile in
                NavigationLink(destination: UserProfileView(userProfile: userProfile)) {
                    Text(userProfile.name)
                }
            }
            .onAppear {
                // Perform initial search when the view appears
                performSearch()
            }
        }
        .navigationTitle("Search")
    }
    
    private func performSearch() {
        dbHelper.searchUserProfiles(withName: searchQuery) { results in
            DispatchQueue.main.async {
                searchResults = results
            }
        }
    }
}
