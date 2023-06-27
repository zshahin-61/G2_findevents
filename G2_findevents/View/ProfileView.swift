//
//  ProfileView.swift
//  G2_findevents
//
//  Created by Golnaz Chehrazi on 2023-06-23.
//

import SwiftUI
import PhotosUI
//import URLImage

struct ProfileView: View {
    
    @EnvironmentObject var authHelper : FireAuthController
    @EnvironmentObject var dbHelper : FirestoreController
    
    @State private var emailFromUI : String = ""
    @State private var addressFromUI : String = ""
    @State private var contactNumberFromUI : String = ""
    @State private var nameFromUI : String = ""
    
    @State private var errorMsg : String? = nil
    
    @State private var showAlert = false
    
    @Binding var rootScreen : RootView
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    //@State private var imageURL: URL? = nil
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
            
            VStack{
                Button("Select Image") {
                    showImagePicker = true
                }
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(selectedImage: $selectedImage)
            }
            
            //HStack{
            Button(action: {
                //validate the data such as no mandatory inputs, password rules, etc.
                ///////
                ///
                dbHelper.userProfile!.address = addressFromUI
                //////Image
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
                // TODO: Delete Account
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
                dbHelper.getUserProfile(withCompletion: { isSuccessful in
                    if (isSuccessful){
                        self.emailFromUI = dbHelper.userProfile!.id!
                        self.addressFromUI = dbHelper.userProfile!.address
                        self.nameFromUI = dbHelper.userProfile!.name
                        
                        self.contactNumberFromUI = dbHelper.userProfile!.contactNumber
                        self.errorMsg = nil
                        
                        // TODO: Show image from db
                        if let imageData = dbHelper.userProfile!.image as? Data {
                            self.imageData = imageData
                        } else {
                            print("Invalid image data format")
                        }
                    }
                })
            }
    }
}
