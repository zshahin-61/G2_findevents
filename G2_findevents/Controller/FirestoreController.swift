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

    @Published var events: [Event] = []
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
    
    func createUserProfile(newUserProfile: UserProfile) {
        print(#function, "Creating user profile")
        do {
            let docRef = db.collection(COLLECTION_USER_PROFILES).document(newUserProfile.id ?? "")
            try docRef.setData(from: newUserProfile) { error in
                if let error = error {
                    print(#function, "Unable to add user profile to DB: \(error)")
                } else {
                    print(#function, "User profile successfully added to DB")
                }
            }
        } catch {
            print(#function, "Unable to add user profile to DB: \(error)")
        }
    }
    
    func updateUserProfile(userUpdate: UserProfile) {
        print(#function, "Updating user profile: \(userUpdate.name)")
        guard let userProfileId = userUpdate.id else {
            print(#function, "Invalid user profile ID")
            return
        }
        
        do {
            let userProfileRef = db.collection(COLLECTION_USER_PROFILES).document(userProfileId)
            try userProfileRef.setData(from: userUpdate, merge: true) { error in
                if let error = error {
                    print(#function, "Unable to update user profile: \(error)")
                } else {
                    print(#function, "User profile updated successfully")
                }
            }
        } catch {
            print(#function, "Unable to update user profile: \(error)")
        }
    }
    
    func deleteUserProfile() {
        print(#function, "Deleting user profile")
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if self.loggedInUserEmail.isEmpty {
            print(#function, "Logged in user's email address not available. Can't delete user profile.")
        } else {
            let userProfileRef = db.collection(COLLECTION_USER_PROFILES).document(self.loggedInUserEmail)
            
            userProfileRef.delete { error in
                if let error = error {
                    print(#function, "Unable to delete user profile: \(error)")
                } else {
                    print(#function, "User profile deleted successfully")
                }
            }
        }
    }
    
    func getUserProfile(withCompletion completion: @escaping (Bool) -> Void) {
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
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
                    
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
}
