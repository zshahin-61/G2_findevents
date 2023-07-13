//
//  ProfileView.swift
//  G2_findevents
//
//  Created by Created by Zahra Shahin - Golnaz Chehrazi on 2023-06-25 on 2023-06-23.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @EnvironmentObject var authHelper : FireAuthController
    @EnvironmentObject var dbHelper : FirestoreController
    
    @StateObject private var photoLibraryManager = PhotoLibraryManager()
    
    @State private var emailFromUI : String = ""
    @State private var addressFromUI : String = ""
    @State private var contactNumberFromUI : String = ""
    @State private var nameFromUI : String = ""
    
    @State private var errorMsg : String? = nil
    
    @State private var showAlert = false
    
    @Binding var rootScreen : RootView
    
    @State private var isShowingPicker = false
    @State private var selectedImage: UIImage?
    @State private var imageData: Data?
    
    var body: some View {
        VStack{
            Form{
                Text("Dear user: \(self.emailFromUI)")
                
                TextField("Name", text: self.$nameFromUI)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Address", text: self.$addressFromUI)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Phone Number", text: self.$contactNumberFromUI)
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
                
                if let data = imageData,
                   let uiImage = UIImage(data: data) {
                    if(selectedImage == nil)
                    {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    else{
                        //
                    }
                } else {
                    Text("No image available")
                }
                
                if let err = errorMsg{
                    Text(err).foregroundColor(Color.red).bold()
                }
            }
            .autocorrectionDisabled(true)
            
            //HStack{
            Button(action: {
                //Validate the data such as no mandatory inputs, password rules, etc.
                //
                dbHelper.userProfile!.address = addressFromUI
                //Image
                var imageData :Data? = nil
                
                if(selectedImage != nil )
                {
                    let image = selectedImage!
                    let imageName = "\(UUID().uuidString).jpg"
                    
                    imageData = image.jpegData(compressionQuality: 0.1)
                    dbHelper.userProfile!.image = imageData
                }
                
                ////////
                
                dbHelper.userProfile!.name = nameFromUI
                dbHelper.userProfile!.contactNumber = contactNumberFromUI
                
                self.dbHelper.updateUserProfile(userToUpdate: dbHelper.userProfile!)
                
                rootScreen = .Home
            }){
                Text("Update Profile")
            }.buttonStyle(.borderedProminent)
            
            Spacer()
            Button(action:{
                if(dbHelper.myEventsList.count > 0)
                {
                    //errorMsg = "before deleting your account you have to remove all cars in parking lots"
                    //self.showAlert = true
                    dbHelper.deleteAllMyEvents()
                    //return
                }
                if(dbHelper.myFriendsList.count > 0 ){
                    //self.showAlert = true
                    //return
                    dbHelper.deleteAllMyFriends()
                }
                self.dbHelper.deleteUser(withCompletion: { isSuccessful in
                    if (isSuccessful){
                        self.authHelper.deleteAccountFromAuth(withCompletion: { isSuccessful2 in
                            if (isSuccessful2){
                                //sign out using Auth
                                self.authHelper.signOut()
                                
                                //self.selectedLink = 1
                                //dismiss current screen and show login screen
                                self.rootScreen = .Login
                            }
                            
                        }
                        )}
                })
                
                
            }){
                Image(systemName: "multiply.circle").foregroundColor(Color.white)
                Text("Delete User Account")
            }.padding(5).font(.title2).foregroundColor(Color.white)//
                .buttonBorderShape(.roundedRectangle(radius: 15)).buttonStyle(.bordered).background(Color.red)
            
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: {
                        rootScreen = .Home
                    }) {
                        Text("Back")
                    })
        }.padding()
            .onAppear(){
                
                if let currentUser = dbHelper.userProfile{
                    self.emailFromUI = currentUser.id!
                    self.addressFromUI = currentUser.address
                    self.nameFromUI = currentUser.name
                    
                    self.contactNumberFromUI = currentUser.contactNumber
                    self.errorMsg = nil
                    
                    // MARK: Show image from db
                    if let imageData = currentUser.image as? Data {
                        self.imageData = imageData
                    } else {
                        print("Invalid image data format")
                    }
                }
            }
    }
}
