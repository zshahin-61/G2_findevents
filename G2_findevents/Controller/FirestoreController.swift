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
    
    @Published var myEventsList: [MyEvent] = [MyEvent]()
    @Published var userProfile: UserProfile?
    @Published var myFriendsList: [UserProfile] = [UserProfile]()
    
    private let db: Firestore
    private static var shared: FirestoreController?
    ////////////////
    private let COLLECTION_EVENTS = "Events"
    /////////
    private let FIELD_ID = "id"
    private let FIELD_TITLE = "title"
    private let FIELD_LOCATION = "location"
    private let FIELD_DATE = "date"
    private let FIELD_IMAGE = "image"
    private let FIELD_TYPE = "type"
    
    ////////////
    private let COLLECTION_USER_PROFILES = "UserProfiles"
    ////////////
    private let FIELD_NAME = "name"
    private let FIELD_CONTACT_NUMBER = "contactNumber"
    private let FIELD_ADDRESS = "address"
    private let FIELD_USER_IMAGE = "image"
    private let FIELD_USER_FRIENDS = "friends"
    private let FIELD_USER_NUMBERATTENDING = "numberOfEventsAttending"
    
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
    
    // MARK: User profile functions
    func createUserProfile(newUser: UserProfile){
        print(#function, "Inserting profile Info")
        
        do{
            let docRef = db.collection(COLLECTION_USER_PROFILES).document(newUser.id!)
            try docRef.setData([FIELD_NAME: newUser.name,
                     FIELD_CONTACT_NUMBER : newUser.contactNumber,
                            FIELD_ADDRESS : newUser.address, FIELD_USER_IMAGE: newUser.image, FIELD_USER_FRIENDS : newUser.friends, FIELD_USER_NUMBERATTENDING : newUser.numberOfEventsAttending]){ error in
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
            print(#function, "Logged in user's email address not available. Can't update User Profile")
        }
        else{
            do{
                try self.db
                    .collection(COLLECTION_USER_PROFILES)
                    .document(userToUpdate.id!)
                    .updateData([FIELD_NAME : userToUpdate.name,
                       FIELD_CONTACT_NUMBER : userToUpdate.contactNumber,
                              FIELD_ADDRESS : userToUpdate.address,
                            FIELD_USER_IMAGE: userToUpdate.image,
                          FIELD_USER_FRIENDS: userToUpdate.friends,
                  FIELD_USER_NUMBERATTENDING: userToUpdate.numberOfEventsAttending]){ error in
                        
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
    func getMyEventsList(){
        print(#function, "Trying to get all logged in user event List.")
        self.myEventsList = [MyEvent]()
        
        //get the email address of currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        //get the instance of Auth Helper to access all the user details
        //self.loggedInUserEmail = self.authHelper.user.email
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't show my Events")
        }
        else{
            do{
                self.db
                    .collection(COLLECTION_USER_PROFILES)
                    .document(self.loggedInUserEmail)
                    .collection(COLLECTION_EVENTS)
                    .addSnapshotListener({ (querySnapshot, error) in
                        
                        guard let snapshot = querySnapshot else{
                            print(#function, "Unable to retrieve data from database : \(error)")
                            return
                        }
                        
                        snapshot.documentChanges.forEach{ (docChange) in
                            
                            do{
                                //convert JSON document to swift object
                                var myEvt : MyEvent = try docChange.document.data(as: MyEvent.self)
                                
                                //get the document id so that it can be used for updating and deleting document
                                var documentID = docChange.document.documentID
                                
                                //set the firestore document id to the converted object
                                myEvt.id = documentID
                                
                                print(#function, "Document ID : \(documentID)")
                                
                                //if new document added, perform required operations
                                if docChange.type == .added{
                                    self.myEventsList.append(myEvt)
                                    print(#function, "New document added : \(myEvt.title)")
                                }
                                
                                //get the index of any matching object in the local list for the firestore document that has been deleted or updated
                                let matchedIndex = self.myEventsList.firstIndex(where: { ($0.id?.elementsEqual(documentID))! })
                                
                                //if a document deleted, perform required operations
                                if docChange.type == .removed{
                                    print(#function, " document removed : \(myEvt.title)")
                                    
                                    //remove the object for deleted document from local list
                                    if (matchedIndex != nil){
                                        self.myEventsList.remove(at: matchedIndex!)
                                    }
                                }
                                
                                //if a document updated, perform required operations
                                if docChange.type == .modified{
                                    print(#function, " document updated : \(myEvt.title)")
                                    
                                    //update the existing object in local list for updated document
                                    if (matchedIndex != nil){
                                        self.myEventsList[matchedIndex!] = myEvt
                                    }
                                }
                                
                            }catch let err as NSError{
                                print(#function, "Unable to convert the JSON doc into Swift Object : \(err)")
                            }
                            
                        }//ForEach
                        
                    })//addSnapshotListener
                
            }catch let err as NSError{
                print(#function, "Unable to get all logged in user events from database : \(err)")
            }//do..catch
        }//else
    }
    
    func insertMyEvent(newEvent : MyEvent){
        print(#function, "Inserting event: \(newEvent.title)")
        
        //get the email address of currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't add Event")
        }
        else{
            do{
                let docRef = db.collection(COLLECTION_USER_PROFILES)
                    .document(self.loggedInUserEmail).collection(COLLECTION_EVENTS).document(newEvent.id!)
                try docRef.setData([FIELD_TYPE : newEvent.type, FIELD_TITLE: newEvent.title, FIELD_LOCATION: newEvent.location,
                                 FIELD_IMAGE : newEvent.image, FIELD_DATE: newEvent.date]){ error in
                    if let err = error {
                        print(#function, "Unable to Insert Event in database : \(err)")
                    }else{
                        print(#function, "event \(newEvent.title) successfully added to database")
                    }
                    
                }
            }catch let err as NSError{
                print(#function, "Unable to add event to database : \(err)")
            }//do..catch
        }//else
    }
    
    func deleteMyEvent(eventToDelete: MyEvent){
        print(#function, "Deleting Event \(eventToDelete.title)")
        
        //get the email address of currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't delete event")
        }
        else{
            do{
                try self.db
                    .collection(COLLECTION_USER_PROFILES)
                    .document(self.loggedInUserEmail)
                    .collection(COLLECTION_EVENTS)
                    .document(eventToDelete.id!)
                    .delete{ error in
                        if let err = error {
                            print(#function, "Unable to delete event from database : \(err)")
                        }else{
                            print(#function, "Event \(eventToDelete.title) successfully deleted from database")
                        }
                    }
            }catch let err as NSError{
                print(#function, "Unable to delete event from database : \(err)")
            }
        }
    }
    
    func deleteAllMyEvents(){
        print(#function, "Deleting All My Events")
        getMyEventsList()
        for myEvt in self.myEventsList{
            deleteMyEvent(eventToDelete: myEvt)
        }
    }
    
    //MARK: User Friend
//    func getNearbyEvents(userProfile: UserProfile, completion: @escaping ([MyEvent]?, Error?) -> Void){
//        let today = Date()
//
//        print(#function, "Trying to get near event for this User.")
//        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
//        if (self.loggedInUserEmail.isEmpty){
//            print(#function, "Logged in user's email address not available. Can't show my Events")
//        }
//        else{
//            do{
//                self.db
//                    .collection(COLLECTION_USER_PROFILES)
//                    .document(self.loggedInUserEmail)
//                    .collection(COLLECTION_EVENTS)
//                    .whereField(FIELD_DATE, isGreaterThanOrEqualTo: today)
//                    .order(by: FIELD_DATE)
//
//
//            }
//        }
//    }
//
    func getNearbyEvents(userProfile: UserProfile, completion: @escaping ([MyEvent]?, Error?) -> Void) {
        let today = Date()
        
        print(#function, "Trying to get nearby events for this User.")
        
        guard let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL"), !loggedInUserEmail.isEmpty else {
            print(#function, "Logged-in user's email address not available. Can't show my Events")
            completion(nil, nil) // Pass nil events and nil error indicating the issue
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection(COLLECTION_USER_PROFILES)
            .document(loggedInUserEmail)
            .collection(COLLECTION_EVENTS)
            .whereField(FIELD_DATE, isGreaterThanOrEqualTo: today)
            .order(by: FIELD_DATE)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting nearby events: \(error.localizedDescription)")
                    completion(nil, error) // Pass nil events and the error
                    return
                }
                
                // Process the retrieved events
                var events: [MyEvent] = []
                for document in querySnapshot?.documents ?? [] {
                    let eventData = document.data()
                    
                    // Parse the eventData and create Event objects
                    // Assuming you have an Event struct or class, create Event objects here
                    // Example:
                    if let event = MyEvent(dictionary: eventData){
                        events.append(event)
                    }
                }
                
                completion(events, nil) // Pass the retrieved events and nil error
            }
    }

    
    func searchUserProfiles(withName searchText: String, completion: @escaping ([UserProfile]) -> Void) {
        
        let lowercaseSearchText = searchText.lowercased()
        let searchQuery = lowercaseSearchText + "z"
        
        // Get the email address of the currently logged in user
        guard let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL"), !loggedInUserEmail.isEmpty else {
            print(#function, "Logged in user's email address not available. Can't search.")
            return
        }

        db.collection(COLLECTION_USER_PROFILES)
            .whereField(FIELD_NAME, isGreaterThanOrEqualTo: lowercaseSearchText)
            .whereField(FIELD_NAME, isLessThan: searchQuery)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error searching user profiles: \(error)")
                    completion([])
                } else {
                    var results: [UserProfile] = []
                    for document in querySnapshot!.documents {
                        do {
                            if let userProfile = try document.data(as: UserProfile?.self) {
                                if userProfile.id != loggedInUserEmail{
                                    results.append(userProfile)
                                }
                            }
                        } catch {
                            print("Error decoding user profile data: \(error.localizedDescription)")
                        }
                    }
                    completion(results)
                }
            }
    }

    
    func getUsersAttendingEvent(eventID: String, completion: @escaping ([UserProfile]) -> Void) {
        let query = db.collection(COLLECTION_USER_PROFILES)
            .whereField(FIELD_USER_NUMBERATTENDING, isGreaterThan: 0)
            .whereField("events.\(eventID)", isGreaterThan: 0)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error retrieving users attending event: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No users attending event found")
                completion([])
                return
            }
            
            let profiles = documents.compactMap { document -> UserProfile? in
                let data = document.data()
                return UserProfile(dictionary: data)
            }
            
            completion(profiles)
        }
    }
    
    func deleteAllMyFriends() {
        print(#function, "Deleting All My Friends")
        
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if self.loggedInUserEmail.isEmpty {
            print(#function, "Logged in user's email address not available. Can't delete friends")
        } else {
            let userProfileRef = self.db.collection(COLLECTION_USER_PROFILES).document(self.loggedInUserEmail)
            
            userProfileRef.updateData([
                "friends": FieldValue.delete()
            ]) { error in
                if let err = error {
                    print(#function, "Unable to remove friends from the user profile: \(err)")
                } else {
                    print(#function, "All friends successfully removed from the user profile")
                }
            }
        }
    }


    func deleteMyFriend(friendID: String) {
        print(#function, "Deleting Friend with ID: \(friendID)")
        
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if self.loggedInUserEmail.isEmpty {
            print(#function, "Logged in user's email address not available. Can't delete friend")
        } else {
            let userProfileRef = self.db.collection(COLLECTION_USER_PROFILES).document(self.loggedInUserEmail)
            
            userProfileRef.updateData([
                "friends": FieldValue.arrayRemove([friendID])
            ]) { error in
                if let err = error {
                    print(#function, "Unable to remove friend from the user profile: \(err)")
                } else {
                    print(#function, "Friend with ID \(friendID) successfully removed from the user profile")
                }
            }
        }
    }

    func getFriends(){
        self.myFriendsList = [UserProfile]()
        //get the email address of currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't show Friends")
        }
        else{
            getUserProfile(withCompletion: { isSuccessful in
                if (isSuccessful){
                    let friends = self.userProfile!.friends
                    for fre in friends{
                        
                        let document = self.db.collection(self.COLLECTION_USER_PROFILES).document(fre)
                        
                        document.addSnapshotListener { (documentSnapshot, error) in
                            if let document = documentSnapshot, document.exists {
                                do {
                                    if let userProfile = try document.data(as: UserProfile?.self) {
                                        self.myFriendsList.append(userProfile)
                                        //                                DispatchQueue.main.async {
                                        //                                    completion(true)
                                        //                                }
                                    }
                                } catch {
                                    print("Error decoding user profile data: \(error.localizedDescription)")
                                    //                            DispatchQueue.main.async {
                                    //                                //self.isLoginSuccessful = false
                                    //                                completion(false)
                                    //                            }
                                }
                            } else {
                                print("Document does not exist")
                                //                        DispatchQueue.main.async {
                                //                            //self.isLoginSuccessful = false
                                //                            completion(false)
                                //                        }
                            }
                        }
                        
                    }
                }})}
    }
    
    func addFriend(newFriend: UserProfile) {
        
        print(#function, "Trying to get all Friends List.")
        
        
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
    
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't show my Events")
        }
        else{
            
            
            let friendID = newFriend.id ?? ""
            
            // Update the current user's profile in Firestore
            let userProfilesCollection = db.collection(COLLECTION_USER_PROFILES)
            let currentUserProfileRef = userProfilesCollection.document(loggedInUserEmail)
            
            currentUserProfileRef.updateData([
                "friends": FieldValue.arrayUnion([friendID])
            ]) { error in
                if let error = error {
                    print("Error adding friend: \(error)")
                } else {
                    print("Friend added successfully")
                }
            }
        }
    }//

    func removeFriend(friendDelet: UserProfile){
        print(#function, "Trying to remove a  Friend \(friendDelet.name).")
        
        
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't show my Events")
        }
        else{
            
            let friendID = friendDelet.id ?? ""
            
            // Update the current user's profile in Firestore
            let userProfilesCollection = db.collection(COLLECTION_USER_PROFILES)
            let currentUserProfileRef = userProfilesCollection.document(loggedInUserEmail)
            
            currentUserProfileRef.updateData([
                "friends": FieldValue.arrayRemove([friendID])
            ]) { error in
                if let error = error {
                    print("Error removing friend: \(error)")
                } else {
                    print("Friend removed successfully")
                }
            }
        }
    }
    
}
