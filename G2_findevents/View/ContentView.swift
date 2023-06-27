//
//  ContentView.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authHelper : FireAuthController
    private var dbHelper = FirestoreController.getInstance()
    
    @State private var root : RootView = .Login
    
    var body: some View {
        
        NavigationView{
            switch root {
            case .Login:
                SignInView(rootScreen: $root).environmentObject(authHelper).environmentObject(self.dbHelper)
            case .Home:
                HomeView(rootScreen: $root).environmentObject(authHelper).environmentObject(self.dbHelper)
                    
            case .SignUp:
                SignUpView(rootScreen: $root).environmentObject(self.authHelper).environmentObject(self.dbHelper)
            
            }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



