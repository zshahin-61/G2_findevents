//
//  G2_findeventsApp.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@main
struct G2_findeventsApp: App {
    let authHelper = FireAuthController()

    init(){
        //configure Firebase in the project
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
           //EventDetailsView()
             ContentView().environmentObject(authHelper)
        }
    }
}
