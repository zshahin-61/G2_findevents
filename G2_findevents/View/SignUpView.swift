//
//  SignUpView.swift
//  G2_findevents
//
//  Created by Golnaz Chehrazi on 2023-06-23.
//

import SwiftUI
import PhotosUI

struct SignUpView: View {
    @EnvironmentObject var authHelper : FireAuthController
    @EnvironmentObject var dbHelper : FirestoreController
    
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var confirmPassword : String = ""
    @State private var addressFromUI : String = ""
    @State private var phoneFromUI : String = ""
    @State private var nameFromUI : String = ""
    @State private var carPlateNumber : String = ""
    @State private var cpnList : [String] = [String]()
    @State private var errorMsg : String? = nil
    
    @Binding var rootScreen : RootView
    
    var body: some View {
        
        VStack{
            Form{
                TextField("Enter Email", text: self.$email)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Enter Password", text: self.$password)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Confirm Password", text: self.$confirmPassword)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Name", text: self.$nameFromUI)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Address", text: self.$addressFromUI)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Phone Number", text: self.$phoneFromUI)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
            }
            .autocorrectionDisabled(true)
            .navigationTitle("Sign Up Form")
           
            
            HStack{
          
                
                Button(action:{
                    self.rootScreen = .Login
                }){
                    Image(systemName: "chevron.left")

                    Text("Back").buttonStyle(.borderedProminent)
                }
                Spacer()
                
                  Button(action: {
                      self.authHelper.signUp(email: self.email.lowercased(), password: self.password, withCompletion: { isSuccessful in
                          if (isSuccessful){
                              
                              let user : UserProfile = UserProfile(id: self.email.lowercased(), name: self.nameFromUI, contactNumber: self.phoneFromUI, address: self.addressFromUI)
                              
                              self.dbHelper.createUserProfile(newUser: user)
                              
                              //show to home screen
                              self.rootScreen = .Home
                          }else{
                              //show the alert with invalid username/password prompt
                              print(#function, "unable to create user")
                          }
                      })
                  }){
                      Text("Create Account")
                  }.buttonStyle(.borderedProminent)
                      .disabled(self.password != self.confirmPassword || self.email.isEmpty || self.password.isEmpty || self.confirmPassword.isEmpty)
                                
            }
           
        }
    }
    
    func validateCarPlateNumber(_ input: String) -> Bool {
        let pattern = "^[a-zA-Z0-9]{2,8}$"
        let regex = NSPredicate(format: "SELF MATCHES %@", pattern)
        return regex.evaluate(with: input)
    }
}
