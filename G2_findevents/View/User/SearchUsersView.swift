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
            HStack {
                TextField("Search", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                Button(action: {
                    performSearch()

                }) {
                    Image(systemName: "magnifyingglass")
                    
                }
                Button(action: {
                    searchQuery = ""
                    performSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                         .font(.system(size: 24))
                        
                    
                }
            }
            
            List(searchResults, id: \.id) { userProfile in
                NavigationLink(destination: UserProfileView(selectedUser: userProfile).environmentObject(authHelper).environmentObject(self.dbHelper)) {
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
                print("$$$$$$$$$$$$$$check\(searchResults)")
                searchResults = results
            }
        }
    }
}
