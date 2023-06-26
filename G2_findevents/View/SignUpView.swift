//
//  SignUpView.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//

import SwiftUI


struct SignUpView: View {
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var contactNumber: String = ""
    @State private var events: [String] = [String]()
    @State private var errorMsg: String? = nil
    @Binding var rootScreen: RootView
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    self.rootScreen = .Login
                }) {
                    Text("Back to Login")
                }
            }
            
            Form {
                TextField("Enter Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Enter Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Enter Name", text: $name)
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Enter Contact Number", text: $contactNumber)
                    .keyboardType(.phonePad)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Enter Address", text: $address)
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: {
                    self.authHelper.signUp(email: self.email.lowercased(), password: self.password) { isSuccessful in
                        if isSuccessful {
                            let userProfile = UserProfile(id: self.email.lowercased(), name: self.name, contactNumber: self.contactNumber, address: self.address, events: self.events)
                            self.dbHelper.createUserProfile(newUserProfile: userProfile)
                            
                            // Show home screen
                            self.rootScreen = .Home
                        } else {
                            // Show alert with error message
                            print("Unable to create user")
                        }
                    }
                }) {
                    Text("Create Account")
                }
                .buttonStyle(.borderedProminent)
                .disabled(password != confirmPassword || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            }
            .autocorrectionDisabled(true)
            
            Spacer()
        }
    }
}

