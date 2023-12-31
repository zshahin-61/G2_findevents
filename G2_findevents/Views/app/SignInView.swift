//
//  SignInView.swift
//  G2_findevents
//
//  Created by Created by Zahra Shahin - Golnaz Chehrazi on 2023-06-25 on 2023-06-25.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authHelper : FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    
    @State private var emailFromUI : String = "g.chehrazi@gmail.com"
    @State private var passwordFromUI : String = "Admin123"
    
    @Binding var rootScreen : RootView
    
    private let gridItems : [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var showAlert = false
    
    var body: some View {
        
        VStack{
            
            Form{
                TextField("Enter Email", text: self.$emailFromUI)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Enter Password", text: self.$passwordFromUI)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
            }
            .autocorrectionDisabled(true)
            
            LazyVGrid(columns: self.gridItems){
                Button(action: {
                    self.authHelper.signIn(email: self.emailFromUI, password: self.passwordFromUI, withCompletion: { isSuccessful in
                        if (isSuccessful){
                            self.dbHelper.getUserProfile(withCompletion: {isSuccessful in
                                dbHelper.getFriends()
                                dbHelper.getMyEventsList()
                            })
                            self.rootScreen = .Home
                        }else{
                            //show the alert with invalid username/password prompt
                            self.showAlert = true
                            print(#function, "invalid username/password")
                        }
                    })
                    
                }){
                    Text("Sign In")
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                    
                    
                }
                //.background(Color.blue)
                .disabled(self.emailFromUI.isEmpty || self.passwordFromUI.isEmpty || !isEmailValid() )
                .buttonStyle(CustomButtonStyle(isEnabled: !self.emailFromUI.isEmpty && !self.passwordFromUI.isEmpty && isEmailValid()))
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Alert Title"),
                        message: Text("invalid username/password"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                Button(action: {
                    self.rootScreen = .SignUp
                }){
                    Text("Sign Up")
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .background(Color.blue)
                }
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: func for check if the form is valid
    func isEmailValid()-> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: emailFromUI)
    }
    
    struct CustomButtonStyle: ButtonStyle {
        let isEnabled: Bool
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                //.padding()
                .foregroundColor(.white)
                .background(!self.isEnabled ? Color.gray : Color.blue)
                .cornerRadius(8)
                .opacity(!self.isEnabled ? 0.8 : 1.0)
                //.disabled(!self.isEnabled)
        }
    }
    
}


