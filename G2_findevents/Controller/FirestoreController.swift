//
//  FirestoreController.swift
//  G2_findevents
//
//  Created by zahra SHAHIN on 2023-06-25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreController: ObservableObject {

    @Published var eventsList: [Event] = []
    @Published var userProfile: UserProfile?
    
    private let db: Firestore
    private static var shared: FirestoreController?
    
    private let COLLECTION_EVENTS = "Events"
    private let COLLECTION_USER_PROFILES = "UserProfiles"
    
    private let FIELD_NAME = "name"
    private let FIELD_TYPE = "type"
    
    private let FIELD_CONTACT_NUMBER = "contactNumber"
    private let FIELD_ADDRESS = "address"
    
    private var loggedInUserEmail: String = ""
    
    init(db: Firestore) {
        self.db = db
    }
    
    static func getInstance() -> FirestoreController {
        if self.shared == nil {
            self.shared = FirestoreController(db: Firestore.firestore())
        }
        return self.shared!
    }
    
    // MARK: Events
    
//    func createEvent(newEvent: allEvents) {
//        print(#function, "Creating event")
//        do {
//            let docRef = db.collection(COLLECTION_EVENTS).document(newEvent.id!)
//            try docRef.setData(from: newEvent) { error in
//                if let error = error {
//                    print(#function, "Unable to add event to DB: \(error)")
//                } else {
//                    print(#function, "Event successfully added to DB")
//                }
//            }
//        } catch {
//            print(#function, "Unable to add event to DB: \(error)")
//        }
//    }
//    
//    func updateEvent(eventUpdate: all) {
//        print(#function, "Updating event: \(eventUpdate.title)")
//        guard let eventId = eventUpdate.id else {
//            print(#function, "Invalid event ID")
//            return
//        }
//        
//        do {
//            let eventRef = db.collection(COLLECTION_EVENTS).document(eventId)
//            try eventRef.setData(from: eventUpdate, merge: true) { error in
//                if let error = error {
//                    print(#function, "Unable to update event: \(error)")
//                } else {
//                    print(#function, "Event updated successfully")
//                }
//            }
//        } catch {
//            print(#function, "Unable to update event: \(error)")
//        }
//    }
//    
    func deleteEvent(eventId: String) {
        print(#function, "Deleting event with ID: \(eventId)")
        let eventRef = db.collection(COLLECTION_EVENTS).document(eventId)
        
        eventRef.delete { error in
            if let error = error {
                print(#function, "Unable to delete event: \(error)")
            } else {
                print(#function, "Event deleted successfully")
            }
        }
    }
    
    func getEvent(eventId: String, completion: @escaping (Event?) -> Void) {
        let eventRef = db.collection(COLLECTION_EVENTS).document(eventId)
        
        eventRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    if let event = try document.data(as: Event?.self) {
                        DispatchQueue.main.async {
                            completion(event)
                        }
                    }
                } catch {
                    print(#function, "Error decoding event data: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: User Profile
    
    // MARK: User profile functions
    func createUserProfile(newUser: UserProfile){
        print(#function, "Inserting profile Info")
        
        do{
            let docRef = db.collection(COLLECTION_USER_PROFILES).document(newUser.id!)
            try docRef.setData([FIELD_NAME: newUser.name,
                              FIELD_CONTACT_NUMBER : newUser.contactNumber,
                              FIELD_ADDRESS : newUser.address]){ error in
                }
            
            print(#function, "user \(newUser.name) successfully added to database")
        }catch let err as NSError{
            print(#function, "Unable to add user to database : \(err)")
        }//do..catch
        
    }
    
    func getUserProfile(withCompletion completion: @escaping (Bool) -> Void) {
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        print("\(self.loggedInUserEmail)")
        
        let document = db.collection(COLLECTION_USER_PROFILES).document(self.loggedInUserEmail)

            document.addSnapshotListener { (documentSnapshot, error) in
                if let document = documentSnapshot, document.exists {
                    do {
                        if let userProfile = try document.data(as: UserProfile?.self) {
                            self.userProfile = userProfile
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        }
                    } catch {
                        print("Error decoding user profile data: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            //self.isLoginSuccessful = false
                            completion(false)
                        }
                    }
                } else {
                    print("Document does not exist")
                    DispatchQueue.main.async {
                        //self.isLoginSuccessful = false
                        completion(false)
                    }
                }
            }
        }
    
    func updateUserProfile(userToUpdate : UserProfile){
        print(#function, "Updating user profile \(userToUpdate.name), ID : \(userToUpdate.id)")
        
        
        //get the email address of currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't update employees")
        }
        else{
            do{
                try self.db
                    .collection(COLLECTION_USER_PROFILES)
                    .document(userToUpdate.id!)
                    .updateData([FIELD_NAME : userToUpdate.name,
                       FIELD_CONTACT_NUMBER : userToUpdate.contactNumber,
                                      FIELD_ADDRESS : userToUpdate.address ]){ error in
                        
                        if let err = error {
                            print(#function, "Unable to update user profile in database : \(err)")
                        }else{
                            print(#function, "User profile \(userToUpdate.name) successfully updated in database")
                        }
                    }
            }catch let err as NSError{
                print(#function, "Unable to update user profile in database : \(err)")
            }//catch
        }//else
    }
    
    func deleteUser23(withCompletion completion: @escaping (Bool) -> Void) {
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't Delete User ")
            DispatchQueue.main.async {
                completion(false)
            }
        }
        else{
            if(self.eventsList.count > 0){
                print("this user has events in the system. before delete the account, list should be removed. ")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
            let userDocRef = db.collection(COLLECTION_USER_PROFILES).document(loggedInUserEmail)
            userDocRef.delete { error in
                if let error = error {
                    print("Error deleting user data from Firestore: \(error)")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                } else {
                    print("User data deleted from Firestore successfully.")
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func deleteUser(withCompletion completion: @escaping (Bool) -> Void) {
        
        //get the email address of currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't delete USER")
            DispatchQueue.main.async {
                completion(false)
            }
        }
        else{
            do{
                try self.db
                    .collection(COLLECTION_USER_PROFILES)
                    .document(self.loggedInUserEmail)
                    .delete{ error in
                        if let err = error {
                            print(#function, "Unable to delete user from database : \(err)")
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        }else{
                            print(#function, "user \(self.loggedInUserEmail) successfully deleted from database")
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        }
                    }
            }catch let err as NSError{
                print(#function, "Unable to delete user from database : \(err)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    
    // MARK: Users events
    func insertEvent(newEvent : Event){
        print(#function, "Inserting event: \(newEvent.title)")
        
        //get the email address of currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't add Event")
        }
        else{
            do{
                try self.db
                    .collection(COLLECTION_USER_PROFILES)
                    .document(self.loggedInUserEmail)
                    .collection(COLLECTION_EVENTS)
                    .addDocument(from: newEvent)
                
                print(#function, "event \(newEvent.title) successfully added to database")
            }catch let err as NSError{
                print(#function, "Unable to add event to database : \(err)")
            }//do..catch
        }//else
    }
  
//      func updateEvent(eventUpdate: all) {
//          print(#function, "Updating event: \(eventUpdate.title)")
//          guard let eventId = eventUpdate.id else {
//              print(#function, "Invalid event ID")
//              return
//          }
//
//          do {
//              let eventRef = db.collection(COLLECTION_EVENTS).document(eventId)
//              try eventRef.setData(from: eventUpdate, merge: true) { error in
//                  if let error = error {
//                      print(#function, "Unable to update event: \(error)")
//                  } else {
//                      print(#function, "Event updated successfully")
//                  }
//              }
//          } catch {
//              print(#function, "Unable to update event: \(error)")
//          }
//      }
//
        
}
