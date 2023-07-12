//
//  SignUpView.swift
//  G2_findevents
//
//  Created by Created by Zahra Shahin - Golnaz Chehrazi on 2023-06-25 on 2023-06-23.
//

import SwiftUI
import PhotosUI

struct SignUpView: View {
    @EnvironmentObject var authHelper : FireAuthController
    @EnvironmentObject var dbHelper : FirestoreController
    
    @StateObject private var photoLibraryManager = PhotoLibraryManager()
    
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var confirmPassword : String = ""
    @State private var addressFromUI : String = ""
    @State private var phoneFromUI : String = ""
    @State private var nameFromUI : String = ""
    @State private var errorMsg : String? = nil
    
    @Binding var rootScreen : RootView
    
    @State private var isShowingPicker = false
    @State private var selectedImage: UIImage?
    
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
                
                VStack{
                  Text("User Profile Picture")
                    if photoLibraryManager.isAuthorized {
                                Button(action: {
                                    isShowingPicker = true
                                }) {
                                    Text("Select Image")
                                }
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            } else {
                                Button(action: {
                                    photoLibraryManager.requestPermission()
                                }) {
                                    Text("Request Access For Photo Library")
                                }
                            }
                        }
                .sheet(isPresented: $isShowingPicker) {
                            if photoLibraryManager.isAuthorized {
                                ImagePickerView(selectedImage: $selectedImage)
                            } else {
                                Text("Access to photo library is not authorized.")
                            }
                        }
            }
            .autocorrectionDisabled(true)
            
            Button(action: {
                self.authHelper.signUp(email: self.email.lowercased(), password: self.password, withCompletion: { isSuccessful in
                    
                    if (isSuccessful){
                        // MARK: USER IMAGE
                        var imageData :Data? = nil
                        
                        if(selectedImage != nil )
                        {
                            let image = selectedImage!
                            let imageName = "\(UUID().uuidString).jpg"
                            
                            imageData = image.jpegData(compressionQuality: 0.1)
                        }
                        
                        let user : UserProfile = UserProfile(id: self.email.lowercased(), name: self.nameFromUI, contactNumber: self.phoneFromUI, address: self.addressFromUI, image: imageData,friends: [], numberOfEventsAttending: 0)
                        
                        self.dbHelper.createUserProfile(newUser: user)
                        //Load User Data
                        self.dbHelper.getUserProfile(withCompletion: {isSuccessful in
                            if(isSuccessful){
                                dbHelper.getFriends()
                                dbHelper.getMyEventsList()
                            }
                        })
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
            
                .navigationBarTitle("Sign Up Form", displayMode: .inline)
                .navigationBarItems(
                    trailing: Button(action: {
                        rootScreen = .Login
                    }) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    })
        }
    }
    
    
}
